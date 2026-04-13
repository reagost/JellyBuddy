import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jelly_buddy/l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/game_constants.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/question.dart';
import '../../domain/entities/user.dart';
import '../../data/services/achievement_service.dart';
import '../../data/services/daily_task_service.dart';
import '../../data/services/leaderboard_service.dart';
import '../../data/services/notification_service.dart';
import '../../domain/repositories/i_learning_repository.dart';
import '../blocs/game/game_bloc.dart';
import '../blocs/game/game_event.dart';
import '../blocs/ai_tutor/ai_tutor_bloc.dart';
import '../blocs/ai_tutor/ai_tutor_event.dart';
import '../widgets/game/hearts_display.dart';
import '../widgets/lesson/question_card.dart';
import '../widgets/lesson/option_tile.dart';
import '../widgets/lesson/lesson_progress_bar.dart';
import '../widgets/common_widgets.dart';

class LessonScreen extends StatefulWidget {
  final String courseId;
  final String lessonId;

  const LessonScreen({
    super.key,
    required this.courseId,
    required this.lessonId,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen>
    with TickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  int _hearts = GameConstants.maxHearts;
  int _currentXp = 0;
  String? _selectedAnswer;
  bool _showResult = false;
  bool _isCorrect = false;
  int _correctCount = 0;
  final List<String> _wrongQuestionIds = [];

  List<Question> _questions = [];
  Lesson? _lesson;
  bool _isLoading = true;
  String? _fillBlankAnswer;
  final _fillBlankController = TextEditingController();
  String? _codeAnswer;
  final _codeAnswerController = TextEditingController();
  List<Option> _sortOrder = [];

  // Animation state
  bool _animateResult = false;
  bool _animateHeartPulse = false;
  bool _showXpPopup = false;

  // Lesson timing
  late DateTime _lessonStartTime;

  @override
  void initState() {
    super.initState();
    _lessonStartTime = DateTime.now();
    _loadLesson();
  }

  @override
  void dispose() {
    _fillBlankController.dispose();
    _codeAnswerController.dispose();
    super.dispose();
  }

  Future<void> _loadLesson() async {
    try {
      final repo = GetIt.instance<ILearningRepository>();
      final course = await repo.getCourse(widget.courseId);
      final lesson = course.lessons.firstWhere((l) => l.id == widget.lessonId);

      // Flatten all questions from all levels in this lesson
      final questions = <Question>[];
      for (final level in lesson.levels) {
        questions.addAll(level.questions);
      }

      setState(() {
        _lesson = lesson;
        _questions = questions;
        _isLoading = false;
        _initSortOrderIfNeeded();
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load lesson: $e')),
        );
      }
    }
  }

  bool get _isBoss => _lesson?.isBoss ?? false;

  void _initSortOrderIfNeeded() {
    if (_questions.isNotEmpty) {
      final question = _questions[_currentQuestionIndex];
      if (question.type == LevelType.sort && question.options != null) {
        _sortOrder = List<Option>.from(question.options!)..shuffle();
      } else {
        _sortOrder = [];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_questions.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No questions found'),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final question = _questions[_currentQuestionIndex];
    final progress = _currentQuestionIndex + 1;
    final total = _questions.length;

    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            if (_isBoss) _buildBossBanner(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: LessonProgressBar(current: progress, total: total),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    QuestionCard(question: question),
                    const SizedBox(height: 24),
                    if (question.type == LevelType.choice && question.options != null)
                      ...question.options!.map((option) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildAnimatedOptionTile(option),
                        );
                      }),
                    if (question.type == LevelType.fillBlank)
                      _buildFillBlankInput(),
                    if (question.type == LevelType.sort)
                      _buildSortInput(),
                    if (question.type == LevelType.code)
                      _buildCodeEditor(),
                    if (!_showResult) ...[
                      const SizedBox(height: 16),
                      _buildAIHelpButton(),
                    ],
                    if (_showResult) ...[
                      const SizedBox(height: 16),
                      _buildXpPopupAndResultFeedback(),
                      const SizedBox(height: 16),
                      _buildExplanation(),
                    ],
                  ],
                ),
              ),
            ),
            _buildBottomAction(),
          ],
        ),
      ),
    );
  }

  Widget _buildFillBlankInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardOf(context),
        borderRadius: AppDecorations.cardRadius,
        border: Border.all(
          color: _showResult
              ? (_isCorrect ? AppColors.success : AppColors.error)
              : (_fillBlankAnswer != null ? AppColors.primary : AppColors.surfaceVariant),
          width: 2,
        ),
      ),
      child: TextField(
        controller: _fillBlankController,
        enabled: !_showResult,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.lessonInputHint,
          hintStyle: const TextStyle(color: AppColors.textHint),
          border: InputBorder.none,
        ),
        style: const TextStyle(
          fontFamily: 'JetBrains Mono',
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
        onChanged: (value) {
          setState(() {
            _fillBlankAnswer = value.trim().isEmpty ? null : value.trim();
          });
        },
      ),
    );
  }

  Widget _buildCodeEditor() {
    final question = _questions[_currentQuestionIndex];
    final snippet = question.codeSnippet ?? [];
    final showCorrectAnswer = _showResult && !_isCorrect;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Read-only code snippet context above the editor
        if (snippet.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < snippet.length; i++)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 32,
                        child: Text(
                          '${i + 1}',
                          style: const TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 14,
                            color: Color(0xFF6C7086),
                            height: 1.5,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          snippet[i],
                          style: const TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 14,
                            color: Color(0xFFCDD6F4),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        if (snippet.isNotEmpty) const SizedBox(height: 12),
        // Editable code editor area
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _showResult
                  ? (_isCorrect ? AppColors.success : AppColors.error)
                  : (_codeAnswer != null
                      ? AppColors.primary
                      : const Color(0xFF313244)),
              width: 2,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Line numbers column
              Container(
                padding: const EdgeInsets.only(
                    top: 16, bottom: 16, left: 12, right: 4),
                child: Column(
                  children: List.generate(
                    (_codeAnswerController.text.split('\n').length)
                        .clamp(5, 12),
                    (i) => Text(
                      '${snippet.length + i + 1}',
                      style: const TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 14,
                        color: Color(0xFF6C7086),
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              // Text editor
              Expanded(
                child: TextField(
                  controller: _codeAnswerController,
                  enabled: !_showResult,
                  maxLines: 12,
                  minLines: 5,
                  decoration: const InputDecoration(
                    hintText: '// 在这里写代码...',
                    hintStyle: TextStyle(
                      color: Color(0xFF6C7086),
                      fontFamily: 'JetBrains Mono',
                    ),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  ),
                  style: const TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 14,
                    color: Color(0xFFCDD6F4),
                    height: 1.5,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _codeAnswer =
                          value.trim().isEmpty ? null : value.trim();
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        // Show correct answer after wrong answer
        if (showCorrectAnswer) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.success, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '正确答案：',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  question.acceptedAnswers.first,
                  style: const TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 14,
                    color: Color(0xFFA6E3A1),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBossBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFF9B59B6)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '\u{1F48E} ${AppLocalizations.of(context)!.lessonBossChallenge}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortInput() {
    final showCorrectOrder = _showResult && !_isCorrect;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!_showResult)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '\u{1F447} ${AppLocalizations.of(context)!.lessonDragToSort}',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardOf(context),
            borderRadius: AppDecorations.cardRadius,
            border: Border.all(
              color: _showResult
                  ? (_isCorrect ? AppColors.success : AppColors.error)
                  : AppColors.surfaceVariant,
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: AppDecorations.cardRadius,
            child: ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: !_showResult,
              onReorder: _showResult ? (_, __) {} : _onSortReorder,
              proxyDecorator: (child, index, animation) {
                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    return Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(12),
                      child: child,
                    );
                  },
                  child: child,
                );
              },
              children: [
                for (int i = 0; i < _sortOrder.length; i++)
                  _buildSortTile(_sortOrder[i], i),
              ],
            ),
          ),
        ),
        if (showCorrectOrder) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: AppDecorations.cardRadius,
              border: Border.all(color: AppColors.success, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.lessonCorrectOrder,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _questions[_currentQuestionIndex].acceptedAnswers.first,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSortTile(Option option, int index) {
    return Container(
      key: ValueKey(option.letter),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.surfaceVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              option.letter,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              option.content,
              style: const TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (!_showResult)
            const Icon(Icons.drag_handle, color: AppColors.textHint, size: 20),
        ],
      ),
    );
  }

  void _onSortReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _sortOrder.removeAt(oldIndex);
      _sortOrder.insert(newIndex, item);
      _selectedAnswer = _sortOrder.map((o) => o.letter).join();
    });
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardOf(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _showExitDialog,
            color: AppColors.textSecondary,
          ),
          const Spacer(),
          _buildAnimatedHearts(),
          const Spacer(),
          Text(
            _lesson?.title ?? '',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// Wraps each option tile with the appropriate animation based on answer state.
  Widget _buildAnimatedOptionTile(Option option) {
    final tile = OptionTile(
      optionLetter: option.letter,
      content: option.content,
      state: _getOptionState(option),
      onTap: _showResult ? null : () => _selectAnswer(option),
    );

    if (!_animateResult) return tile;

    // Correct option: scale pulse with green glow
    if (_showResult && option.isCorrect && _isCorrect) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: AppDecorations.cardRadius,
          boxShadow: [
            BoxShadow(
              color: AppColors.success.withValues(alpha: 0.4),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: tile,
      )
          .animate(onPlay: (c) => c.forward())
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.05, 1.05),
            duration: 150.ms,
          )
          .then()
          .scale(
            begin: const Offset(1.05, 1.05),
            end: const Offset(1.0, 1.0),
            duration: 150.ms,
          );
    }

    // Wrong selected option: shake horizontally
    if (_showResult &&
        !_isCorrect &&
        _selectedAnswer == option.letter &&
        !option.isCorrect) {
      return tile
          .animate(onPlay: (c) => c.forward())
          .moveX(begin: 0, end: -8, duration: 75.ms)
          .then()
          .moveX(begin: -8, end: 8, duration: 75.ms)
          .then()
          .moveX(begin: 8, end: -8, duration: 75.ms)
          .then()
          .moveX(begin: -8, end: 0, duration: 75.ms);
    }

    return tile;
  }

  /// Builds the XP popup (for correct) stacked above the result feedback card.
  Widget _buildXpPopupAndResultFeedback() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _buildResultFeedback(),
        if (_showXpPopup && _isCorrect)
          Positioned(
            top: -40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '+${_isBoss ? GameConstants.xpPerCorrect * 2 : GameConstants.xpPerCorrect} XP',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.xpGold,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              )
                  .animate(onPlay: (c) => c.forward())
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1.2, 1.2),
                    duration: 300.ms,
                    curve: Curves.easeOut,
                  )
                  .then()
                  .scale(
                    begin: const Offset(1.2, 1.2),
                    end: const Offset(1.0, 1.0),
                    duration: 300.ms,
                    curve: Curves.easeIn,
                  )
                  .then(delay: 200.ms)
                  .fadeOut(duration: 300.ms),
            ),
          ),
      ],
    );
  }

  /// Hearts display with pulse animation on wrong answer.
  Widget _buildAnimatedHearts() {
    final heartsWidget = HeartsDisplay(current: _hearts, max: 5);
    if (!_animateHeartPulse) return heartsWidget;
    return heartsWidget
        .animate(onPlay: (c) => c.forward())
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.3, 1.3),
          duration: 200.ms,
          curve: Curves.easeOut,
        )
        .then()
        .scale(
          begin: const Offset(1.3, 1.3),
          end: const Offset(1.0, 1.0),
          duration: 200.ms,
          curve: Curves.easeIn,
        );
  }

  Widget _buildResultFeedback() {
    Widget feedback = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isCorrect
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.error.withValues(alpha: 0.1),
        borderRadius: AppDecorations.cardRadius,
        border: Border.all(
          color: _isCorrect ? AppColors.success : AppColors.error,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isCorrect ? Icons.check_circle : Icons.cancel,
            color: _isCorrect ? AppColors.success : AppColors.error,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isCorrect ? AppLocalizations.of(context)!.lessonCorrect : AppLocalizations.of(context)!.lessonIncorrect,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _isCorrect ? AppColors.success : AppColors.error,
                  ),
                ),
                if (_isCorrect)
                  Text(
                    '+${_isBoss ? GameConstants.xpPerCorrect * 2 : GameConstants.xpPerCorrect} XP',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.xpGold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (!_isCorrect &&
                    (_questions[_currentQuestionIndex].type == LevelType.fillBlank ||
                     _questions[_currentQuestionIndex].type == LevelType.code))
                  Text(
                    AppLocalizations.of(context)!.lessonCorrectAnswer(_questions[_currentQuestionIndex].acceptedAnswers.first),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );

    if (_animateResult) {
      feedback = feedback
          .animate(onPlay: (c) => c.forward())
          .fadeIn(duration: 300.ms)
          .slideY(begin: 0.3, end: 0, duration: 300.ms);
    }

    return feedback;
  }

  Widget _buildExplanation() {
    final question = _questions[_currentQuestionIndex];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.1),
        borderRadius: AppDecorations.cardRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.lessonExplanation,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            question.explanation,
            style: const TextStyle(
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    final question = _questions[_currentQuestionIndex];
    final bool hasAnswer;
    if (question.type == LevelType.fillBlank) {
      hasAnswer = _fillBlankAnswer != null;
    } else if (question.type == LevelType.code) {
      hasAnswer = _codeAnswer != null;
    } else if (question.type == LevelType.sort) {
      hasAnswer = _sortOrder.isNotEmpty;
    } else {
      hasAnswer = _selectedAnswer != null;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardOf(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: _showResult
            ? AppButton(
                label: _currentQuestionIndex < _questions.length - 1
                    ? AppLocalizations.of(context)!.lessonNextQuestion
                    : AppLocalizations.of(context)!.lessonComplete,
                onPressed: _goToNext,
              )
            : AppButton(
                label: AppLocalizations.of(context)!.lessonConfirmAnswer,
                onPressed: hasAnswer ? _submitAnswer : null,
              ),
      ),
    );
  }

  OptionState _getOptionState(Option option) {
    if (!_showResult) {
      return _selectedAnswer == option.letter ? OptionState.selected : OptionState.normal;
    }
    if (option.isCorrect) return OptionState.correct;
    if (_selectedAnswer == option.letter && !option.isCorrect) return OptionState.incorrect;
    return OptionState.normal;
  }

  void _selectAnswer(Option option) {
    setState(() {
      _selectedAnswer = option.letter;
    });
  }

  void _submitAnswer() {
    final question = _questions[_currentQuestionIndex];
    bool correct;

    if (question.type == LevelType.fillBlank) {
      correct = question.acceptedAnswers.any(
        (a) => a.trim().toLowerCase() == (_fillBlankAnswer ?? '').trim().toLowerCase(),
      );
    } else if (question.type == LevelType.code) {
      final userCode = (_codeAnswer ?? '').trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
      correct = question.acceptedAnswers.any(
        (a) => a.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase() == userCode,
      );
    } else if (question.type == LevelType.sort) {
      final userOrder = _sortOrder.map((o) => o.letter).join();
      correct = question.acceptedAnswers.contains(userOrder);
    } else {
      correct = question.acceptedAnswers.contains(_selectedAnswer);
    }

    // Track consecutive correct answers for quick_learner achievement
    final achievementService = GetIt.instance<AchievementService>();
    if (correct) {
      achievementService.recordCorrectAnswer();
    } else {
      achievementService.resetConsecutiveCorrect();
    }

    setState(() {
      _showResult = true;
      _isCorrect = correct;
      _animateResult = true;
      _showXpPopup = correct;
      _animateHeartPulse = !correct && !_isBoss;
      if (correct) {
        _correctCount++;
        _currentXp += _isBoss ? GameConstants.xpPerCorrect * 2 : GameConstants.xpPerCorrect;
      } else {
        // BOSS levels don't consume hearts
        if (!_isBoss) {
          _hearts = (_hearts - GameConstants.heartsPerWrong).clamp(0, GameConstants.maxHearts);
        }
        _wrongQuestionIds.add(question.id);
      }
    });

    // Reset heart pulse animation after it plays
    if (!correct && !_isBoss) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _animateHeartPulse = false;
          });
        }
      });
    }

    if (!_isBoss && !correct && _hearts == 0) {
      // Sync heart loss to GameBloc immediately
      final heartsLost = GameConstants.maxHearts - _hearts;
      if (heartsLost > 0) {
        context.read<GameBloc>().add(UpdateHearts(-heartsLost));
      }
      _showHeartsDepletedDialog();
    }
  }

  void _showHeartsDepletedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Column(
          children: [
            const Text(
              '\u{1F494}',
              style: TextStyle(fontSize: 48),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.lessonHeartsEmpty,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          AppLocalizations.of(context)!.lessonHeartsDepletedMsg(GameConstants.heartsRecoveryHours),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                Navigator.pop(context); // back to home
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.lessonReturnHome,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _goToNext() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _fillBlankAnswer = null;
        _fillBlankController.clear();
        _codeAnswer = null;
        _codeAnswerController.clear();
        _showResult = false;
        _animateResult = false;
        _showXpPopup = false;
        _animateHeartPulse = false;
        _initSortOrderIfNeeded();
      });
    } else {
      _showCompletionScreen();
    }
  }

  void _showCompletionScreen() {
    final score = (_correctCount / _questions.length * 100).round();
    final isPerfect = score >= 80;
    final bossFailed = _isBoss && score < 70;
    final totalXp = _currentXp + GameConstants.xpPerLevelComplete + (isPerfect ? GameConstants.xpPerfectBonus : 0);
    final timeSpent = DateTime.now().difference(_lessonStartTime);

    // Don't reward if BOSS challenge failed
    if (!bossFailed) {
      // Dispatch game state updates
      final gameBloc = context.read<GameBloc>();
      gameBloc.add(AddXp(totalXp));
      gameBloc.add(UpdateStreak());
      if ((isPerfect || _isBoss) && _lesson != null) {
        gameBloc.add(AddDiamond(_lesson!.diamondReward));
      }
      // Sync heart loss (BOSS doesn't lose hearts)
      if (!_isBoss) {
        final heartsLost = GameConstants.maxHearts - _hearts;
        if (heartsLost > 0) {
          gameBloc.add(UpdateHearts(-heartsLost));
        }
      }

      // Update daily task progress
      final dailyTaskService = GetIt.instance<DailyTaskService>();
      dailyTaskService.markLessonCompleted(isPerfect);

      // Persist lesson result
      final repo = GetIt.instance<ILearningRepository>();
      repo.saveLessonResult(
        widget.courseId,
        LessonResult(
          lessonId: widget.lessonId,
          score: score,
          correctCount: _correctCount,
          totalCount: _questions.length,
          timeSpent: timeSpent,
          isPerfect: isPerfect,
          completedAt: DateTime.now(),
          wrongQuestionIds: _wrongQuestionIds,
        ),
      );

      // Record stats for leaderboard
      final leaderboardService = GetIt.instance<LeaderboardService>();
      leaderboardService.recordLessonCompletion(
        xpEarned: totalXp,
        isPerfect: isPerfect,
        timeSpent: timeSpent,
      );

      // Check and unlock achievements
      _checkAchievements();

      // Schedule streak warning notification (30h after now, 6h before grace period expires)
      NotificationService().scheduleStreakWarning(DateTime.now());
    }

    // Check if level-up happened, show celebration first if so
    _showCompletionWithLevelUpCheck(score, isPerfect, totalXp);
  }

  /// Shows the level-up celebration overlay if applicable, then the completion sheet.
  void _showCompletionWithLevelUpCheck(int score, bool isPerfect, int totalXp) {
    // Use a short delay to allow the bloc state to update after AddXp
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      final gameState = context.read<GameBloc>().state;
      if (gameState.justLeveledUp) {
        _showLevelUpCelebration(gameState.progress.level, () {
          context.read<GameBloc>().add(ClearLevelUpNotification());
          _openCompletionSheet(score, isPerfect, totalXp);
        });
      } else {
        _openCompletionSheet(score, isPerfect, totalXp);
      }
    });
  }

  /// Displays a fullscreen level-up celebration overlay.
  void _showLevelUpCelebration(int newLevel, VoidCallback onComplete) {
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => _LevelUpOverlay(
        newLevel: newLevel,
        onDismiss: () {
          overlayEntry.remove();
          onComplete();
        },
      ),
    );
    Overlay.of(context).insert(overlayEntry);
  }

  void _openCompletionSheet(int score, bool isPerfect, int totalXp) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (context) => _buildCompletionSheet(score, isPerfect, totalXp),
    );
  }

  Future<void> _checkAchievements() async {
    try {
      final achievementService = GetIt.instance<AchievementService>();
      final newlyUnlocked = await achievementService.checkAndUnlockAchievements(
        courseId: widget.courseId,
      );

      if (!mounted) return;

      // Reload game state so profile screen reflects unlocks
      if (newlyUnlocked.isNotEmpty) {
        context.read<GameBloc>().add(LoadUserProgress());
      }

      for (final achievement in newlyUnlocked) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('\u{1F3C6} ${AppLocalizations.of(context)!.lessonAchievementUnlocked(achievement.nameZh)}'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (_) {
      // Achievement check is non-critical; silently ignore errors.
    }
  }

  Widget _buildCompletionSheet(int score, bool isPerfect, int totalXp) {
    final bossFailed = _isBoss && score < 70;

    final l10n = AppLocalizations.of(context)!;
    // Build stat items list for staggered animation
    final statItems = <Widget>[
      if (!_isBoss) _buildStatItem('\u2764\uFE0F', '$_hearts/5', l10n.lessonStatLife),
      _buildStatItem('\u26A1', '+$totalXp', 'XP'),
      if (isPerfect || _isBoss)
        _buildStatItem('\u{1F48E}', '+${_lesson?.diamondReward ?? 1}', l10n.lessonStatDiamond),
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardOf(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        gradient: _isBoss
            ? LinearGradient(
                colors: isDark
                    ? [const Color(0xFF3E3A20), AppColors.darkSurface]
                    : [const Color(0xFFFFF8E1), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
            : null,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Emoji: scale in with bounce (0ms)
            Text(
              bossFailed
                  ? '\u{1F4A5}'
                  : (_isBoss
                      ? '\u{1F451}'
                      : (isPerfect ? '\u{1F31F}' : '\u{1F389}')),
              style: const TextStyle(fontSize: 64),
            )
                .animate()
                .scale(
                  begin: const Offset(0.0, 0.0),
                  end: const Offset(1.0, 1.0),
                  duration: 400.ms,
                  curve: Curves.bounceOut,
                ),
            const SizedBox(height: 16),
            // Title: fadeIn + slideUp (200ms delay)
            Text(
              bossFailed
                  ? l10n.lessonChallengeFailed
                  : (_isBoss
                      ? l10n.lessonBossSuccess
                      : (isPerfect ? l10n.lessonPerfectClear : l10n.lessonCongrats)),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: bossFailed ? AppColors.error : AppColors.textPrimary,
              ),
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 300.ms)
                .slideY(begin: 0.3, end: 0, delay: 200.ms, duration: 300.ms),
            const SizedBox(height: 8),
            // Score: fadeIn (400ms delay)
            Text(
              bossFailed
                  ? l10n.lessonNeedReview
                  : l10n.lessonScoreResult(_correctCount, _questions.length, score),
              style: TextStyle(
                fontSize: bossFailed ? 16 : 18,
                color: bossFailed ? AppColors.textSecondary : AppColors.textSecondary,
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 300.ms),
            if (!bossFailed) ...[
              const SizedBox(height: 24),
              // Stat items: fadeIn one by one (600ms, 700ms, 800ms delay)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (int i = 0; i < statItems.length; i++)
                    statItems[i].animate().fadeIn(
                          delay: Duration(milliseconds: 600 + (i * 100)),
                          duration: 300.ms,
                        ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            // Continue button: fadeIn + slideUp (1000ms delay)
            AppButton(
              label: bossFailed ? l10n.lessonReturnReview : l10n.lessonContinue,
              onPressed: () {
                Navigator.pop(context); // close sheet
                Navigator.pop(context); // back to home
              },
            )
                .animate()
                .fadeIn(delay: 1000.ms, duration: 300.ms)
                .slideY(begin: 0.3, end: 0, delay: 1000.ms, duration: 300.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAIHelpButton() {
    return Center(
      child: TextButton.icon(
        onPressed: _showAIHelp,
        icon: const Icon(Icons.lightbulb_outline, color: AppColors.primary),
        label: Text(
          AppLocalizations.of(context)!.lessonAskAI,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showAIHelp() {
    final question = _questions[_currentQuestionIndex];

    // Build a context message from the current question
    final contextParts = <String>[];
    if (_lesson != null) {
      contextParts.add('课程: ${_lesson!.title}');
    }
    contextParts.add('题目: ${question.content}');
    if (question.relatedConcepts.isNotEmpty) {
      contextParts.add('相关知识点: ${question.relatedConcepts.join(', ')}');
    }
    contextParts.add('请帮我理解这道题。');

    final contextMessage = contextParts.join('\n');

    // Set question context on the bloc and navigate to AI tutor
    context.read<AITutorBloc>().add(
      StartAITutor(questionContext: contextMessage),
    );
    context.push('/ai-tutor', extra: contextMessage);
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.lessonExitTitle),
        content: Text(AppLocalizations.of(context)!.lessonExitContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.lessonContinueChallenge),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.lessonExit),
          ),
        ],
      ),
    );
  }
}

/// Fullscreen level-up celebration overlay widget.
class _LevelUpOverlay extends StatefulWidget {
  final int newLevel;
  final VoidCallback onDismiss;

  const _LevelUpOverlay({
    required this.newLevel,
    required this.onDismiss,
  });

  @override
  State<_LevelUpOverlay> createState() => _LevelUpOverlayState();
}

class _LevelUpOverlayState extends State<_LevelUpOverlay> {
  @override
  void initState() {
    super.initState();
    // Auto-dismiss after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: widget.onDismiss,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFFFFD700).withValues(alpha: 0.85),
                const Color(0xFFFFA000).withValues(alpha: 0.85),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Star emoji with elastic scale
              const Text(
                '\u2B50',
                style: TextStyle(fontSize: 80),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.0, 0.0),
                    end: const Offset(1.2, 1.2),
                    duration: 400.ms,
                    curve: Curves.elasticOut,
                  )
                  .then()
                  .scale(
                    begin: const Offset(1.2, 1.2),
                    end: const Offset(1.0, 1.0),
                    duration: 200.ms,
                  ),
              const SizedBox(height: 24),
              // "Level Up!" text with fadeIn
              const Text(
                'Level Up!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
              const SizedBox(height: 16),
              // New level number with bounce
              Text(
                'Lv. ${widget.newLevel}',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.0, 0.0),
                    end: const Offset(1.0, 1.0),
                    delay: 300.ms,
                    duration: 500.ms,
                    curve: Curves.bounceOut,
                  )
                  .fadeIn(delay: 300.ms, duration: 300.ms),
            ],
          ),
        ),
      ),
    );
  }
}
