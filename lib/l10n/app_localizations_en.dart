// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'JellyBuddy';

  @override
  String get tabHome => 'Home';

  @override
  String get tabCourses => 'Courses';

  @override
  String get tabAITutor => 'AI Tutor';

  @override
  String get tabProfile => 'Profile';

  @override
  String get splashSubtitle => 'AI-Powered Gamified Learning';

  @override
  String homeStreakDays(int days) {
    return '$days-Day Streak';
  }

  @override
  String get homeStartLearning => 'Pick a lesson to start learning!';

  @override
  String get homeDailyTasks => 'Daily Tasks';

  @override
  String get homePythonLessons => 'Python Lessons';

  @override
  String get homeReviewBook => 'Review Book';

  @override
  String get homeReviewSubtitle =>
      'Review wrong answers and reinforce concepts';

  @override
  String get homeHeartsRecovering => 'Hearts recovering...';

  @override
  String get homeRecoverySoon => 'Recovering soon';

  @override
  String homeRecoveryTime(int hours, int minutes) {
    return 'Estimated ${hours}h ${minutes}m until 1 heart recovers';
  }

  @override
  String homeRecoveryMinutes(int minutes) {
    return 'Estimated ${minutes}m until 1 heart recovers';
  }

  @override
  String get homeFailedToLoadCourse => 'Failed to load course data';

  @override
  String homeLessonQuestions(int count, int xp) {
    return '$count questions  +$xp XP';
  }

  @override
  String homeLessonResult(int score, int correct, int total, int xp) {
    return '$score%  $correct/$total correct  +$xp XP';
  }

  @override
  String get lessonConfirmAnswer => 'Confirm';

  @override
  String get lessonNextQuestion => 'Next';

  @override
  String get lessonComplete => 'Done';

  @override
  String get lessonCorrect => 'Correct!';

  @override
  String get lessonIncorrect => 'Wrong';

  @override
  String get lessonExplanation => 'Explanation';

  @override
  String get lessonHeartsEmpty => 'No Hearts Left';

  @override
  String get lessonAskAI => 'Ask AI';

  @override
  String get lessonInputHint => 'Type your answer...';

  @override
  String get lessonDragToSort => 'Drag to reorder';

  @override
  String get lessonCorrectOrder => 'Correct order:';

  @override
  String lessonCorrectAnswer(String answer) {
    return 'Correct answer: $answer';
  }

  @override
  String get lessonBossChallenge => 'BOSS Challenge';

  @override
  String get lessonExitTitle => 'Quit Lesson?';

  @override
  String get lessonExitContent =>
      'You won\'t earn any rewards. Continue the challenge?';

  @override
  String get lessonContinueChallenge => 'Keep Going';

  @override
  String get lessonExit => 'Quit';

  @override
  String get lessonReturnHome => 'Back to Home';

  @override
  String lessonHeartsDepletedMsg(int hours) {
    return 'You\'ve run out of hearts. Wait for recovery. 1 heart recovers every $hours hours.';
  }

  @override
  String get lessonChallengeFailed => 'Challenge Failed';

  @override
  String get lessonBossSuccess => 'BOSS Challenge Cleared!';

  @override
  String get lessonPerfectClear => 'Perfect Clear!';

  @override
  String get lessonCongrats => 'Well Done!';

  @override
  String get lessonNeedReview => 'Review this chapter again';

  @override
  String lessonScoreResult(int correct, int total, int score) {
    return '$correct/$total correct  ($score%)';
  }

  @override
  String get lessonReturnReview => 'Back to Review';

  @override
  String get lessonContinue => 'Continue';

  @override
  String get lessonStatLife => 'Lives';

  @override
  String get lessonStatDiamond => 'Diamonds';

  @override
  String lessonAchievementUnlocked(String name) {
    return 'Achievement unlocked: $name';
  }

  @override
  String get profileLevelProgress => 'Level Progress';

  @override
  String get profileAchievements => 'Achievements';

  @override
  String get profileAIModelManagement => 'AI Model Management';

  @override
  String get profileAIModelSubtitle => 'Download & load local AI models';

  @override
  String get profileStreakDays => 'Streak Days';

  @override
  String get profileDiamonds => 'Diamonds';

  @override
  String get profileHearts => 'Hearts';

  @override
  String get modelManagementTitle => 'AI Model Management';

  @override
  String get modelAvailable => 'Available Models';

  @override
  String get modelNoModels => 'No models available';

  @override
  String get modelInferenceEngine => 'AI Inference Engine';

  @override
  String get modelReady => 'Model ready';

  @override
  String get modelLoading => 'Loading model...';

  @override
  String get modelDownloading => 'Downloading model...';

  @override
  String get modelGenerating => 'Generating response...';

  @override
  String get modelError => 'Model loading failed';

  @override
  String get modelUninitialized => 'No model loaded';

  @override
  String modelDownloadProgress(String percent) {
    return 'Downloading: $percent';
  }

  @override
  String modelCurrentFile(String file) {
    return 'Current file: $file';
  }

  @override
  String modelDownloadSource(String source) {
    return 'Source: $source';
  }

  @override
  String get modelCancelDownload => 'Cancel Download';

  @override
  String get modelDownloadButton => 'Download';

  @override
  String get modelLoadButton => 'Load';

  @override
  String get modelUnloadButton => 'Unload';

  @override
  String get modelLoaded => 'Loaded';

  @override
  String get coursesTitle => 'All Courses';

  @override
  String get coursesNoCourses => 'No courses available';

  @override
  String coursesLessonCount(int count) {
    return '$count lessons';
  }

  @override
  String get reviewTitle => 'Review Book';

  @override
  String get reviewEmpty => 'No wrong answers, keep going!';

  @override
  String get reviewEmptySubtitle =>
      'Complete more lessons to test your knowledge';

  @override
  String get reviewCorrectAnswer => 'Correct Answer';

  @override
  String get reviewDifficultyEasy => 'Easy';

  @override
  String get reviewDifficultyMedium => 'Medium';

  @override
  String get reviewDifficultyHard => 'Hard';

  @override
  String get aiTutorTitle => 'JellyBuddy';

  @override
  String get aiTutorClearChat => 'Clear Chat';

  @override
  String get aiTutorClearConfirm =>
      'Are you sure you want to clear all chat history?';

  @override
  String get aiTutorCancel => 'Cancel';

  @override
  String get aiTutorClear => 'Clear';

  @override
  String get aiTutorWelcome =>
      'Hi! I\'m JellyBuddy, your programming tutor. What would you like to ask?';

  @override
  String get aiTutorInputHint => 'Type your question...';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStart => 'Get Started';

  @override
  String get onboardingTitle1 => 'Learn to Code Like Playing a Game';

  @override
  String get onboardingSubtitle1 =>
      'Complete levels, solve problems, earn XP — make learning fun';

  @override
  String get onboardingTitle2 => 'JellyBuddy is Always Here';

  @override
  String get onboardingSubtitle2 =>
      'Stuck? Your AI tutor explains step by step';

  @override
  String get onboardingTitle3 => 'Anytime, Anywhere, Offline';

  @override
  String get onboardingSubtitle3 =>
      'Local AI model, privacy-first, learn without internet';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSubtitle => 'Switch app display language';

  @override
  String get settingsDarkMode => 'Dark Mode';

  @override
  String get settingsDarkModeSubtitle => 'Toggle dark/light theme';

  @override
  String get settingsLearning => 'Learning';

  @override
  String get settingsResetProgress => 'Reset Learning Progress';

  @override
  String get settingsResetProgressSubtitle =>
      'Clear all course progress and scores';

  @override
  String get settingsResetProgressConfirm =>
      'Are you sure you want to reset all learning progress? This cannot be undone.';

  @override
  String get settingsResetProgressDone => 'Learning progress has been reset';

  @override
  String get settingsExportProgress => 'Export Progress';

  @override
  String get settingsExportProgressSubtitle => 'Export your learning data';

  @override
  String get settingsComingSoon => 'Coming Soon';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsVersion => 'App Version';

  @override
  String get settingsSlogan => 'AI-powered gamified learning';

  @override
  String get settingsLicenses => 'Open Source Licenses';

  @override
  String get settingsLicensesSubtitle => 'View third-party library licenses';

  @override
  String get settingsGithub => 'GitHub';

  @override
  String get settingsGithubUrl => 'https://github.com/user/JellyBuddy';

  @override
  String get settingsDangerZone => 'Danger Zone';

  @override
  String get settingsClearAllData => 'Clear All Data';

  @override
  String get settingsClearAllDataSubtitle => 'Factory reset — delete all data';

  @override
  String get settingsClearAllDataConfirm =>
      'Are you sure you want to clear all data? This will delete all learning progress, settings, and cache. This cannot be undone.';

  @override
  String get settingsClearAllDataDone => 'All data has been cleared';

  @override
  String get settingsCancel => 'Cancel';

  @override
  String get settingsConfirm => 'Confirm';

  @override
  String get settingsReset => 'Reset';

  @override
  String get settingsClearAll => 'Clear All';

  @override
  String get settingsLanguageZh => 'Chinese';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get profileSettings => 'Settings';

  @override
  String get profileSettingsSubtitle => 'Language, data management, etc.';

  @override
  String get homeStatsTitle => 'Learning Stats';

  @override
  String get homeStatsSubtitle => 'View your learning progress and scores';
}
