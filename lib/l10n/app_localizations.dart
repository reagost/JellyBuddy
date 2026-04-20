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

  /// No description provided for @homeNoNotifications.
  ///
  /// In zh, this message translates to:
  /// **'暂无新通知'**
  String get homeNoNotifications;

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

  /// No description provided for @lessonCodeHint.
  ///
  /// In zh, this message translates to:
  /// **'// 在这里写代码...'**
  String get lessonCodeHint;

  /// No description provided for @lessonCorrectAnswerLabel.
  ///
  /// In zh, this message translates to:
  /// **'正确答案：'**
  String get lessonCorrectAnswerLabel;

  /// No description provided for @lessonProgress.
  ///
  /// In zh, this message translates to:
  /// **'进度'**
  String get lessonProgress;

  /// No description provided for @lessonDifficultyEasy.
  ///
  /// In zh, this message translates to:
  /// **'简单'**
  String get lessonDifficultyEasy;

  /// No description provided for @lessonDifficultyMedium.
  ///
  /// In zh, this message translates to:
  /// **'中等'**
  String get lessonDifficultyMedium;

  /// No description provided for @lessonDifficultyHard.
  ///
  /// In zh, this message translates to:
  /// **'困难'**
  String get lessonDifficultyHard;

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

  /// No description provided for @profileEditName.
  ///
  /// In zh, this message translates to:
  /// **'修改用户名'**
  String get profileEditName;

  /// No description provided for @profileEditNameHint.
  ///
  /// In zh, this message translates to:
  /// **'输入新用户名'**
  String get profileEditNameHint;

  /// No description provided for @profileSave.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get profileSave;

  /// No description provided for @profileCancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get profileCancel;

  /// No description provided for @profileLeaderboard.
  ///
  /// In zh, this message translates to:
  /// **'个人排行榜'**
  String get profileLeaderboard;

  /// No description provided for @profileLeaderboardSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'查看个人最佳记录'**
  String get profileLeaderboardSubtitle;

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
  /// **'JellyBuddy'**
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
  /// **'你好！我是 JellyBuddy，你的编程学习助手。有什么问题想问我吗？'**
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
  /// **'JellyBuddy 随时帮你'**
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

  /// No description provided for @modelRetry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get modelRetry;

  /// No description provided for @modelSettingsTitle.
  ///
  /// In zh, this message translates to:
  /// **'模型设置'**
  String get modelSettingsTitle;

  /// No description provided for @modelLocalAI.
  ///
  /// In zh, this message translates to:
  /// **'本地 AI 模型'**
  String get modelLocalAI;

  /// No description provided for @modelLocalAISubtitle.
  ///
  /// In zh, this message translates to:
  /// **'离线推理 · 隐私优先'**
  String get modelLocalAISubtitle;

  /// No description provided for @modelLocalAIFree.
  ///
  /// In zh, this message translates to:
  /// **'离线推理 · 隐私优先 · 免费'**
  String get modelLocalAIFree;

  /// No description provided for @modelCloudAI.
  ///
  /// In zh, this message translates to:
  /// **'云端 AI 模型'**
  String get modelCloudAI;

  /// No description provided for @modelCloudAIProviders.
  ///
  /// In zh, this message translates to:
  /// **'MiniMax · OpenRouter · OpenAI · Claude · DeepSeek'**
  String get modelCloudAIProviders;

  /// No description provided for @modelManage.
  ///
  /// In zh, this message translates to:
  /// **'管理'**
  String get modelManage;

  /// No description provided for @modelCloudDisabled.
  ///
  /// In zh, this message translates to:
  /// **'已禁用云端 AI'**
  String get modelCloudDisabled;

  /// No description provided for @modelCloudSwitched.
  ///
  /// In zh, this message translates to:
  /// **'已切换到云端 AI'**
  String get modelCloudSwitched;

  /// No description provided for @modelInUse.
  ///
  /// In zh, this message translates to:
  /// **'使用中'**
  String get modelInUse;

  /// No description provided for @modelDisable.
  ///
  /// In zh, this message translates to:
  /// **'停用'**
  String get modelDisable;

  /// No description provided for @modelEnable.
  ///
  /// In zh, this message translates to:
  /// **'启用'**
  String get modelEnable;

  /// No description provided for @modelSetAsAssistant.
  ///
  /// In zh, this message translates to:
  /// **'设为 AI 助手使用'**
  String get modelSetAsAssistant;

  /// No description provided for @modelLoadHint.
  ///
  /// In zh, this message translates to:
  /// **'加载模型或配置云端 AI 获得智能回答'**
  String get modelLoadHint;

  /// No description provided for @modelInUseCloud.
  ///
  /// In zh, this message translates to:
  /// **'使用中: {provider}'**
  String modelInUseCloud(String provider);

  /// No description provided for @modelInUseLocal.
  ///
  /// In zh, this message translates to:
  /// **'使用中: 本地模型'**
  String get modelInUseLocal;

  /// No description provided for @modelNoCloudConfig.
  ///
  /// In zh, this message translates to:
  /// **'还没有配置云端模型'**
  String get modelNoCloudConfig;

  /// No description provided for @modelNoCloudConfigHint.
  ///
  /// In zh, this message translates to:
  /// **'添加你自己的 API Key，使用 MiniMax / OpenRouter 等在线模型'**
  String get modelNoCloudConfigHint;

  /// No description provided for @modelAddCloud.
  ///
  /// In zh, this message translates to:
  /// **'添加云端模型'**
  String get modelAddCloud;

  /// No description provided for @modelSettingsSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'本地模型 · 云端 AI (MiniMax / OpenRouter / Claude)'**
  String get modelSettingsSubtitle;

  /// No description provided for @cloudAITitle.
  ///
  /// In zh, this message translates to:
  /// **'云端 AI 模型'**
  String get cloudAITitle;

  /// No description provided for @cloudAIAddModel.
  ///
  /// In zh, this message translates to:
  /// **'添加模型'**
  String get cloudAIAddModel;

  /// No description provided for @cloudAIConfigured.
  ///
  /// In zh, this message translates to:
  /// **'已配置的模型'**
  String get cloudAIConfigured;

  /// No description provided for @cloudAIIntroDesc.
  ///
  /// In zh, this message translates to:
  /// **'使用 MiniMax、OpenRouter、OpenAI、Claude 等在线模型\n需要你自己的 API Key，密钥加密存储在设备本地'**
  String get cloudAIIntroDesc;

  /// No description provided for @cloudAIEmptyTitle.
  ///
  /// In zh, this message translates to:
  /// **'暂无配置的云端模型'**
  String get cloudAIEmptyTitle;

  /// No description provided for @cloudAIEmptyHint.
  ///
  /// In zh, this message translates to:
  /// **'点击右下角 + 添加你的第一个 AI 模型'**
  String get cloudAIEmptyHint;

  /// No description provided for @cloudAIDeleteTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除配置'**
  String get cloudAIDeleteTitle;

  /// No description provided for @cloudAIDeleteConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确认删除此 AI 配置？API Key 也会一并删除。'**
  String get cloudAIDeleteConfirm;

  /// No description provided for @cloudAIEdit.
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get cloudAIEdit;

  /// No description provided for @cloudAIDelete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get cloudAIDelete;

  /// No description provided for @cloudAICancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cloudAICancel;

  /// No description provided for @cloudAIAddTitle.
  ///
  /// In zh, this message translates to:
  /// **'添加云端 AI 模型'**
  String get cloudAIAddTitle;

  /// No description provided for @cloudAIEditTitle.
  ///
  /// In zh, this message translates to:
  /// **'编辑云端 AI 模型'**
  String get cloudAIEditTitle;

  /// No description provided for @cloudAIProvider.
  ///
  /// In zh, this message translates to:
  /// **'提供商'**
  String get cloudAIProvider;

  /// No description provided for @cloudAIModelId.
  ///
  /// In zh, this message translates to:
  /// **'模型 ID'**
  String get cloudAIModelId;

  /// No description provided for @cloudAIAdvancedOptions.
  ///
  /// In zh, this message translates to:
  /// **'高级选项'**
  String get cloudAIAdvancedOptions;

  /// No description provided for @cloudAITestConnection.
  ///
  /// In zh, this message translates to:
  /// **'测试连接'**
  String get cloudAITestConnection;

  /// No description provided for @cloudAITesting.
  ///
  /// In zh, this message translates to:
  /// **'测试中...'**
  String get cloudAITesting;

  /// No description provided for @cloudAISave.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get cloudAISave;

  /// No description provided for @cloudAISaving.
  ///
  /// In zh, this message translates to:
  /// **'保存中...'**
  String get cloudAISaving;

  /// No description provided for @cloudAIConnectionSuccess.
  ///
  /// In zh, this message translates to:
  /// **'连接成功'**
  String get cloudAIConnectionSuccess;

  /// No description provided for @cloudAIConnectionFailed.
  ///
  /// In zh, this message translates to:
  /// **'连接失败，请检查 API Key 和模型 ID'**
  String get cloudAIConnectionFailed;

  /// No description provided for @cloudAITestFailed.
  ///
  /// In zh, this message translates to:
  /// **'测试失败: {error}'**
  String cloudAITestFailed(String error);

  /// No description provided for @cloudAISaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'保存失败: {error}'**
  String cloudAISaveFailed(String error);

  /// No description provided for @cloudAIEmptyFields.
  ///
  /// In zh, this message translates to:
  /// **'模型 ID 和 API Key 不能为空'**
  String get cloudAIEmptyFields;

  /// No description provided for @settingsTitle.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settingsTitle;

  /// No description provided for @settingsGeneral.
  ///
  /// In zh, this message translates to:
  /// **'通用'**
  String get settingsGeneral;

  /// No description provided for @settingsLanguage.
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'切换应用显示语言'**
  String get settingsLanguageSubtitle;

  /// No description provided for @settingsDarkMode.
  ///
  /// In zh, this message translates to:
  /// **'深色模式'**
  String get settingsDarkMode;

  /// No description provided for @settingsDarkModeSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'切换深色/浅色主题'**
  String get settingsDarkModeSubtitle;

  /// No description provided for @settingsLearning.
  ///
  /// In zh, this message translates to:
  /// **'学习'**
  String get settingsLearning;

  /// No description provided for @settingsResetProgress.
  ///
  /// In zh, this message translates to:
  /// **'重置学习进度'**
  String get settingsResetProgress;

  /// No description provided for @settingsResetProgressSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'清除所有课程进度和成绩'**
  String get settingsResetProgressSubtitle;

  /// No description provided for @settingsResetProgressConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定要重置所有学习进度吗？此操作不可撤销。'**
  String get settingsResetProgressConfirm;

  /// No description provided for @settingsResetProgressDone.
  ///
  /// In zh, this message translates to:
  /// **'学习进度已重置'**
  String get settingsResetProgressDone;

  /// No description provided for @settingsExportProgress.
  ///
  /// In zh, this message translates to:
  /// **'导出学习进度'**
  String get settingsExportProgress;

  /// No description provided for @settingsExportProgressSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'导出你的学习数据'**
  String get settingsExportProgressSubtitle;

  /// No description provided for @settingsComingSoon.
  ///
  /// In zh, this message translates to:
  /// **'即将推出'**
  String get settingsComingSoon;

  /// No description provided for @settingsAbout.
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get settingsAbout;

  /// No description provided for @settingsVersion.
  ///
  /// In zh, this message translates to:
  /// **'应用版本'**
  String get settingsVersion;

  /// No description provided for @settingsSlogan.
  ///
  /// In zh, this message translates to:
  /// **'AI 驱动游戏化学习'**
  String get settingsSlogan;

  /// No description provided for @settingsLicenses.
  ///
  /// In zh, this message translates to:
  /// **'开源许可证'**
  String get settingsLicenses;

  /// No description provided for @settingsLicensesSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'查看第三方库许可证'**
  String get settingsLicensesSubtitle;

  /// No description provided for @settingsGithub.
  ///
  /// In zh, this message translates to:
  /// **'GitHub'**
  String get settingsGithub;

  /// No description provided for @settingsGithubUrl.
  ///
  /// In zh, this message translates to:
  /// **'https://github.com/user/JellyBuddy'**
  String get settingsGithubUrl;

  /// No description provided for @settingsDangerZone.
  ///
  /// In zh, this message translates to:
  /// **'危险操作'**
  String get settingsDangerZone;

  /// No description provided for @settingsClearAllData.
  ///
  /// In zh, this message translates to:
  /// **'清除所有数据'**
  String get settingsClearAllData;

  /// No description provided for @settingsClearAllDataSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'恢复出厂设置，删除所有数据'**
  String get settingsClearAllDataSubtitle;

  /// No description provided for @settingsClearAllDataConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定要清除所有数据吗？这将删除所有学习进度、设置和缓存。此操作不可撤销。'**
  String get settingsClearAllDataConfirm;

  /// No description provided for @settingsClearAllDataDone.
  ///
  /// In zh, this message translates to:
  /// **'所有数据已清除'**
  String get settingsClearAllDataDone;

  /// No description provided for @settingsCancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get settingsCancel;

  /// No description provided for @settingsConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get settingsConfirm;

  /// No description provided for @settingsReset.
  ///
  /// In zh, this message translates to:
  /// **'重置'**
  String get settingsReset;

  /// No description provided for @settingsClearAll.
  ///
  /// In zh, this message translates to:
  /// **'清除全部'**
  String get settingsClearAll;

  /// No description provided for @settingsLanguageZh.
  ///
  /// In zh, this message translates to:
  /// **'中文'**
  String get settingsLanguageZh;

  /// No description provided for @settingsLanguageEn.
  ///
  /// In zh, this message translates to:
  /// **'English'**
  String get settingsLanguageEn;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In zh, this message translates to:
  /// **'隐私政策'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsPrivacyPolicySubtitle.
  ///
  /// In zh, this message translates to:
  /// **'了解我们如何保护你的数据'**
  String get settingsPrivacyPolicySubtitle;

  /// No description provided for @settingsTermsOfService.
  ///
  /// In zh, this message translates to:
  /// **'用户服务协议'**
  String get settingsTermsOfService;

  /// No description provided for @settingsTermsOfServiceSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'使用条款和服务协议'**
  String get settingsTermsOfServiceSubtitle;

  /// No description provided for @settingsCrashLogs.
  ///
  /// In zh, this message translates to:
  /// **'错误日志'**
  String get settingsCrashLogs;

  /// No description provided for @settingsCrashLogsSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'查看应用错误记录'**
  String get settingsCrashLogsSubtitle;

  /// No description provided for @settingsNoCrashLogs.
  ///
  /// In zh, this message translates to:
  /// **'暂无错误日志'**
  String get settingsNoCrashLogs;

  /// No description provided for @settingsCopiedToClipboard.
  ///
  /// In zh, this message translates to:
  /// **'已复制到剪贴板'**
  String get settingsCopiedToClipboard;

  /// No description provided for @settingsCopyToClipboard.
  ///
  /// In zh, this message translates to:
  /// **'复制到剪贴板'**
  String get settingsCopyToClipboard;

  /// No description provided for @settingsCopy.
  ///
  /// In zh, this message translates to:
  /// **'复制'**
  String get settingsCopy;

  /// No description provided for @settingsClose.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get settingsClose;

  /// No description provided for @settingsClearLogs.
  ///
  /// In zh, this message translates to:
  /// **'清除日志'**
  String get settingsClearLogs;

  /// No description provided for @settingsLogsCleared.
  ///
  /// In zh, this message translates to:
  /// **'日志已清除'**
  String get settingsLogsCleared;

  /// No description provided for @profileSettings.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get profileSettings;

  /// No description provided for @profileSettingsSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'语言、数据管理等'**
  String get profileSettingsSubtitle;

  /// No description provided for @homeStatsTitle.
  ///
  /// In zh, this message translates to:
  /// **'学习统计'**
  String get homeStatsTitle;

  /// No description provided for @homeStatsSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'查看你的学习进度和成绩'**
  String get homeStatsSubtitle;

  /// No description provided for @importAddCourse.
  ///
  /// In zh, this message translates to:
  /// **'添加课程'**
  String get importAddCourse;

  /// No description provided for @importLocalFile.
  ///
  /// In zh, this message translates to:
  /// **'本地文件'**
  String get importLocalFile;

  /// No description provided for @importUrlImport.
  ///
  /// In zh, this message translates to:
  /// **'URL 导入'**
  String get importUrlImport;

  /// No description provided for @importFromLocalFile.
  ///
  /// In zh, this message translates to:
  /// **'从本地文件导入'**
  String get importFromLocalFile;

  /// No description provided for @importFileHint.
  ///
  /// In zh, this message translates to:
  /// **'选择一个 .md / .markdown / .txt 文件'**
  String get importFileHint;

  /// No description provided for @importSelectFile.
  ///
  /// In zh, this message translates to:
  /// **'选择文件'**
  String get importSelectFile;

  /// No description provided for @importImporting.
  ///
  /// In zh, this message translates to:
  /// **'导入中...'**
  String get importImporting;

  /// No description provided for @importDownloadAndImport.
  ///
  /// In zh, this message translates to:
  /// **'下载并导入'**
  String get importDownloadAndImport;

  /// No description provided for @importDownloading.
  ///
  /// In zh, this message translates to:
  /// **'下载中...'**
  String get importDownloading;

  /// No description provided for @importSuccess.
  ///
  /// In zh, this message translates to:
  /// **'导入成功: {name}（{count} 课）'**
  String importSuccess(String name, int count);

  /// No description provided for @importFileFailed.
  ///
  /// In zh, this message translates to:
  /// **'文件导入失败: {error}'**
  String importFileFailed(String error);

  /// No description provided for @importInvalidUrl.
  ///
  /// In zh, this message translates to:
  /// **'请输入有效的 URL'**
  String get importInvalidUrl;

  /// No description provided for @importUrlMustStartWithHttp.
  ///
  /// In zh, this message translates to:
  /// **'URL 必须以 http:// 或 https:// 开头'**
  String get importUrlMustStartWithHttp;

  /// No description provided for @importUrlFailed.
  ///
  /// In zh, this message translates to:
  /// **'URL 导入失败: {error}'**
  String importUrlFailed(String error);

  /// No description provided for @importDeleteCourse.
  ///
  /// In zh, this message translates to:
  /// **'删除课程'**
  String get importDeleteCourse;

  /// No description provided for @importDeleteConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定删除「{name}」？此操作不可恢复。'**
  String importDeleteConfirm(String name);

  /// No description provided for @importCancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get importCancel;

  /// No description provided for @importDelete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get importDelete;

  /// No description provided for @importTemplateFormat.
  ///
  /// In zh, this message translates to:
  /// **'题库模版格式'**
  String get importTemplateFormat;

  /// No description provided for @importCopyTemplate.
  ///
  /// In zh, this message translates to:
  /// **'复制模版'**
  String get importCopyTemplate;

  /// No description provided for @importTemplateCopied.
  ///
  /// In zh, this message translates to:
  /// **'模版已复制到剪贴板'**
  String get importTemplateCopied;

  /// No description provided for @importHowToMake.
  ///
  /// In zh, this message translates to:
  /// **'如何制作题库？'**
  String get importHowToMake;

  /// No description provided for @importHowToMakeDesc.
  ///
  /// In zh, this message translates to:
  /// **'按照 Markdown 模版格式编写题目，支持选择题、填空题、排序题、编程题 4 种类型。'**
  String get importHowToMakeDesc;

  /// No description provided for @importViewTemplate.
  ///
  /// In zh, this message translates to:
  /// **'查看模版格式'**
  String get importViewTemplate;

  /// No description provided for @importImported.
  ///
  /// In zh, this message translates to:
  /// **'已导入'**
  String get importImported;

  /// No description provided for @importLessonCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 课'**
  String importLessonCount(int count);

  /// No description provided for @importFromUrl.
  ///
  /// In zh, this message translates to:
  /// **'从 URL 导入'**
  String get importFromUrl;

  /// No description provided for @importUrlHint.
  ///
  /// In zh, this message translates to:
  /// **'粘贴一个 Markdown 文档的 URL'**
  String get importUrlHint;

  /// No description provided for @importGithubAutoConvert.
  ///
  /// In zh, this message translates to:
  /// **'支持 GitHub blob URL 自动转换为 raw'**
  String get importGithubAutoConvert;

  /// No description provided for @importExampleUrl.
  ///
  /// In zh, this message translates to:
  /// **'示例 URL'**
  String get importExampleUrl;

  /// No description provided for @importTemplateTooltip.
  ///
  /// In zh, this message translates to:
  /// **'模版格式'**
  String get importTemplateTooltip;

  /// No description provided for @leaderboardTitle.
  ///
  /// In zh, this message translates to:
  /// **'个人排行榜'**
  String get leaderboardTitle;

  /// No description provided for @leaderboardPersonalBest.
  ///
  /// In zh, this message translates to:
  /// **'个人最佳记录'**
  String get leaderboardPersonalBest;

  /// No description provided for @leaderboardChallengeSelf.
  ///
  /// In zh, this message translates to:
  /// **'挑战自己，刷新记录！'**
  String get leaderboardChallengeSelf;

  /// No description provided for @leaderboardPersonalRecords.
  ///
  /// In zh, this message translates to:
  /// **'Personal Records'**
  String get leaderboardPersonalRecords;

  /// No description provided for @leaderboardHallOfFame.
  ///
  /// In zh, this message translates to:
  /// **'Hall of Fame'**
  String get leaderboardHallOfFame;

  /// No description provided for @leaderboardHighestXP.
  ///
  /// In zh, this message translates to:
  /// **'单次最高XP'**
  String get leaderboardHighestXP;

  /// No description provided for @leaderboardLongestStreak.
  ///
  /// In zh, this message translates to:
  /// **'最长连续天数'**
  String get leaderboardLongestStreak;

  /// No description provided for @leaderboardPerfectStreak.
  ///
  /// In zh, this message translates to:
  /// **'连续满分课程'**
  String get leaderboardPerfectStreak;

  /// No description provided for @leaderboardFastestLesson.
  ///
  /// In zh, this message translates to:
  /// **'最快完成课程'**
  String get leaderboardFastestLesson;

  /// No description provided for @leaderboardUnlockHint.
  ///
  /// In zh, this message translates to:
  /// **'完成课程来解锁记录！'**
  String get leaderboardUnlockHint;

  /// No description provided for @leaderboardDays.
  ///
  /// In zh, this message translates to:
  /// **'{count} 天'**
  String leaderboardDays(int count);

  /// No description provided for @leaderboardLessons.
  ///
  /// In zh, this message translates to:
  /// **'{count} 课'**
  String leaderboardLessons(int count);

  /// No description provided for @leaderboardMinSec.
  ///
  /// In zh, this message translates to:
  /// **'{min}分{sec}秒'**
  String leaderboardMinSec(int min, int sec);

  /// No description provided for @leaderboardSec.
  ///
  /// In zh, this message translates to:
  /// **'{sec}秒'**
  String leaderboardSec(int sec);

  /// No description provided for @achievementFirstStep.
  ///
  /// In zh, this message translates to:
  /// **'第一步'**
  String get achievementFirstStep;

  /// No description provided for @achievementFirstStepDesc.
  ///
  /// In zh, this message translates to:
  /// **'完成第一个关卡'**
  String get achievementFirstStepDesc;

  /// No description provided for @achievementStreakMaster.
  ///
  /// In zh, this message translates to:
  /// **'连续大师'**
  String get achievementStreakMaster;

  /// No description provided for @achievementStreakMasterDesc.
  ///
  /// In zh, this message translates to:
  /// **'7天连续学习'**
  String get achievementStreakMasterDesc;

  /// No description provided for @achievementPerfectionist.
  ///
  /// In zh, this message translates to:
  /// **'完美主义者'**
  String get achievementPerfectionist;

  /// No description provided for @achievementPerfectionistDesc.
  ///
  /// In zh, this message translates to:
  /// **'完成10个 Perfect 关卡'**
  String get achievementPerfectionistDesc;

  /// No description provided for @achievementQuickLearner.
  ///
  /// In zh, this message translates to:
  /// **'快速学习者'**
  String get achievementQuickLearner;

  /// No description provided for @achievementQuickLearnerDesc.
  ///
  /// In zh, this message translates to:
  /// **'连续答对5题'**
  String get achievementQuickLearnerDesc;

  /// No description provided for @dailyTaskLesson.
  ///
  /// In zh, this message translates to:
  /// **'日课'**
  String get dailyTaskLesson;

  /// No description provided for @dailyTaskLessonReward.
  ///
  /// In zh, this message translates to:
  /// **'+30 XP + 1 钻石'**
  String get dailyTaskLessonReward;

  /// No description provided for @dailyTaskPerfect.
  ///
  /// In zh, this message translates to:
  /// **'完美'**
  String get dailyTaskPerfect;

  /// No description provided for @dailyTaskPerfectReward.
  ///
  /// In zh, this message translates to:
  /// **'+20 XP'**
  String get dailyTaskPerfectReward;

  /// No description provided for @dailyTaskReview.
  ///
  /// In zh, this message translates to:
  /// **'复习'**
  String get dailyTaskReview;

  /// No description provided for @dailyTaskReviewReward.
  ///
  /// In zh, this message translates to:
  /// **'+25 XP'**
  String get dailyTaskReviewReward;

  /// No description provided for @dailyTaskEarlyBird.
  ///
  /// In zh, this message translates to:
  /// **'晨鸟'**
  String get dailyTaskEarlyBird;

  /// No description provided for @dailyTaskEarlyBirdReward.
  ///
  /// In zh, this message translates to:
  /// **'XP x1.5'**
  String get dailyTaskEarlyBirdReward;

  /// No description provided for @aiModelNotLoaded.
  ///
  /// In zh, this message translates to:
  /// **'本地 AI 模型未加载，当前使用预设答案。前往「我的 → AI 模型管理」下载模型。'**
  String get aiModelNotLoaded;

  /// No description provided for @aiGoDownload.
  ///
  /// In zh, this message translates to:
  /// **'去下载'**
  String get aiGoDownload;

  /// No description provided for @notificationDailyTitle.
  ///
  /// In zh, this message translates to:
  /// **'该学习啦！'**
  String get notificationDailyTitle;

  /// No description provided for @notificationDailyBody.
  ///
  /// In zh, this message translates to:
  /// **'保持你的连续学习记录 🔥'**
  String get notificationDailyBody;

  /// No description provided for @notificationStreakTitle.
  ///
  /// In zh, this message translates to:
  /// **'⚠️ 连击即将断裂！'**
  String get notificationStreakTitle;

  /// No description provided for @notificationStreakBody.
  ///
  /// In zh, this message translates to:
  /// **'还有 {hours} 小时恢复时间，快来学习吧'**
  String notificationStreakBody(int hours);
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
