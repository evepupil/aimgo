import 'package:aimgo/core/utils/time_formatter.dart';
import 'package:aimgo/features/goals/presentation/widgets/highlight_text.dart';
import 'package:aimgo/shared/models/planning_models.dart';
import 'package:flutter/material.dart';

class TaskItemTile extends StatelessWidget {
  const TaskItemTile({
    required this.task,
    required this.searchQuery,
    required this.editLabel,
    required this.deleteLabel,
    required this.onTapToggle,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final TaskModel task;
  final String searchQuery;
  final String editLabel;
  final String deleteLabel;
  final VoidCallback onTapToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDone = task.isCompleted;
    final effectiveRatio =
        task.progressRatio.isNaN
            ? 0.0
            : task.progressRatio.clamp(0, 1).toDouble();

    final titleStyle = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: isDone ? FontWeight.w400 : FontWeight.w500,
      decoration: isDone ? TextDecoration.lineThrough : null,
      color:
          isDone
              ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.72)
              : theme.colorScheme.onSurface,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: onTapToggle,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 24,
              height: 24,
              child: Center(
                child: _TaskStatusIcon(
                  task: task,
                  progressRatio: effectiveRatio,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(4),
              onTap: onEdit,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: HighlightText(
                  text: task.title,
                  query: searchQuery,
                  baseStyle: titleStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 96,
            child: Text(
              '${formatMinutes(task.effectiveMinutes)} / ${formatMinutes(task.estimateMinutes)}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.82,
                ),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskStatusIcon extends StatelessWidget {
  const _TaskStatusIcon({required this.task, required this.progressRatio});

  final TaskModel task;
  final double progressRatio;

  @override
  Widget build(BuildContext context) {
    const baseBorder = Color(0xFFB0B0B0);
    final activeColor = Theme.of(context).colorScheme.primary;
    final normalizedProgress = progressRatio.clamp(0, 1).toDouble();

    if (task.isCompleted) {
      return Icon(Icons.check_circle_rounded, color: activeColor, size: 20);
    }

    final centerColor =
        Color.lerp(
          baseBorder.withValues(alpha: 0.12),
          activeColor.withValues(alpha: 0.20),
          normalizedProgress,
        )!;
    final progressColor =
        Color.lerp(
          activeColor.withValues(alpha: 0.42),
          activeColor,
          normalizedProgress,
        )!;

    return SizedBox(
      width: 20,
      height: 20,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: normalizedProgress,
            strokeWidth: 2,
            backgroundColor: baseBorder.withValues(alpha: 0.38),
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: centerColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
