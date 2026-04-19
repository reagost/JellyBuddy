import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jelly_buddy/l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/constants/game_constants.dart';
import '../../../data/services/daily_task_service.dart';
import '../../../domain/entities/course.dart';
import '../../../domain/entities/daily_task.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/i_learning_repository.dart';
import '../../blocs/game/game_bloc.dart';
import '../../blocs/game/game_state.dart';
import '../../widgets/game/hearts_display.dart';
import '../../widgets/game/xp_progress_bar.dart';
import '../../widgets/game/streak_counter.dart';
import '../../widgets/game/diamond_display.dart';
import '../../widgets/common/skeleton_loader.dart';
import '../../widgets/learning_path/learning_path_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Course? _course;
  bool _isLoading = true;
  Set<String> _completedLessonIds = {};
  Map<String, LessonResult> _lessonResults = {};
  List<DailyTask> _dailyTasks = [];

  @override
  void initState() {
    super.initState();
    _loadCourseData();
  }

  Future<void> _loadCourseData() async {
    try {
      final repo = GetIt.instance<ILearningRepository>();
      final course = await repo.getCourse('python');
      final completedIds = repo.getCompletedLessonIds('python');

      // Load results for completed lessons
      final results = <String, LessonResult>{};
      for (final lessonId in completedIds) {
        final result = await repo.getLessonResult(lessonId);
        if (result != null) {
          results[lessonId] = result;
        }
      }

      // Load daily tasks
      final dailyTaskService = GetIt.instance<DailyTaskService>();
      final dailyTasks = dailyTaskService.getDailyTasks();

      setState(() {
        _course = course;
        _completedLessonIds = completedIds.toSet();
        _lessonResults = results;
        _dailyTasks = dailyTasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      body: SafeArea(
        child: BlocBuilder<GameBloc, GameState>(
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.screenPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.asset(
                                    'assets/icon/app_icon.png',
                                    width: 40,
                                    height: 40,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'JellyBuddy',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimaryOf(context),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.notifications_outlined),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('暂无新通知'),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.settings_outlined),
                                  onPressed: () => context.push('/settings'),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Streak Banner
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.streakOrange, AppColors.secondary],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Text('🔥', style: TextStyle(fontSize: 32)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.homeStreakDays(state.progress.streak),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      AppLocalizations.of(context)!.homeStartLearning,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // XP Progress
                        XpProgressBar(
                          currentXp: state.progress.totalXp,
                          nextLevelXp: 150,
                          level: state.progress.level,
                        ),
                        const SizedBox(height: 24),

                        // Stats Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            HeartsDisplay(
                              current: state.progress.hearts,
                              max: 5,
                            ),
                            StreakCounter(days: state.progress.streak),
                            DiamondDisplay(count: state.progress.diamonds),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Daily Tasks Section
                        _buildDailyTasksSection(),
                        const SizedBox(height: 24),

                        // Stats button
                        _buildStatsButton(),
                        const SizedBox(height: 24),

                        // Review button
                        _buildReviewButton(),
                        const SizedBox(height: 24),

                        // Lessons Section
                        Text(
                          '\u{1F4DA} ${AppLocalizations.of(context)!.homePythonLessons}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryOf(context),
                          ),
                        ),
                        const SizedBox(height: 12),

                        if (state.progress.hearts == 0)
                          _buildHeartsRecoveryBanner(state),

                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _isLoading
                              ? const Column(
                                  key: ValueKey('skeleton'),
                                  children: [
                                    SkeletonLessonCard(),
                                    SkeletonLessonCard(),
                                    SkeletonLessonCard(),
                                  ],
                                )
                              : _course != null
                                  ? LearningPathWidget(
                                      key: const ValueKey('lessons'),
                                      lessons: _course!.lessons,
                                      completedLessonIds: _completedLessonIds,
                                      lessonResults: _lessonResults,
                                      onLessonTap: (lesson) async {
                                        await context.push('/lesson/${lesson.courseId}/${lesson.id}');
                                        _loadCourseData();
                                      },
                                      heartsEmpty: state.progress.hearts == 0,
                                    )
                                  : Text(
                                      AppLocalizations.of(context)!.homeFailedToLoadCourse,
                                      key: const ValueKey('error'),
                                    ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatsButton() {
    return GestureDetector(
      onTap: () => context.push('/stats'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardOf(context),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('\u{1F4CA}', style: TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\u{1F4CA} ${AppLocalizations.of(context)!.homeStatsTitle}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryOf(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppLocalizations.of(context)!.homeStatsSubtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondaryOf(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textHintOf(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewButton() {
    return GestureDetector(
      onTap: () => context.push('/review'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardOf(context),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('\u{1F4DD}', style: TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\u{1F4DD} ${AppLocalizations.of(context)!.homeReviewBook}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryOf(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppLocalizations.of(context)!.homeReviewSubtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondaryOf(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textHintOf(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeartsRecoveryBanner(GameState state) {
    final l10n = AppLocalizations.of(context)!;
    String recoveryText = '';
    final lastLost = state.progress.lastHeartLostAt;
    if (lastLost != null) {
      final recoveryTime = lastLost.add(
        const Duration(hours: GameConstants.heartsRecoveryHours),
      );
      final remaining = recoveryTime.difference(DateTime.now());
      if (remaining.isNegative) {
        recoveryText = l10n.homeRecoverySoon;
      } else {
        final hours = remaining.inHours;
        final minutes = remaining.inMinutes % 60;
        recoveryText = hours > 0
            ? l10n.homeRecoveryTime(hours, minutes)
            : l10n.homeRecoveryMinutes(minutes);
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Text('\u2764\uFE0F', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\u2764\uFE0F ${l10n.homeHeartsRecovering}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
                if (recoveryText.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    recoveryText,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTasksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '\u{1F3AF} ${AppLocalizations.of(context)!.homeDailyTasks}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryOf(context),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardOf(context),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              for (int i = 0; i < _dailyTasks.length; i++) ...[
                _buildDailyTaskRow(_dailyTasks[i]),
                if (i < _dailyTasks.length - 1)
                  const Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: AppColors.surfaceVariant,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDailyTaskRow(DailyTask task) {
    final isCompleted = task.isCompleted;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Checkbox icon
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.success.withValues(alpha: 0.15)
                  : AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: AppColors.success, size: 18)
                  : const Icon(Icons.circle_outlined,
                      color: AppColors.textHint, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          // Title and reward
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isCompleted
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                    decoration:
                        isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  task.reward,
                  style: TextStyle(
                    fontSize: 12,
                    color: isCompleted
                        ? AppColors.textHint
                        : AppColors.xpGold,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Progress text
          Text(
            '${task.currentProgress}/${task.targetProgress}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isCompleted ? AppColors.success : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

}
