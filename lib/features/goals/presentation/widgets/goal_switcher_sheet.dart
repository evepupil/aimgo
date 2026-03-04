import 'package:aimgo/core/utils/time_formatter.dart';
import 'package:aimgo/features/goals/application/goals_page_controller.dart';
import 'package:aimgo/features/goals/presentation/widgets/time_progress_bar.dart';
import 'package:flutter/material.dart';

class GoalSwitcherSheet extends StatefulWidget {
  const GoalSwitcherSheet({
    required this.goals,
    required this.selectedGoalId,
    required this.addGoalLabel,
    required this.manageLabel,
    required this.editLabel,
    required this.deleteLabel,
    required this.onSelectGoal,
    required this.onAddGoal,
    required this.onEditGoal,
    required this.onDeleteGoal,
    super.key,
  });

  final List<GoalWithMilestones> goals;
  final int? selectedGoalId;
  final String addGoalLabel;
  final String manageLabel;
  final String editLabel;
  final String deleteLabel;
  final void Function(int goalId) onSelectGoal;
  final VoidCallback onAddGoal;
  final void Function(int goalId) onEditGoal;
  final void Function(int goalId) onDeleteGoal;

  @override
  State<GoalSwitcherSheet> createState() => _GoalSwitcherSheetState();
}

class _GoalSwitcherSheetState extends State<GoalSwitcherSheet> {
  bool _manageMode = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 14),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: widget.goals.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final node = widget.goals[index];
                  final goal = node.goal;
                  final selected = goal.id == widget.selectedGoalId;
                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => widget.onSelectGoal(goal.id),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              selected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(
                                    context,
                                  ).colorScheme.outlineVariant,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  goal.title,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ),
                              if (selected)
                                Icon(
                                  Icons.check_circle,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              if (_manageMode) ...[
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: () => widget.onEditGoal(goal.id),
                                  icon: const Icon(Icons.edit_outlined),
                                  tooltip: widget.editLabel,
                                ),
                                IconButton(
                                  onPressed: () => widget.onDeleteGoal(goal.id),
                                  icon: const Icon(Icons.delete_outline),
                                  tooltip: widget.deleteLabel,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 8),
                          TimeProgressBar(progressRatio: goal.progressRatio),
                          const SizedBox(height: 6),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '${formatMinutes(goal.effectiveMinutes)} / ${formatMinutes(goal.estimateMinutes)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: widget.onAddGoal,
                    icon: const Icon(Icons.add),
                    label: Text(widget.addGoalLabel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _manageMode = !_manageMode;
                      });
                    },
                    icon: Icon(
                      _manageMode
                          ? Icons.check_circle_outline
                          : Icons.tune_outlined,
                    ),
                    label: Text(widget.manageLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
