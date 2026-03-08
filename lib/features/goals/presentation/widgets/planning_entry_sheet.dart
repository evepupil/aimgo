import 'package:aimgo/app/l10n/generated/app_localizations.dart';
import 'package:aimgo/features/goals/application/goals_page_controller.dart';
import 'package:aimgo/shared/models/planning_models.dart';
import 'package:flutter/material.dart';

enum PlanningComposerType { goal, milestone, task }

class PlanningComposerRequest {
  const PlanningComposerRequest({
    required this.type,
    required this.title,
    this.description,
    this.goalId,
    this.milestoneId,
    this.estimateMinutes,
  });

  final PlanningComposerType type;
  final String title;
  final String? description;
  final int? goalId;
  final int? milestoneId;
  final int? estimateMinutes;
}

class PlanningComposerSheet extends StatefulWidget {
  const PlanningComposerSheet({
    required this.goalTree,
    required this.submitLabel,
    this.initialType = PlanningComposerType.task,
    this.initialGoalId,
    this.initialMilestoneId,
    super.key,
  });

  final List<GoalWithMilestones> goalTree;
  final String submitLabel;
  final PlanningComposerType initialType;
  final int? initialGoalId;
  final int? initialMilestoneId;

  @override
  State<PlanningComposerSheet> createState() => _PlanningComposerSheetState();
}

