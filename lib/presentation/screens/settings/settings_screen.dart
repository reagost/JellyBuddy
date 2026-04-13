import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jelly_buddy/l10n/app_localizations.dart';
import '../../../app.dart';
import '../../../core/theme/app_colors.dart';
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

  void _exportProgress() {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.settingsComingSoon)),
    );
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
            const Divider(height: 1),
            _actionTile(
              icon: Icons.upload_file,
              title: l10n.settingsExportProgress,
              subtitle: l10n.settingsExportProgressSubtitle,
              onTap: _exportProgress,
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
            _infoTile(
              icon: Icons.lightbulb_outline,
              title: l10n.settingsSlogan,
            ),
            const Divider(height: 1),
            _actionTile(
              icon: Icons.description_outlined,
              title: l10n.settingsLicenses,
              subtitle: l10n.settingsLicensesSubtitle,
              onTap: () => showLicensePage(
                context: context,
                applicationName: 'JellyBuddy',
                applicationVersion: 'v1.0.0',
              ),
            ),
            const Divider(height: 1),
            _infoTile(
              icon: Icons.code,
              title: l10n.settingsGithub,
              trailing: l10n.settingsGithubUrl,
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
