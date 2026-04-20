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
  String get homeNoNotifications => 'No new notifications';

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
  String get lessonCodeHint => '// Write code here...';

  @override
  String get lessonCorrectAnswerLabel => 'Correct answer:';

  @override
  String get lessonProgress => 'Progress';

  @override
  String get lessonDifficultyEasy => 'Easy';

  @override
  String get lessonDifficultyMedium => 'Medium';

  @override
  String get lessonDifficultyHard => 'Hard';

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
  String get profileEditName => 'Edit Username';

  @override
  String get profileEditNameHint => 'Enter new username';

  @override
  String get profileSave => 'Save';

  @override
  String get profileCancel => 'Cancel';

  @override
  String get profileLeaderboard => 'Personal Leaderboard';

  @override
  String get profileLeaderboardSubtitle => 'View personal best records';

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
  String get modelRetry => 'Retry';

  @override
  String get modelSettingsTitle => 'Model Settings';

  @override
  String get modelLocalAI => 'Local AI Model';

  @override
  String get modelLocalAISubtitle => 'Offline inference · Privacy first';

  @override
  String get modelLocalAIFree => 'Offline inference · Privacy first · Free';

  @override
  String get modelCloudAI => 'Cloud AI Model';

  @override
  String get modelCloudAIProviders =>
      'MiniMax · OpenRouter · OpenAI · Claude · DeepSeek';

  @override
  String get modelManage => 'Manage';

  @override
  String get modelCloudDisabled => 'Cloud AI disabled';

  @override
  String get modelCloudSwitched => 'Switched to cloud AI';

  @override
  String get modelInUse => 'In Use';

  @override
  String get modelDisable => 'Disable';

  @override
  String get modelEnable => 'Enable';

  @override
  String get modelSetAsAssistant => 'Set as AI assistant';

  @override
  String get modelLoadHint =>
      'Load a model or configure cloud AI for smart answers';

  @override
  String modelInUseCloud(String provider) {
    return 'In Use: $provider';
  }

  @override
  String get modelInUseLocal => 'In Use: Local Model';

  @override
  String get modelNoCloudConfig => 'No cloud models configured';

  @override
  String get modelNoCloudConfigHint =>
      'Add your own API Key to use MiniMax / OpenRouter and other online models';

  @override
  String get modelAddCloud => 'Add Cloud Model';

  @override
  String get modelSettingsSubtitle =>
      'Local model · Cloud AI (MiniMax / OpenRouter / Claude)';

  @override
  String get cloudAITitle => 'Cloud AI Models';

  @override
  String get cloudAIAddModel => 'Add Model';

  @override
  String get cloudAIConfigured => 'Configured Models';

  @override
  String get cloudAIIntroDesc =>
      'Use MiniMax, OpenRouter, OpenAI, Claude, and other online models\nRequires your own API Key — encrypted and stored locally';

  @override
  String get cloudAIEmptyTitle => 'No cloud models configured';

  @override
  String get cloudAIEmptyHint => 'Tap the + button to add your first AI model';

  @override
  String get cloudAIDeleteTitle => 'Delete Configuration';

  @override
  String get cloudAIDeleteConfirm =>
      'Delete this AI configuration? The API Key will also be removed.';

  @override
  String get cloudAIEdit => 'Edit';

  @override
  String get cloudAIDelete => 'Delete';

  @override
  String get cloudAICancel => 'Cancel';

  @override
  String get cloudAIAddTitle => 'Add Cloud AI Model';

  @override
  String get cloudAIEditTitle => 'Edit Cloud AI Model';

  @override
  String get cloudAIProvider => 'Provider';

  @override
  String get cloudAIModelId => 'Model ID';

  @override
  String get cloudAIAdvancedOptions => 'Advanced Options';

  @override
  String get cloudAITestConnection => 'Test Connection';

  @override
  String get cloudAITesting => 'Testing...';

  @override
  String get cloudAISave => 'Save';

  @override
  String get cloudAISaving => 'Saving...';

  @override
  String get cloudAIConnectionSuccess => 'Connection successful';

  @override
  String get cloudAIConnectionFailed =>
      'Connection failed. Check your API Key and Model ID';

  @override
  String cloudAITestFailed(String error) {
    return 'Test failed: $error';
  }

  @override
  String cloudAISaveFailed(String error) {
    return 'Save failed: $error';
  }

  @override
  String get cloudAIEmptyFields => 'Model ID and API Key cannot be empty';

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
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsPrivacyPolicySubtitle => 'Learn how we protect your data';

  @override
  String get settingsTermsOfService => 'Terms of Service';

  @override
  String get settingsTermsOfServiceSubtitle =>
      'Usage terms and service agreement';

  @override
  String get settingsCrashLogs => 'Error Logs';

  @override
  String get settingsCrashLogsSubtitle => 'View app error records';

  @override
  String get settingsNoCrashLogs => 'No error logs';

  @override
  String get settingsCopiedToClipboard => 'Copied to clipboard';

  @override
  String get settingsCopyToClipboard => 'Copy to clipboard';

  @override
  String get settingsCopy => 'Copy';

  @override
  String get settingsClose => 'Close';

  @override
  String get settingsClearLogs => 'Clear Logs';

  @override
  String get settingsLogsCleared => 'Logs cleared';

  @override
  String get profileSettings => 'Settings';

  @override
  String get profileSettingsSubtitle => 'Language, data management, etc.';

  @override
  String get homeStatsTitle => 'Learning Stats';

  @override
  String get homeStatsSubtitle => 'View your learning progress and scores';

  @override
  String get importAddCourse => 'Add Course';

  @override
  String get importLocalFile => 'Local File';

  @override
  String get importUrlImport => 'URL Import';

  @override
  String get importFromLocalFile => 'Import from Local File';

  @override
  String get importFileHint => 'Select a .md / .markdown / .txt file';

  @override
  String get importSelectFile => 'Select File';

  @override
  String get importImporting => 'Importing...';

  @override
  String get importDownloadAndImport => 'Download & Import';

  @override
  String get importDownloading => 'Downloading...';

  @override
  String importSuccess(String name, int count) {
    return 'Import successful: $name ($count lessons)';
  }

  @override
  String importFileFailed(String error) {
    return 'File import failed: $error';
  }

  @override
  String get importInvalidUrl => 'Please enter a valid URL';

  @override
  String get importUrlMustStartWithHttp =>
      'URL must start with http:// or https://';

  @override
  String importUrlFailed(String error) {
    return 'URL import failed: $error';
  }

  @override
  String get importDeleteCourse => 'Delete Course';

  @override
  String importDeleteConfirm(String name) {
    return 'Delete \"$name\"? This cannot be undone.';
  }

  @override
  String get importCancel => 'Cancel';

  @override
  String get importDelete => 'Delete';

  @override
  String get importTemplateFormat => 'Question Bank Template';

  @override
  String get importCopyTemplate => 'Copy Template';

  @override
  String get importTemplateCopied => 'Template copied to clipboard';

  @override
  String get importHowToMake => 'How to create a question bank?';

  @override
  String get importHowToMakeDesc =>
      'Write questions in Markdown template format. Supports 4 types: multiple choice, fill-in-the-blank, sorting, and coding.';

  @override
  String get importViewTemplate => 'View Template';

  @override
  String get importImported => 'Imported';

  @override
  String importLessonCount(int count) {
    return '$count lessons';
  }

  @override
  String get importFromUrl => 'Import from URL';

  @override
  String get importUrlHint => 'Paste a Markdown document URL';

  @override
  String get importGithubAutoConvert =>
      'Supports auto-conversion of GitHub blob URLs to raw';

  @override
  String get importExampleUrl => 'Example URLs';

  @override
  String get importTemplateTooltip => 'Template Format';

  @override
  String get leaderboardTitle => 'Personal Leaderboard';

  @override
  String get leaderboardPersonalBest => 'Personal Best Records';

  @override
  String get leaderboardChallengeSelf => 'Challenge yourself, break records!';

  @override
  String get leaderboardPersonalRecords => 'Personal Records';

  @override
  String get leaderboardHallOfFame => 'Hall of Fame';

  @override
  String get leaderboardHighestXP => 'Highest Session XP';

  @override
  String get leaderboardLongestStreak => 'Longest Streak';

  @override
  String get leaderboardPerfectStreak => 'Consecutive Perfect Lessons';

  @override
  String get leaderboardFastestLesson => 'Fastest Lesson';

  @override
  String get leaderboardUnlockHint => 'Complete lessons to unlock records!';

  @override
  String leaderboardDays(int count) {
    return '$count days';
  }

  @override
  String leaderboardLessons(int count) {
    return '$count lessons';
  }

  @override
  String leaderboardMinSec(int min, int sec) {
    return '${min}m ${sec}s';
  }

  @override
  String leaderboardSec(int sec) {
    return '${sec}s';
  }

  @override
  String get achievementFirstStep => 'First Step';

  @override
  String get achievementFirstStepDesc => 'Complete your first lesson';

  @override
  String get achievementStreakMaster => 'Streak Master';

  @override
  String get achievementStreakMasterDesc => '7-day learning streak';

  @override
  String get achievementPerfectionist => 'Perfectionist';

  @override
  String get achievementPerfectionistDesc => 'Complete 10 Perfect lessons';

  @override
  String get achievementQuickLearner => 'Quick Learner';

  @override
  String get achievementQuickLearnerDesc =>
      'Answer 5 questions correctly in a row';

  @override
  String get dailyTaskLesson => 'Daily Lessons';

  @override
  String get dailyTaskLessonReward => '+30 XP + 1 Diamond';

  @override
  String get dailyTaskPerfect => 'Perfect';

  @override
  String get dailyTaskPerfectReward => '+20 XP';

  @override
  String get dailyTaskReview => 'Review';

  @override
  String get dailyTaskReviewReward => '+25 XP';

  @override
  String get dailyTaskEarlyBird => 'Early Bird';

  @override
  String get dailyTaskEarlyBirdReward => 'XP x1.5';

  @override
  String get aiModelNotLoaded =>
      'Local AI model not loaded. Using preset answers. Go to \"Profile → AI Model Management\" to download.';

  @override
  String get aiGoDownload => 'Download';

  @override
  String get notificationDailyTitle => 'Time to study!';

  @override
  String get notificationDailyBody => 'Keep your learning streak going 🔥';

  @override
  String get notificationStreakTitle => '⚠️ Streak about to break!';

  @override
  String notificationStreakBody(int hours) {
    return '$hours hours left to recover. Come study now!';
  }
}