class _PlanningComposerSheetState extends State<PlanningComposerSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _estimateController;
  late PlanningComposerType _selectedType;
  int? _selectedGoalId;
  int? _selectedMilestoneId;

  GoalWithMilestones? get _selectedGoalNode {
    final goalId = _selectedGoalId;
    if (goalId == null) {
      return null;
    }
    for (final goalNode in widget.goalTree) {
      if (goalNode.goal.id == goalId) {
        return goalNode;
      }
    }
    return null;
  }

  MilestoneModel? get _selectedMilestone {
    final milestoneId = _selectedMilestoneId;
    final goalNode = _selectedGoalNode;
    if (milestoneId == null || goalNode == null) {
      return null;
    }
    for (final milestoneNode in goalNode.milestones) {
      if (milestoneNode.milestone.id == milestoneId) {
        return milestoneNode.milestone;
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _estimateController = TextEditingController(text: '25');
    _selectedType = widget.initialType;
    _selectedGoalId = widget.initialGoalId ?? _firstGoalId();
    _selectedMilestoneId = widget.initialMilestoneId;
    _syncSelectionForType();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _estimateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final composerTheme = theme.copyWith(
      inputDecorationTheme: const InputDecorationTheme(
        isDense: true,
        isCollapsed: true,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        filled: false,
      ),
    );

    return Theme(
      data: composerTheme,
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Material(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
          clipBehavior: Clip.antiAlias,
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
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
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: _titleController,
                              autofocus: true,
                              textInputAction: TextInputAction.next,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                              ),
                              decoration: InputDecoration.collapsed(
                                hintText: l10n.goalsEntryTitle,
                                hintStyle: theme.textTheme.headlineSmall
                                    ?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant
                                          .withValues(alpha: 0.62),
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _descriptionController,
                              minLines: 1,
                              maxLines: 4,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurface,
                                height: 1.35,
                              ),
                              decoration: InputDecoration.collapsed(
                                hintText: l10n.goalsEntryDescription,
                                hintStyle: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.78),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _ComposerTabChip(
                                  label: l10n.goalsCreateTypeTask,
                                  selected:
                                      _selectedType ==
                                      PlanningComposerType.task,
                                  onTap:
                                      () => _onSelectType(
                                        PlanningComposerType.task,
                                      ),
                                ),
                                _ComposerTabChip(
                                  label: l10n.goalsCreateTypeMilestone,
                                  selected:
                                      _selectedType ==
                                      PlanningComposerType.milestone,
                                  onTap:
                                      () => _onSelectType(
                                        PlanningComposerType.milestone,
                                      ),
                                ),
                                _ComposerTabChip(
                                  label: l10n.goalsCreateTypeGoal,
                                  selected:
                                      _selectedType ==
                                      PlanningComposerType.goal,
                                  onTap:
                                      () => _onSelectType(
                                        PlanningComposerType.goal,
                                      ),
                                ),
                              ],
                            ),
                            if (_selectedType == PlanningComposerType.task) ...[
                              const SizedBox(height: 14),
                              _ComposerMetaChip(
                                icon: Icons.timelapse_outlined,
                                child: SizedBox(
                                  width: 88,
                                  child: TextField(
                                    controller: _estimateController,
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.done,
                                    style: theme.textTheme.bodyMedium,
                                    decoration: InputDecoration.collapsed(
                                      hintText: l10n.goalsEntryEstimateMinutes,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    Divider(
                      height: 1,
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.35,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
                      child: Row(
                        children: [
                          Expanded(child: _buildSelectionButton(context)),
                          const SizedBox(width: 10),
                          _ComposerSubmitButton(
                            tooltip: widget.submitLabel,
                            onPressed: _submit,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionButton(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    if (_selectedType == PlanningComposerType.goal) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: _openSelectionSheet,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 17,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  _selectionLabel(l10n),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.92),
                  ),
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.arrow_drop_down,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _selectionLabel(AppLocalizations l10n) {
    if (_selectedType == PlanningComposerType.milestone) {
      return _selectedGoalNode?.goal.title ?? l10n.goalsCreateTypeGoal;
    }

    final goalTitle = _selectedGoalNode?.goal.title;
    final milestoneTitle = _selectedMilestone?.title;
    if (goalTitle != null && milestoneTitle != null) {
      return '$goalTitle / $milestoneTitle';
    }
    return '${l10n.goalsCreateTypeGoal} / ${l10n.goalsCreateTypeMilestone}';
  }

  void _onSelectType(PlanningComposerType type) {
    if (_selectedType == type) {
      return;
    }
    setState(() {
      _selectedType = type;
      _syncSelectionForType();
    });
  }

  void _syncSelectionForType() {
    _selectedGoalId ??= _firstGoalId();

    if (_selectedType == PlanningComposerType.goal) {
      return;
    }

    final goalId = _selectedGoalId;
    if (goalId == null) {
      _selectedMilestoneId = null;
      return;
    }

    final goalNode = _findGoalNode(goalId);
    if (goalNode == null) {
      _selectedGoalId = _firstGoalId();
      _selectedMilestoneId = null;
      _syncSelectionForType();
      return;
    }

    if (!_goalContainsMilestone(goalNode, _selectedMilestoneId)) {
      _selectedMilestoneId =
          goalNode.milestones.isNotEmpty
              ? goalNode.milestones.first.milestone.id
              : null;
    }
  }

  bool _goalContainsMilestone(GoalWithMilestones goalNode, int? milestoneId) {
    if (milestoneId == null) {
      return false;
    }
    for (final milestoneNode in goalNode.milestones) {
      if (milestoneNode.milestone.id == milestoneId) {
        return true;
      }
    }
    return false;
  }

  GoalWithMilestones? _findGoalNode(int goalId) {
    for (final goalNode in widget.goalTree) {
      if (goalNode.goal.id == goalId) {
        return goalNode;
      }
    }
    return null;
  }

  List<GoalWithMilestones> get _selectionGoalTree {
    final currentGoalNode = _selectedGoalNode;
    if (currentGoalNode != null) {
      return [currentGoalNode];
    }
    return widget.goalTree;
  }

  int? _firstGoalId() {
    if (widget.goalTree.isEmpty) {
      return null;
    }
    return widget.goalTree.first.goal.id;
  }

  Future<void> _openSelectionSheet() async {
    if (_selectedType == PlanningComposerType.goal) {
      return;
    }

    final visibleGoalTree = _selectionGoalTree;

    if (_selectedType == PlanningComposerType.milestone) {
      final goalId = await showDialog<int>(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.black26,
        builder: (context) {
          return _SelectionPopupFrame(
            child: _GoalPickerCard(
              goalTree: visibleGoalTree,
              selectedGoalId: _selectedGoalId,
            ),
          );
        },
      );
      if (goalId == null) {
        return;
      }
      setState(() {
        _selectedGoalId = goalId;
        _syncSelectionForType();
      });
      return;
    }

    final selection = await showDialog<_TaskParentSelection>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black26,
      builder: (context) {
        return _SelectionPopupFrame(
          child: _TaskParentPickerCard(
            goalTree: visibleGoalTree,
            selectedGoalId: _selectedGoalId,
            selectedMilestoneId: _selectedMilestoneId,
          ),
        );
      },
    );
    if (selection == null) {
      return;
    }
    setState(() {
      _selectedGoalId = selection.goalId;
      _selectedMilestoneId = selection.milestoneId;
      _syncSelectionForType();
    });
  }

  void _submit() {
    final l10n = AppLocalizations.of(context)!;
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      return;
    }
    final description = _normalizeNullable(_descriptionController.text);

    switch (_selectedType) {
      case PlanningComposerType.goal:
        Navigator.of(context).pop(
          PlanningComposerRequest(
            type: PlanningComposerType.goal,
            title: title,
            description: description,
          ),
        );
        return;
      case PlanningComposerType.milestone:
        final goalId = _selectedGoalId;
        if (goalId == null) {
          _showSnackBar(l10n.goalsSelectGoalFirst);
          return;
        }
        Navigator.of(context).pop(
          PlanningComposerRequest(
            type: PlanningComposerType.milestone,
            title: title,
            description: description,
            goalId: goalId,
          ),
        );
        return;
      case PlanningComposerType.task:
        final goalId = _selectedGoalId;
        final milestoneId = _selectedMilestoneId;
        final estimateMinutes = int.tryParse(_estimateController.text.trim());
        if (goalId == null) {
          _showSnackBar(l10n.goalsSelectGoalFirst);
          return;
        }
        if (milestoneId == null) {
          _showSnackBar(l10n.goalsSelectMilestoneFirst);
          return;
        }
        if (estimateMinutes == null || estimateMinutes <= 0) {
          return;
        }
        Navigator.of(context).pop(
          PlanningComposerRequest(
            type: PlanningComposerType.task,
            title: title,
            description: description,
            goalId: goalId,
            milestoneId: milestoneId,
            estimateMinutes: estimateMinutes,
          ),
        );
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}

class _SelectionPopupFrame extends StatelessWidget {
  const _SelectionPopupFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bottomOffset = 106 + MediaQuery.viewInsetsOf(context).bottom;
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, bottomOffset),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 420,
                    maxHeight: 360,
                  ),
                  child: Material(
                    color: Theme.of(context).colorScheme.surface,
                    elevation: 12,
                    borderRadius: BorderRadius.circular(20),
                    clipBehavior: Clip.antiAlias,
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalPickerCard extends StatelessWidget {
  const _GoalPickerCard({required this.goalTree, required this.selectedGoalId});

  final List<GoalWithMilestones> goalTree;
  final int? selectedGoalId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (goalTree.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Text(l10n.goalsNoGoal),
      );
    }

    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        for (final goalNode in goalTree)
          ListTile(
            visualDensity: const VisualDensity(vertical: -2),
            leading: Icon(
              goalNode.goal.id == selectedGoalId
                  ? Icons.check_circle_rounded
                  : Icons.flag_outlined,
              size: 20,
              color:
                  goalNode.goal.id == selectedGoalId
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            title: Text(
              goalNode.goal.title,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            onTap: () => Navigator.of(context).pop(goalNode.goal.id),
          ),
      ],
    );
  }
}

class _TaskParentPickerCard extends StatelessWidget {
  const _TaskParentPickerCard({
    required this.goalTree,
    required this.selectedGoalId,
    required this.selectedMilestoneId,
  });

  final List<GoalWithMilestones> goalTree;
  final int? selectedGoalId;
  final int? selectedMilestoneId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (goalTree.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Text(l10n.goalsNoGoal),
      );
    }

    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        for (final goalNode in goalTree) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
            child: Row(
              children: [
                Icon(
                  Icons.flag_outlined,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    goalNode.goal.title,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (goalNode.milestones.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(44, 0, 16, 10),
              child: Text(
                l10n.goalsNoMilestone,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          for (final milestoneNode in goalNode.milestones)
            ListTile(
              visualDensity: const VisualDensity(vertical: -2),
              contentPadding: const EdgeInsets.only(left: 44, right: 16),
              minLeadingWidth: 20,
              leading: Icon(
                goalNode.goal.id == selectedGoalId &&
                        milestoneNode.milestone.id == selectedMilestoneId
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 18,
                color:
                    goalNode.goal.id == selectedGoalId &&
                            milestoneNode.milestone.id == selectedMilestoneId
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
              ),
              title: Text(
                milestoneNode.milestone.title,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              onTap: () {
                Navigator.of(context).pop(
                  _TaskParentSelection(
                    goalId: goalNode.goal.id,
                    milestoneId: milestoneNode.milestone.id,
                  ),
                );
              },
            ),
        ],
      ],
    );
  }
}

class _TaskParentSelection {
  const _TaskParentSelection({required this.goalId, required this.milestoneId});

  final int goalId;
  final int milestoneId;
}

class _ComposerTabChip extends StatelessWidget {
  const _ComposerTabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color:
          selected
              ? theme.colorScheme.surfaceContainerLow
              : theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  selected
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.10)
                      : theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.62,
                      ),
            ),
            boxShadow:
                selected
                    ? const [
                      BoxShadow(
                        color: Color(0x0F000000),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ]
                    : null,
          ),
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.94),
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              letterSpacing: -0.1,
            ),
          ),
        ),
      ),
    );
  }
}

