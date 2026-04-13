class DailyTask {
  final String id;
  final String title;
  final String reward;
  final int currentProgress;
  final int targetProgress;

  const DailyTask({
    required this.id,
    required this.title,
    required this.reward,
    required this.currentProgress,
    required this.targetProgress,
  });

  bool get isCompleted => currentProgress >= targetProgress;
}
