// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'JellyBuddy';

  @override
  String get tabHome => '首页';

  @override
  String get tabCourses => '课程';

  @override
  String get tabAITutor => 'AI 助手';

  @override
  String get tabProfile => '我的';

  @override
  String get splashSubtitle => 'AI 驱动游戏化学习';

  @override
  String homeStreakDays(int days) {
    return '连续学习 $days 天';
  }

  @override
  String get homeStartLearning => '选择一个关卡开始学习！';

  @override
  String get homeDailyTasks => '今日任务';

  @override
  String get homePythonLessons => 'Python 关卡';

  @override
  String get homeReviewBook => '错题本';

  @override
  String get homeReviewSubtitle => '复习做错的题目，巩固知识点';

  @override
  String get homeHeartsRecovering => '生命值恢复中...';

  @override
  String get homeRecoverySoon => '即将恢复';

  @override
  String homeRecoveryTime(int hours, int minutes) {
    return '预计 $hours 小时 $minutes 分钟后恢复 1 颗生命';
  }

  @override
  String homeRecoveryMinutes(int minutes) {
    return '预计 $minutes 分钟后恢复 1 颗生命';
  }

  @override
  String get homeFailedToLoadCourse => '课程数据加载失败';

  @override
  String homeLessonQuestions(int count, int xp) {
    return '$count 题  +$xp XP';
  }

  @override
  String homeLessonResult(int score, int correct, int total, int xp) {
    return '$score%  $correct/$total 正确  +$xp XP';
  }

  @override
  String get lessonConfirmAnswer => '确认答案';

  @override
  String get lessonNextQuestion => '下一题';

  @override
  String get lessonComplete => '完成';

  @override
  String get lessonCorrect => '正确！';

  @override
  String get lessonIncorrect => '错误';

  @override
  String get lessonExplanation => '解析';

  @override
  String get lessonHeartsEmpty => '生命值耗尽';

  @override
  String get lessonAskAI => '求助 AI';

  @override
  String get lessonInputHint => '输入你的答案...';

  @override
  String get lessonDragToSort => '拖动调整顺序';

  @override
  String get lessonCorrectOrder => '正确顺序:';

  @override
  String lessonCorrectAnswer(String answer) {
    return '正确答案: $answer';
  }

  @override
  String get lessonBossChallenge => 'BOSS 挑战';

  @override
  String get lessonExitTitle => '退出关卡？';

  @override
  String get lessonExitContent => '退出将不会获得任何奖励，继续挑战吗？';

  @override
  String get lessonContinueChallenge => '继续挑战';

  @override
  String get lessonExit => '退出';

  @override
  String get lessonReturnHome => '返回首页';

  @override
  String lessonHeartsDepletedMsg(int hours) {
    return '你的生命值已用完，需要等待恢复。每 $hours 小时恢复 1 颗生命。';
  }

  @override
  String get lessonChallengeFailed => '挑战失败';

  @override
  String get lessonBossSuccess => 'BOSS 挑战成功！';

  @override
  String get lessonPerfectClear => '完美通关！';

  @override
  String get lessonCongrats => '恭喜完成！';

  @override
  String get lessonNeedReview => '需要重新学习本章节';

  @override
  String lessonScoreResult(int correct, int total, int score) {
    return '$correct/$total 正确  ($score%)';
  }

  @override
  String get lessonReturnReview => '返回复习';

  @override
  String get lessonContinue => '继续';

  @override
  String get lessonStatLife => '生命';

  @override
  String get lessonStatDiamond => '钻石';

  @override
  String lessonAchievementUnlocked(String name) {
    return '成就解锁：$name';
  }

  @override
  String get profileLevelProgress => '升级进度';

  @override
  String get profileAchievements => '成就';

  @override
  String get profileAIModelManagement => 'AI 模型管理';

  @override
  String get profileAIModelSubtitle => '下载、加载本地大模型';

  @override
  String get profileStreakDays => '连击天数';

  @override
  String get profileDiamonds => '钻石';

  @override
  String get profileHearts => '生命值';

  @override
  String get modelManagementTitle => 'AI 模型管理';

  @override
  String get modelAvailable => '可用模型';

  @override
  String get modelNoModels => '暂无可用模型';

  @override
  String get modelInferenceEngine => 'AI 推理引擎';

  @override
  String get modelReady => '模型已就绪';

  @override
  String get modelLoading => '正在加载模型...';

  @override
  String get modelDownloading => '正在下载模型...';

  @override
  String get modelGenerating => '正在生成回答...';

  @override
  String get modelError => '模型加载失败';

  @override
  String get modelUninitialized => '未加载模型';

  @override
  String modelDownloadProgress(String percent) {
    return '下载中: $percent';
  }

  @override
  String modelCurrentFile(String file) {
    return '当前文件: $file';
  }

  @override
  String modelDownloadSource(String source) {
    return '下载源: $source';
  }

  @override
  String get modelCancelDownload => '取消下载';

  @override
  String get modelDownloadButton => '下载';

  @override
  String get modelLoadButton => '加载';

  @override
  String get modelUnloadButton => '卸载';

  @override
  String get modelLoaded => '已加载';

  @override
  String get coursesTitle => '全部课程';

  @override
  String get coursesNoCourses => '暂无课程';

  @override
  String coursesLessonCount(int count) {
    return '$count 个关卡';
  }

  @override
  String get reviewTitle => '错题本';

  @override
  String get reviewEmpty => '没有错题，继续保持！';

  @override
  String get reviewEmptySubtitle => '完成更多关卡来检验你的学习成果';

  @override
  String get reviewCorrectAnswer => '正确答案';

  @override
  String get reviewDifficultyEasy => '简单';

  @override
  String get reviewDifficultyMedium => '中等';

  @override
  String get reviewDifficultyHard => '困难';

  @override
  String get aiTutorTitle => 'JellyBuddy';

  @override
  String get aiTutorClearChat => '清空对话';

  @override
  String get aiTutorClearConfirm => '确定要清空所有聊天记录吗？';

  @override
  String get aiTutorCancel => '取消';

  @override
  String get aiTutorClear => '清空';

  @override
  String get aiTutorWelcome => '你好！我是 JellyBuddy，你的编程学习助手。有什么问题想问我吗？';

  @override
  String get aiTutorInputHint => '输入你的问题...';

  @override
  String get onboardingSkip => '跳过';

  @override
  String get onboardingNext => '下一步';

  @override
  String get onboardingStart => '开始学习';

  @override
  String get onboardingTitle1 => '像玩游戏一样学编程';

  @override
  String get onboardingSubtitle1 => '闯关、答题、赚经验值，让学习变得有趣';

  @override
  String get onboardingTitle2 => 'JellyBuddy 随时帮你';

  @override
  String get onboardingSubtitle2 => '遇到难题？AI 助手为你分步讲解';

  @override
  String get onboardingTitle3 => '随时随地，无需网络';

  @override
  String get onboardingSubtitle3 => '本地 AI 模型，保护隐私，离线学习';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsGeneral => '通用';

  @override
  String get settingsLanguage => '语言';

  @override
  String get settingsLanguageSubtitle => '切换应用显示语言';

  @override
  String get settingsDarkMode => '深色模式';

  @override
  String get settingsDarkModeSubtitle => '切换深色/浅色主题';

  @override
  String get settingsLearning => '学习';

  @override
  String get settingsResetProgress => '重置学习进度';

  @override
  String get settingsResetProgressSubtitle => '清除所有课程进度和成绩';

  @override
  String get settingsResetProgressConfirm => '确定要重置所有学习进度吗？此操作不可撤销。';

  @override
  String get settingsResetProgressDone => '学习进度已重置';

  @override
  String get settingsExportProgress => '导出学习进度';

  @override
  String get settingsExportProgressSubtitle => '导出你的学习数据';

  @override
  String get settingsComingSoon => '即将推出';

  @override
  String get settingsAbout => '关于';

  @override
  String get settingsVersion => '应用版本';

  @override
  String get settingsSlogan => 'AI 驱动游戏化学习';

  @override
  String get settingsLicenses => '开源许可证';

  @override
  String get settingsLicensesSubtitle => '查看第三方库许可证';

  @override
  String get settingsGithub => 'GitHub';

  @override
  String get settingsGithubUrl => 'https://github.com/user/JellyBuddy';

  @override
  String get settingsDangerZone => '危险操作';

  @override
  String get settingsClearAllData => '清除所有数据';

  @override
  String get settingsClearAllDataSubtitle => '恢复出厂设置，删除所有数据';

  @override
  String get settingsClearAllDataConfirm =>
      '确定要清除所有数据吗？这将删除所有学习进度、设置和缓存。此操作不可撤销。';

  @override
  String get settingsClearAllDataDone => '所有数据已清除';

  @override
  String get settingsCancel => '取消';

  @override
  String get settingsConfirm => '确定';

  @override
  String get settingsReset => '重置';

  @override
  String get settingsClearAll => '清除全部';

  @override
  String get settingsLanguageZh => '中文';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get profileSettings => '设置';

  @override
  String get profileSettingsSubtitle => '语言、数据管理等';

  @override
  String get homeStatsTitle => '学习统计';

  @override
  String get homeStatsSubtitle => '查看你的学习进度和成绩';
}