class _ComposerMetaChip extends StatelessWidget {
  const _ComposerMetaChip({required this.icon, required this.child});

  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.75),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _ComposerSubmitButton extends StatelessWidget {
  const _ComposerSubmitButton({required this.tooltip, required this.onPressed});

  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: 52,
        height: 42,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            padding: EdgeInsets.zero,
            elevation: 0,
            backgroundColor: const Color(0xFFE95F37),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Icon(Icons.send_rounded, size: 20),
        ),
      ),
    );
  }
}

class GoalEntrySheet extends StatefulWidget {
  const GoalEntrySheet({
    required this.title,
    required this.submitLabel,
    this.initialTitle,
    this.initialDescription,
    super.key,
  });

  final String title;
  final String submitLabel;
  final String? initialTitle;
  final String? initialDescription;

  @override
  State<GoalEntrySheet> createState() => _GoalEntrySheetState();
}

class _GoalEntrySheetState extends State<GoalEntrySheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _descriptionController = TextEditingController(
      text: widget.initialDescription ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _EntrySheetFrame(
      title: widget.title,
      submitLabel: widget.submitLabel,
      onSubmit: () {
        final title = _titleController.text.trim();
        if (title.isEmpty) {
          return;
        }
        Navigator.of(context).pop(
          CreateGoalInput(
            title: title,
            description: _normalizeNullable(_descriptionController.text),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _titleController,
            autofocus: true,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(labelText: l10n.goalsEntryTitle),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            minLines: 3,
            maxLines: 5,
            decoration: InputDecoration(labelText: l10n.goalsEntryDescription),
          ),
        ],
      ),
    );
  }
}

