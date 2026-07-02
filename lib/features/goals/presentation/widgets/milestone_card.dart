import 'package:aimgo/app/l10n/generated/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final dividerColor = theme.colorScheme.outlineVariant.withValues(
      alpha: 0.32,
    );
    final milestone = milestoneNode.milestone;
    final tasks = milestoneNode.tasks;
    final completedCount = tasks.where((task) => task.isCompleted).length;
    final progressPercent = (milestone.progressRatio * 100).round();
    final timeProgressText =
        '${formatMinutes(milestone.effectiveMinutes)} / ${formatMinutes(milestone.estimateMinutes)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: LayoutTokens.daybookSurface(theme),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                        baseStyle: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: onToggleExpanded,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 2,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$completedCount/${tasks.length}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          expanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '$progressPercent%',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    timeProgressText,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.82,
                      ),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            TimeProgressBar(progressRatio: milestone.progressRatio),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child:
                  expanded
                      ? Column(
                        children: [
                          const SizedBox(height: 8),
                          Divider(height: 1, color: dividerColor),
                          if (tasks.isEmpty)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(4, 8, 4, 2),
                              child: Center(
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 4,
                                  children: [
                                    Text(
                                      l10n.goalsNoTaskYet,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color:
                                                theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                          ),
                                    ),
                                    TextButton(
                                      onPressed: onAddTask,
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(0, 24),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                      child: Text(addTaskLabel),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (tasks.isNotEmpty) ...[
                            for (
                              var index = 0;
                              index < tasks.length;
                              index++
                            ) ...[
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
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton.icon(
                                  onPressed: onAddTask,
                                  style: TextButton.styleFrom(
                                    minimumSize: const Size(0, 30),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 0,
                                      vertical: 4,
                                    ),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  icon: const Icon(Icons.add_rounded, size: 16),
                                  label: Text(addTaskLabel),
                                ),
                              ),
                            ),
                          ],
                        ],
                      )
                      : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
