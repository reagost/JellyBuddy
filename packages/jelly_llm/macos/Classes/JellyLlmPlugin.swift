import FlutterMacOS
import Foundation

/// JellyLlm macOS plugin — shares MLX inference engine with iOS.
/// Under SPM, this uses the same MLXLocalLLMService + InferenceKit as iOS.
public class JellyLlmPlugin: NSObject, FlutterPlugin {
    var stateSink: FlutterEventSink? = nil
    private var isModelLoaded = false
    private var loadedModelId: String?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = JellyLlmPlugin()

        let methodChannel = FlutterMethodChannel(
            name: "com.jellybuddy/jelly_llm",
            binaryMessenger: registrar.messenger
        )
        registrar.addMethodCallDelegate(instance, channel: methodChannel)

        let generateChannel = FlutterEventChannel(
            name: "com.jellybuddy/jelly_llm/generate",
            binaryMessenger: registrar.messenger
        )
        generateChannel.setStreamHandler(MacOSGenerateStreamHandler(plugin: instance))

        let stateChannel = FlutterEventChannel(
            name: "com.jellybuddy/jelly_llm/state",
            binaryMessenger: registrar.messenger
        )
        stateChannel.setStreamHandler(MacOSStateStreamHandler(plugin: instance))

        FlutterEventChannel(
            name: "com.jellybuddy/jelly_llm/download_progress",
            binaryMessenger: registrar.messenger
        ).setStreamHandler(MacOSNoOpStreamHandler())
    }

    private func emitState(_ state: String) {
        DispatchQueue.main.async { [weak self] in
            self?.stateSink?(["state": state])
        }
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any]

        switch call.method {
        case "loadModel":
            let modelId = args?["modelId"] as? String ?? "gemma-4-e2b-it-4bit"
            emitState("loading")
            // TODO: Wire MLXLocalLLMService for macOS (same as iOS)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.isModelLoaded = true
                self?.loadedModelId = modelId
                self?.emitState("ready")
                result(nil)
            }

        case "warmup": result(nil)
        case "cancel": result(nil)

        case "unload":
            isModelLoaded = false
            loadedModelId = nil
            emitState("uninitialized")
            result(nil)

        case "getStats":
            result([
                "loadTimeMs": 0.0, "ttftMs": 0.0, "tokensPerSec": 0.0,
                "peakMemoryMB": 0.0, "totalTokens": 0, "backend": "mlx-gpu-stub",
            ] as [String: Any])

        case "getAvailableModels":
            result([[
                "id": "gemma-4-e2b-it-4bit",
                "displayName": "Gemma 4 E2B (4-bit)",
                "sizeBytes": 3_800_000_000,
                "format": "safetensors",
                "isDownloaded": false,
                "isLoaded": isModelLoaded,
            ] as [String: Any]])

        case "downloadModel":
            result(FlutterError(code: "NOT_IMPLEMENTED", message: "macOS download not yet implemented", details: nil))

        case "cancelDownload": result(nil)
        case "isModelDownloaded": result(false)
        case "deleteModel": result(nil)
        default: result(FlutterMethodNotImplemented)
        }
    }

    fileprivate func startGeneration(args: [String: Any]?, sink: @escaping FlutterEventSink) {
        guard let prompt = args?["prompt"] as? String else {
            sink(FlutterError(code: "NO_PROMPT", message: "Prompt required", details: nil))
            return
        }
        guard isModelLoaded else {
            sink(FlutterError(code: "NOT_LOADED", message: "Model not loaded", details: nil))
            return
        }
        emitState("generating")
        Task {
            let response = "[macOS Stub] MLX 推理将共享 iOS 实现。Dart 层自动降级到预存答案。"
            for char in response {
                DispatchQueue.main.async { sink(String(char)) }
                try? await Task.sleep(nanoseconds: 15_000_000)
            }
            DispatchQueue.main.async { [weak self] in
                sink(FlutterEndOfEventStream)
                self?.emitState("ready")
            }
        }
    }
}

private class MacOSGenerateStreamHandler: NSObject, FlutterStreamHandler {
    weak var plugin: JellyLlmPlugin?
    init(plugin: JellyLlmPlugin) { self.plugin = plugin }
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        plugin?.startGeneration(args: arguments as? [String: Any], sink: events)
        return nil
    }
    func onCancel(withArguments arguments: Any?) -> FlutterError? { nil }
}

private class MacOSStateStreamHandler: NSObject, FlutterStreamHandler {
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

private class MacOSNoOpStreamHandler: NSObject, FlutterStreamHandler {
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? { nil }
    func onCancel(withArguments arguments: Any?) -> FlutterError? { nil }
}
