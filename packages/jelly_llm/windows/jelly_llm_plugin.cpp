// JellyLlm Windows plugin stub.
// Phase 5 will add llama.cpp inference via FetchContent + CMake.

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <flutter/event_channel.h>
#include <flutter/event_stream_handler_functions.h>

#include <memory>
#include <string>
#include <map>
#include <vector>

namespace jelly_llm {

class JellyLlmPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  JellyLlmPlugin();
  virtual ~JellyLlmPlugin();

  JellyLlmPlugin(const JellyLlmPlugin&) = delete;
  JellyLlmPlugin& operator=(const JellyLlmPlugin&) = delete;

 private:
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

void JellyLlmPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      registrar->messenger(), "com.jellybuddy/jelly_llm",
      &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<JellyLlmPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

JellyLlmPlugin::JellyLlmPlugin() {}
JellyLlmPlugin::~JellyLlmPlugin() {}

void JellyLlmPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name() == "getAvailableModels") {
    flutter::EncodableList models;
    flutter::EncodableMap model;
    model[flutter::EncodableValue("id")] = flutter::EncodableValue("gemma-4-e2b-it-gguf");
    model[flutter::EncodableValue("displayName")] = flutter::EncodableValue("Gemma 4 E2B (GGUF Q4)");
    model[flutter::EncodableValue("sizeBytes")] = flutter::EncodableValue(2500000000);
    model[flutter::EncodableValue("format")] = flutter::EncodableValue("gguf");
    model[flutter::EncodableValue("isDownloaded")] = flutter::EncodableValue(false);
    model[flutter::EncodableValue("isLoaded")] = flutter::EncodableValue(false);
    models.push_back(flutter::EncodableValue(model));
    result->Success(flutter::EncodableValue(models));
  } else if (method_call.method_name() == "getStats") {
    flutter::EncodableMap stats;
    stats[flutter::EncodableValue("loadTimeMs")] = flutter::EncodableValue(0.0);
    stats[flutter::EncodableValue("ttftMs")] = flutter::EncodableValue(0.0);
    stats[flutter::EncodableValue("tokensPerSec")] = flutter::EncodableValue(0.0);
    stats[flutter::EncodableValue("peakMemoryMB")] = flutter::EncodableValue(0.0);
    stats[flutter::EncodableValue("totalTokens")] = flutter::EncodableValue(0);
    stats[flutter::EncodableValue("backend")] = flutter::EncodableValue("llama-cpp-stub");
    result->Success(flutter::EncodableValue(stats));
  } else if (method_call.method_name() == "loadModel" ||
             method_call.method_name() == "warmup" ||
             method_call.method_name() == "cancel" ||
             method_call.method_name() == "unload" ||
             method_call.method_name() == "cancelDownload" ||
             method_call.method_name() == "deleteModel") {
    result->Success();
  } else if (method_call.method_name() == "isModelDownloaded") {
    result->Success(flutter::EncodableValue(false));
  } else if (method_call.method_name() == "downloadModel") {
    result->Error("NOT_IMPLEMENTED", "llama.cpp download not yet implemented (Phase 5)");
  } else {
    result->NotImplemented();
  }
}

}  // namespace jelly_llm

void JellyLlmPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  jelly_llm::JellyLlmPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
