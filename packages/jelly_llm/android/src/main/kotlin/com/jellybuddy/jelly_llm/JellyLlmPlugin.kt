package com.jellybuddy.jelly_llm

import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File
import java.util.concurrent.Executors

/**
 * JellyLlm Android plugin — real llama.cpp inference via JNI.
 *
 * Architecture:
 * - Kotlin [JellyLlmPlugin] handles Flutter MethodChannel/EventChannel
 * - [LlamaBridge] provides JNI native methods to llama.cpp C library
 * - Background thread for model loading and generation
 * - Main thread callbacks for Flutter EventChannel
 */
class JellyLlmPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var methodChannel: MethodChannel
    private lateinit var generateChannel: EventChannel
    private lateinit var stateChannel: EventChannel
    private lateinit var downloadChannel: EventChannel

    private var stateSink: EventChannel.EventSink? = null
    private var generateSink: EventChannel.EventSink? = null
    private val mainHandler = Handler(Looper.getMainLooper())
    private val executor = Executors.newSingleThreadExecutor()

    private val llamaBridge = LlamaBridge()
    private var loadedModelId: String? = null
    private var appFilesDir: String? = null

    companion object {
        private val KNOWN_MODELS = listOf(
            mapOf(
                "id" to "gemma-4-e2b-it-gguf",
                "displayName" to "Gemma 4 E2B (GGUF Q4)",
                "sizeBytes" to 2_500_000_000L,
                "format" to "gguf",
            )
        )
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        // Match Flutter's getApplicationDocumentsDirectory() which uses app_flutter/
        val flutterDir = java.io.File(binding.applicationContext.filesDir.parentFile, "app_flutter")
        appFilesDir = if (flutterDir.exists()) flutterDir.absolutePath
                      else binding.applicationContext.filesDir.absolutePath

        methodChannel = MethodChannel(binding.binaryMessenger, "com.jellybuddy/jelly_llm")
        methodChannel.setMethodCallHandler(this)

        generateChannel = EventChannel(binding.binaryMessenger, "com.jellybuddy/jelly_llm/generate")
        generateChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                generateSink = events
                val args = arguments as? Map<*, *>
                val prompt = args?.get("prompt") as? String ?: return
                val maxTokens = (args["maxTokens"] as? Number)?.toInt() ?: 512
                val temperature = (args["temperature"] as? Number)?.toFloat() ?: 0.7f
                val topP = (args["topP"] as? Number)?.toFloat() ?: 0.9f
                startGeneration(prompt, maxTokens, temperature, topP, events!!)
            }

            override fun onCancel(arguments: Any?) {
                llamaBridge.cancel()
                generateSink = null
            }
        })

        stateChannel = EventChannel(binding.binaryMessenger, "com.jellybuddy/jelly_llm/state")
        stateChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                stateSink = events
            }

            override fun onCancel(arguments: Any?) {
                stateSink = null
            }
        })

        downloadChannel = EventChannel(binding.binaryMessenger, "com.jellybuddy/jelly_llm/download_progress")
        downloadChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {}
            override fun onCancel(arguments: Any?) {}
        })
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        executor.shutdown()
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "loadModel" -> {
                val modelId = call.argument<String>("modelId") ?: "gemma-4-e2b-it-gguf"
                emitState("loading")
                executor.execute {
                    val modelPath = findModelFile(modelId)
                    if (modelPath == null) {
                        mainHandler.post {
                            emitState("error")
                            result.error("MODEL_NOT_FOUND",
                                "Model file not found. Download the model first.", null)
                        }
                        return@execute
                    }
                    val success = llamaBridge.loadModel(modelPath, nCtx = 2048, nGpuLayers = 0)
                    mainHandler.post {
                        if (success) {
                            loadedModelId = modelId
                            emitState("ready")
                            result.success(null)
                        } else {
                            emitState("error")
                            result.error("LOAD_ERROR", "Failed to load model", null)
                        }
                    }
                }
            }

            "warmup" -> result.success(null)

            "cancel" -> {
                llamaBridge.cancel()
                result.success(null)
            }

            "unload" -> {
                executor.execute {
                    llamaBridge.unload()
                    loadedModelId = null
                    mainHandler.post {
                        emitState("uninitialized")
                        result.success(null)
                    }
                }
            }

            "getStats" -> {
                val stats = llamaBridge.getStats()
                result.success(
                    mapOf(
                        "loadTimeMs" to stats[0],
                        "ttftMs" to stats[1],
                        "tokensPerSec" to stats[2],
                        "peakMemoryMB" to stats[3],
                        "totalTokens" to stats[4].toInt(),
                        "backend" to "llama-cpp"
                    )
                )
            }

            "getAvailableModels" -> {
                val models = KNOWN_MODELS.map { model ->
                    val id = model["id"] as String
                    model.toMutableMap().apply {
                        this["isDownloaded"] = findModelFile(id) != null
                        this["isLoaded"] = llamaBridge.isLoaded() && loadedModelId == id
                    }
                }
                result.success(models)
            }

            "downloadModel" -> {
                // Downloads handled by Dart ModelDownloadService
                result.success(null)
            }

            "cancelDownload" -> result.success(null)

            "isModelDownloaded" -> {
                val modelId = call.argument<String>("modelId") ?: ""
                result.success(findModelFile(modelId) != null)
            }

            "deleteModel" -> {
                val modelId = call.argument<String>("modelId") ?: ""
                val modelDir = File("${appFilesDir}/models/$modelId")
                if (modelDir.exists()) modelDir.deleteRecursively()
                result.success(null)
            }

            else -> result.notImplemented()
        }
    }

    private fun emitState(state: String) {
        mainHandler.post {
            stateSink?.success(mapOf("state" to state))
        }
    }

    /**
     * Find the GGUF model file on disk.
     * Searches: app_files/models/{modelId}/ for .gguf files.
     */
    private fun findModelFile(modelId: String): String? {
        val baseDir = appFilesDir ?: return null
        val modelDir = File("$baseDir/models/$modelId")
        if (!modelDir.exists()) return null
        return modelDir.listFiles()
            ?.firstOrNull { it.extension == "gguf" }
            ?.absolutePath
    }

    /**
     * Run inference on a background thread, streaming tokens to Flutter.
     */
    private fun startGeneration(
        prompt: String,
        maxTokens: Int,
        temperature: Float,
        topP: Float,
        sink: EventChannel.EventSink
    ) {
        emitState("generating")

        executor.execute {
            if (!llamaBridge.isLoaded()) {
                mainHandler.post {
                    sink.error("NOT_LOADED", "Model not loaded", null)
                    emitState("uninitialized")
                }
                return@execute
            }

            try {
                llamaBridge.generate(
                    prompt = prompt,
                    maxTokens = maxTokens,
                    temperature = temperature,
                    topP = topP,
                    callback = object : LlamaBridge.TokenCallback {
                        override fun onToken(token: String) {
                            mainHandler.post {
                                sink.success(token)
                            }
                        }
                    }
                )

                mainHandler.post {
                    sink.endOfStream()
                    emitState("ready")
                }
            } catch (e: Exception) {
                mainHandler.post {
                    sink.error("GENERATION_ERROR", e.message, null)
                    emitState("ready")
                }
            }
        }
    }
}
