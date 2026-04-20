import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:jelly_buddy/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/custom_course_service.dart';
import '../../../domain/entities/course.dart';

/// Screen for importing custom courses — supports local file and URL.
class ImportCourseScreen extends StatefulWidget {
  const ImportCourseScreen({super.key});

  @override
  State<ImportCourseScreen> createState() => _ImportCourseScreenState();
}

class _ImportCourseScreenState extends State<ImportCourseScreen>
    with SingleTickerProviderStateMixin {
  final _service = GetIt.instance<CustomCourseService>();
  late TabController _tabController;
  final _urlController = TextEditingController();

  bool _isImporting = false;
  String? _errorMessage;
  List<Course> _customCourses = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCustomCourses();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _loadCustomCourses() {
    setState(() {
      _customCourses = _service.getCustomCourses();
    });
  }

  Future<void> _pickFile() async {
    setState(() {
      _isImporting = true;
      _errorMessage = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['md', 'markdown', 'txt'],
      );

      if (result == null || result.files.isEmpty) {
        setState(() => _isImporting = false);
        return;
      }

      final file = File(result.files.first.path!);
      final content = await file.readAsString();

      final course = await _service.importFromMarkdown(content);
      _onImportSuccess(course);
    } catch (e) {
      setState(() => _errorMessage = AppLocalizations.of(context)!.importFileFailed(e.toString()));
    } finally {
      setState(() => _isImporting = false);
    }
  }

  Future<void> _importFromUrl() async {
    final url = _urlController.text.trim();
    final l10n = AppLocalizations.of(context)!;
    if (url.isEmpty) {
      setState(() => _errorMessage = l10n.importInvalidUrl);
      return;
    }
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      setState(() => _errorMessage = l10n.importUrlMustStartWithHttp);
      return;
    }

    setState(() {
      _isImporting = true;
      _errorMessage = null;
    });

    try {
      final course = await _service.importFromUrl(url);
      _urlController.clear();
      _onImportSuccess(course);
    } catch (e) {
      setState(() => _errorMessage = l10n.importUrlFailed(e.toString().replaceFirst('FormatException: ', '')));
    } finally {
      setState(() => _isImporting = false);
    }
  }

  void _onImportSuccess(Course course) {
    _loadCustomCourses();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ ${AppLocalizations.of(context)!.importSuccess(course.name, course.lessons.length)}'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _deleteCourse(Course course) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.importDeleteCourse),
        content: Text(l10n.importDeleteConfirm(course.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.importCancel)),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.importDelete, style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _service.deleteCustomCourse(course.id);
      _loadCustomCourses();
    }
  }

  void _showTemplateHelp() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          children: [
            Text('📝 ${AppLocalizations.of(context)!.importTemplateFormat}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                _sampleTemplate,
                style: TextStyle(fontFamily: 'monospace', fontSize: 12, height: 1.4),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () async {
                await Clipboard.setData(const ClipboardData(text: _sampleTemplate));
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.importTemplateCopied)),
                  );
                }
              },
              icon: const Icon(Icons.copy, size: 18),
              label: Text(AppLocalizations.of(context)!.importCopyTemplate),
            ),
            const SizedBox(height: 12),
            const Text(
              '完整文档: docs/question_bank_template.md',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.importAddCourse),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(icon: const Icon(Icons.folder_open), text: AppLocalizations.of(context)!.importLocalFile),
            Tab(icon: const Icon(Icons.cloud_download), text: AppLocalizations.of(context)!.importUrlImport),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showTemplateHelp,
            tooltip: AppLocalizations.of(context)!.importTemplateTooltip,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFileTab(),
                _buildUrlTab(),
              ],
            ),
          ),
          if (_errorMessage != null)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: AppColors.error, fontSize: 13),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () => setState(() => _errorMessage = null),
                    color: AppColors.error,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          if (_customCourses.isNotEmpty) _buildImportedSection(),
        ],
      ),
    );
  }

  Widget _buildFileTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: _cardDecoration(),
          child: Column(
            children: [
              const Icon(Icons.description, size: 56, color: AppColors.primary),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context)!.importFromLocalFile,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                AppLocalizations.of(context)!.importFileHint,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isImporting ? null : _pickFile,
                  icon: _isImporting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.folder_open),
                  label: Text(_isImporting ? AppLocalizations.of(context)!.importImporting : AppLocalizations.of(context)!.importSelectFile),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildHelpCard(),
      ],
    );
  }

  Widget _buildUrlTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: _cardDecoration(),
          child: Column(
            children: [
              const Icon(Icons.cloud_download, size: 56, color: AppColors.primary),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context)!.importFromUrl,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                AppLocalizations.of(context)!.importUrlHint,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  hintText: 'https://...',
                  prefixIcon: const Icon(Icons.link),
                  suffixIcon: _urlController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _urlController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                ),
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.done,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _importFromUrl(),
              ),
              const SizedBox(height: 8),
              Text(
                '💡 ${AppLocalizations.of(context)!.importGithubAutoConvert}',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isImporting || _urlController.text.trim().isEmpty
                      ? null
                      : _importFromUrl,
                  icon: _isImporting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.download),
                  label: Text(_isImporting ? AppLocalizations.of(context)!.importDownloading : AppLocalizations.of(context)!.importDownloadAndImport),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(AppLocalizations.of(context)!.importExampleUrl, style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 8),
              _buildExampleUrl(
                'GitHub Raw',
                'https://raw.githubusercontent.com/user/repo/main/course.md',
              ),
              _buildExampleUrl(
                'GitHub Blob',
                'https://github.com/user/repo/blob/main/course.md',
              ),
              _buildExampleUrl(
                'Gist',
                'https://gist.githubusercontent.com/user/id/raw/course.md',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExampleUrl(String label, String url) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: GestureDetector(
        onTap: () {
          _urlController.text = url;
          setState(() {});
        },
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                label,
                style: const TextStyle(fontSize: 11, color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                url,
                style: const TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  color: AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.importHowToMake,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.importHowToMakeDesc,
            style: const TextStyle(fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _showTemplateHelp,
            icon: const Icon(Icons.description, size: 16),
            label: Text(AppLocalizations.of(context)!.importViewTemplate),
          ),
        ],
      ),
    );
  }

  Widget _buildImportedSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.surfaceVariant, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${AppLocalizations.of(context)!.importImported} (${_customCourses.length})',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 70,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _customCourses.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final course = _customCourses[i];
                return _buildCourseChip(course);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseChip(Course course) {
    return GestureDetector(
      onLongPress: () => _deleteCourse(course),
      onTap: () {
        if (course.lessons.isNotEmpty) {
          context.push('/lesson/${course.id}/${course.lessons.first.id}');
        }
      },
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Text(course.icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    course.name,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    AppLocalizations.of(context)!.importLessonCount(course.lessons.length),
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      );

  static const _sampleTemplate = '''---
id: my_course
name: 我的课程
icon: 📚
description: 课程描述
difficulty: beginner
---

## Lesson 1: 课程标题

<!-- lesson-meta
order: 1
xpReward: 50
-->

### Question 1.1 (choice, easy)

题目内容？

- [ ] 选项 A
- [x] 选项 B (正确)
- [ ] 选项 C

**解析**: 解释文字

### Question 1.2 (fillBlank, easy)

填空题内容

**答案**: 答案1 | 答案2

**解析**: 解释
''';
}
