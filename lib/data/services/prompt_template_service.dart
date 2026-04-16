/// Builds prompts for the educational AI tutor.
///
/// Mirrors PhoneClaw's PromptBuilder but specialized for
/// JellyBuddy's learning context.
class PromptTemplateService {
  /// Build a system prompt for the AI tutor.
  static String buildSystemPrompt({
    String? courseName,
    String? lessonName,
    String? questionContent,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('你是一个友好的编程学习助手，名叫 JellyBuddy。');
    buffer.writeln('你的特点是：');
    buffer.writeln('1. 温和鼓励，不批评错误');
    buffer.writeln('2. 解释清晰，使用简单语言');
    buffer.writeln('3. 适当提问引导思考');
    buffer.writeln('4. 提供代码示例');
    buffer.writeln('5. 当用户做对了，给予肯定和表扬');
    buffer.writeln();

    if (courseName != null || lessonName != null || questionContent != null) {
      buffer.writeln('当前用户正在学习：');
      if (courseName != null) buffer.writeln('- 课程: $courseName');
      if (lessonName != null) buffer.writeln('- 章节: $lessonName');
      if (questionContent != null) buffer.writeln('- 题目: $questionContent');
      buffer.writeln();
    }

    buffer.writeln('如果用户答错了，先安慰，然后解释正确答案。');
    buffer.writeln('如果用户做对了，给予表扬并可以适当扩展。');
    buffer.writeln('回答简洁明了，每次回答不超过200字。');

    return buffer.toString();
  }

  /// Build a full prompt with conversation history.
  static String buildConversationPrompt({
    required String systemPrompt,
    required List<({String role, String content})> history,
    required String userMessage,
  }) {
    final buffer = StringBuffer();

    // System block
    buffer.writeln('<|turn>system');
    buffer.writeln(systemPrompt);
    buffer.writeln('<turn|>');

    // Conversation history
    for (final msg in history) {
      final role = msg.role == 'user' ? 'user' : 'model';
      buffer.writeln('<|turn>$role');
      buffer.writeln(msg.content);
      buffer.writeln('<turn|>');
    }

    // Current user message
    buffer.writeln('<|turn>user');
    buffer.writeln(userMessage);
    buffer.writeln('<turn|>');

    // Model turn start
    buffer.write('<|turn>model\n');

    return buffer.toString();
  }
}
