/**
 * JNI bridge between Kotlin (JellyLlmPlugin) and llama.cpp C API.
 *
 * Provides: model loading, text generation with token-by-token callback,
 * cancellation, unloading, and stats reporting.
 *
 * Thread safety: all llama.cpp calls happen on a single background thread
 * managed by the Kotlin layer. The JNI callback to Kotlin happens via
 * the provided callback interface.
 */

#include <jni.h>
#include <string>
#include <vector>
#include <atomic>
#include <chrono>
#include <android/log.h>

#include "llama.h"
#include "ggml.h"

#define TAG "JellyLLM"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, TAG, __VA_ARGS__)

// Global state
static llama_model *g_model = nullptr;
static llama_context *g_ctx = nullptr;
static const llama_vocab *g_vocab = nullptr;
static std::atomic<bool> g_cancelled{false};

// Stats
static double g_load_time_ms = 0;
static double g_ttft_ms = 0;
static double g_tokens_per_sec = 0;
static int g_total_tokens = 0;

extern "C" {

// ============================================================
// Model Loading
// ============================================================

JNIEXPORT jboolean JNICALL
Java_com_jellybuddy_jelly_1llm_LlamaBridge_loadModel(
        JNIEnv *env, jobject /* this */,
        jstring modelPath, jint nCtx, jint nGpuLayers) {

    const char *path = env->GetStringUTFChars(modelPath, nullptr);
    LOGI("Loading model: %s (ctx=%d, gpu_layers=%d)", path, nCtx, nGpuLayers);

    auto start = std::chrono::high_resolution_clock::now();

    // Initialize llama backend
    llama_backend_init();

    // Load model
    llama_model_params model_params = llama_model_default_params();
    model_params.n_gpu_layers = nGpuLayers;

    g_model = llama_model_load_from_file(path, model_params);
    env->ReleaseStringUTFChars(modelPath, path);

    if (!g_model) {
        LOGE("Failed to load model");
        return JNI_FALSE;
    }

    g_vocab = llama_model_get_vocab(g_model);

    // Create context
    llama_context_params ctx_params = llama_context_default_params();
    ctx_params.n_ctx = nCtx;
    ctx_params.n_batch = 512;
    ctx_params.n_threads = 4;

    g_ctx = llama_init_from_model(g_model, ctx_params);
    if (!g_ctx) {
        LOGE("Failed to create context");
        llama_model_free(g_model);
        g_model = nullptr;
        return JNI_FALSE;
    }

    auto end = std::chrono::high_resolution_clock::now();
    g_load_time_ms = std::chrono::duration<double, std::milli>(end - start).count();
    g_cancelled.store(false);

    LOGI("Model loaded in %.0fms", g_load_time_ms);
    return JNI_TRUE;
}

// ============================================================
// Text Generation
// ============================================================

JNIEXPORT jstring JNICALL
Java_com_jellybuddy_jelly_1llm_LlamaBridge_generate(
        JNIEnv *env, jobject /* this */,
        jstring prompt, jint maxTokens, jfloat temperature, jfloat topP,
        jobject callback) {

    if (!g_model || !g_ctx) {
        return env->NewStringUTF("[Error: Model not loaded]");
    }

    g_cancelled.store(false);

    const char *prompt_str = env->GetStringUTFChars(prompt, nullptr);
    std::string prompt_cpp(prompt_str);
    env->ReleaseStringUTFChars(prompt, prompt_str);

    // Tokenize
    int n_prompt_tokens = -llama_tokenize(g_vocab, prompt_cpp.c_str(), prompt_cpp.size(), nullptr, 0, true, true);
    std::vector<llama_token> tokens(n_prompt_tokens);
    llama_tokenize(g_vocab, prompt_cpp.c_str(), prompt_cpp.size(), tokens.data(), tokens.size(), true, true);

    LOGI("Tokenized: %d tokens", n_prompt_tokens);

    // Clear KV cache
    llama_kv_self_clear(g_ctx);

    // Process prompt using llama_batch_get_one (simpler API)
    llama_batch batch = llama_batch_get_one(tokens.data(), tokens.size());
    if (llama_decode(g_ctx, batch) != 0) {
        LOGE("Decode failed for prompt");
        return env->NewStringUTF("[Error: Decode failed]");
    }

    // Get callback method
    jclass callbackClass = env->GetObjectClass(callback);
    jmethodID onTokenMethod = env->GetMethodID(callbackClass, "onToken", "(Ljava/lang/String;)V");

    // Sample tokens
    auto sampler = llama_sampler_chain_init(llama_sampler_chain_default_params());
    llama_sampler_chain_add(sampler, llama_sampler_init_temp(temperature));
    llama_sampler_chain_add(sampler, llama_sampler_init_top_p(topP, 1));
    llama_sampler_chain_add(sampler, llama_sampler_init_dist(42));

    std::string result;
    auto gen_start = std::chrono::high_resolution_clock::now();
    bool first_token = true;
    int n_generated = 0;
    int n_cur = tokens.size();

    for (int i = 0; i < maxTokens; i++) {
        if (g_cancelled.load()) {
            LOGI("Generation cancelled at token %d", i);
            break;
        }

        llama_token new_token = llama_sampler_sample(sampler, g_ctx, -1);

        // Check for end of generation
        if (llama_vocab_is_eog(g_vocab, new_token)) {
            break;
        }

        // Decode token to text
        char buf[256];
        int n = llama_token_to_piece(g_vocab, new_token, buf, sizeof(buf), 0, true);
        if (n > 0) {
            std::string piece(buf, n);
            result += piece;
            n_generated++;

            if (first_token) {
                auto now = std::chrono::high_resolution_clock::now();
                g_ttft_ms = std::chrono::duration<double, std::milli>(now - gen_start).count();
                first_token = false;
            }

            // Callback to Kotlin with the token
            if (callback && onTokenMethod) {
                jstring jToken = env->NewStringUTF(piece.c_str());
                env->CallVoidMethod(callback, onTokenMethod, jToken);
                env->DeleteLocalRef(jToken);
            }
        }

        // Decode next token
        llama_batch next_batch = llama_batch_get_one(&new_token, 1);
        n_cur++;

        if (llama_decode(g_ctx, next_batch) != 0) {
            LOGE("Decode failed at token %d", i);
            break;
        }
    }

    llama_sampler_free(sampler);

    auto gen_end = std::chrono::high_resolution_clock::now();
    double gen_time_ms = std::chrono::duration<double, std::milli>(gen_end - gen_start).count();
    g_tokens_per_sec = n_generated > 0 ? (n_generated * 1000.0 / gen_time_ms) : 0;
    g_total_tokens = n_generated;

    LOGI("Generated %d tokens in %.0fms (%.1f tok/s, TTFT=%.0fms)",
         n_generated, gen_time_ms, g_tokens_per_sec, g_ttft_ms);

    return env->NewStringUTF(result.c_str());
}

// ============================================================
// Control
// ============================================================

JNIEXPORT void JNICALL
Java_com_jellybuddy_jelly_1llm_LlamaBridge_cancel(
        JNIEnv * /* env */, jobject /* this */) {
    g_cancelled.store(true);
}

JNIEXPORT void JNICALL
Java_com_jellybuddy_jelly_1llm_LlamaBridge_unload(
        JNIEnv * /* env */, jobject /* this */) {
    if (g_ctx) {
        llama_free(g_ctx);
        g_ctx = nullptr;
    }
    if (g_model) {
        llama_model_free(g_model);
        g_model = nullptr;
    }
    g_vocab = nullptr;
    llama_backend_free();
    LOGI("Model unloaded");
}

JNIEXPORT jboolean JNICALL
Java_com_jellybuddy_jelly_1llm_LlamaBridge_isLoaded(
        JNIEnv * /* env */, jobject /* this */) {
    return (g_model != nullptr && g_ctx != nullptr) ? JNI_TRUE : JNI_FALSE;
}

// ============================================================
// Stats
// ============================================================

JNIEXPORT jdoubleArray JNICALL
Java_com_jellybuddy_jelly_1llm_LlamaBridge_getStats(
        JNIEnv *env, jobject /* this */) {
    // Returns [loadTimeMs, ttftMs, tokensPerSec, peakMemoryMB, totalTokens]
    jdoubleArray stats = env->NewDoubleArray(5);
    double values[5] = {
        g_load_time_ms,
        g_ttft_ms,
        g_tokens_per_sec,
        0.0,  // peakMemoryMB — not tracked on Android yet
        (double)g_total_tokens,
    };
    env->SetDoubleArrayRegion(stats, 0, 5, values);
    return stats;
}

} // extern "C"