class MilestoneEntrySheet extends StatefulWidget {
  const MilestoneEntrySheet({
    required this.goalId,
    required this.title,
    required this.submitLabel,
    this.initialTitle,
    this.initialDescription,
    super.key,
  });

  final int goalId;
  final String title;
  final String submitLabel;
  final String? initialTitle;
  final String? initialDescription;

  @override
  State<MilestoneEntrySheet> createState() => _MilestoneEntrySheetState();
}

class _MilestoneEntrySheetState extends State<MilestoneEntrySheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _descriptionController = TextEditingController(
      text: widget.initialDescription ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _EntrySheetFrame(
      title: widget.title,
      submitLabel: widget.submitLabel,
      onSubmit: () {
        final title = _titleController.text.trim();
        if (title.isEmpty) {
          return;
        }
        Navigator.of(context).pop(
          CreateMilestoneInput(
            goalId: widget.goalId,
            title: title,
            description: _normalizeNullable(_descriptionController.text),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _titleController,
            autofocus: true,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(labelText: l10n.goalsEntryTitle),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            minLines: 3,
            maxLines: 5,
            decoration: InputDecoration(labelText: l10n.goalsEntryDescription),
          ),
        ],
      ),
    );
  }
}

class TaskEntrySheet extends StatefulWidget {
  const TaskEntrySheet({
    required this.title,
    required this.submitLabel,
    required this.availableMilestones,
    required this.initialMilestoneId,
    this.initialTitle,
    this.initialDescription,
    this.initialEstimateMinutes = 25,
    super.key,
  });

