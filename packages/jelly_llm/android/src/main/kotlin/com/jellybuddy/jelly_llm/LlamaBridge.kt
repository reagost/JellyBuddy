package com.jellybuddy.jelly_llm

/**
 * JNI bridge to llama.cpp native library.
 *
 * All native methods run on a background thread managed by the caller.
 * Token generation uses a callback interface for streaming.
 */
class LlamaBridge {

    companion object {
        init {
            System.loadLibrary("jelly_llm_jni")
        }
    }

    /**
     * Callback interface for token-by-token generation.
     * Called from the C++ JNI layer on each generated token.
     */
    interface TokenCallback {
        fun onToken(token: String)
    }

    /**
     * Load a GGUF model file into memory.
     * @param modelPath Absolute path to the .gguf file
     * @param nCtx Context window size (default 2048)
     * @param nGpuLayers Number of layers to offload to GPU (0 = CPU only)
     * @return true if loaded successfully
     */
    external fun loadModel(modelPath: String, nCtx: Int = 2048, nGpuLayers: Int = 0): Boolean

    /**
     * Generate text for the given prompt.
     * Calls [callback.onToken] for each generated token (streaming).
     * @return The complete generated text
     */
    external fun generate(
        prompt: String,
        maxTokens: Int = 512,
        temperature: Float = 0.7f,
        topP: Float = 0.9f,
        callback: TokenCallback
    ): String

    /** Cancel ongoing generation. */
    external fun cancel()

    /** Unload model and free memory. */
    external fun unload()

    /** Check if a model is currently loaded. */
    external fun isLoaded(): Boolean

    /**
     * Get inference stats.
     * @return [loadTimeMs, ttftMs, tokensPerSec, peakMemoryMB, totalTokens]
     */
    external fun getStats(): DoubleArray
}
