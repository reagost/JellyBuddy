import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../domain/repositories/i_ai_repository.dart';
import 'cloud_ai_provider.dart';

/// Provider for Anthropic Claude API.
///
/// Uses the /v1/messages endpoint with SSE streaming.
class AnthropicProvider extends CloudAiProvider {
  @override
  final CloudAiConfig config;
  final String apiKey;
  final Dio _dio;

  AnthropicProvider({
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
    // Anthropic separates system from messages
    final messages = history.map((m) => {
          'role': m.role == MessageRole.user ? 'user' : 'assistant',
          'content': m.content,
        }).toList();

    final url = '${config.baseUrl.replaceAll(RegExp(r'/+$'), '')}/messages';

    try {
      final response = await _dio.post<ResponseBody>(
        url,
        data: {
          'model': config.modelId,
          'messages': messages,
          if (systemPrompt != null && systemPrompt.isNotEmpty) 'system': systemPrompt,
          'stream': true,
          'temperature': aiConfig.temperature,
          'top_p': aiConfig.topP,
          'max_tokens': aiConfig.maxTokens,
        },
        options: Options(
          headers: {
            'x-api-key': apiKey,
            'anthropic-version': '2023-06-01',
            'Content-Type': 'application/json',
          },
          responseType: ResponseType.stream,
          receiveTimeout: const Duration(minutes: 5),
        ),
      );

      final stream = response.data!.stream;
      final decoder = utf8.decoder;
      final buffer = StringBuffer();

      await for (final chunk in stream) {
        final text = decoder.convert(chunk);
        buffer.write(text);

        while (true) {
          final contents = buffer.toString();
          final newlineIdx = contents.indexOf('\n');
          if (newlineIdx < 0) break;

          final line = contents.substring(0, newlineIdx).trim();
          buffer.clear();
          buffer.write(contents.substring(newlineIdx + 1));

          if (line.isEmpty || !line.startsWith('data:')) continue;

          final data = line.substring(5).trim();
          if (data.isEmpty) continue;

          try {
            final json = jsonDecode(data) as Map<String, dynamic>;
            final type = json['type'] as String?;
            if (type == 'content_block_delta') {
              final delta = json['delta'] as Map?;
              final text = delta?['text'] as String?;
              if (text != null && text.isNotEmpty) {
                yield text;
              }
            } else if (type == 'message_stop') {
              return;
            }
          } catch (_) {
            // Skip malformed chunks
          }
        }
      }
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      throw Exception('Claude 请求失败: $message');
    }
  }

  @override
  Future<bool> testConnection() async {
    try {
      final url = '${config.baseUrl.replaceAll(RegExp(r'/+$'), '')}/messages';
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
          headers: {
            'x-api-key': apiKey,
            'anthropic-version': '2023-06-01',
            'Content-Type': 'application/json',
          },
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
        }
      } catch (_) {}
    }
    return e.message ?? e.type.toString();
  }
}
