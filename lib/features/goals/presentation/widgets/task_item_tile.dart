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
      decoration: isDone ? TextDecoration.lineThrough : null,
      color:
          isDone
              ? theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.55)
              : null,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 7, 2, 7),
      child: Row(
        children: [
          GestureDetector(
            onTap: onTapToggle,
            behavior: HitTestBehavior.opaque,
            child: _TaskStatusIcon(task: task, progressRatio: effectiveRatio),
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
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 74, maxWidth: 98),
            child: Text(
              '${formatMinutes(task.effectiveMinutes)} / ${formatMinutes(task.estimateMinutes)}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
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
    const activeColor = Color(0xFF2E7D32);
    final normalizedProgress = progressRatio.clamp(0, 1).toDouble();

    if (task.isCompleted) {
      return const Icon(Icons.check_circle, color: activeColor, size: 22);
    }

    final centerColor =
        Color.lerp(
          baseBorder.withValues(alpha: 0.15),
          activeColor.withValues(alpha: 0.22),
          normalizedProgress,
        )!;
    final progressColor =
        Color.lerp(
          activeColor.withValues(alpha: 0.45),
          activeColor,
          normalizedProgress,
        )!;

    return SizedBox(
      width: 22,
      height: 22,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: normalizedProgress,
            strokeWidth: 2.1,
            backgroundColor: baseBorder.withValues(alpha: 0.45),
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
          Container(
            width: 8,
            height: 8,
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
