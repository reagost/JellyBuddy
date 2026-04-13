import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jelly_buddy/l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/constants/game_constants.dart';
import '../../../data/services/achievement_service.dart';
import '../../blocs/game/game_bloc.dart';
import '../../blocs/game/game_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  /// Default courseId used for achievement progress queries.
  static const _defaultCourseId = 'python';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<GameBloc, GameState>(
          builder: (context, state) {
            final progress = state.progress;
            final nextLevelXp = progress.level < GameConstants.xpToLevel.length
                ? GameConstants.xpToLevel[progress.level]
                : GameConstants.xpToLevel.last;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Profile Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppGradients.primaryGradient,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text('🧑‍💻', style: TextStyle(fontSize: 40)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          progress.userName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Level ${progress.level}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stats Grid
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('⚡', '${progress.totalXp}', 'XP')),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard('🔥', '${progress.streak}', AppLocalizations.of(context)!.profileStreakDays)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('💎', '${progress.diamonds}', AppLocalizations.of(context)!.profileDiamonds)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard('❤️', '${progress.hearts}/5', AppLocalizations.of(context)!.profileHearts)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // XP Progress
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.profileLevelProgress,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '${progress.totalXp} / $nextLevelXp XP',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: nextLevelXp > 0
                                ? (progress.totalXp / nextLevelXp).clamp(0.0, 1.0)
                                : 0.0,
                            minHeight: 10,
                            backgroundColor: AppColors.surfaceVariant,
                            valueColor: const AlwaysStoppedAnimation(AppColors.xpGold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Achievements Section
                  _buildAchievementsSection(state, progress),
                  // Settings
                  const SizedBox(height: 24),
                  _buildSettingsItem(
                    context,
                    icon: Icons.smart_toy_outlined,
                    title: AppLocalizations.of(context)!.profileAIModelManagement,
                    subtitle: AppLocalizations.of(context)!.profileAIModelSubtitle,
                    onTap: () => context.push('/model-settings'),
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsItem(
                    context,
                    icon: Icons.settings_outlined,
                    title: AppLocalizations.of(context)!.profileSettings,
                    subtitle: AppLocalizations.of(context)!.profileSettingsSubtitle,
                    onTap: () => context.push('/settings'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAchievementsSection(GameState state, dynamic progress) {
    final achievementService = GetIt.instance<AchievementService>();
    // getAchievementProgress is sync-friendly (reads from Hive cache),
    // but the API is async. We use a FutureBuilder to resolve it.
    return FutureBuilder<Map<String, (int, int)>>(
      future: achievementService.getAchievementProgress(
        courseId: _defaultCourseId,
        progress: state.progress,
      ),
      builder: (context, snapshot) {
        final progressMap = snapshot.data ?? {};
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.profileAchievements,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ...state.allAchievements.map((achievement) {
                final isUnlocked = progress.unlockedAchievements.contains(achievement.id);
                final pair = progressMap[achievement.id];
                final current = pair?.$1 ?? 0;
                final target = pair?.$2 ?? 1;
                final ratio = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            achievement.icon,
                            style: TextStyle(
                              fontSize: 28,
                              color: isUnlocked ? null : Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  achievement.nameZh,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: isUnlocked ? AppColors.textPrimary : AppColors.textHint,
                                  ),
                                ),
                                Text(
                                  achievement.description,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isUnlocked ? AppColors.textSecondary : AppColors.textHint,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isUnlocked)
                            const Icon(Icons.check_circle, color: AppColors.success, size: 20)
                          else
                            Text(
                              '$current/$target',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textHint,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                      if (!isUnlocked) ...[
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: ratio,
                            minHeight: 6,
                            backgroundColor: AppColors.surfaceVariant,
                            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
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
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String emoji, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
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
      ),
    );
  }
}
