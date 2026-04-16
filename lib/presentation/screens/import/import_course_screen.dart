import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/custom_course_service.dart';
import '../../../domain/entities/course.dart';

/// Screen for importing custom courses from Markdown files.
class ImportCourseScreen extends StatefulWidget {
  const ImportCourseScreen({super.key});

  @override
  State<ImportCourseScreen> createState() => _ImportCourseScreenState();
}

class _ImportCourseScreenState extends State<ImportCourseScreen> {
  final _service = GetIt.instance<CustomCourseService>();
  bool _isImporting = false;
  String? _errorMessage;
  List<Course> _customCourses = [];

  @override
  void initState() {
    super.initState();
    _loadCustomCourses();
  }

  void _loadCustomCourses() {
    setState(() {
      _customCourses = _service.getCustomCourses();
    });
  }

  Future<void> _pickAndImport() async {
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

      _loadCustomCourses();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ 导入成功: ${course.name}（${course.lessons.length} 课）'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isImporting = false);
    }
  }

  Future<void> _deleteCourse(Course course) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('删除课程'),
        content: Text('确定删除「${course.name}」？此操作不可恢复。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除', style: TextStyle(color: AppColors.error)),
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
            const Text('📝 题库模版格式',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(const ClipboardData(text: _sampleTemplate));
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('模版已复制到剪贴板')),
                        );
                      }
                    },
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('复制模版'),
                  ),
                ),
              ],
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
        title: const Text('导入题库'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showTemplateHelp,
            tooltip: '模版格式',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Import card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(Icons.file_upload, size: 48, color: AppColors.primary),
                const SizedBox(height: 12),
                const Text(
                  '导入自定义题库',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  '选择一个 Markdown (.md) 文件',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isImporting ? null : _pickAndImport,
                    icon: _isImporting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.folder_open),
                    label: Text(_isImporting ? '导入中...' : '选择文件'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _showTemplateHelp,
                  icon: const Icon(Icons.description, size: 16),
                  label: const Text('查看模版格式'),
                ),
              ],
            ),
          ),

          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Text(
                '❌ 导入失败: $_errorMessage',
                style: const TextStyle(color: AppColors.error, fontSize: 13),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Imported courses list
          if (_customCourses.isNotEmpty) ...[
            const Text(
              '已导入的课程',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._customCourses.map((course) => _buildCourseCard(course)),
          ] else ...[
            const SizedBox(height: 40),
            Center(
              child: Column(
                children: [
                  const Icon(Icons.inbox_outlined, size: 64, color: AppColors.textHint),
                  const SizedBox(height: 12),
                  Text(
                    '暂无导入的课程',
                    style: TextStyle(
                      color: AppColors.textHint.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCourseCard(Course course) {
    final questionCount = course.lessons.fold<int>(
      0,
      (sum, l) => sum + l.levels.fold<int>(0, (s, lv) => s + lv.questions.length),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(course.icon, style: const TextStyle(fontSize: 36)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${course.lessons.length} 课 · $questionCount 题',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                if (course.metadata.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    course.metadata.description,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: AppColors.error,
            onPressed: () => _deleteCourse(course),
          ),
          IconButton(
            icon: const Icon(Icons.play_arrow),
            color: AppColors.primary,
            onPressed: course.lessons.isEmpty
                ? null
                : () => context.push('/lesson/${course.id}/${course.lessons.first.id}'),
          ),
        ],
      ),
    );
  }

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
