import 'package:aimgo/core/constants/layout_tokens.dart';
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
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Material(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          top: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.92,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 28,
                  height: 3,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.24,
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    shrinkWrap: true,
                    itemCount: widget.goals.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final node = widget.goals[index];
                      final goal = node.goal;
                      final selected = goal.id == widget.selectedGoalId;
                      return InkWell(
                        borderRadius: BorderRadius.circular(
                          LayoutTokens.radiusCard,
                        ),
                        onTap: () => widget.onSelectGoal(goal.id),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(
                              LayoutTokens.radiusCard,
                            ),
                            border:
                                selected
                                    ? Border.all(
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.32),
                                    )
                                    : null,
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: selected ? 0.06 : 0.04,
                                ),
                                blurRadius: selected ? 10 : 8,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        goal.title,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (selected)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 8,
                                          top: 2,
                                        ),
                                        child: Icon(
                                          Icons.check_circle,
                                          size: 18,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    if (_manageMode) ...[
                                      const SizedBox(width: 6),
                                      IconButton(
                                        onPressed:
                                            () => widget.onEditGoal(goal.id),
                                        icon: const Icon(Icons.edit_outlined),
                                        tooltip: widget.editLabel,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                      IconButton(
                                        onPressed:
                                            () => widget.onDeleteGoal(goal.id),
                                        icon: const Icon(Icons.delete_outline),
                                        tooltip: widget.deleteLabel,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${(goal.progressRatio * 100).round()}%',
                                        style: theme.textTheme.headlineSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: theme.colorScheme.primary,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          '${formatMinutes(goal.effectiveMinutes)} / ${formatMinutes(goal.estimateMinutes)}',
                                          style: theme.textTheme.labelMedium
                                              ?.copyWith(
                                                color: theme.colorScheme.primary
                                                    .withValues(alpha: 0.88),
                                                fontWeight: FontWeight.w600,
                                              ),
                                          textAlign: TextAlign.right,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                TimeProgressBar(
                                  progressRatio: goal.progressRatio,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: widget.onAddGoal,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 40),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            backgroundColor: theme.colorScheme.primary
                                .withValues(alpha: 0.10),
                            foregroundColor: theme.colorScheme.primary,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                LayoutTokens.radiusMedium,
                              ),
                            ),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            textStyle: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          icon: const Icon(Icons.add),
                          label: Text(widget.addGoalLabel),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            setState(() {
                              _manageMode = !_manageMode;
                            });
                          },
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 40),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            backgroundColor: theme.colorScheme.primary
                                .withValues(alpha: 0.10),
                            foregroundColor: theme.colorScheme.primary,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                LayoutTokens.radiusMedium,
                              ),
                            ),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            textStyle: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
