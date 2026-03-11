import 'package:aimgo/core/constants/layout_tokens.dart';
import 'package:aimgo/core/utils/time_formatter.dart';
import 'package:aimgo/features/goals/application/goals_page_controller.dart';
import 'package:aimgo/features/goals/presentation/widgets/highlight_text.dart';
import 'package:aimgo/features/goals/presentation/widgets/task_item_tile.dart';
import 'package:aimgo/features/goals/presentation/widgets/time_progress_bar.dart';
import 'package:flutter/material.dart';

class MilestoneCard extends StatelessWidget {
  const MilestoneCard({
    required this.milestoneNode,
    required this.searchQuery,
    required this.expanded,
    required this.editLabel,
    required this.deleteLabel,
    required this.addTaskLabel,
    required this.onToggleExpanded,
    required this.onEditMilestone,
    required this.onDeleteMilestone,
    required this.onAddTask,
    required this.onToggleTask,
    required this.onEditTask,
    required this.onDeleteTask,
    super.key,
  });

  final MilestoneWithTasks milestoneNode;
  final String searchQuery;
  final bool expanded;
  final String editLabel;
  final String deleteLabel;
  final String addTaskLabel;
  final VoidCallback onToggleExpanded;
  final VoidCallback onEditMilestone;
  final VoidCallback onDeleteMilestone;
  final VoidCallback onAddTask;
  final void Function(int taskId, bool targetCompleted) onToggleTask;
  final void Function(int taskId) onEditTask;
  final void Function(int taskId) onDeleteTask;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dividerColor = theme.colorScheme.outlineVariant.withValues(
      alpha: 0.45,
    );
    final milestone = milestoneNode.milestone;
    final tasks = milestoneNode.tasks;
    final completedCount = tasks.where((task) => task.isCompleted).length;
    final timeProgressText =
        '${formatMinutes(milestone.effectiveMinutes)} / ${formatMinutes(milestone.estimateMinutes)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(LayoutTokens.radiusMedium),
        border: Border.all(color: dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(4),
                    onTap: onEditMilestone,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: HighlightText(
                        text: milestone.title,
                        query: searchQuery,
                        baseStyle: theme.textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: onAddTask,
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Icon(
                      Icons.add_circle_outline,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: onToggleExpanded,
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$completedCount/${tasks.length}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          expanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          size: 18,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.45,
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${tasks.length}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TimeProgressBar(
                    progressRatio: milestone.progressRatio,
                  ),
                ),
                const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 118),
                  child: Text(
                    timeProgressText,
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
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                children: [
                  const SizedBox(height: 6),
                  Divider(height: 1, color: dividerColor),
                  if (tasks.isEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 10, 4, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              addTaskLabel,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: onAddTask,
                            child: Text(addTaskLabel),
                          ),
                        ],
                      ),
                    ),
                  if (tasks.isNotEmpty) ...[
                    for (var index = 0; index < tasks.length; index++) ...[
                      TaskItemTile(
                        task: tasks[index],
                        searchQuery: searchQuery,
                        editLabel: editLabel,
                        deleteLabel: deleteLabel,
                        onTapToggle: () {
                          onToggleTask(
                            tasks[index].id,
                            !tasks[index].isCompleted,
                          );
                        },
                        onEdit: () => onEditTask(tasks[index].id),
                        onDelete: () => onDeleteTask(tasks[index].id),
                      ),
                      if (index != tasks.length - 1)
                        Divider(height: 1, color: dividerColor),
                    ],
                  ],
                ],
              ),
              crossFadeState:
                  expanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 220),
            ),
          ],
        ),
      ),
    );
  }
}
