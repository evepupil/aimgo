import 'dart:math' as math;

import 'package:aimgo/app/l10n/generated/app_localizations.dart';
import 'package:aimgo/app/router/route_paths.dart';
import 'package:aimgo/core/constants/layout_tokens.dart';
import 'package:aimgo/core/services/local_storage_service.dart';
import 'package:aimgo/core/utils/duration_formatter.dart';
import 'package:aimgo/core/utils/time_formatter.dart';
import 'package:aimgo/features/focus/application/focus_context_provider.dart';
import 'package:aimgo/features/focus/application/focus_evaluation_draft_controller.dart';
import 'package:aimgo/features/focus/application/focus_models.dart';
import 'package:aimgo/features/focus/application/focus_timer_controller.dart';
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
  bool _isCompletionDialogShowing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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

    ref.listen<FocusTimerState>(focusTimerControllerProvider, (previous, next) {
      if (previous == null) {
        return;
      }
      if (next.completionEventId == previous.completionEventId) {
        return;
      }
      final autoOpenEvaluation =
          ref.read(localStorageServiceProvider).getAutoOpenEvaluationEnabled();
      final draft = ref.read(focusEvaluationDraftProvider);
      if (draft == null) {
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
    });

    final focusState = ref.watch(focusTimerControllerProvider);
    final focusController = ref.read(focusTimerControllerProvider.notifier);
    final hierarchyAsync = ref.watch(focusHierarchyProvider);
    final layoutMetrics = _FocusLayoutMetrics.fromSize(
      MediaQuery.sizeOf(context),
    );
    final timerTextStyle = Theme.of(context).textTheme.headlineMedium?.copyWith(
      fontSize: layoutMetrics.timerTextSize,
      height: 1.05,
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
          PopupMenuButton<_FocusTopAction>(
            icon: const Icon(Icons.more_horiz),
            position: PopupMenuPosition.under,
            elevation: 6,
            constraints: const BoxConstraints(minWidth: 132, maxWidth: 142),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(LayoutTokens.radiusMedium),
            ),
            onSelected: (_FocusTopAction action) {
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
            itemBuilder:
                (menuContext) => [
                  PopupMenuItem<_FocusTopAction>(
                    value: _FocusTopAction.history,
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: _FocusMenuActionRow(
                      icon: Icons.history,
                      label: l10n.historyTitle,
                    ),
                  ),
                  PopupMenuItem<_FocusTopAction>(
                    value: _FocusTopAction.manual,
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: _FocusMenuActionRow(
                      icon: Icons.add_circle_outline,
                      label: l10n.focusManualAddTooltip,
                    ),
                  ),
                ],
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
              // ── Mode switch in a white card ──
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
                  child: _FocusModeTabSwitch(
                    mode: focusState.mode,
                    onChange: focusController.setMode,
                    pomodoroLabel: l10n.focusModePomodoro,
                    freeLabel: l10n.focusModeFree,
                  ),
                ),
              ),
              SizedBox(height: layoutMetrics.modeToTargetSpacing),

              // ── Target selector in a white card ──
              _FocusTargetEntry(
                enabled: focusState.status != FocusTimerStatus.running,
                pathText:
                    selectedTarget?.displayPath ??
                    AppLocalizations.of(context)!.focusContextEmpty,
                onTap:
                    () => _openFocusTargetPicker(
                      hierarchy: hierarchy,
                      state: focusState,
                    ),
              ),
              SizedBox(height: layoutMetrics.targetToTimerSpacing),

              // ── Timer ring ──
              Center(
                child: GestureDetector(
                  onTap:
                      focusState.mode == FocusMode.pomodoro
                          ? _openPomodoroDurationPicker
                          : null,
                  child: SizedBox(
                    width: layoutMetrics.timerSize,
                    height: layoutMetrics.timerSize,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background ring
                        SizedBox.expand(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.colorScheme.surface,
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.06),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Track ring
                        SizedBox.expand(
                          child: CircularProgressIndicator(
                            value: 1,
                            strokeWidth: layoutMetrics.timerStrokeWidth,
                            backgroundColor: Colors.transparent,
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          ),
                        ),
                        // Progress ring
                        if (focusState.mode == FocusMode.pomodoro)
                          SizedBox.expand(
                            child: CircularProgressIndicator(
                              value: focusState.progressRatio,
                              strokeWidth: layoutMetrics.timerStrokeWidth,
                              backgroundColor: Colors.transparent,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        if (focusState.mode == FocusMode.free &&
                            focusState.status != FocusTimerStatus.idle)
                          SizedBox.expand(
                            child: CircularProgressIndicator(
                              value: 1,
                              strokeWidth: layoutMetrics.timerStrokeWidth,
                              backgroundColor: Colors.transparent,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        // Timer text
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              focusState.mode == FocusMode.pomodoro
                                  ? formatClockFromSeconds(
                                    focusState.remainingSeconds,
                                  )
                                  : formatClockFromSeconds(
                                    focusState.displayElapsedSeconds,
                                  ),
                              style: timerTextStyle,
                            ),
                            SizedBox(height: layoutMetrics.timerLabelSpacing),
                            Text(
                              focusState.mode == FocusMode.pomodoro
                                  ? l10n.focusRemaining
                                  : l10n.focusElapsed,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            if (focusState.mode == FocusMode.pomodoro) ...[
                              SizedBox(
                                height: layoutMetrics.timerPresetTopSpacing,
                              ),
                              Text(
                                l10n.focusPomodoroPreset(
                                  focusState.pomodoroMinutes.toString(),
                                ),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: layoutMetrics.timerToControlSpacing),

              // ── Control buttons ──
              _FocusControlSection(
                state: focusState,
                canStart: focusState.selectedTaskId != null,
                onStart: focusController.startOrResume,
                onPause: focusController.pause,
                onTerminate: () async {
                  final confirm = await _confirmTerminate();
                  if (confirm) {
                    focusController.terminate(isAbandoned: false);
                  }
                },
                onChangeDuration: _openPomodoroDurationPicker,
                l10n: l10n,
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.focusEndTitle),
          content: Text(l10n.focusEndMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.commonConfirm),
            ),
          ],
        );
      },
    );
    return confirmed == true;
  }

  Future<void> _showCompletionDecisionDialog() async {
    if (_isCompletionDialogShowing || !mounted) {
      return;
    }
    _isCompletionDialogShowing = true;
    final l10n = AppLocalizations.of(context)!;
    final shouldEvaluate = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.focusCompletedTitle),
          content: Text(l10n.focusCompletedMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.commonClose),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.focusGoEvaluation),
            ),
          ],
        );
      },
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
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _FocusTargetEntry extends StatelessWidget {
  const _FocusTargetEntry({
    required this.enabled,
    required this.pathText,
    required this.onTap,
  });

  final bool enabled;
  final String pathText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fgColor =
        enabled
            ? theme.colorScheme.onSurface
            : theme.colorScheme.onSurfaceVariant;

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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  Icons.flag_outlined,
                  size: 22,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.78),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _FocusTargetBreadcrumb(
                    pathText: pathText,
                    color: fgColor,
                    separatorColor: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FocusTargetBreadcrumb extends StatelessWidget {
  const _FocusTargetBreadcrumb({
    required this.pathText,
    required this.color,
    required this.separatorColor,
  });

  final String pathText;
  final Color color;
  final Color separatorColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final parts =
        pathText
            .split('>')
            .map((segment) => segment.trim())
            .where((segment) => segment.isNotEmpty)
            .toList();

    if (parts.isEmpty) {
      return Text(
        pathText,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleSmall?.copyWith(
          color: separatorColor,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    return Text.rich(
      TextSpan(
        children: [
          for (var i = 0; i < parts.length; i++) ...[
            TextSpan(
              text: parts[i],
              style: theme.textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight:
                    i == parts.length - 1 ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            if (i != parts.length - 1)
              TextSpan(
                text: '  >  ',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: separatorColor.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _FocusModeTabSwitch extends StatelessWidget {
  const _FocusModeTabSwitch({
    required this.mode,
    required this.onChange,
    required this.pomodoroLabel,
    required this.freeLabel,
  });

  final FocusMode mode;
  final void Function(FocusMode mode) onChange;
  final String pomodoroLabel;
  final String freeLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = theme.colorScheme.onSurface;
    final inactiveColor = theme.colorScheme.onSurfaceVariant;
    return Row(
      children: [
        Expanded(
          child: _FocusModeTabItem(
            label: pomodoroLabel,
            selected: mode == FocusMode.pomodoro,
            activeColor: activeColor,
            inactiveColor: inactiveColor,
            onTap: () => onChange(FocusMode.pomodoro),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: _FocusModeTabItem(
            label: freeLabel,
            selected: mode == FocusMode.free,
            activeColor: activeColor,
            inactiveColor: inactiveColor,
            onTap: () => onChange(FocusMode.free),
          ),
        ),
      ],
    );
  }
}

class _FocusModeTabItem extends StatelessWidget {
  const _FocusModeTabItem({
    required this.label,
    required this.selected,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color:
              selected
                  ? theme.colorScheme.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Center(
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: selected ? theme.colorScheme.primary : inactiveColor,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
      ),
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
      borderRadius: BorderRadius.circular(LayoutTokens.radiusMedium),
      onTap: onTap,
      child: Ink(
        width: width,
        height: 44,
        decoration: BoxDecoration(
          color:
              selected
                  ? theme.colorScheme.primary.withValues(alpha: 0.12)
                  : theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.55,
                  ),
          borderRadius: BorderRadius.circular(LayoutTokens.radiusMedium),
          border:
              selected
                  ? Border.all(color: theme.colorScheme.primary, width: 1.2)
                  : null,
        ),
        child: Center(
          child: Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(
              color: selected ? theme.colorScheme.primary : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _FocusControlSection extends StatelessWidget {
  const _FocusControlSection({
    required this.state,
    required this.canStart,
    required this.onStart,
    required this.onPause,
    required this.onTerminate,
    required this.onChangeDuration,
    required this.l10n,
  });

  final FocusTimerState state;
  final bool canStart;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onTerminate;
  final VoidCallback onChangeDuration;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case FocusTimerStatus.idle:
        return Center(
          child: SizedBox(
            width: 200,
            height: 48,
            child: FilledButton(
              style: FilledButton.styleFrom(
                shape: const StadiumBorder(),
              ),
              onPressed: canStart ? onStart : null,
              child: Text(l10n.focusStart),
            ),
          ),
        );
      case FocusTimerStatus.running:
        return _FocusRunningControlRow(
          showDurationAction: state.mode == FocusMode.pomodoro,
          centerIcon: Icons.pause_rounded,
          centerTooltip: l10n.focusPause,
          onCenterTap: onPause,
          onSideTap: onTerminate,
          onDurationTap: onChangeDuration,
          sideTooltip: l10n.focusTerminate,
          durationTooltip: l10n.focusPickDuration,
        );
      case FocusTimerStatus.paused:
        return _FocusRunningControlRow(
          showDurationAction: state.mode == FocusMode.pomodoro,
          centerIcon: Icons.play_arrow_rounded,
          centerTooltip: l10n.focusResume,
          onCenterTap: onStart,
          onSideTap: onTerminate,
          onDurationTap: onChangeDuration,
          sideTooltip: l10n.focusTerminate,
          durationTooltip: l10n.focusPickDuration,
        );
    }
  }
}

class _FocusRunningControlRow extends StatelessWidget {
  const _FocusRunningControlRow({
    required this.showDurationAction,
    required this.centerIcon,
    required this.centerTooltip,
    required this.onCenterTap,
    required this.onSideTap,
    required this.onDurationTap,
    required this.sideTooltip,
    required this.durationTooltip,
  });

  final bool showDurationAction;
  final IconData centerIcon;
  final String centerTooltip;
  final VoidCallback onCenterTap;
  final VoidCallback onSideTap;
  final VoidCallback onDurationTap;
  final String sideTooltip;
  final String durationTooltip;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _FocusOutlineCircleButton(
          icon: Icons.timer_outlined,
          tooltip: durationTooltip,
          onPressed: showDurationAction ? onDurationTap : null,
          size: 62,
        ),
        const SizedBox(width: 24),
        _FocusPrimaryCircleButton(
          icon: centerIcon,
          tooltip: centerTooltip,
          onPressed: onCenterTap,
          size: 90,
        ),
        const SizedBox(width: 24),
        _FocusOutlineCircleButton(
          icon: Icons.stop_rounded,
          tooltip: sideTooltip,
          onPressed: onSideTap,
          size: 62,
        ),
      ],
    );
  }
}

class _FocusPrimaryCircleButton extends StatelessWidget {
  const _FocusPrimaryCircleButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    required this.size,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Tooltip(
        message: tooltip,
        child: FilledButton(
          style: FilledButton.styleFrom(
            shape: const CircleBorder(),
            padding: EdgeInsets.zero,
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          onPressed: onPressed,
          child: Icon(icon, size: size * 0.42),
        ),
      ),
    );
  }
}

class _FocusOutlineCircleButton extends StatelessWidget {
  const _FocusOutlineCircleButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    required this.size,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Tooltip(
        message: tooltip,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            shape: const CircleBorder(),
            padding: EdgeInsets.zero,
            side: BorderSide(color: Theme.of(context).colorScheme.outline),
          ),
          onPressed: onPressed,
          child: Icon(icon, size: size * 0.38),
        ),
      ),
    );
  }
}

class _FocusLayoutMetrics {
  const _FocusLayoutMetrics({
    required this.horizontalPadding,
    required this.topPadding,
    required this.bottomPadding,
    required this.modeToTargetSpacing,
    required this.targetToTimerSpacing,
    required this.timerToControlSpacing,
    required this.timerSize,
    required this.timerStrokeWidth,
    required this.timerTextSize,
    required this.timerLabelSpacing,
    required this.timerPresetTopSpacing,
  });

  final double horizontalPadding;
  final double topPadding;
  final double bottomPadding;
  final double modeToTargetSpacing;
  final double targetToTimerSpacing;
  final double timerToControlSpacing;
  final double timerSize;
  final double timerStrokeWidth;
  final double timerTextSize;
  final double timerLabelSpacing;
  final double timerPresetTopSpacing;

  factory _FocusLayoutMetrics.fromSize(Size size) {
    final compactWidth = size.width <= 360;
    final compactHeight = size.height <= 720;
    final widthBasedTimer = size.width - (compactWidth ? 30 : 44);
    final targetTimer = compactHeight ? 182.0 : 224.0;
    final timerSize = math.max(164.0, math.min(widthBasedTimer, targetTimer));

    return _FocusLayoutMetrics(
      horizontalPadding: compactWidth ? 12 : 16,
      topPadding: compactHeight ? 30 : 40,
      bottomPadding: 30,
      modeToTargetSpacing: compactHeight ? 18 : 24,
      targetToTimerSpacing: compactHeight ? 30 : 40,
      timerToControlSpacing: compactHeight ? 28 : 42,
      timerSize: timerSize,
      timerStrokeWidth: compactWidth ? 8 : 10,
      timerTextSize: compactWidth ? 32 : 36,
      timerLabelSpacing: compactHeight ? 4 : 6,
      timerPresetTopSpacing: compactHeight ? 2 : 4,
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
          // ── Header ──
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

          // ── Content ──
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
              children: [
                for (var goalIndex = 0;
                    goalIndex < hierarchy.length;
                    goalIndex++) ...[
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
                        for (var mIndex = 0;
                            mIndex <
                                hierarchy[goalIndex].milestones.length;
                            mIndex++) ...[
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
      color: theme.colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            Row(
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
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                children: [
                  _ManualFieldTile(
                    label: l10n.focusManualDateLabel,
                    value: selectedDateLabel,
                    onTap: _isSaving ? null : _pickDate,
                  ),
                  const SizedBox(height: 10),
                  _ManualFieldTile(
                    label: l10n.focusManualStartTimeLabel,
                    value: selectedTimeLabel,
                    onTap: _isSaving ? null : _pickStartTime,
                  ),
                  const SizedBox(height: 10),
                  _ManualFieldTile(
                    label: l10n.focusManualTargetLabel,
                    value: _selectedTarget?.pathText ?? l10n.focusContextEmpty,
                    actionLabel: l10n.focusManualPickTarget,
                    onTap: _isSaving ? null : _pickTarget,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _durationController,
                    enabled: !_isSaving,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.focusManualDurationLabel,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _efficiencyController,
                    enabled: !_isSaving,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.focusManualEfficiencyLabel,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _noteController,
                    enabled: !_isSaving,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: l10n.focusManualNoteLabel,
                    ),
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
    required this.label,
    required this.value,
    required this.onTap,
    this.actionLabel,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: theme.textTheme.labelMedium),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              if (actionLabel != null)
                Text(
                  actionLabel!,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
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
