import 'package:aimgo/app/l10n/generated/app_localizations.dart';
import 'package:aimgo/app/router/route_paths.dart';
import 'package:aimgo/core/services/local_storage_service.dart';
import 'package:aimgo/core/widgets/app_confirm_dialog.dart';
import 'package:aimgo/core/widgets/anchored_action_menu.dart';
import 'package:aimgo/core/utils/duration_formatter.dart';
import 'package:aimgo/core/utils/time_formatter.dart';
import 'package:aimgo/features/focus/application/focus_context_provider.dart';
import 'package:aimgo/features/focus/application/focus_evaluation_draft_controller.dart';
import 'package:aimgo/features/focus/application/focus_models.dart';
import 'package:aimgo/features/focus/application/focus_timer_controller.dart';
import 'package:aimgo/features/focus/presentation/widgets/focus_session_widgets.dart';
import 'package:aimgo/features/goals/application/progress_sync_service.dart';
import 'package:aimgo/shared/models/planning_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class FocusPage extends ConsumerStatefulWidget {
  const FocusPage({super.key});

  @override
  ConsumerState<FocusPage> createState() => _FocusPageState();
}

class _FocusPageState extends ConsumerState<FocusPage>
    with WidgetsBindingObserver {
  final List<int> _pomodoroOptions = <int>[15, 25, 40, 60];
  final GlobalKey _topMenuAnchorKey = GlobalKey();
  bool _isCompletionDialogShowing = false;
  bool _isOpeningFullscreen = false;
  ProviderSubscription<FocusTimerState>? _focusTimerSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _focusTimerSubscription = ref.listenManual<FocusTimerState>(
      focusTimerControllerProvider,
      _handleFocusTimerStateChanged,
    );
  }

  @override
  void dispose() {
    _focusTimerSubscription?.close();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _handleFocusTimerStateChanged(
    FocusTimerState? previous,
    FocusTimerState next,
  ) {
    if (previous == null) {
      return;
    }
    if (next.completionEventId == previous.completionEventId) {
      return;
    }
    final autoOpenEvaluation =
        ref.read(localStorageServiceProvider).getAutoOpenEvaluationEnabled();
    final draft = ref.read(focusEvaluationDraftProvider);
    if (draft == null || _isOpeningFullscreen) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      if (autoOpenEvaluation) {
        context.push(RoutePaths.evaluation);
        return;
      }
      _showCompletionDecisionDialog();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(focusTimerControllerProvider.notifier).syncFromLifecycle();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final focusState = ref.watch(focusTimerControllerProvider);
    final focusController = ref.read(focusTimerControllerProvider.notifier);
    final canSwitchMode = focusState.status == FocusTimerStatus.idle;
    final hierarchyAsync = ref.watch(focusHierarchyProvider);
    final layoutMetrics = FocusSessionLayoutMetrics.fromSize(
      MediaQuery.sizeOf(context),
    );
    final hierarchy =
        hierarchyAsync.valueOrNull ?? const <FocusHierarchyItem>[];
    final selectedTarget = _resolveSelectedTarget(
      hierarchy: hierarchy,
      state: focusState,
    );

    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.focusTitle),
        actions: [
          IconButton(
            key: _topMenuAnchorKey,
            onPressed: () async {
              final action = await showAnchoredActionMenu<_FocusTopAction>(
                context: context,
                anchorKey: _topMenuAnchorKey,
                items: [
                  AnchoredMenuItem<_FocusTopAction>(
                    value: _FocusTopAction.history,
                    child: _FocusMenuActionRow(
                      icon: Icons.history,
                      label: l10n.historyTitle,
                    ),
                  ),
                  AnchoredMenuItem<_FocusTopAction>(
                    value: _FocusTopAction.manual,
                    child: _FocusMenuActionRow(
                      icon: Icons.add_circle_outline,
                      label: l10n.focusManualAddTooltip,
                    ),
                  ),
                ],
              );
              if (!context.mounted || action == null) {
                return;
              }
              if (action == _FocusTopAction.history) {
                final goalId = focusState.selectedGoalId;
                if (goalId == null) {
                  context.push(RoutePaths.history);
                  return;
                }
                context.push('${RoutePaths.history}?goalId=$goalId');
                return;
              }
              _openManualFocusSheet(hierarchy: hierarchy, state: focusState);
            },
            icon: const Icon(Icons.more_horiz),
            tooltip: l10n.goalsMenuTooltip,
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.fromLTRB(
              layoutMetrics.horizontalPadding,
              layoutMetrics.topPadding,
              layoutMetrics.horizontalPadding,
              layoutMetrics.bottomPadding,
            ),
            children: [
              // 鈹€鈹€ Mode switch in a white card 鈹€鈹€
              DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: FocusSessionModeTabs(
                    mode: focusState.mode,
                    onChange: canSwitchMode ? focusController.setMode : null,
                    pomodoroLabel: l10n.focusModePomodoro,
                    freeLabel: l10n.focusModeFree,
                    enabled: canSwitchMode,
                  ),
                ),
              ),
              SizedBox(height: layoutMetrics.modeToTargetSpacing),

              // 鈹€鈹€ Target selector in a white card 鈹€鈹€
              Hero(
                tag: FocusSessionHeroTags.targetEntry,
                child: FocusSessionTargetEntry(
                  enabled: focusState.status != FocusTimerStatus.running,
                  hasSelection: selectedTarget != null,
                  pathText:
                      selectedTarget?.displayPath ?? l10n.focusContextOptional,
                  onTap:
                      () => _openFocusTargetPicker(
                        hierarchy: hierarchy,
                        state: focusState,
                      ),
                ),
              ),
              SizedBox(height: layoutMetrics.targetToTimerSpacing),

              // 鈹€鈹€ Timer ring 鈹€鈹€
              GestureDetector(
                onTap:
                    focusState.mode == FocusMode.pomodoro &&
                            focusState.status == FocusTimerStatus.idle
                        ? _openPomodoroDurationPicker
                        : null,
                child: Hero(
                  tag: FocusSessionHeroTags.timerRing,
                  child: FocusSessionTimerRing(
                    state: focusState,
                    metrics: layoutMetrics,
                    l10n: l10n,
                  ),
                ),
              ),
              SizedBox(height: layoutMetrics.timerToControlSpacing),

              // 鈹€鈹€ Control buttons 鈹€鈹€
              Hero(
                tag: FocusSessionHeroTags.controls,
                child: FocusSessionControls(
                  state: focusState,
                  canStart: true,
                  onStart: () => _startAndEnterFullscreen(focusController),
                  onPause: focusController.pause,
                  onTerminate: () async {
                    final confirm = await _confirmTerminate();
                    if (confirm) {
                      focusController.terminate(isAbandoned: false);
                    }
                  },
                  l10n: l10n,
                ),
              ),
            ],
          ),
          if (hierarchyAsync.isLoading)
            const Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: LinearProgressIndicator(minHeight: 2),
            ),
        ],
      ),
    );
  }

  void _startAndEnterFullscreen(FocusTimerController controller) {
    controller.startOrResume();
    if (_isOpeningFullscreen || !mounted) {
      return;
    }
    _isOpeningFullscreen = true;
    context.push(RoutePaths.focusFullscreen).whenComplete(() {
      if (mounted) {
        _isOpeningFullscreen = false;
      }
    });
  }

  Future<void> _openPomodoroDurationPicker() async {
    final l10n = AppLocalizations.of(context)!;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: StatefulBuilder(
              builder: (context, setModalState) {
                final theme = Theme.of(context);
                final options = _pomodoroOptions.toList()..sort();
                final selectedMinutes =
                    ref.read(focusTimerControllerProvider).pomodoroMinutes;
                final itemWidth =
                    ((MediaQuery.sizeOf(context).width - 32 - 24) / 2)
                        .clamp(120.0, 180.0)
                        .toDouble();

                return Material(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.focusPickDuration,
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final value in options)
                              _DurationChoiceButton(
                                width: itemWidth,
                                label: formatClockFromSeconds(value * 60),
                                selected: value == selectedMinutes,
                                onTap: () {
                                  ref
                                      .read(
                                        focusTimerControllerProvider.notifier,
                                      )
                                      .setPomodoroMinutes(value);
                                  Navigator.of(sheetContext).pop();
                                },
                              ),
                            _DurationChoiceButton(
                              width: itemWidth,
                              label: '+',
                              selected: false,
                              onTap: () async {
                                final customValue =
                                    await _showAddPomodoroDurationDialog();
                                if (!mounted || customValue == null) {
                                  return;
                                }
                                setState(() {
                                  if (!_pomodoroOptions.contains(customValue)) {
                                    _pomodoroOptions.add(customValue);
                                  }
                                });
                                setModalState(() {});
                                ref
                                    .read(focusTimerControllerProvider.notifier)
                                    .setPomodoroMinutes(customValue);
                                if (sheetContext.mounted) {
                                  Navigator.of(sheetContext).pop();
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<int?> _showAddPomodoroDurationDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final textController = TextEditingController();
    final value = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.focusPickDuration),
          content: TextField(
            controller: textController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: l10n.goalsEntryEstimateMinutes,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () {
                final parsed = int.tryParse(textController.text.trim());
                if (parsed == null || parsed < 1 || parsed > 240) {
                  return;
                }
                Navigator.of(dialogContext).pop(parsed);
              },
              child: Text(l10n.commonConfirm),
            ),
          ],
        );
      },
    );
    textController.dispose();
    return value;
  }

  Future<void> _openFocusTargetPicker({
    required List<FocusHierarchyItem> hierarchy,
    required FocusTimerState state,
  }) async {
    if (state.status == FocusTimerStatus.running) {
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    if (hierarchy.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.goalsNoGoal)));
      return;
    }

    final picked = await _pickTaskTarget(
      hierarchy: hierarchy,
      selectedGoalId: state.selectedGoalId,
      selectedMilestoneId: state.selectedMilestoneId,
      selectedTaskId: state.selectedTaskId,
    );
    if (!mounted || picked == null) {
      return;
    }

    final controller = ref.read(focusTimerControllerProvider.notifier);
    controller.selectGoal(picked.goalId);
    controller.selectMilestone(picked.milestoneId);
    controller.selectTask(picked.taskId);
  }

  Future<void> _openManualFocusSheet({
    required List<FocusHierarchyItem> hierarchy,
    required FocusTimerState state,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    if (hierarchy.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.goalsNoGoal)));
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      useSafeArea: true,
      builder: (sheetContext) {
        return FractionallySizedBox(
          heightFactor: 0.93,
          child: _ManualFocusSheet(
            hierarchy: hierarchy,
            initialGoalId: state.selectedGoalId,
            initialMilestoneId: state.selectedMilestoneId,
            initialTaskId: state.selectedTaskId,
            initialFocusMode: state.mode,
            onPickTarget: ({
              required int? selectedGoalId,
              required int? selectedMilestoneId,
              required int? selectedTaskId,
            }) {
              return _pickTaskTarget(
                hierarchy: hierarchy,
                selectedGoalId: selectedGoalId,
                selectedMilestoneId: selectedMilestoneId,
                selectedTaskId: selectedTaskId,
              );
            },
            onSave: (input) async {
              await ref
                  .read(progressSyncServiceProvider)
                  .createSessionAndSync(input);
            },
          ),
        );
      },
    );
  }

  Future<_FocusTaskSelection?> _pickTaskTarget({
    required List<FocusHierarchyItem> hierarchy,
    required int? selectedGoalId,
    required int? selectedMilestoneId,
    required int? selectedTaskId,
  }) async {
    return showModalBottomSheet<_FocusTaskSelection>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      useSafeArea: true,
      builder: (sheetContext) {
        return FractionallySizedBox(
          heightFactor: 0.93,
          child: _FocusTargetPickerSheet(
            hierarchy: hierarchy,
            selectedGoalId: selectedGoalId,
            selectedMilestoneId: selectedMilestoneId,
            selectedTaskId: selectedTaskId,
            onSelectTask: (goalId, milestoneId, taskId, pathText) {
              Navigator.of(sheetContext).pop(
                _FocusTaskSelection(
                  goalId: goalId,
                  milestoneId: milestoneId,
                  taskId: taskId,
                  pathText: pathText,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<bool> _confirmTerminate() async {
    final l10n = AppLocalizations.of(context)!;
    return showAppConfirmDialog(
      context: context,
      title: l10n.focusEndTitle,
      message: l10n.focusEndMessage,
      confirmText: l10n.commonConfirm,
      cancelText: l10n.commonCancel,
    );
  }

  Future<void> _showCompletionDecisionDialog() async {
    if (_isCompletionDialogShowing || !mounted) {
      return;
    }
    _isCompletionDialogShowing = true;
    final l10n = AppLocalizations.of(context)!;
    final shouldEvaluate = await showAppConfirmDialog(
      context: context,
      title: l10n.focusCompletedTitle,
      message: l10n.focusCompletedMessage,
      confirmText: l10n.focusGoEvaluation,
      cancelText: l10n.commonClose,
    );
    _isCompletionDialogShowing = false;
    if (!mounted) {
      return;
    }
    if (shouldEvaluate == true) {
      context.push(RoutePaths.evaluation);
    }
  }
}

enum _FocusTopAction { history, manual }

class _FocusMenuActionRow extends StatelessWidget {
  const _FocusMenuActionRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurface),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _DurationChoiceButton extends StatelessWidget {
  const _DurationChoiceButton({
    required this.width,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final double width;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Ink(
        width: width,
        height: 40,
        decoration: BoxDecoration(
          color:
              selected
                  ? theme.colorScheme.primary.withValues(alpha: 0.10)
                  : theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.34,
                  ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                selected
                    ? theme.colorScheme.primary.withValues(alpha: 0.28)
                    : theme.colorScheme.outlineVariant.withValues(alpha: 0.16),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color:
                  selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.82),
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

typedef _TaskSelectCallback =
    void Function(int goalId, int milestoneId, int taskId, String pathText);

class _PickerCard extends StatelessWidget {
  const _PickerCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _FocusTargetPickerSheet extends StatelessWidget {
  const _FocusTargetPickerSheet({
    required this.hierarchy,
    required this.selectedGoalId,
    required this.selectedMilestoneId,
    required this.selectedTaskId,
    required this.onSelectTask,
  });

  final List<FocusHierarchyItem> hierarchy;
  final int? selectedGoalId;
  final int? selectedMilestoneId;
  final int? selectedTaskId;
  final _TaskSelectCallback onSelectTask;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Material(
      color: theme.scaffoldBackgroundColor,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Column(
        children: [
          // 鈹€鈹€ Header 鈹€鈹€
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, size: 22),
                  tooltip: l10n.commonClose,
                ),
                Expanded(
                  child: Text(
                    l10n.focusContextTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // 鈹€鈹€ Content 鈹€鈹€
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
              children: [
                for (
                  var goalIndex = 0;
                  goalIndex < hierarchy.length;
                  goalIndex++
                ) ...[
                  if (goalIndex > 0) const SizedBox(height: 14),
                  // Goal section label
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      hierarchy[goalIndex].goal.title,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  // Milestones card
                  if (hierarchy[goalIndex].milestones.isEmpty)
                    _PickerCard(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Text(
                            l10n.goalsNoMilestone,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    _PickerCard(
                      children: [
                        for (
                          var mIndex = 0;
                          mIndex < hierarchy[goalIndex].milestones.length;
                          mIndex++
                        ) ...[
                          if (mIndex > 0)
                            Divider(
                              height: 1,
                              indent: 16,
                              endIndent: 16,
                              color: theme.colorScheme.outlineVariant
                                  .withValues(alpha: 0.28),
                            ),
                          _buildMilestoneSection(
                            context: context,
                            theme: theme,
                            goalNode: hierarchy[goalIndex],
                            milestoneNode:
                                hierarchy[goalIndex].milestones[mIndex],
                            l10n: l10n,
                          ),
                        ],
                      ],
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneSection({
    required BuildContext context,
    required ThemeData theme,
    required FocusHierarchyItem goalNode,
    required FocusMilestoneItem milestoneNode,
    required AppLocalizations l10n,
  }) {
    final isExpanded =
        milestoneNode.milestone.id == selectedMilestoneId ||
        milestoneNode.tasks.any((task) => task.id == selectedTaskId);

    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: isExpanded,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: EdgeInsets.zero,
        shape: const Border(),
        collapsedShape: const Border(),
        title: Text(
          milestoneNode.milestone.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium,
        ),
        subtitle: Text(
          '${formatMinutes(milestoneNode.milestone.effectiveMinutes)} / ${formatMinutes(milestoneNode.milestone.estimateMinutes)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        children:
            milestoneNode.tasks.isEmpty
                ? [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Text(
                      l10n.goalsNoSearchResult,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ]
                : [
                  for (final task in milestoneNode.tasks)
                    _buildTaskRow(
                      context: context,
                      theme: theme,
                      goalNode: goalNode,
                      milestoneNode: milestoneNode,
                      task: task,
                    ),
                ],
      ),
    );
  }

  Widget _buildTaskRow({
    required BuildContext context,
    required ThemeData theme,
    required FocusHierarchyItem goalNode,
    required FocusMilestoneItem milestoneNode,
    required TaskModel task,
  }) {
    final isSelected = selectedTaskId == task.id;
    return InkWell(
      onTap:
          () => onSelectTask(
            goalNode.goal.id,
            milestoneNode.milestone.id,
            task.id,
            '${goalNode.goal.title}>${milestoneNode.milestone.title}>${task.title}',
          ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              size: 20,
              color:
                  isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.45,
                      ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color:
                          isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.w600 : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${formatMinutes(task.effectiveMinutes)} / ${formatMinutes(task.estimateMinutes)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

typedef _PickManualTarget =
    Future<_FocusTaskSelection?> Function({
      required int? selectedGoalId,
      required int? selectedMilestoneId,
      required int? selectedTaskId,
    });

typedef _SaveManualFocusSession =
    Future<void> Function(CreateFocusSessionInput input);

final class _FocusTaskSelection {
  const _FocusTaskSelection({
    required this.goalId,
    required this.milestoneId,
    required this.taskId,
    required this.pathText,
  });

  final int goalId;
  final int milestoneId;
  final int taskId;
  final String pathText;
}

class _ManualFocusSheet extends StatefulWidget {
  const _ManualFocusSheet({
    required this.hierarchy,
    required this.initialGoalId,
    required this.initialMilestoneId,
    required this.initialTaskId,
    required this.initialFocusMode,
    required this.onPickTarget,
    required this.onSave,
  });

  final List<FocusHierarchyItem> hierarchy;
  final int? initialGoalId;
  final int? initialMilestoneId;
  final int? initialTaskId;
  final FocusMode initialFocusMode;
  final _PickManualTarget onPickTarget;
  final _SaveManualFocusSession onSave;

  @override
  State<_ManualFocusSheet> createState() => _ManualFocusSheetState();
}

class _ManualFocusSheetState extends State<_ManualFocusSheet> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedStartTime;
  late TextEditingController _durationController;
  late TextEditingController _efficiencyController;
  late TextEditingController _noteController;

  _FocusTaskSelection? _selectedTarget;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _selectedStartTime = TimeOfDay(hour: now.hour, minute: now.minute);
    _durationController = TextEditingController(text: '25');
    _efficiencyController = TextEditingController(text: '60');
    _noteController = TextEditingController();
    _selectedTarget = _resolveTaskSelectionFromIds(
      hierarchy: widget.hierarchy,
      goalId: widget.initialGoalId,
      milestoneId: widget.initialMilestoneId,
      taskId: widget.initialTaskId,
    );
  }

  @override
  void dispose() {
    _durationController.dispose();
    _efficiencyController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final selectedDateLabel = DateFormat(
      'yyyy-MM-dd',
      locale,
    ).format(_selectedDate);
    final selectedTimeLabel = _selectedStartTime.format(context);

    return Material(
      color: theme.scaffoldBackgroundColor,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed:
                        _isSaving ? null : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    tooltip: l10n.commonClose,
                  ),
                  Expanded(
                    child: Text(
                      l10n.focusManualTitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                children: [
                  _ManualSectionLabel(label: l10n.focusManualDateLabel),
                  _PickerCard(
                    children: [
                      _ManualFieldTile(
                        icon: Icons.event_outlined,
                        label: l10n.focusManualDateLabel,
                        value: selectedDateLabel,
                        onTap: _isSaving ? null : _pickDate,
                      ),
                      Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.28,
                        ),
                      ),
                      _ManualFieldTile(
                        icon: Icons.schedule_outlined,
                        label: l10n.focusManualStartTimeLabel,
                        value: selectedTimeLabel,
                        onTap: _isSaving ? null : _pickStartTime,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _ManualSectionLabel(label: l10n.focusManualTargetLabel),
                  _PickerCard(
                    children: [
                      _ManualFieldTile(
                        icon: Icons.flag_outlined,
                        label: l10n.focusManualTargetLabel,
                        value:
                            _selectedTarget?.pathText ?? l10n.focusContextEmpty,
                        actionLabel: l10n.focusManualPickTarget,
                        onTap: _isSaving ? null : _pickTarget,
                        maxLines: 2,
                        showLabel: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _ManualSectionLabel(label: l10n.focusManualInfoTitle),
                  _PickerCard(
                    children: [
                      _ManualValueInputTile(
                        label: l10n.focusManualDurationLabel,
                        controller: _durationController,
                        enabled: !_isSaving,
                        keyboardType: TextInputType.number,
                      ),
                      Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.28,
                        ),
                      ),
                      _ManualValueInputTile(
                        label: l10n.focusManualEfficiencyLabel,
                        controller: _efficiencyController,
                        enabled: !_isSaving,
                        keyboardType: TextInputType.number,
                        suffix: '%',
                      ),
                      Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.28,
                        ),
                      ),
                      _ManualInputTile(
                        label: l10n.focusManualNoteLabel,
                        controller: _noteController,
                        enabled: !_isSaving,
                        maxLines: 4,
                        keyboardType: TextInputType.multiline,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                8,
                16,
                12 + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSaving ? null : _save,
                  child:
                      _isSaving
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : Text(l10n.focusManualSave),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: _selectedDate,
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() {
      _selectedDate = DateTime(picked.year, picked.month, picked.day);
    });
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedStartTime,
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() {
      _selectedStartTime = picked;
    });
  }

  Future<void> _pickTarget() async {
    final picked = await widget.onPickTarget(
      selectedGoalId: _selectedTarget?.goalId ?? widget.initialGoalId,
      selectedMilestoneId:
          _selectedTarget?.milestoneId ?? widget.initialMilestoneId,
      selectedTaskId: _selectedTarget?.taskId ?? widget.initialTaskId,
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() {
      _selectedTarget = picked;
    });
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final durationMinutes = int.tryParse(_durationController.text.trim());
    final efficiency = int.tryParse(_efficiencyController.text.trim());

    if (_selectedTarget == null ||
        durationMinutes == null ||
        durationMinutes <= 0 ||
        durationMinutes > 1440 ||
        efficiency == null ||
        efficiency < 0 ||
        efficiency > 100) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.focusManualInvalidInput)));
      }
      return;
    }

    final startedAt = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedStartTime.hour,
      _selectedStartTime.minute,
    );
    final endedAt = startedAt.add(Duration(minutes: durationMinutes));
    final note = _noteController.text.trim();

    setState(() {
      _isSaving = true;
    });
    try {
      await widget.onSave(
        CreateFocusSessionInput(
          goalId: _selectedTarget!.goalId,
          milestoneId: _selectedTarget!.milestoneId,
          taskId: _selectedTarget!.taskId,
          durationMinutes: durationMinutes,
          efficiencyPercent: efficiency,
          focusTargetLevel: FocusTargetLevel.task,
          focusMode:
              widget.initialFocusMode == FocusMode.free
                  ? FocusSessionMode.free
                  : FocusSessionMode.pomodoro,
          startedAt: startedAt,
          endedAt: endedAt,
          note: note.isEmpty ? null : note,
          isAbandoned: false,
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.focusManualSaved)));
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}

class _ManualFieldTile extends StatelessWidget {
  const _ManualFieldTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.actionLabel,
    this.maxLines = 1,
    this.showLabel = true,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final String? actionLabel;
  final int maxLines;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                icon,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showLabel)
                    Text(
                      label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  if (showLabel) const SizedBox(height: 4),
                  Text(
                    value,
                    maxLines: maxLines,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (actionLabel != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  actionLabel!,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManualSectionLabel extends StatelessWidget {
  const _ManualSectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _ManualInputTile extends StatelessWidget {
  const _ManualInputTile({
    required this.label,
    required this.controller,
    required this.enabled,
    required this.keyboardType,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final bool enabled;
  final TextInputType keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            enabled: enabled,
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ManualValueInputTile extends StatelessWidget {
  const _ManualValueInputTile({
    required this.label,
    required this.controller,
    required this.enabled,
    required this.keyboardType,
    this.suffix,
  });

  final String label;
  final TextEditingController controller;
  final bool enabled;
  final TextInputType keyboardType;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 42, maxWidth: 84),
            child: TextField(
              controller: controller,
              enabled: enabled,
              keyboardType: keyboardType,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (suffix != null) ...[
            const SizedBox(width: 4),
            Text(
              suffix!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

_FocusTaskSelection? _resolveTaskSelectionFromIds({
  required List<FocusHierarchyItem> hierarchy,
  required int? goalId,
  required int? milestoneId,
  required int? taskId,
}) {
  if (goalId == null || milestoneId == null || taskId == null) {
    return null;
  }
  for (final goalNode in hierarchy) {
    if (goalNode.goal.id != goalId) {
      continue;
    }
    for (final milestoneNode in goalNode.milestones) {
      if (milestoneNode.milestone.id != milestoneId) {
        continue;
      }
      for (final task in milestoneNode.tasks) {
        if (task.id == taskId) {
          return _FocusTaskSelection(
            goalId: goalId,
            milestoneId: milestoneId,
            taskId: taskId,
            pathText:
                '${goalNode.goal.title}>${milestoneNode.milestone.title}>${task.title}',
          );
        }
      }
    }
  }
  return null;
}

_FocusSelectedTarget? _resolveSelectedTarget({
  required List<FocusHierarchyItem> hierarchy,
  required FocusTimerState state,
}) {
  GoalModel? selectedGoal;
  FocusMilestoneItem? selectedMilestone;
  TaskModel? selectedTask;

  for (final goalNode in hierarchy) {
    if (goalNode.goal.id == state.selectedGoalId) {
      selectedGoal = goalNode.goal;
    }
    for (final milestoneNode in goalNode.milestones) {
      if (milestoneNode.milestone.id == state.selectedMilestoneId) {
        selectedMilestone = milestoneNode;
        selectedGoal ??= goalNode.goal;
      }
      for (final task in milestoneNode.tasks) {
        if (task.id == state.selectedTaskId) {
          selectedTask = task;
          selectedMilestone = milestoneNode;
          selectedGoal = goalNode.goal;
        }
      }
    }
  }

  if (selectedGoal == null &&
      selectedMilestone == null &&
      selectedTask == null) {
    return null;
  }

  return _FocusSelectedTarget(
    goal: selectedGoal,
    milestone: selectedMilestone?.milestone,
    task: selectedTask,
  );
}

final class _FocusSelectedTarget {
  const _FocusSelectedTarget({
    required this.goal,
    required this.milestone,
    required this.task,
  });

  final GoalModel? goal;
  final MilestoneModel? milestone;
  final TaskModel? task;

  String get displayPath {
    final parts = <String>[];
    if (goal != null) {
      parts.add(goal!.title);
    }
    if (milestone != null) {
      parts.add(milestone!.title);
    }
    if (task != null) {
      parts.add(task!.title);
    }
    return parts.join('>');
  }
}
