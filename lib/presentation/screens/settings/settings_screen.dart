import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jelly_buddy/l10n/app_localizations.dart';
import '../../../app.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/crash_log_service.dart';
import '../../../data/services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final StorageService _storage;
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();
    _storage = GetIt.instance<StorageService>();
    _darkMode = _storage.getString('dark_mode') == 'true';
  }

  String _currentLocaleCode() {
    final stored = _storage.getString('app_locale');
    if (stored != null) return stored;
    // Fall back to the platform locale resolved by the framework.
    final platformLocale = WidgetsBinding.instance.platformDispatcher.locale;
    return platformLocale.languageCode == 'en' ? 'en' : 'zh';
  }

  Future<void> _setLocale(String code) async {
    await _storage.setString('app_locale', code);
    localeNotifier.value = Locale(code);
    if (mounted) setState(() {});
  }

  Future<void> _toggleDarkMode(bool value) async {
    await _storage.setString('dark_mode', value.toString());
    themeModeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
    setState(() => _darkMode = value);
  }

  Future<void> _resetProgress() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsResetProgress),
        content: Text(l10n.settingsResetProgressConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.settingsCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.settingsReset),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      // Clear all lesson/course progress keys in storage.
      // ProgressService stores keys with prefixes: lesson_result_, completed_lessons_, wrong_questions_
      final box = Hive.box<String>('settings');
      final keysToRemove = box.keys.where((key) {
        final k = key.toString();
        return k.startsWith('lesson_result_') ||
            k.startsWith('completed_lessons_') ||
            k.startsWith('wrong_questions_');
      }).toList();
      for (final key in keysToRemove) {
        await box.delete(key);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.settingsResetProgressDone)),
        );
      }
    }
  }

  Future<void> _clearAllData() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsClearAllData),
        content: Text(l10n.settingsClearAllDataConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.settingsCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.settingsClearAll),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _storage.clearAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.settingsClearAllDataDone)),
        );
      }
    }
  }

  void _showModelSettingsSheet() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.smart_toy, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('模型设置',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.phone_android, color: AppColors.primary),
                title: const Text('本地 AI 模型'),
                subtitle: const Text('离线推理 · 隐私优先 · 免费'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/model-settings');
                },
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: const Icon(Icons.cloud, color: AppColors.primary),
                title: const Text('云端 AI 模型'),
                subtitle: const Text('MiniMax · OpenRouter · OpenAI · Claude · DeepSeek'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/cloud-ai-settings');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCrashLogs() {
    final crashLogService = GetIt.instance<CrashLogService>();
    final crashes = crashLogService.getRecentCrashes().reversed.toList();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.bug_report, size: 22),
            SizedBox(width: 8),
            Text('错误日志'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: crashes.isEmpty
              ? const Center(child: Text('暂无错误日志'))
              : ListView.separated(
                  itemCount: crashes.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, index) {
                    final entry = crashes[index];
                    final timestamp = entry['timestamp'] ?? '';
                    final error = entry['error'] ?? '';
                    // Format timestamp for display
                    String displayTime = timestamp;
                    try {
                      final dt = DateTime.parse(timestamp);
                      displayTime =
                          '${dt.month}/${dt.day} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                    } catch (_) {}

                    return ListTile(
                      dense: true,
                      title: Text(
                        error.split('\n').first,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                      subtitle: Text(
                        displayTime,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondaryOf(context),
                        ),
                      ),
                      onTap: () => _showCrashDetail(entry),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Copy all logs to clipboard
              final buffer = StringBuffer();
              for (final entry in crashes) {
                buffer.writeln('--- ${entry['timestamp']} ---');
                buffer.writeln(entry['error']);
                if (entry['stackTrace']?.isNotEmpty == true) {
                  buffer.writeln(entry['stackTrace']);
                }
                buffer.writeln();
              }
              Clipboard.setData(ClipboardData(text: buffer.toString()));
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已复制到剪贴板')),
              );
            },
            child: const Text('复制到剪贴板'),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(ctx);
              final messenger = ScaffoldMessenger.of(context);
              await crashLogService.clearLogs();
              navigator.pop();
              messenger.showSnackBar(
                const SnackBar(content: Text('日志已清除')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('清除日志'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _showCrashDetail(Map<String, String> entry) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          entry['timestamp'] ?? '',
          style: const TextStyle(fontSize: 14),
        ),
        content: SingleChildScrollView(
          child: SelectableText(
            '${entry['error']}\n\n${entry['stackTrace'] ?? ''}',
            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(
                text: '${entry['error']}\n\n${entry['stackTrace'] ?? ''}',
              ));
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已复制到剪贴板')),
              );
            },
            child: const Text('复制'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // Build helpers
  // ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = _currentLocaleCode();

    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        backgroundColor: AppColors.backgroundOf(context),
        foregroundColor: AppColors.textPrimaryOf(context),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          // ----- General -----
          _sectionHeader(l10n.settingsGeneral),
          _buildCard(children: [
            _languageTile(l10n, currentLocale),
            const Divider(height: 1),
            _darkModeTile(l10n),
            const Divider(height: 1),
            _actionTile(
              icon: Icons.smart_toy_outlined,
              title: '模型设置',
              subtitle: '本地模型 · 云端 AI (MiniMax / OpenRouter / Claude)',
              onTap: _showModelSettingsSheet,
            ),
          ]),

          const SizedBox(height: 24),

          // ----- Learning -----
          _sectionHeader(l10n.settingsLearning),
          _buildCard(children: [
            _actionTile(
              icon: Icons.restart_alt,
              title: l10n.settingsResetProgress,
              subtitle: l10n.settingsResetProgressSubtitle,
              onTap: _resetProgress,
            ),
          ]),

          const SizedBox(height: 24),

          // ----- About -----
          _sectionHeader(l10n.settingsAbout),
          _buildCard(children: [
            _infoTile(
              icon: Icons.info_outline,
              title: l10n.settingsVersion,
              trailing: 'JellyBuddy v1.0.0',
            ),
            const Divider(height: 1),
            _actionTile(
              icon: Icons.privacy_tip_outlined,
              title: '隐私政策',
              subtitle: '了解我们如何保护你的数据',
              onTap: () => context.push('/legal/privacy'),
            ),
            const Divider(height: 1),
            _actionTile(
              icon: Icons.gavel_outlined,
              title: '用户服务协议',
              subtitle: '使用条款和服务协议',
              onTap: () => context.push('/legal/terms'),
            ),
            const Divider(height: 1),
            _infoTile(
              icon: Icons.code,
              title: l10n.settingsGithub,
              trailing: l10n.settingsGithubUrl,
            ),
            const Divider(height: 1),
            _actionTile(
              icon: Icons.bug_report,
              title: '错误日志',
              subtitle: '查看应用错误记录',
              onTap: _showCrashLogs,
            ),
          ]),

          const SizedBox(height: 24),

          // ----- Danger Zone -----
          _sectionHeader(l10n.settingsDangerZone),
          _buildCard(
            borderColor: AppColors.error.withValues(alpha: 0.3),
            children: [
              _actionTile(
                icon: Icons.delete_forever,
                title: l10n.settingsClearAllData,
                subtitle: l10n.settingsClearAllDataSubtitle,
                iconColor: AppColors.error,
                titleColor: AppColors.error,
                onTap: _clearAllData,
              ),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondaryOf(context),
        ),
      ),
    );
  }

  Widget _buildCard({
    required List<Widget> children,
    Color? borderColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardOf(context),
        borderRadius: BorderRadius.circular(16),
        border: borderColor != null ? Border.all(color: borderColor) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _languageTile(AppLocalizations l10n, String currentLocale) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.language, color: AppColors.primary, size: 22),
      ),
      title: Text(
        l10n.settingsLanguage,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryOf(context),
        ),
      ),
      subtitle: Text(
        l10n.settingsLanguageSubtitle,
        style: TextStyle(fontSize: 12, color: AppColors.textSecondaryOf(context)),
      ),
      trailing: SegmentedButton<String>(
        segments: [
          ButtonSegment(value: 'zh', label: Text(l10n.settingsLanguageZh)),
          ButtonSegment(value: 'en', label: Text(l10n.settingsLanguageEn)),
        ],
        selected: {currentLocale},
        onSelectionChanged: (s) => _setLocale(s.first),
        style: const ButtonStyle(
          visualDensity: VisualDensity.compact,
          textStyle: WidgetStatePropertyAll(
            TextStyle(fontSize: 13),
          ),
        ),
      ),
    );
  }

  Widget _darkModeTile(AppLocalizations l10n) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.dark_mode_outlined, color: AppColors.primary, size: 22),
      ),
      title: Text(
        l10n.settingsDarkMode,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryOf(context),
        ),
      ),
      subtitle: Text(
        l10n.settingsDarkModeSubtitle,
        style: TextStyle(fontSize: 12, color: AppColors.textSecondaryOf(context)),
      ),
      trailing: Switch(
        value: _darkMode,
        onChanged: _toggleDarkMode,
        activeTrackColor: AppColors.primary,
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? titleColor,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor ?? AppColors.primary, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: titleColor ?? AppColors.textPrimaryOf(context),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: AppColors.textSecondaryOf(context)),
      ),
      trailing: Icon(Icons.chevron_right, color: AppColors.textHintOf(context)),
      onTap: onTap,
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String title,
    String? trailing,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryOf(context),
        ),
      ),
      trailing: trailing != null
          ? ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 180),
              child: Text(
                trailing,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondaryOf(context),
                ),
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
              ),
            )
          : null,
    );
  }
}
