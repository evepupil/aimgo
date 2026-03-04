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
    final milestone = milestoneNode.milestone;
    final tasks = milestoneNode.tasks;
    final completedCount = tasks.where((task) => task.isCompleted).length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onToggleExpanded,
              child: Row(
                children: [
                  Expanded(
                    child: HighlightText(
                      text: milestone.title,
                      query: searchQuery,
                      baseStyle: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('$completedCount/${tasks.length}'),
                  IconButton(
                    onPressed: onToggleExpanded,
                    icon: Icon(
                      expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'add_task':
                          onAddTask();
                          break;
                        case 'edit':
                          onEditMilestone();
                          break;
                        case 'delete':
                          onDeleteMilestone();
                          break;
                      }
                    },
                    itemBuilder:
                        (context) => [
                          PopupMenuItem(
                            value: 'add_task',
                            child: Text(addTaskLabel),
                          ),
                          PopupMenuItem(value: 'edit', child: Text(editLabel)),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text(deleteLabel),
                          ),
                        ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            TimeProgressBar(progressRatio: milestone.progressRatio),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${formatMinutes(milestone.effectiveMinutes)} / ${formatMinutes(milestone.estimateMinutes)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                children: [
                  const SizedBox(height: 8),
                  const Divider(height: 1),
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
                    if (index != tasks.length - 1) const Divider(height: 1),
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
