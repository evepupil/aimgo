import 'dart:math' as math;

import 'package:aimgo/app/l10n/generated/app_localizations.dart';
import 'package:aimgo/app/router/route_paths.dart';
import 'package:aimgo/core/utils/duration_formatter.dart';
import 'package:aimgo/core/utils/time_formatter.dart';
import 'package:aimgo/features/focus/application/focus_context_provider.dart';
import 'package:aimgo/features/focus/application/focus_models.dart';
import 'package:aimgo/features/focus/application/focus_timer_controller.dart';
import 'package:aimgo/shared/models/planning_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FocusPage extends ConsumerStatefulWidget {
  const FocusPage({super.key});

  @override
  ConsumerState<FocusPage> createState() => _FocusPageState();
}

class _FocusPageState extends ConsumerState<FocusPage>
    with WidgetsBindingObserver {
  final List<int> _pomodoroOptions = <int>[15, 25, 40, 60];

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

    return Scaffold(
      body: Stack(
        children: [
          NestedScrollView(
            headerSliverBuilder:
                (context, innerBoxIsScrolled) => [
                  SliverAppBar(
                    floating: true,
                    snap: true,
                    title: Text(l10n.focusTitle),
                    actions: [
                      IconButton(
                        onPressed: () {
                          final goalId = focusState.selectedGoalId;
                          if (goalId == null) {
                            context.push(RoutePaths.history);
                            return;
                          }
                          context.push('${RoutePaths.history}?goalId=$goalId');
                        },
                        icon: const Icon(Icons.history),
                        tooltip: l10n.focusHistory,
                      ),
                      IconButton(
                        onPressed:
                            focusState.status == FocusTimerStatus.running
                                ? null
                                : () => _openFocusTargetPicker(
                                  hierarchy: hierarchy,
                                  state: focusState,
                                ),
                        icon: const Icon(Icons.add),
                        tooltip: l10n.focusContextTitle,
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) {
                          if (value == 'settings') {
                            context.push(RoutePaths.settings);
                          }
                        },
                        itemBuilder:
                            (context) => [
                              PopupMenuItem<String>(
                                value: 'settings',
                                child: Text(l10n.settingsTitle),
                              ),
                            ],
                      ),
                    ],
                  ),
                ],
            body: ListView(
              padding: EdgeInsets.fromLTRB(
                layoutMetrics.horizontalPadding,
                layoutMetrics.topPadding,
                layoutMetrics.horizontalPadding,
                layoutMetrics.bottomPadding,
              ),
              children: [
                _FocusModeTabSwitch(
                  mode: focusState.mode,
                  onChange: focusController.setMode,
                  pomodoroLabel: l10n.focusModePomodoro,
                  freeLabel: l10n.focusModeFree,
                ),
                SizedBox(height: layoutMetrics.modeToTargetSpacing),
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
                          SizedBox(
                            width: layoutMetrics.timerSize,
                            height: layoutMetrics.timerSize,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.outlineVariant,
                                  width: layoutMetrics.timerStrokeWidth,
                                ),
                              ),
                            ),
                          ),
                          if (focusState.mode == FocusMode.pomodoro)
                            CircularProgressIndicator(
                              value: focusState.progressRatio,
                              strokeWidth: layoutMetrics.timerStrokeWidth,
                              backgroundColor: Colors.transparent,
                            ),
                          if (focusState.mode == FocusMode.free &&
                              focusState.status != FocusTimerStatus.idle)
                            CircularProgressIndicator(
                              value: 1,
                              strokeWidth: layoutMetrics.timerStrokeWidth,
                              backgroundColor: Colors.transparent,
                            ),
                          SizedBox(
                            width:
                                layoutMetrics.timerSize -
                                (layoutMetrics.timerStrokeWidth * 2),
                            height:
                                layoutMetrics.timerSize -
                                (layoutMetrics.timerStrokeWidth * 2),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).colorScheme.surface,
                              ),
                            ),
                          ),
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
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              if (focusState.mode == FocusMode.pomodoro) ...[
                                SizedBox(
                                  height: layoutMetrics.timerPresetTopSpacing,
                                ),
                                Text(
                                  l10n.focusPomodoroPreset(
                                    focusState.pomodoroMinutes.toString(),
                                  ),
                                  style: Theme.of(context).textTheme.bodySmall,
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

    final controller = ref.read(focusTimerControllerProvider.notifier);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      useSafeArea: true,
      builder: (sheetContext) {
        return FractionallySizedBox(
          heightFactor: 0.93,
          child: _FocusTargetPickerSheet(
            hierarchy: hierarchy,
            selectedGoalId: state.selectedGoalId,
            selectedMilestoneId: state.selectedMilestoneId,
            selectedTaskId: state.selectedTaskId,
            onSelectTask: (goalId, milestoneId, taskId) {
              controller.selectGoal(goalId);
              controller.selectMilestone(milestoneId);
              controller.selectTask(taskId);
              Navigator.of(sheetContext).pop();
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
    final mutedColor = theme.colorScheme.onSurfaceVariant;
    final pathStyle = theme.textTheme.titleMedium?.copyWith(
      color: enabled ? null : mutedColor,
      fontWeight: FontWeight.w600,
    );

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                pathText,
                style: pathStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 18, color: mutedColor),
          ],
        ),
      ),
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
        _FocusModeTabItem(
          label: pomodoroLabel,
          selected: mode == FocusMode.pomodoro,
          activeColor: activeColor,
          inactiveColor: inactiveColor,
          onTap: () => onChange(FocusMode.pomodoro),
        ),
        const SizedBox(width: 14),
        _FocusModeTabItem(
          label: freeLabel,
          selected: mode == FocusMode.free,
          activeColor: activeColor,
          inactiveColor: inactiveColor,
          onTap: () => onChange(FocusMode.free),
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
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: selected ? activeColor : inactiveColor,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              height: 2.5,
              width: 52,
              decoration: BoxDecoration(
                color:
                    selected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ],
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
      borderRadius: BorderRadius.circular(12),
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
          borderRadius: BorderRadius.circular(12),
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
            width: 190,
            height: 46,
            child: FilledButton(
              style: FilledButton.styleFrom(
                shape: const StadiumBorder(),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
      topPadding: compactHeight ? 14 : 20,
      bottomPadding: 20,
      modeToTargetSpacing: compactHeight ? 24 : 36,
      targetToTimerSpacing: compactHeight ? 26 : 52,
      timerToControlSpacing: compactHeight ? 26 : 54,
      timerSize: timerSize,
      timerStrokeWidth: compactWidth ? 8 : 10,
      timerTextSize: compactWidth ? 32 : 36,
      timerLabelSpacing: compactHeight ? 4 : 6,
      timerPresetTopSpacing: compactHeight ? 2 : 4,
    );
  }
}

typedef _TaskSelectCallback =
    void Function(int goalId, int milestoneId, int taskId);

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
    final dividerColor = Theme.of(context).colorScheme.outlineVariant;

    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
                tooltip: l10n.commonClose,
              ),
              Expanded(
                child: Text(
                  l10n.focusContextTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          Divider(height: 1, color: dividerColor),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 20),
              children: [
                for (final goalNode in hierarchy) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                    child: Text(
                      goalNode.goal.title,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  if (goalNode.milestones.isEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      child: Text(
                        l10n.goalsNoMilestone,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  for (final milestoneNode in goalNode.milestones)
                    Theme(
                      data: Theme.of(
                        context,
                      ).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        initiallyExpanded:
                            milestoneNode.milestone.id == selectedMilestoneId ||
                            milestoneNode.tasks.any(
                              (task) => task.id == selectedTaskId,
                            ),
                        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                        childrenPadding: EdgeInsets.zero,
                        title: Text(
                          milestoneNode.milestone.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${formatMinutes(milestoneNode.milestone.effectiveMinutes)} / ${formatMinutes(milestoneNode.milestone.estimateMinutes)}',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        children:
                            milestoneNode.tasks.isEmpty
                                ? [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      24,
                                      0,
                                      16,
                                      10,
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        l10n.goalsNoSearchResult,
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                      ),
                                    ),
                                  ),
                                ]
                                : [
                                  for (final task in milestoneNode.tasks)
                                    ListTile(
                                      contentPadding: const EdgeInsets.fromLTRB(
                                        24,
                                        0,
                                        12,
                                        0,
                                      ),
                                      leading: Icon(
                                        selectedTaskId == task.id
                                            ? Icons.check_circle
                                            : Icons.radio_button_unchecked,
                                        color:
                                            selectedTaskId == task.id
                                                ? Theme.of(
                                                  context,
                                                ).colorScheme.primary
                                                : Theme.of(
                                                  context,
                                                ).colorScheme.outline,
                                      ),
                                      title: Text(
                                        task.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: Text(
                                        '${formatMinutes(task.effectiveMinutes)} / ${formatMinutes(task.estimateMinutes)}',
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.labelSmall,
                                      ),
                                      onTap:
                                          () => onSelectTask(
                                            goalNode.goal.id,
                                            milestoneNode.milestone.id,
                                            task.id,
                                          ),
                                    ),
                                ],
                      ),
                    ),
                  Divider(height: 1, color: dividerColor),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
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
