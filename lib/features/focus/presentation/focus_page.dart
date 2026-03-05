import 'package:aimgo/app/l10n/generated/app_localizations.dart';
import 'package:aimgo/app/router/route_paths.dart';
import 'package:aimgo/core/utils/duration_formatter.dart';
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

    final hierarchy =
        hierarchyAsync.valueOrNull ?? const <FocusHierarchyItem>[];

    return Scaffold(
      appBar: AppBar(
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
            onPressed: () => context.push(RoutePaths.settings),
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.settingsTitle,
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            children: [
              SegmentedButton<FocusMode>(
                segments: [
                  ButtonSegment(
                    value: FocusMode.pomodoro,
                    icon: const Icon(Icons.timer_outlined),
                    label: Text(l10n.focusModePomodoro),
                  ),
                  ButtonSegment(
                    value: FocusMode.free,
                    icon: const Icon(Icons.timelapse_outlined),
                    label: Text(l10n.focusModeFree),
                  ),
                ],
                selected: {focusState.mode},
                onSelectionChanged: (selection) {
                  focusController.setMode(selection.first);
                },
              ),
              const SizedBox(height: 12),
              _FocusContextSection(
                hierarchy: hierarchy,
                state: focusState,
                onGoalChanged: focusController.selectGoal,
                onMilestoneChanged: focusController.selectMilestone,
                onTaskChanged: focusController.selectTask,
              ),
              const SizedBox(height: 12),
              Center(
                child: GestureDetector(
                  onTap:
                      focusState.mode == FocusMode.pomodoro
                          ? _openPomodoroDurationPicker
                          : null,
                  child: SizedBox(
                    width: 220,
                    height: 220,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value:
                              focusState.mode == FocusMode.pomodoro
                                  ? focusState.progressRatio
                                  : null,
                          strokeWidth: 10,
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
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              focusState.mode == FocusMode.pomodoro
                                  ? l10n.focusRemaining
                                  : l10n.focusElapsed,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            if (focusState.mode == FocusMode.pomodoro) ...[
                              const SizedBox(height: 4),
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
              const SizedBox(height: 16),
              _FocusControlSection(
                state: focusState,
                canStart: focusState.hasSelection,
                onStart: focusController.startOrResume,
                onPause: focusController.pause,
                onTerminate: () async {
                  final confirm = await _confirmTerminate();
                  if (confirm) {
                    focusController.terminate(isAbandoned: false);
                  }
                },
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
    final options = [25, 45, 60, 90];
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(title: Text(l10n.focusPickDuration)),
              for (final value in options)
                ListTile(
                  leading: const Icon(Icons.timer),
                  title: Text(l10n.focusPomodoroPreset(value.toString())),
                  onTap: () {
                    ref
                        .read(focusTimerControllerProvider.notifier)
                        .setPomodoroMinutes(value);
                    Navigator.of(context).pop();
                  },
                ),
            ],
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

class _FocusControlSection extends StatelessWidget {
  const _FocusControlSection({
    required this.state,
    required this.canStart,
    required this.onStart,
    required this.onPause,
    required this.onTerminate,
    required this.l10n,
  });

  final FocusTimerState state;
  final bool canStart;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onTerminate;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case FocusTimerStatus.idle:
        return FilledButton.icon(
          onPressed: canStart ? onStart : null,
          icon: const Icon(Icons.play_arrow),
          label: Text(l10n.focusStart),
        );
      case FocusTimerStatus.running:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onPause,
                icon: const Icon(Icons.pause),
                label: Text(l10n.focusPause),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: onTerminate,
                icon: const Icon(Icons.stop),
                label: Text(l10n.focusTerminate),
              ),
            ),
          ],
        );
      case FocusTimerStatus.paused:
        return Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: onStart,
                icon: const Icon(Icons.play_arrow),
                label: Text(l10n.focusResume),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onTerminate,
                icon: const Icon(Icons.stop),
                label: Text(l10n.focusTerminate),
              ),
            ),
          ],
        );
    }
  }
}

class _FocusContextSection extends StatelessWidget {
  const _FocusContextSection({
    required this.hierarchy,
    required this.state,
    required this.onGoalChanged,
    required this.onMilestoneChanged,
    required this.onTaskChanged,
  });

  final List<FocusHierarchyItem> hierarchy;
  final FocusTimerState state;
  final void Function(int?) onGoalChanged;
  final void Function(int?) onMilestoneChanged;
  final void Function(int?) onTaskChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final selectedGoal = _findGoal(hierarchy, state.selectedGoalId);

    final milestones = selectedGoal?.milestones ?? const <FocusMilestoneItem>[];
    final selectedMilestone = _findMilestone(
      milestones,
      state.selectedMilestoneId,
    );
    final tasks = selectedMilestone?.tasks ?? const <TaskModel>[];
    final selectedTask = _findTask(tasks, state.selectedTaskId);

    final pathSegments = <String>[];
    if (selectedGoal != null) {
      pathSegments.add(selectedGoal.goal.title);
    }
    if (selectedMilestone != null) {
      pathSegments.add(selectedMilestone.milestone.title);
    }
    if (selectedTask != null) {
      pathSegments.add(selectedTask.title);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.focusContextTitle,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: state.selectedGoalId,
              decoration: InputDecoration(
                labelText: l10n.goalsCreateTypeGoal,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              items: [
                for (final item in hierarchy)
                  DropdownMenuItem<int>(
                    value: item.goal.id,
                    child: Text(
                      item.goal.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged:
                  state.status == FocusTimerStatus.running
                      ? null
                      : onGoalChanged,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: state.selectedMilestoneId,
              decoration: InputDecoration(
                labelText: l10n.goalsCreateTypeMilestone,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              items: [
                for (final item in milestones)
                  DropdownMenuItem<int>(
                    value: item.milestone.id,
                    child: Text(
                      item.milestone.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged:
                  state.status == FocusTimerStatus.running
                      ? null
                      : onMilestoneChanged,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: state.selectedTaskId,
              decoration: InputDecoration(
                labelText: l10n.goalsCreateTypeTask,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              items: [
                for (final item in tasks)
                  DropdownMenuItem<int>(
                    value: item.id,
                    child: Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged:
                  state.status == FocusTimerStatus.running
                      ? null
                      : onTaskChanged,
            ),
            if (pathSegments.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                pathSegments.join(' > '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

FocusHierarchyItem? _findGoal(List<FocusHierarchyItem> items, int? goalId) {
  if (goalId == null) {
    return null;
  }
  for (final item in items) {
    if (item.goal.id == goalId) {
      return item;
    }
  }
  return null;
}

FocusMilestoneItem? _findMilestone(
  List<FocusMilestoneItem> items,
  int? milestoneId,
) {
  if (milestoneId == null) {
    return null;
  }
  for (final item in items) {
    if (item.milestone.id == milestoneId) {
      return item;
    }
  }
  return null;
}

TaskModel? _findTask(List<TaskModel> items, int? taskId) {
  if (taskId == null) {
    return null;
  }
  for (final item in items) {
    if (item.id == taskId) {
      return item;
    }
  }
  return null;
}
