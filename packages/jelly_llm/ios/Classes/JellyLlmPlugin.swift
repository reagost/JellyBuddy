import Flutter
import UIKit

/// Flutter plugin bridging JellyLlm Dart interface to native LLM inference.
///
/// Two compilation modes:
/// - CocoaPods (default): Stub — model metadata works, generation returns placeholder.
/// - SPM (flutter config --enable-swift-package-manager): Full MLX inference
///   via MLXLocalLLMService + InferenceKit + Gemma 4.
public class JellyLlmPlugin: NSObject, FlutterPlugin {
    var stateSink: FlutterEventSink?
    private var generationTask: Task<Void, Never>?

    #if canImport(MLX)
    private var llmService: MLXLocalLLMService?
    #endif

    /// Known model metadata — Gemma 4 E2B for all Apple platforms.
    private static let knownModels: [[String: Any]] = [
        [
            "id": "gemma-4-e2b-it-4bit",
            "displayName": "Gemma 4 E2B (MLX 4-bit)",
            "sizeBytes": 3_800_000_000,
            "format": "safetensors",
        ],
    ]

    // Stub state tracking (used when MLX not available)
    private var stubModelLoaded = false
    private var stubLoadedModelId: String?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = JellyLlmPlugin()

        let methodChannel = FlutterMethodChannel(
            name: "com.jellybuddy/jelly_llm",
            binaryMessenger: registrar.messenger()
        )
        registrar.addMethodCallDelegate(instance, channel: methodChannel)

        let generateChannel = FlutterEventChannel(
            name: "com.jellybuddy/jelly_llm/generate",
            binaryMessenger: registrar.messenger()
        )
        generateChannel.setStreamHandler(GenerateStreamHandler(plugin: instance))

        let stateChannel = FlutterEventChannel(
            name: "com.jellybuddy/jelly_llm/state",
            binaryMessenger: registrar.messenger()
        )
        stateChannel.setStreamHandler(StateStreamHandler(plugin: instance))

