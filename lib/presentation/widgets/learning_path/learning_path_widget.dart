import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/course.dart';
import '../../../domain/entities/user.dart';

/// The status of a lesson node on the learning path.
enum LessonNodeStatus { completed, active, locked }

/// A Duolingo-style learning path that renders lessons as circular nodes
/// on a zigzag path connected by curved lines.
class LearningPathWidget extends StatelessWidget {
  final List<Lesson> lessons;
  final Set<String> completedLessonIds;
  final Map<String, LessonResult> lessonResults;
  final void Function(Lesson lesson) onLessonTap;
  final bool heartsEmpty;

  const LearningPathWidget({
    super.key,
    required this.lessons,
    required this.completedLessonIds,
    required this.lessonResults,
    required this.onLessonTap,
    this.heartsEmpty = false,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = List<Lesson>.from(lessons)
      ..sort((a, b) => a.order.compareTo(b.order));

    // Find the first uncompleted lesson index.
    int firstUncompletedIndex = sorted.length;
    for (int i = 0; i < sorted.length; i++) {
      if (!completedLessonIds.contains(sorted[i].id)) {
        firstUncompletedIndex = i;
        break;
      }
    }

    // Build node data list.
    final nodes = <_NodeData>[];
    for (int i = 0; i < sorted.length; i++) {
      final lesson = sorted[i];
      LessonNodeStatus status;
      if (completedLessonIds.contains(lesson.id)) {
        status = LessonNodeStatus.completed;
      } else if (i == firstUncompletedIndex) {
        status = LessonNodeStatus.active;
      } else {
        status = LessonNodeStatus.locked;
      }
      nodes.add(_NodeData(
        lesson: lesson,
        status: status,
        result: lessonResults[lesson.id],
      ));
    }

    if (nodes.isEmpty) return const SizedBox.shrink();

    const double verticalSpacing = 120.0;
    const double nodeRadius = 32.0;
    final double totalHeight =
        (nodes.length - 1) * verticalSpacing + nodeRadius * 2 + 60;

    return SizedBox(
      height: totalHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final leftX = width * 0.30;
          final rightX = width * 0.70;

          // Compute center positions for each node.
          final centers = <Offset>[];
          for (int i = 0; i < nodes.length; i++) {
            final x = i.isEven ? leftX : rightX;
            final y = nodeRadius + i * verticalSpacing;
            centers.add(Offset(x, y));
          }

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Connector lines painted behind nodes.
              CustomPaint(
                size: Size(width, totalHeight),
                painter: _PathConnectorPainter(
                  centers: centers,
                  nodes: nodes,
                ),
              ),
              // Node widgets positioned on top.
              for (int i = 0; i < nodes.length; i++)
                Positioned(
                  left: centers[i].dx - nodeRadius,
                  top: centers[i].dy - nodeRadius,
                  child: Semantics(
                    label: 'Lesson ${nodes[i].lesson.order}: ${nodes[i].lesson.title}, ${nodes[i].status.name}',
                    button: true,
                    child: _LessonNode(
                      nodeData: nodes[i],
                      radius: nodeRadius,
                      index: i,
                      heartsEmpty: heartsEmpty,
                      onTap: () {
                        final nd = nodes[i];
                        final isCompleted =
                            nd.status == LessonNodeStatus.completed;
                        final isLocked = nd.status == LessonNodeStatus.locked;
                        final disabledByHearts = heartsEmpty && !isCompleted;
                        if (!isLocked && !disabledByHearts) {
                          onLessonTap(nd.lesson);
                        }
                      },
                    ),
                  ),
                ),
              // Labels below each node.
              for (int i = 0; i < nodes.length; i++)
                Positioned(
                  left: centers[i].dx - 60,
                  top: centers[i].dy + nodeRadius + 6,
                  child: SizedBox(
                    width: 120,
                    child: Column(
                      children: [
                        Text(
                          nodes[i].lesson.title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: nodes[i].status == LessonNodeStatus.locked
                                ? AppColors.textHint
                                : AppColors.textPrimary,
                          ),
                        ),
                        if (nodes[i].status == LessonNodeStatus.completed &&
                            nodes[i].result != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star,
                                    size: 14, color: AppColors.xpGold),
                                const SizedBox(width: 2),
                                Text(
                                  '${nodes[i].result!.score}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.xpGold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Internal data holder for a node.
class _NodeData {
  final Lesson lesson;
  final LessonNodeStatus status;
  final LessonResult? result;

  const _NodeData({
    required this.lesson,
    required this.status,
    this.result,
  });
}

/// CustomPainter that draws Bezier curve connectors between adjacent nodes.
class _PathConnectorPainter extends CustomPainter {
  final List<Offset> centers;
  final List<_NodeData> nodes;

  _PathConnectorPainter({
    required this.centers,
    required this.nodes,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < centers.length - 1; i++) {
      final from = centers[i];
      final to = centers[i + 1];
      final isCompleted = nodes[i].status == LessonNodeStatus.completed &&
          nodes[i + 1].status != LessonNodeStatus.locked;
      final isNextCompleted =
          nodes[i + 1].status == LessonNodeStatus.completed;

      final paint = Paint()
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      if (isCompleted && isNextCompleted) {
        // Solid green line for completed sections.
        paint.color = AppColors.success;
      } else if (isCompleted) {
        // Gradient from green to grey for the transition segment.
        paint.color = AppColors.success.withValues(alpha: 0.5);
      } else {
        // Dashed grey line for upcoming sections.
        paint.color = Colors.grey.withValues(alpha: 0.35);
      }

      final midY = (from.dy + to.dy) / 2;
      final path = Path()
        ..moveTo(from.dx, from.dy)
        ..cubicTo(from.dx, midY, to.dx, midY, to.dx, to.dy);

      final bool isDashed = !(isCompleted && isNextCompleted) && !isCompleted;
      if (isDashed) {
        _drawDashedPath(canvas, path, paint);
      } else {
        canvas.drawPath(path, paint);
      }
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      const dashLen = 8.0;
      const gapLen = 6.0;
      bool draw = true;
      while (distance < metric.length) {
        final len = draw ? dashLen : gapLen;
        final end = min(distance + len, metric.length);
        if (draw) {
          final extractPath = metric.extractPath(distance, end);
          canvas.drawPath(extractPath, paint);
        }
        distance = end;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PathConnectorPainter oldDelegate) {
    return oldDelegate.centers != centers || oldDelegate.nodes != nodes;
  }
}

/// A single lesson node on the path.
class _LessonNode extends StatelessWidget {
  final _NodeData nodeData;
  final double radius;
  final int index;
  final bool heartsEmpty;
  final VoidCallback onTap;

  const _LessonNode({
    required this.nodeData,
    required this.radius,
    required this.index,
    required this.heartsEmpty,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = nodeData.status;
    final lesson = nodeData.lesson;
    final diameter = radius * 2;

    switch (status) {
      case LessonNodeStatus.completed:
        return _buildCompletedNode(diameter, lesson);
      case LessonNodeStatus.active:
        return _buildActiveNode(diameter, lesson);
      case LessonNodeStatus.locked:
        return _buildLockedNode(diameter, lesson);
    }
  }

  Widget _buildCompletedNode(double diameter, Lesson lesson) {
    final isBoss = lesson.isBoss;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.success.withValues(alpha: 0.15),
          border: Border.all(
            color: isBoss ? AppColors.xpGold : AppColors.success,
            width: isBoss ? 3 : 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.success.withValues(alpha: 0.3),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: isBoss
              ? const Icon(Icons.diamond, color: AppColors.xpGold, size: 28)
              : const Icon(Icons.check, color: AppColors.success, size: 28),
        ),
      ),
    );
  }

  Widget _buildActiveNode(double diameter, Lesson lesson) {
    final isBoss = lesson.isBoss;
    final isDisabledByHearts = heartsEmpty;
    final activeDiameter = diameter + 12;

    if (isDisabledByHearts) {
      // Show a muted version when hearts are empty.
      return GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: activeDiameter,
          height: activeDiameter,
          child: Center(
            child: Opacity(
              opacity: 0.5,
              child: Container(
                width: diameter,
                height: diameter,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.withValues(alpha: 0.1),
                  border: Border.all(color: Colors.grey, width: 2),
                ),
                child: const Center(
                  child:
                      Icon(Icons.heart_broken, color: Colors.grey, size: 26),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.92, end: 1.0),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        builder: (context, scale, child) {
          // Continuously bounce: restart animation on completion.
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        onEnd: () {
          // The TweenAnimationBuilder runs once; for continuous pulse we
          // wrap with a dedicated repeating widget below.
        },
        child: _PulsingWrapper(
          child: Container(
            width: activeDiameter,
            height: activeDiameter,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isBoss
                  ? AppColors.xpGold.withValues(alpha: 0.12)
                  : AppColors.primary.withValues(alpha: 0.12),
              border: Border.all(
                color: isBoss ? AppColors.xpGold : AppColors.primary,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isBoss ? AppColors.xpGold : AppColors.primary)
                      .withValues(alpha: 0.35),
                  blurRadius: 16,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Center(
              child: isBoss
                  ? const Icon(Icons.diamond,
                      color: AppColors.xpGold, size: 30)
                  : const Icon(Icons.play_arrow,
                      color: AppColors.primary, size: 30),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLockedNode(double diameter, Lesson lesson) {
    final isBoss = lesson.isBoss;
    final lockedDiameter = diameter - 8;
    return Opacity(
      opacity: 0.5,
      child: SizedBox(
        width: diameter,
        height: diameter,
        child: Center(
          child: Container(
            width: lockedDiameter,
            height: lockedDiameter,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.withValues(alpha: 0.1),
              border: Border.all(
                color: isBoss
                    ? AppColors.xpGold.withValues(alpha: 0.5)
                    : Colors.grey.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: Center(
              child: isBoss
                  ? Icon(Icons.diamond,
                      color: AppColors.xpGold.withValues(alpha: 0.5),
                      size: 22)
                  : const Icon(Icons.lock, color: Colors.grey, size: 22),
            ),
          ),
        ),
      ),
    );
  }
}

/// A widget that continuously pulses its child with a scale animation.
class _PulsingWrapper extends StatefulWidget {
  final Widget child;

  const _PulsingWrapper({required this.child});

  @override
  State<_PulsingWrapper> createState() => _PulsingWrapperState();
}

class _PulsingWrapperState extends State<_PulsingWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 0.93, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
