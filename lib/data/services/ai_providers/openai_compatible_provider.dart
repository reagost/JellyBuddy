import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../domain/repositories/i_ai_repository.dart';
import 'cloud_ai_provider.dart';

/// Provider for OpenAI-compatible APIs (OpenAI, MiniMax, OpenRouter, DeepSeek, etc.)
///
/// Uses the /chat/completions endpoint with SSE streaming.
class OpenAiCompatibleProvider extends CloudAiProvider {
  @override
  final CloudAiConfig config;
  final String apiKey;
  final Dio _dio;

  OpenAiCompatibleProvider({
    required this.config,
    required this.apiKey,
    Dio? dio,
  }) : _dio = dio ?? Dio();

  @override
  Stream<String> streamResponse({
    required List<AIMessage> history,
    required AIConfig aiConfig,
    String? systemPrompt,
  }) async* {
    final messages = <Map<String, String>>[];
    if (systemPrompt != null && systemPrompt.isNotEmpty) {
      messages.add({'role': 'system', 'content': systemPrompt});
    }
    for (final msg in history) {
      messages.add({
        'role': msg.role == MessageRole.user ? 'user' : 'assistant',
        'content': msg.content,
      });
    }

    final url = '${config.baseUrl.replaceAll(RegExp(r'/+$'), '')}/chat/completions';

    final headers = <String, String>{
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };

    // OpenRouter requires these optional headers
    if (config.type == CloudAiProviderType.openRouter) {
      headers['HTTP-Referer'] = 'https://github.com/reagost/JellyBuddy';
      headers['X-Title'] = 'JellyBuddy';
    }

    try {
      final response = await _dio.post<ResponseBody>(
        url,
        data: {
          'model': config.modelId,
          'messages': messages,
          'stream': true,
          'temperature': aiConfig.temperature,
          'top_p': aiConfig.topP,
          'max_tokens': aiConfig.maxTokens,
        },
        options: Options(
          headers: headers,
          responseType: ResponseType.stream,
          receiveTimeout: const Duration(minutes: 5),
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final stream = response.data!.stream;
      final decoder = utf8.decoder;
      final buffer = StringBuffer();

      await for (final chunk in stream) {
        final text = decoder.convert(chunk);
        buffer.write(text);

        // Parse SSE format: each line starts with "data: "
        while (true) {
          final contents = buffer.toString();
          final newlineIdx = contents.indexOf('\n');
          if (newlineIdx < 0) break;

          final line = contents.substring(0, newlineIdx).trim();
          buffer.clear();
          buffer.write(contents.substring(newlineIdx + 1));

          if (line.isEmpty) continue;
          if (!line.startsWith('data:')) continue;

          final data = line.substring(5).trim();
          if (data == '[DONE]') return;

          try {
            final json = jsonDecode(data) as Map<String, dynamic>;
            final choices = json['choices'] as List?;
            if (choices == null || choices.isEmpty) continue;
            final delta = (choices[0] as Map)['delta'] as Map?;
            final content = delta?['content'] as String?;
            if (content != null && content.isNotEmpty) {
              yield content;
            }
          } catch (_) {
            // Skip malformed chunks
          }
        }
      }
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      throw Exception('AI 请求失败: $message');
    }
  }

  @override
  Future<bool> testConnection() async {
    try {
      final url = '${config.baseUrl.replaceAll(RegExp(r'/+$'), '')}/chat/completions';
      final headers = <String, String>{
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      };

      if (config.type == CloudAiProviderType.openRouter) {
        headers['HTTP-Referer'] = 'https://github.com/reagost/JellyBuddy';
        headers['X-Title'] = 'JellyBuddy';
      }

      final response = await _dio.post(
        url,
        data: {
          'model': config.modelId,
          'messages': [
            {'role': 'user', 'content': 'hi'}
          ],
          'max_tokens': 5,
        },
        options: Options(
          headers: headers,
          receiveTimeout: const Duration(seconds: 30),
          validateStatus: (_) => true,
        ),
      );

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  String _extractErrorMessage(DioException e) {
    if (e.response?.data != null) {
      try {
        final data = e.response!.data;
        if (data is Map) {
          final error = data['error'];
          if (error is Map && error['message'] != null) {
            return error['message'].toString();
          }
          if (error is String) return error;
        }
        if (data is String) return data;
      } catch (_) {}
    }
    return e.message ?? e.type.toString();
  }
}