        FlutterEventChannel(
            name: "com.jellybuddy/jelly_llm/download_progress",
            binaryMessenger: registrar.messenger()
        ).setStreamHandler(NoOpStreamHandler())
    }

    private func emitState(_ state: String) {
        DispatchQueue.main.async { [weak self] in
            self?.stateSink?(["state": state])
        }
    }

    private var isModelLoaded: Bool {
        #if canImport(MLX)
        return llmService?.isLoaded ?? false
        #else
        return stubModelLoaded
        #endif
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any]

        switch call.method {
        case "loadModel":
            handleLoadModel(args: args, result: result)
        case "warmup":
            handleWarmup(result: result)
        case "cancel":
            handleCancel(result: result)
        case "unload":
            handleUnload(result: result)
        case "getStats":
            handleGetStats(result: result)
        case "getAvailableModels":
            handleGetAvailableModels(result: result)
        case "downloadModel":
            handleDownloadModel(args: args, result: result)
        case "cancelDownload":
            result(nil)
        case "isModelDownloaded":
            handleIsModelDownloaded(args: args, result: result)
        case "deleteModel":
            handleDeleteModel(args: args, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Method Handlers

    private func handleLoadModel(args: [String: Any]?, result: @escaping FlutterResult) {
        let modelId = args?["modelId"] as? String ?? "gemma-4-e2b-it-4bit"
        emitState("loading")

        #if canImport(MLX)
        Task {
            do {
                if llmService == nil {
                    llmService = MLXLocalLLMService(selectedModelID: modelId)
                }
                try await llmService!.load()
                self.emitState("ready")
                DispatchQueue.main.async { result(nil) }
            } catch {
                self.emitState("error")
                DispatchQueue.main.async {
                    result(FlutterError(code: "LOAD_ERROR", message: error.localizedDescription, details: nil))
                }
            }
        }
        #else
        // Stub mode
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.stubModelLoaded = true
            self?.stubLoadedModelId = modelId
            self?.emitState("ready")
            result(nil)
        }
        #endif
    }

    private func handleWarmup(result: @escaping FlutterResult) {
        #if canImport(MLX)
        Task {
            try? await llmService?.warmup()
            DispatchQueue.main.async { result(nil) }
        }
        #else
        result(nil)
        #endif
    }

    private func handleCancel(result: @escaping FlutterResult) {
        generationTask?.cancel()
        #if canImport(MLX)
        llmService?.cancel()
        #endif
        result(nil)
    }

    private func handleUnload(result: @escaping FlutterResult) {
        #if canImport(MLX)
        llmService?.unload()
        llmService = nil
        #else
        stubModelLoaded = false
        stubLoadedModelId = nil
        #endif
        emitState("uninitialized")
        result(nil)
    }

    private func handleGetStats(result: @escaping FlutterResult) {
        #if canImport(MLX)
        let stats = llmService?.stats ?? LLMStats()
        result(stats.toFlutterMap())
        #else
        result([
            "loadTimeMs": 0.0,
            "ttftMs": 0.0,
            "tokensPerSec": 0.0,
            "peakMemoryMB": 0.0,
            "totalTokens": 0,
            "backend": "stub",
        ] as [String: Any])
        #endif
    }

    private func handleGetAvailableModels(result: @escaping FlutterResult) {
        let models = Self.knownModels.map { model -> [String: Any] in
            var m = model
            let id = model["id"] as? String ?? ""
            m["isDownloaded"] = checkModelExists(id)
            #if canImport(MLX)
            m["isLoaded"] = llmService?.isLoaded == true && llmService?.loadedModelID == id
            #else
            m["isLoaded"] = stubModelLoaded && stubLoadedModelId == id
            #endif
            return m
        }
        result(models)
    }

    private func handleDownloadModel(args: [String: Any]?, result: @escaping FlutterResult) {
        let modelId = args?["modelId"] as? String ?? ""
        emitState("downloading")

        #if canImport(MLX)
        guard MLXLocalLLMService.availableModels.contains(where: { $0.id == modelId }) else {
            emitState("error")
            result(FlutterError(code: "MODEL_NOT_FOUND", message: "Unknown model: \(modelId)", details: nil))
            return
        }
        Task {
            do {
                // Create a temporary service to trigger download
                let service = MLXLocalLLMService(selectedModelID: modelId)
                // The download happens as part of the install flow
                // ModelInstaller is used internally by the service
                try await service.load()
                service.unload()
                self.emitState("uninitialized")
                DispatchQueue.main.async { result(nil) }
            } catch {
                self.emitState("error")
                DispatchQueue.main.async {
                    result(FlutterError(code: "DOWNLOAD_ERROR", message: error.localizedDescription, details: nil))
                }
            }
        }
        #else
        emitState("uninitialized")
        result(FlutterError(
            code: "NOT_IMPLEMENTED",
            message: "Model download requires SPM build with MLX. Run: flutter config --enable-swift-package-manager",
            details: nil
        ))
        #endif
    }

    private func handleIsModelDownloaded(args: [String: Any]?, result: @escaping FlutterResult) {
        let modelId = args?["modelId"] as? String ?? ""
        result(checkModelExists(modelId))
    }

    private func handleDeleteModel(args: [String: Any]?, result: @escaping FlutterResult) {
        let modelId = args?["modelId"] as? String ?? ""
        deleteModelFiles(modelId)
        result(nil)
    }

    // MARK: - Generation

    fileprivate func startGeneration(args: [String: Any]?, sink: @escaping FlutterEventSink) {
        guard let prompt = args?["prompt"] as? String else {
            sink(FlutterError(code: "NO_PROMPT", message: "Prompt is required", details: nil))
            return
        }

        guard isModelLoaded else {
            sink(FlutterError(code: "NOT_LOADED", message: "Model not loaded", details: nil))
            return
        }

        emitState("generating")

        #if canImport(MLX)
        generationTask = Task {
            do {
                let stream = llmService!.generateStream(prompt: prompt)
                for try await token in stream {
                    if Task.isCancelled { break }
                    DispatchQueue.main.async { sink(token) }
                }
                DispatchQueue.main.async { [weak self] in
                    sink(FlutterEndOfEventStream)
                    self?.emitState("ready")
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    sink(FlutterError(code: "GENERATION_ERROR", message: error.localizedDescription, details: nil))
                    self?.emitState("ready")
                }
            }
        }
        #else
        // Stub: return placeholder
        generationTask = Task {
            let response = "[Stub] 本地推理需启用 SPM 构建。Dart 层将自动降级到预存答案。"
            for char in response {
                DispatchQueue.main.async { sink(String(char)) }
                try? await Task.sleep(nanoseconds: 15_000_000)
            }
            DispatchQueue.main.async { [weak self] in
                sink(FlutterEndOfEventStream)
                self?.emitState("ready")
            }
        }
        #endif
    }

    fileprivate func cancelGeneration() {
        generationTask?.cancel()
        #if canImport(MLX)
        llmService?.cancel()
        #endif
    }

    // MARK: - File Helpers

    private func checkModelExists(_ modelId: String) -> Bool {
        #if canImport(MLX)
        if let model = MLXLocalLLMService.availableModels.first(where: { $0.id == modelId }) {
            return ModelPaths.isAvailable(for: model)
        }
        #endif
        // Fallback: check Documents/models/
        guard let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return false
        }
        return FileManager.default.fileExists(atPath: docs.appendingPathComponent("models/\(modelId)").path)
    }

    private func deleteModelFiles(_ modelId: String) {
        #if canImport(MLX)
        if let model = MLXLocalLLMService.availableModels.first(where: { $0.id == modelId }) {
            ModelPaths.deleteDownloaded(for: model)
            return
        }
        #endif
        guard let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        try? FileManager.default.removeItem(at: docs.appendingPathComponent("models/\(modelId)"))
    }
}

// MARK: - Stream Handlers

private class GenerateStreamHandler: NSObject, FlutterStreamHandler {
    weak var plugin: JellyLlmPlugin?
    init(plugin: JellyLlmPlugin) { self.plugin = plugin }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        plugin?.startGeneration(args: arguments as? [String: Any], sink: events)
        return nil
    }
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        plugin?.cancelGeneration()
        return nil
    }
}

private class StateStreamHandler: NSObject, FlutterStreamHandler {
    weak var plugin: JellyLlmPlugin?
    init(plugin: JellyLlmPlugin) { self.plugin = plugin }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        plugin?.stateSink = events
        return nil
    }
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        plugin?.stateSink = nil
        return nil
    }
}

private class NoOpStreamHandler: NSObject, FlutterStreamHandler {
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? { nil }
    func onCancel(withArguments arguments: Any?) -> FlutterError? { nil }
}
