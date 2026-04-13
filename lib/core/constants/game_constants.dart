class GameConstants {
  // Level rewards
  static const int xpPerCorrect = 10;
  static const int xpPerLevelComplete = 50;
  static const int xpPerfectBonus = 30;
  static const int diamondPerLevel = 1;

  // Hearts system
  static const int maxHearts = 5;
  static const int heartsPerWrong = 1;
  static const int heartsRecoveryHours = 4;
  static const int heartsPerAd = 1;
  static const int heartsMaxRecovery = 5;

  // Streak system
  static const int streakDailyBonus = 10;
  static const int streakWeeklyBonus = 50;
  static const int streakGraceHours = 36;

  // XP to level (truncated example)
  static const List<int> xpToLevel = [
    0, 60, 150, 300, 500, 800, 1200, 1700, 2300, 3000,
    3800, 4700, 5700, 6800, 8000, 9300, 10700, 12200, 13800, 15500,
  ];

  // Pass condition
  static const int defaultPassRate = 70;
}
