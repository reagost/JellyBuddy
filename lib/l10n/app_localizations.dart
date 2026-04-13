import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In zh, this message translates to:
  /// **'JellyBuddy'**
  String get appTitle;

  /// No description provided for @tabHome.
  ///
  /// In zh, this message translates to:
  /// **'首页'**
  String get tabHome;

  /// No description provided for @tabCourses.
  ///
  /// In zh, this message translates to:
  /// **'课程'**
  String get tabCourses;

  /// No description provided for @tabAITutor.
  ///
  /// In zh, this message translates to:
  /// **'AI 助手'**
  String get tabAITutor;

  /// No description provided for @tabProfile.
  ///
  /// In zh, this message translates to:
  /// **'我的'**
  String get tabProfile;

  /// No description provided for @splashSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'AI 驱动游戏化学习'**
  String get splashSubtitle;

  /// No description provided for @homeStreakDays.
  ///
  /// In zh, this message translates to:
  /// **'连续学习 {days} 天'**
  String homeStreakDays(int days);

  /// No description provided for @homeStartLearning.
  ///
  /// In zh, this message translates to:
  /// **'选择一个关卡开始学习！'**
  String get homeStartLearning;

  /// No description provided for @homeDailyTasks.
  ///
  /// In zh, this message translates to:
  /// **'今日任务'**
  String get homeDailyTasks;

  /// No description provided for @homePythonLessons.
  ///
  /// In zh, this message translates to:
  /// **'Python 关卡'**
  String get homePythonLessons;

  /// No description provided for @homeReviewBook.
  ///
  /// In zh, this message translates to:
  /// **'错题本'**
  String get homeReviewBook;

  /// No description provided for @homeReviewSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'复习做错的题目，巩固知识点'**
  String get homeReviewSubtitle;

  /// No description provided for @homeHeartsRecovering.
  ///
  /// In zh, this message translates to:
  /// **'生命值恢复中...'**
  String get homeHeartsRecovering;

  /// No description provided for @homeRecoverySoon.
  ///
  /// In zh, this message translates to:
  /// **'即将恢复'**
  String get homeRecoverySoon;

  /// No description provided for @homeRecoveryTime.
  ///
  /// In zh, this message translates to:
  /// **'预计 {hours} 小时 {minutes} 分钟后恢复 1 颗生命'**
  String homeRecoveryTime(int hours, int minutes);

  /// No description provided for @homeRecoveryMinutes.
  ///
  /// In zh, this message translates to:
  /// **'预计 {minutes} 分钟后恢复 1 颗生命'**
  String homeRecoveryMinutes(int minutes);

  /// No description provided for @homeFailedToLoadCourse.
  ///
  /// In zh, this message translates to:
  /// **'课程数据加载失败'**
  String get homeFailedToLoadCourse;

  /// No description provided for @homeLessonQuestions.
  ///
  /// In zh, this message translates to:
  /// **'{count} 题  +{xp} XP'**
  String homeLessonQuestions(int count, int xp);

  /// No description provided for @homeLessonResult.
  ///
  /// In zh, this message translates to:
  /// **'{score}%  {correct}/{total} 正确  +{xp} XP'**
  String homeLessonResult(int score, int correct, int total, int xp);

  /// No description provided for @lessonConfirmAnswer.
  ///
  /// In zh, this message translates to:
  /// **'确认答案'**
  String get lessonConfirmAnswer;

  /// No description provided for @lessonNextQuestion.
  ///
  /// In zh, this message translates to:
  /// **'下一题'**
  String get lessonNextQuestion;

  /// No description provided for @lessonComplete.
  ///
  /// In zh, this message translates to:
  /// **'完成'**
  String get lessonComplete;

  /// No description provided for @lessonCorrect.
  ///
  /// In zh, this message translates to:
  /// **'正确！'**
  String get lessonCorrect;

  /// No description provided for @lessonIncorrect.
  ///
  /// In zh, this message translates to:
  /// **'错误'**
  String get lessonIncorrect;

  /// No description provided for @lessonExplanation.
  ///
  /// In zh, this message translates to:
  /// **'解析'**
  String get lessonExplanation;

  /// No description provided for @lessonHeartsEmpty.
  ///
  /// In zh, this message translates to:
  /// **'生命值耗尽'**
  String get lessonHeartsEmpty;

  /// No description provided for @lessonAskAI.
  ///
  /// In zh, this message translates to:
  /// **'求助 AI'**
  String get lessonAskAI;

  /// No description provided for @lessonInputHint.
  ///
  /// In zh, this message translates to:
  /// **'输入你的答案...'**
  String get lessonInputHint;

  /// No description provided for @lessonDragToSort.
  ///
  /// In zh, this message translates to:
  /// **'拖动调整顺序'**
  String get lessonDragToSort;

  /// No description provided for @lessonCorrectOrder.
  ///
  /// In zh, this message translates to:
  /// **'正确顺序:'**
  String get lessonCorrectOrder;

  /// No description provided for @lessonCorrectAnswer.
  ///
  /// In zh, this message translates to:
  /// **'正确答案: {answer}'**
  String lessonCorrectAnswer(String answer);

  /// No description provided for @lessonBossChallenge.
  ///
  /// In zh, this message translates to:
  /// **'BOSS 挑战'**
  String get lessonBossChallenge;

  /// No description provided for @lessonExitTitle.
  ///
  /// In zh, this message translates to:
  /// **'退出关卡？'**
  String get lessonExitTitle;

  /// No description provided for @lessonExitContent.
  ///
  /// In zh, this message translates to:
  /// **'退出将不会获得任何奖励，继续挑战吗？'**
  String get lessonExitContent;

  /// No description provided for @lessonContinueChallenge.
  ///
  /// In zh, this message translates to:
  /// **'继续挑战'**
  String get lessonContinueChallenge;

  /// No description provided for @lessonExit.
  ///
  /// In zh, this message translates to:
  /// **'退出'**
  String get lessonExit;

  /// No description provided for @lessonReturnHome.
  ///
  /// In zh, this message translates to:
  /// **'返回首页'**
  String get lessonReturnHome;

  /// No description provided for @lessonHeartsDepletedMsg.
  ///
  /// In zh, this message translates to:
  /// **'你的生命值已用完，需要等待恢复。每 {hours} 小时恢复 1 颗生命。'**
  String lessonHeartsDepletedMsg(int hours);

  /// No description provided for @lessonChallengeFailed.
  ///
  /// In zh, this message translates to:
  /// **'挑战失败'**
  String get lessonChallengeFailed;

  /// No description provided for @lessonBossSuccess.
  ///
  /// In zh, this message translates to:
  /// **'BOSS 挑战成功！'**
  String get lessonBossSuccess;

  /// No description provided for @lessonPerfectClear.
  ///
  /// In zh, this message translates to:
  /// **'完美通关！'**
  String get lessonPerfectClear;

  /// No description provided for @lessonCongrats.
  ///
  /// In zh, this message translates to:
  /// **'恭喜完成！'**
  String get lessonCongrats;

  /// No description provided for @lessonNeedReview.
  ///
  /// In zh, this message translates to:
  /// **'需要重新学习本章节'**
  String get lessonNeedReview;

  /// No description provided for @lessonScoreResult.
  ///
  /// In zh, this message translates to:
  /// **'{correct}/{total} 正确  ({score}%)'**
  String lessonScoreResult(int correct, int total, int score);

  /// No description provided for @lessonReturnReview.
  ///
  /// In zh, this message translates to:
  /// **'返回复习'**
  String get lessonReturnReview;

  /// No description provided for @lessonContinue.
  ///
  /// In zh, this message translates to:
  /// **'继续'**
  String get lessonContinue;

  /// No description provided for @lessonStatLife.
  ///
  /// In zh, this message translates to:
  /// **'生命'**
  String get lessonStatLife;

  /// No description provided for @lessonStatDiamond.
  ///
  /// In zh, this message translates to:
  /// **'钻石'**
  String get lessonStatDiamond;

  /// No description provided for @lessonAchievementUnlocked.
  ///
  /// In zh, this message translates to:
  /// **'成就解锁：{name}'**
  String lessonAchievementUnlocked(String name);

  /// No description provided for @profileLevelProgress.
  ///
  /// In zh, this message translates to:
  /// **'升级进度'**
  String get profileLevelProgress;

  /// No description provided for @profileAchievements.
  ///
  /// In zh, this message translates to:
  /// **'成就'**
  String get profileAchievements;

  /// No description provided for @profileAIModelManagement.
  ///
  /// In zh, this message translates to:
  /// **'AI 模型管理'**
  String get profileAIModelManagement;

  /// No description provided for @profileAIModelSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'下载、加载本地大模型'**
  String get profileAIModelSubtitle;

  /// No description provided for @profileStreakDays.
  ///
  /// In zh, this message translates to:
  /// **'连击天数'**
  String get profileStreakDays;

  /// No description provided for @profileDiamonds.
  ///
  /// In zh, this message translates to:
  /// **'钻石'**
  String get profileDiamonds;

  /// No description provided for @profileHearts.
  ///
  /// In zh, this message translates to:
  /// **'生命值'**
  String get profileHearts;

  /// No description provided for @modelManagementTitle.
  ///
  /// In zh, this message translates to:
  /// **'AI 模型管理'**
  String get modelManagementTitle;

  /// No description provided for @modelAvailable.
  ///
  /// In zh, this message translates to:
  /// **'可用模型'**
  String get modelAvailable;

  /// No description provided for @modelNoModels.
  ///
  /// In zh, this message translates to:
  /// **'暂无可用模型'**
  String get modelNoModels;

  /// No description provided for @modelInferenceEngine.
  ///
  /// In zh, this message translates to:
  /// **'AI 推理引擎'**
  String get modelInferenceEngine;

  /// No description provided for @modelReady.
  ///
  /// In zh, this message translates to:
  /// **'模型已就绪'**
  String get modelReady;

  /// No description provided for @modelLoading.
  ///
  /// In zh, this message translates to:
  /// **'正在加载模型...'**
  String get modelLoading;

  /// No description provided for @modelDownloading.
  ///
  /// In zh, this message translates to:
  /// **'正在下载模型...'**
  String get modelDownloading;

  /// No description provided for @modelGenerating.
  ///
  /// In zh, this message translates to:
  /// **'正在生成回答...'**
  String get modelGenerating;

  /// No description provided for @modelError.
  ///
  /// In zh, this message translates to:
  /// **'模型加载失败'**
  String get modelError;

  /// No description provided for @modelUninitialized.
  ///
  /// In zh, this message translates to:
  /// **'未加载模型'**
  String get modelUninitialized;

  /// No description provided for @modelDownloadProgress.
  ///
  /// In zh, this message translates to:
  /// **'下载中: {percent}'**
  String modelDownloadProgress(String percent);

  /// No description provided for @modelCurrentFile.
  ///
  /// In zh, this message translates to:
  /// **'当前文件: {file}'**
  String modelCurrentFile(String file);

  /// No description provided for @modelDownloadSource.
  ///
  /// In zh, this message translates to:
  /// **'下载源: {source}'**
  String modelDownloadSource(String source);

  /// No description provided for @modelCancelDownload.
  ///
  /// In zh, this message translates to:
  /// **'取消下载'**
  String get modelCancelDownload;

  /// No description provided for @modelDownloadButton.
  ///
  /// In zh, this message translates to:
  /// **'下载'**
  String get modelDownloadButton;

  /// No description provided for @modelLoadButton.
  ///
  /// In zh, this message translates to:
  /// **'加载'**
  String get modelLoadButton;

  /// No description provided for @modelUnloadButton.
  ///
  /// In zh, this message translates to:
  /// **'卸载'**
  String get modelUnloadButton;

  /// No description provided for @modelLoaded.
  ///
  /// In zh, this message translates to:
  /// **'已加载'**
  String get modelLoaded;

  /// No description provided for @coursesTitle.
  ///
  /// In zh, this message translates to:
  /// **'全部课程'**
  String get coursesTitle;

  /// No description provided for @coursesNoCourses.
  ///
  /// In zh, this message translates to:
  /// **'暂无课程'**
  String get coursesNoCourses;

  /// No description provided for @coursesLessonCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个关卡'**
  String coursesLessonCount(int count);

  /// No description provided for @reviewTitle.
  ///
  /// In zh, this message translates to:
  /// **'错题本'**
  String get reviewTitle;

  /// No description provided for @reviewEmpty.
  ///
  /// In zh, this message translates to:
  /// **'没有错题，继续保持！'**
  String get reviewEmpty;

  /// No description provided for @reviewEmptySubtitle.
  ///
  /// In zh, this message translates to:
  /// **'完成更多关卡来检验你的学习成果'**
  String get reviewEmptySubtitle;

  /// No description provided for @reviewCorrectAnswer.
  ///
  /// In zh, this message translates to:
  /// **'正确答案'**
  String get reviewCorrectAnswer;

  /// No description provided for @reviewDifficultyEasy.
  ///
  /// In zh, this message translates to:
  /// **'简单'**
  String get reviewDifficultyEasy;

  /// No description provided for @reviewDifficultyMedium.
  ///
  /// In zh, this message translates to:
  /// **'中等'**
  String get reviewDifficultyMedium;

  /// No description provided for @reviewDifficultyHard.
  ///
  /// In zh, this message translates to:
  /// **'困难'**
  String get reviewDifficultyHard;

  /// No description provided for @aiTutorTitle.
  ///
  /// In zh, this message translates to:
  /// **'Code Buddy'**
  String get aiTutorTitle;

  /// No description provided for @aiTutorClearChat.
  ///
  /// In zh, this message translates to:
  /// **'清空对话'**
  String get aiTutorClearChat;

  /// No description provided for @aiTutorClearConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定要清空所有聊天记录吗？'**
  String get aiTutorClearConfirm;

  /// No description provided for @aiTutorCancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get aiTutorCancel;

  /// No description provided for @aiTutorClear.
  ///
  /// In zh, this message translates to:
  /// **'清空'**
  String get aiTutorClear;

  /// No description provided for @aiTutorWelcome.
  ///
  /// In zh, this message translates to:
  /// **'你好！我是 Code Buddy，你的编程学习助手。有什么问题想问我吗？'**
  String get aiTutorWelcome;

  /// No description provided for @aiTutorInputHint.
  ///
  /// In zh, this message translates to:
  /// **'输入你的问题...'**
  String get aiTutorInputHint;

  /// No description provided for @onboardingSkip.
  ///
  /// In zh, this message translates to:
  /// **'跳过'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In zh, this message translates to:
  /// **'下一步'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In zh, this message translates to:
  /// **'开始学习'**
  String get onboardingStart;

  /// No description provided for @onboardingTitle1.
  ///
  /// In zh, this message translates to:
  /// **'像玩游戏一样学编程'**
  String get onboardingTitle1;

  /// No description provided for @onboardingSubtitle1.
  ///
  /// In zh, this message translates to:
  /// **'闯关、答题、赚经验值，让学习变得有趣'**
  String get onboardingSubtitle1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In zh, this message translates to:
  /// **'Code Buddy 随时帮你'**
  String get onboardingTitle2;

  /// No description provided for @onboardingSubtitle2.
  ///
  /// In zh, this message translates to:
  /// **'遇到难题？AI 助手为你分步讲解'**
  String get onboardingSubtitle2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In zh, this message translates to:
  /// **'随时随地，无需网络'**
  String get onboardingTitle3;

  /// No description provided for @onboardingSubtitle3.
  ///
  /// In zh, this message translates to:
  /// **'本地 AI 模型，保护隐私，离线学习'**
  String get onboardingSubtitle3;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
