import Flutter
import UIKit
import MLX
import MLXLLM
import MLXLMCommon
import MLXVLM

class MLXBridge: NSObject {
    private var llmService: MLXLocalLLMService?
    var stateSink: FlutterEventSink?
    private var generationTask: Task<Void, Never>?

    func register(with controller: FlutterViewController) {
        let methodChannel = FlutterMethodChannel(
            name: "com.jellybuddy/jelly_llm",
            binaryMessenger: controller.binaryMessenger
        )
        methodChannel.setMethodCallHandler(handle)

        let generateChannel = FlutterEventChannel(
            name: "com.jellybuddy/jelly_llm/generate",
            binaryMessenger: controller.binaryMessenger
        )
        generateChannel.setStreamHandler(GenerateHandler(bridge: self))

        let stateChannel = FlutterEventChannel(
            name: "com.jellybuddy/jelly_llm/state",
            binaryMessenger: controller.binaryMessenger
        )
        stateChannel.setStreamHandler(StateHandler(bridge: self))

        FlutterEventChannel(
            name: "com.jellybuddy/jelly_llm/download_progress",
            binaryMessenger: controller.binaryMessenger
        ).setStreamHandler(NoOpHandler())

        print("[MLXBridge] Registered real MLX inference handlers")
    }

    private func emitState(_ state: String) {
        DispatchQueue.main.async { [weak self] in
            self?.stateSink?(["state": state])
        }
    }

    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any]
        switch call.method {
        case "loadModel":
            let modelId = args?["modelId"] as? String ?? "gemma-4-e2b-it-4bit"
            print("[MLXBridge] loadModel: \(modelId)")

            // Check if model files exist
            if let model = MLXLocalLLMService.availableModels.first(where: { $0.id == modelId }) {
                let path = ModelPaths.resolve(for: model)
                let exists = ModelPaths.hasRequiredFiles(model, at: path)
                print("[MLXBridge] Model path: \(path.path)")
                print("[MLXBridge] Files exist: \(exists)")
                if !exists {
                    // List what's actually in the directory
                    let fm = FileManager.default
                    if let files = try? fm.contentsOfDirectory(at: path, includingPropertiesForKeys: [.fileSizeKey]) {
                        for f in files {
                            let size = (try? f.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
                            print("[MLXBridge]   \(f.lastPathComponent): \(size / 1_048_576) MB")
                        }
                    } else {
                        print("[MLXBridge]   Directory does not exist or is empty")
                        // Also check Documents/models/
                        let docsModels = ModelPaths.documentsRoot()
                        print("[MLXBridge]   Documents/models/ path: \(docsModels.path)")
                        let docsExists = fm.fileExists(atPath: docsModels.path)
                        print("[MLXBridge]   Documents/models/ exists: \(docsExists)")
                        if docsExists {
                            if let items = try? fm.contentsOfDirectory(atPath: docsModels.path) {
                                print("[MLXBridge]   Contents: \(items)")
                            }
                        }
                    }
                }
            } else {
                print("[MLXBridge] Unknown model ID: \(modelId)")
            }

            emitState("loading")
            Task {
                do {
                    if llmService == nil {
                        llmService = MLXLocalLLMService(selectedModelID: modelId)
                    }
                    try await llmService!.load()
                    print("[MLXBridge] Model loaded successfully!")
                    self.emitState("ready")
                    DispatchQueue.main.async { result(nil) }
                } catch {
                    print("[MLXBridge] Load error: \(error)")
                    self.emitState("error")
                    DispatchQueue.main.async {
                        result(FlutterError(code: "LOAD_ERROR", message: "\(error)", details: nil))
                    }
                }
            }
        case "warmup":
            Task { try? await llmService?.warmup(); DispatchQueue.main.async { result(nil) } }
        case "cancel":
            generationTask?.cancel(); llmService?.cancel(); result(nil)
        case "unload":
            llmService?.unload(); llmService = nil; emitState("uninitialized"); result(nil)
        case "getStats":
            let s = llmService?.stats ?? LLMStats()
            result(s.toFlutterMap())
        case "getAvailableModels":
            let models = MLXLocalLLMService.availableModels.map { m -> [String: Any] in
                ["id": m.id, "displayName": m.displayName, "sizeBytes": 3800000000,
                 "format": "safetensors", "isDownloaded": ModelPaths.isAvailable(for: m),
                 "isLoaded": llmService?.isLoaded == true && llmService?.loadedModelID == m.id]
            }
            result(models)
        case "downloadModel": result(nil)
        case "cancelDownload": result(nil)
        case "isModelDownloaded":
            let id = args?["modelId"] as? String ?? ""
            if let m = MLXLocalLLMService.availableModels.first(where: { $0.id == id }) {
                result(ModelPaths.isAvailable(for: m))
            } else { result(false) }
        case "deleteModel":
            let id = args?["modelId"] as? String ?? ""
            if let m = MLXLocalLLMService.availableModels.first(where: { $0.id == id }) {
                ModelPaths.deleteDownloaded(for: m)
            }
            result(nil)
        default: result(FlutterMethodNotImplemented)
        }
    }

    fileprivate func startGeneration(args: [String: Any]?, sink: @escaping FlutterEventSink) {
        guard let prompt = args?["prompt"] as? String else {
            sink(FlutterError(code: "NO_PROMPT", message: "Prompt required", details: nil))
            return
        }
        guard let service = llmService, service.isLoaded else {
            sink(FlutterError(code: "NOT_LOADED", message: "Model not loaded", details: nil))
            return
        }
        emitState("generating")
        generationTask = Task {
            do {
                let stream = service.generateStream(prompt: prompt)
                for try await token in stream {
                    if Task.isCancelled { break }
                    DispatchQueue.main.async { sink(token) }
                }
                DispatchQueue.main.async { [weak self] in
                    sink(FlutterEndOfEventStream); self?.emitState("ready")
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    sink(FlutterError(code: "GEN_ERROR", message: error.localizedDescription, details: nil))
                    self?.emitState("ready")
                }
            }
        }
    }
    fileprivate func cancelGeneration() { generationTask?.cancel(); llmService?.cancel() }
}

private class GenerateHandler: NSObject, FlutterStreamHandler {
    weak var bridge: MLXBridge?
    init(bridge: MLXBridge) { self.bridge = bridge }
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        bridge?.startGeneration(args: arguments as? [String: Any], sink: events); return nil
    }
    func onCancel(withArguments arguments: Any?) -> FlutterError? { bridge?.cancelGeneration(); return nil }
}
private class StateHandler: NSObject, FlutterStreamHandler {
    weak var bridge: MLXBridge?
    init(bridge: MLXBridge) { self.bridge = bridge }
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        bridge?.stateSink = events; return nil
    }
    func onCancel(withArguments arguments: Any?) -> FlutterError? { bridge?.stateSink = nil; return nil }
}
private class NoOpHandler: NSObject, FlutterStreamHandler {
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? { nil }
    func onCancel(withArguments arguments: Any?) -> FlutterError? { nil }
}
