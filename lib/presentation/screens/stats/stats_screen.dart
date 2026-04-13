import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/services/stats_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  bool _isLoading = true;

  int _totalXp = 0;
  int _currentStreak = 0;
  int _bestStreak = 0;
  int _lessonsCompleted = 0;
  double _overallAccuracy = 0.0;
  List<bool> _weeklyActivity = List.filled(7, false);
  List<CourseCompletionRate> _courseRates = [];
  List<RecentLessonResult> _recentResults = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final stats = GetIt.instance<StatsService>();
      final results = await Future.wait([
        stats.getTotalXpEarned(),
        stats.getCurrentStreak(),
        stats.getBestStreak(),
        stats.getTotalLessonsCompleted(),
        stats.getOverallAccuracy(),
        stats.getWeeklyActivity(),
        stats.getCourseCompletionRates(),
        stats.getRecentResults(limit: 5),
      ]);

      setState(() {
        _totalXp = results[0] as int;
        _currentStreak = results[1] as int;
        _bestStreak = results[2] as int;
        _lessonsCompleted = results[3] as int;
        _overallAccuracy = results[4] as double;
        _weeklyActivity = results[5] as List<bool>;
        _courseRates = results[6] as List<CourseCompletionRate>;
        _recentResults = results[7] as List<RecentLessonResult>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '\u{1F4CA} \u5B66\u4E60\u7EDF\u8BA1',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderCard(),
                    const SizedBox(height: AppSpacing.sectionGap),
                    _buildWeeklyActivity(),
                    const SizedBox(height: AppSpacing.sectionGap),
                    _buildCourseProgress(),
                    const SizedBox(height: AppSpacing.sectionGap),
                    _buildRecentResults(),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
    );
  }

  // -------------------------------------------------------
  // Header Card — big number stats
  // -------------------------------------------------------
  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppGradients.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '\u2B50',
                  '$_totalXp',
                  '\u603B XP',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  '\u{1F525}',
                  '$_currentStreak',
                  '\u8FDE\u7EED\u5929\u6570',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '\u{1F4DA}',
                  '$_lessonsCompleted',
                  '\u5DF2\u5B8C\u6210',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  '\u{1F3AF}',
                  '${_overallAccuracy.toStringAsFixed(0)}%',
                  '\u6B63\u786E\u7387',
                ),
              ),
            ],
          ),
          if (_bestStreak > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '\u{1F3C6} \u6700\u4F73\u8FDE\u7EED: $_bestStreak \u5929',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
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
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------
  // Weekly Activity — 7 circles
  // -------------------------------------------------------
  Widget _buildWeeklyActivity() {
    const dayLabels = ['\u4E00', '\u4E8C', '\u4E09', '\u56DB', '\u4E94', '\u516D', '\u65E5'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '\u{1F4C5} \u672C\u5468\u6D3B\u52A8',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (i) {
              final isActive = _weeklyActivity[i];
              return Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? AppColors.success
                          : AppColors.surfaceVariant,
                      border: isActive
                          ? null
                          : Border.all(
                              color: AppColors.textHint.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                    ),
                    child: Center(
                      child: isActive
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    dayLabels[i],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? AppColors.success
                          : AppColors.textHint,
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------
  // Course Progress
  // -------------------------------------------------------
  Widget _buildCourseProgress() {
    if (_courseRates.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '\u{1F4D6} \u8BFE\u7A0B\u8FDB\u5EA6',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(_courseRates.length, (i) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: i < _courseRates.length - 1 ? AppSpacing.itemGap : 0,
            ),
            child: _buildCourseCard(_courseRates[i]),
          );
        }),
      ],
    );
  }

  Widget _buildCourseCard(CourseCompletionRate rate) {
    final pct = rate.percentage;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular progress indicator
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 56,
                  height: 56,
                  child: CircularProgressIndicator(
                    value: pct,
                    strokeWidth: 5,
                    backgroundColor: AppColors.surfaceVariant,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
                Text(
                  rate.icon,
                  style: const TextStyle(fontSize: 22),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rate.courseName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\u5DF2\u5B8C\u6210 ${rate.completed}/${rate.total} \u5173\u5361',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${(pct * 100).toStringAsFixed(0)}%',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------
  // Recent Results
  // -------------------------------------------------------
  Widget _buildRecentResults() {
    if (_recentResults.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '\u{1F4CB} \u6700\u8FD1\u8BB0\u5F55',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              '\u8FD8\u6CA1\u6709\u5B66\u4E60\u8BB0\u5F55\uFF0C\u5F00\u59CB\u5B66\u4E60\u5427\uFF01',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textHint,
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '\u{1F4CB} \u6700\u8FD1\u8BB0\u5F55',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(_recentResults.length, (i) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: i < _recentResults.length - 1 ? AppSpacing.sm : 0,
            ),
            child: _buildResultCard(_recentResults[i]),
          );
        }),
      ],
    );
  }

  Widget _buildResultCard(RecentLessonResult result) {
    final dateStr = _formatDate(result.completedAt);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Score circle
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: result.isPerfect
                  ? AppGradients.perfectGradient
                  : AppGradients.xpGradient,
            ),
            child: Center(
              child: Text(
                '${result.score}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.lessonTitle,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  dateStr,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          if (result.isPerfect)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: AppGradients.perfectGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Perfect',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(dateOnly).inDays;

    if (diff == 0) return '\u4ECA\u5929';
    if (diff == 1) return '\u6628\u5929';
    if (diff < 7) return '$diff \u5929\u524D';
    return '${dt.month}/${dt.day}';
  }
}
