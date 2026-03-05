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

    return InkWell(
      onTap: onTapToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            GestureDetector(
              onTap: onTapToggle,
              child: _TaskStatusIcon(task: task),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: HighlightText(
                text: task.title,
                query: searchQuery,
                baseStyle: theme.textTheme.bodyLarge?.copyWith(
                  decoration: isDone ? TextDecoration.lineThrough : null,
                  color:
                      isDone
                          ? theme.textTheme.bodyLarge?.color?.withValues(
                            alpha: 0.55,
                          )
                          : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 100),
              child: Text(
                '${formatMinutes(task.effectiveMinutes)} / ${formatMinutes(task.estimateMinutes)}',
                style: theme.textTheme.labelSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit();
                } else if (value == 'delete') {
                  onDelete();
                }
              },
              itemBuilder:
                  (context) => [
                    PopupMenuItem(value: 'edit', child: Text(editLabel)),
                    PopupMenuItem(value: 'delete', child: Text(deleteLabel)),
                  ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskStatusIcon extends StatelessWidget {
  const _TaskStatusIcon({required this.task});

  final TaskModel task;

  @override
  Widget build(BuildContext context) {
    if (task.isCompleted) {
      return const Icon(Icons.check_circle, color: Color(0xFF2E7D32));
    }
    return SizedBox(
      width: 22,
      height: 22,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.circle_outlined, size: 20),
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              value: task.progressRatio.clamp(0, 1).toDouble(),
              strokeWidth: 2.2,
              backgroundColor: Colors.transparent,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF2E7D32),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
