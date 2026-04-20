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
  String get homeNoNotifications => '暂无新通知';

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
  String get lessonCodeHint => '// 在这里写代码...';

  @override
  String get lessonCorrectAnswerLabel => '正确答案：';

  @override
  String get lessonProgress => '进度';

  @override
  String get lessonDifficultyEasy => '简单';

  @override
  String get lessonDifficultyMedium => '中等';

  @override
  String get lessonDifficultyHard => '困难';

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
  String get profileEditName => '修改用户名';

  @override
  String get profileEditNameHint => '输入新用户名';

  @override
  String get profileSave => '保存';

  @override
  String get profileCancel => '取消';

  @override
  String get profileLeaderboard => '个人排行榜';

  @override
  String get profileLeaderboardSubtitle => '查看个人最佳记录';

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
  String get modelRetry => '重试';

  @override
  String get modelSettingsTitle => '模型设置';

  @override
  String get modelLocalAI => '本地 AI 模型';

  @override
  String get modelLocalAISubtitle => '离线推理 · 隐私优先';

  @override
  String get modelLocalAIFree => '离线推理 · 隐私优先 · 免费';

  @override
  String get modelCloudAI => '云端 AI 模型';

  @override
  String get modelCloudAIProviders =>
      'MiniMax · OpenRouter · OpenAI · Claude · DeepSeek';

  @override
  String get modelManage => '管理';

  @override
  String get modelCloudDisabled => '已禁用云端 AI';

  @override
  String get modelCloudSwitched => '已切换到云端 AI';

  @override
  String get modelInUse => '使用中';

  @override
  String get modelDisable => '停用';

  @override
  String get modelEnable => '启用';

  @override
  String get modelSetAsAssistant => '设为 AI 助手使用';

  @override
  String get modelLoadHint => '加载模型或配置云端 AI 获得智能回答';

  @override
  String modelInUseCloud(String provider) {
    return '使用中: $provider';
  }

  @override
  String get modelInUseLocal => '使用中: 本地模型';

  @override
  String get modelNoCloudConfig => '还没有配置云端模型';

  @override
  String get modelNoCloudConfigHint =>
      '添加你自己的 API Key，使用 MiniMax / OpenRouter 等在线模型';

  @override
  String get modelAddCloud => '添加云端模型';

  @override
  String get modelSettingsSubtitle =>
      '本地模型 · 云端 AI (MiniMax / OpenRouter / Claude)';

  @override
  String get cloudAITitle => '云端 AI 模型';

  @override
  String get cloudAIAddModel => '添加模型';

  @override
  String get cloudAIConfigured => '已配置的模型';

  @override
  String get cloudAIIntroDesc =>
      '使用 MiniMax、OpenRouter、OpenAI、Claude 等在线模型\n需要你自己的 API Key，密钥加密存储在设备本地';

  @override
  String get cloudAIEmptyTitle => '暂无配置的云端模型';

  @override
  String get cloudAIEmptyHint => '点击右下角 + 添加你的第一个 AI 模型';

  @override
  String get cloudAIDeleteTitle => '删除配置';

  @override
  String get cloudAIDeleteConfirm => '确认删除此 AI 配置？API Key 也会一并删除。';

  @override
  String get cloudAIEdit => '编辑';

  @override
  String get cloudAIDelete => '删除';

  @override
  String get cloudAICancel => '取消';

  @override
  String get cloudAIAddTitle => '添加云端 AI 模型';

  @override
  String get cloudAIEditTitle => '编辑云端 AI 模型';

  @override
  String get cloudAIProvider => '提供商';

  @override
  String get cloudAIModelId => '模型 ID';

  @override
  String get cloudAIAdvancedOptions => '高级选项';

  @override
  String get cloudAITestConnection => '测试连接';

  @override
  String get cloudAITesting => '测试中...';

  @override
  String get cloudAISave => '保存';

  @override
  String get cloudAISaving => '保存中...';

  @override
  String get cloudAIConnectionSuccess => '连接成功';

  @override
  String get cloudAIConnectionFailed => '连接失败，请检查 API Key 和模型 ID';

  @override
  String cloudAITestFailed(String error) {
    return '测试失败: $error';
  }

  @override
  String cloudAISaveFailed(String error) {
    return '保存失败: $error';
  }

  @override
  String get cloudAIEmptyFields => '模型 ID 和 API Key 不能为空';

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
  String get settingsPrivacyPolicy => '隐私政策';

  @override
  String get settingsPrivacyPolicySubtitle => '了解我们如何保护你的数据';

  @override
  String get settingsTermsOfService => '用户服务协议';

  @override
  String get settingsTermsOfServiceSubtitle => '使用条款和服务协议';

  @override
  String get settingsCrashLogs => '错误日志';

  @override
  String get settingsCrashLogsSubtitle => '查看应用错误记录';

  @override
  String get settingsNoCrashLogs => '暂无错误日志';

  @override
  String get settingsCopiedToClipboard => '已复制到剪贴板';

  @override
  String get settingsCopyToClipboard => '复制到剪贴板';

  @override
  String get settingsCopy => '复制';

  @override
  String get settingsClose => '关闭';

  @override
  String get settingsClearLogs => '清除日志';

  @override
  String get settingsLogsCleared => '日志已清除';

  @override
  String get profileSettings => '设置';

  @override
  String get profileSettingsSubtitle => '语言、数据管理等';

  @override
  String get homeStatsTitle => '学习统计';

  @override
  String get homeStatsSubtitle => '查看你的学习进度和成绩';

  @override
  String get importAddCourse => '添加课程';

  @override
  String get importLocalFile => '本地文件';

  @override
  String get importUrlImport => 'URL 导入';

  @override
  String get importFromLocalFile => '从本地文件导入';

  @override
  String get importFileHint => '选择一个 .md / .markdown / .txt 文件';

  @override
  String get importSelectFile => '选择文件';

  @override
  String get importImporting => '导入中...';

  @override
  String get importDownloadAndImport => '下载并导入';

  @override
  String get importDownloading => '下载中...';

  @override
  String importSuccess(String name, int count) {
    return '导入成功: $name（$count 课）';
  }

  @override
  String importFileFailed(String error) {
    return '文件导入失败: $error';
  }

  @override
  String get importInvalidUrl => '请输入有效的 URL';

  @override
  String get importUrlMustStartWithHttp => 'URL 必须以 http:// 或 https:// 开头';

  @override
  String importUrlFailed(String error) {
    return 'URL 导入失败: $error';
  }

  @override
  String get importDeleteCourse => '删除课程';

  @override
  String importDeleteConfirm(String name) {
    return '确定删除「$name」？此操作不可恢复。';
  }

  @override
  String get importCancel => '取消';

  @override
  String get importDelete => '删除';

  @override
  String get importTemplateFormat => '题库模版格式';

  @override
  String get importCopyTemplate => '复制模版';

  @override
  String get importTemplateCopied => '模版已复制到剪贴板';

  @override
  String get importHowToMake => '如何制作题库？';

  @override
  String get importHowToMakeDesc =>
      '按照 Markdown 模版格式编写题目，支持选择题、填空题、排序题、编程题 4 种类型。';

  @override
  String get importViewTemplate => '查看模版格式';

  @override
  String get importImported => '已导入';

  @override
  String importLessonCount(int count) {
    return '$count 课';
  }

  @override
  String get importFromUrl => '从 URL 导入';

  @override
  String get importUrlHint => '粘贴一个 Markdown 文档的 URL';

  @override
  String get importGithubAutoConvert => '支持 GitHub blob URL 自动转换为 raw';

  @override
  String get importExampleUrl => '示例 URL';

  @override
  String get importTemplateTooltip => '模版格式';

  @override
  String get leaderboardTitle => '个人排行榜';

  @override
  String get leaderboardPersonalBest => '个人最佳记录';

  @override
  String get leaderboardChallengeSelf => '挑战自己，刷新记录！';

  @override
  String get leaderboardPersonalRecords => 'Personal Records';

  @override
  String get leaderboardHallOfFame => 'Hall of Fame';

  @override
  String get leaderboardHighestXP => '单次最高XP';

  @override
  String get leaderboardLongestStreak => '最长连续天数';

  @override
  String get leaderboardPerfectStreak => '连续满分课程';

  @override
  String get leaderboardFastestLesson => '最快完成课程';

  @override
  String get leaderboardUnlockHint => '完成课程来解锁记录！';

  @override
  String leaderboardDays(int count) {
    return '$count 天';
  }

  @override
  String leaderboardLessons(int count) {
    return '$count 课';
  }

  @override
  String leaderboardMinSec(int min, int sec) {
    return '$min分$sec秒';
  }

  @override
  String leaderboardSec(int sec) {
    return '$sec秒';
  }

  @override
  String get achievementFirstStep => '第一步';

  @override
  String get achievementFirstStepDesc => '完成第一个关卡';

  @override
  String get achievementStreakMaster => '连续大师';

  @override
  String get achievementStreakMasterDesc => '7天连续学习';

  @override
  String get achievementPerfectionist => '完美主义者';

  @override
  String get achievementPerfectionistDesc => '完成10个 Perfect 关卡';

  @override
  String get achievementQuickLearner => '快速学习者';

  @override
  String get achievementQuickLearnerDesc => '连续答对5题';

  @override
  String get dailyTaskLesson => '日课';

  @override
  String get dailyTaskLessonReward => '+30 XP + 1 钻石';

  @override
  String get dailyTaskPerfect => '完美';

  @override
  String get dailyTaskPerfectReward => '+20 XP';

  @override
  String get dailyTaskReview => '复习';

  @override
  String get dailyTaskReviewReward => '+25 XP';

  @override
  String get dailyTaskEarlyBird => '晨鸟';

  @override
  String get dailyTaskEarlyBirdReward => 'XP x1.5';

  @override
  String get aiModelNotLoaded => '本地 AI 模型未加载，当前使用预设答案。前往「我的 → AI 模型管理」下载模型。';

  @override
  String get aiGoDownload => '去下载';

  @override
  String get notificationDailyTitle => '该学习啦！';

  @override
  String get notificationDailyBody => '保持你的连续学习记录 🔥';

  @override
  String get notificationStreakTitle => '⚠️ 连击即将断裂！';

  @override
  String notificationStreakBody(int hours) {
    return '还有 $hours 小时恢复时间，快来学习吧';
  }
}