  final String title;
  final String submitLabel;
  final List<MilestoneModel> availableMilestones;
  final int initialMilestoneId;
  final String? initialTitle;
  final String? initialDescription;
  final int initialEstimateMinutes;

  @override
  State<TaskEntrySheet> createState() => _TaskEntrySheetState();
}

class _TaskEntrySheetState extends State<TaskEntrySheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _estimateController;
  late int _milestoneId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _descriptionController = TextEditingController(
      text: widget.initialDescription ?? '',
    );
    _estimateController = TextEditingController(
      text: widget.initialEstimateMinutes.toString(),
    );
    _milestoneId = widget.initialMilestoneId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _estimateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _EntrySheetFrame(
      title: widget.title,
      submitLabel: widget.submitLabel,
      onSubmit: () {
        final title = _titleController.text.trim();
        final estimateMinutes = int.tryParse(_estimateController.text.trim());
        if (title.isEmpty || estimateMinutes == null || estimateMinutes <= 0) {
          return;
        }
        Navigator.of(context).pop(
          CreateTaskInput(
            milestoneId: _milestoneId,
            title: title,
            description: _normalizeNullable(_descriptionController.text),
            estimateMinutes: estimateMinutes,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<int>(
            value: _milestoneId,
            isExpanded: true,
            decoration: InputDecoration(labelText: l10n.goalsAddMilestone),
            items: widget.availableMilestones
                .map(
                  (milestone) => DropdownMenuItem<int>(
                    value: milestone.id,
                    child: Text(
                      milestone.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(growable: false),
            onChanged: (value) {
              if (value == null) {
                return;
              }
              setState(() {
                _milestoneId = value;
              });
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _titleController,
            autofocus: true,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(labelText: l10n.goalsEntryTitle),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            minLines: 3,
            maxLines: 5,
            decoration: InputDecoration(labelText: l10n.goalsEntryDescription),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _estimateController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: l10n.goalsEntryEstimateMinutes,
            ),
          ),
        ],
      ),
    );
  }
}

class _EntrySheetFrame extends StatelessWidget {
  const _EntrySheetFrame({
    required this.title,
    required this.submitLabel,
    required this.onSubmit,
    required this.child,
  });

  final String title;
  final String submitLabel;
  final VoidCallback onSubmit;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
        clipBehavior: Clip.antiAlias,
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
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
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.4,
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                          tooltip: l10n.commonClose,
                        ),
                        Expanded(
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.35,
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                      child: child,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: onSubmit,
                        child: Text(submitLabel),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String? _normalizeNullable(String text) {
  final trimmed = text.trim();
  return trimmed.isEmpty ? null : trimmed;
}
