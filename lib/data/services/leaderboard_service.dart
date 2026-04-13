import 'storage_service.dart';
import 'stats_service.dart';

class PersonalRecord {
  final String title;
  final String value;
  final String emoji;
  final DateTime achievedAt;

  const PersonalRecord({
    required this.title,
    required this.value,
    required this.emoji,
    required this.achievedAt,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'value': value,
        'emoji': emoji,
        'achievedAt': achievedAt.toIso8601String(),
      };

  factory PersonalRecord.fromJson(Map<String, dynamic> json) => PersonalRecord(
        title: json['title'] as String,
        value: json['value'] as String,
        emoji: json['emoji'] as String,
        achievedAt: DateTime.parse(json['achievedAt'] as String),
      );
}

class LeaderboardService {
  final StorageService _storage;
  final StatsService _statsService;

  static const String _highestSessionXpKey = 'lb_highest_session_xp';
  static const String _bestStreakKey = 'lb_best_streak';
  static const String _perfectStreakKey = 'lb_perfect_streak';
  static const String _fastestLessonKey = 'lb_fastest_lesson';
  static const String _recordsDatePrefix = 'lb_date_';

  LeaderboardService({
    required StorageService storage,
    required StatsService statsService,
  })  : _storage = storage,
        _statsService = statsService;

  /// Called after each lesson completion to update personal records.
  Future<void> recordLessonCompletion({
    required int xpEarned,
    required bool isPerfect,
    required Duration timeSpent,
  }) async {
    // 1. Highest XP in a single session
    final storedXp =
        int.tryParse(_storage.getString(_highestSessionXpKey) ?? '') ?? 0;
    if (xpEarned > storedXp) {
      await _storage.setString(_highestSessionXpKey, xpEarned.toString());
      await _storage.setString(
        '${_recordsDatePrefix}highest_xp',
        DateTime.now().toIso8601String(),
      );
    }

    // 2. Best streak — delegate to StatsService which already tracks this
    final bestStreak = await _statsService.getBestStreak();
    final storedBestStreak =
        int.tryParse(_storage.getString(_bestStreakKey) ?? '') ?? 0;
    if (bestStreak > storedBestStreak) {
      await _storage.setString(_bestStreakKey, bestStreak.toString());
      await _storage.setString(
        '${_recordsDatePrefix}best_streak',
        DateTime.now().toIso8601String(),
      );
    }

    // 3. Perfect streak (consecutive perfect lessons)
    if (isPerfect) {
      final currentPerfectStreak =
          int.tryParse(_storage.getString('${_perfectStreakKey}_current') ?? '') ?? 0;
      final newPerfectStreak = currentPerfectStreak + 1;
      await _storage.setString(
          '${_perfectStreakKey}_current', newPerfectStreak.toString());

      final storedBestPerfect =
          int.tryParse(_storage.getString(_perfectStreakKey) ?? '') ?? 0;
      if (newPerfectStreak > storedBestPerfect) {
        await _storage.setString(_perfectStreakKey, newPerfectStreak.toString());
        await _storage.setString(
          '${_recordsDatePrefix}perfect_streak',
          DateTime.now().toIso8601String(),
        );
      }
    } else {
      // Reset the current perfect streak
      await _storage.setString('${_perfectStreakKey}_current', '0');
    }

    // 4. Fastest lesson completion
    if (timeSpent.inSeconds > 0) {
      final storedFastest =
          int.tryParse(_storage.getString(_fastestLessonKey) ?? '') ?? 0;
      if (storedFastest == 0 || timeSpent.inSeconds < storedFastest) {
        await _storage.setString(
            _fastestLessonKey, timeSpent.inSeconds.toString());
        await _storage.setString(
          '${_recordsDatePrefix}fastest_lesson',
          DateTime.now().toIso8601String(),
        );
      }
    }
  }

  /// Returns the list of personal records for display.
  Future<List<PersonalRecord>> getPersonalRecords() async {
    final records = <PersonalRecord>[];

    // Highest XP in a single session
    final highestXp =
        int.tryParse(_storage.getString(_highestSessionXpKey) ?? '') ?? 0;
    final highestXpDate = _getRecordDate('highest_xp');
    records.add(PersonalRecord(
      title: '单次最高XP',
      value: '$highestXp XP',
      emoji: highestXp > 0 ? '🥇' : '🏅',
      achievedAt: highestXpDate,
    ));

    // Best streak
    final bestStreak = await _statsService.getBestStreak();
    final bestStreakDate = _getRecordDate('best_streak');
    records.add(PersonalRecord(
      title: '最长连续天数',
      value: '$bestStreak 天',
      emoji: bestStreak >= 7 ? '🥇' : (bestStreak >= 3 ? '🥈' : '🥉'),
      achievedAt: bestStreakDate,
    ));

    // Most perfect lessons in a row
    final perfectStreak =
        int.tryParse(_storage.getString(_perfectStreakKey) ?? '') ?? 0;
    final perfectDate = _getRecordDate('perfect_streak');
    records.add(PersonalRecord(
      title: '连续满分课程',
      value: '$perfectStreak 课',
      emoji: perfectStreak >= 5 ? '🥇' : (perfectStreak >= 3 ? '🥈' : '🥉'),
      achievedAt: perfectDate,
    ));

    // Fastest lesson completion
    final fastestSeconds =
        int.tryParse(_storage.getString(_fastestLessonKey) ?? '') ?? 0;
    final fastestDate = _getRecordDate('fastest_lesson');
    final fastestDisplay = fastestSeconds > 0
        ? _formatDuration(Duration(seconds: fastestSeconds))
        : '--';
    records.add(PersonalRecord(
      title: '最快完成课程',
      value: fastestDisplay,
      emoji: fastestSeconds > 0 && fastestSeconds < 120
          ? '🥇'
          : (fastestSeconds > 0 && fastestSeconds < 300 ? '🥈' : '🥉'),
      achievedAt: fastestDate,
    ));

    return records;
  }

  DateTime _getRecordDate(String key) {
    final dateStr = _storage.getString('$_recordsDatePrefix$key');
    if (dateStr != null) {
      return DateTime.tryParse(dateStr) ?? DateTime.now();
    }
    return DateTime.now();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    if (minutes > 0) {
      return '$minutes分$seconds秒';
    }
    return '$seconds秒';
  }
}
