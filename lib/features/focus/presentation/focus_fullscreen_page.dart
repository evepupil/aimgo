import 'package:aimgo/app/l10n/generated/app_localizations.dart';
import 'package:aimgo/features/focus/application/focus_context_provider.dart';
import 'package:aimgo/features/focus/application/focus_models.dart';
import 'package:aimgo/features/focus/application/focus_timer_controller.dart';
import 'package:aimgo/features/focus/presentation/widgets/focus_session_widgets.dart';
import 'package:aimgo/shared/models/planning_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FocusFullscreenPage extends ConsumerStatefulWidget {
  const FocusFullscreenPage({super.key});

  @override
  ConsumerState<FocusFullscreenPage> createState() =>
      _FocusFullscreenPageState();
}

class _FocusFullscreenPageState extends ConsumerState<FocusFullscreenPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    ref.listen<FocusTimerState>(focusTimerControllerProvider, (previous, next) {
      if (previous == null) {
        return;
      }
      if (previous.status != FocusTimerStatus.idle &&
          next.status == FocusTimerStatus.idle &&
          mounted) {
        Navigator.of(context).pop();
      }
    });

    final state = ref.watch(focusTimerControllerProvider);
    final controller = ref.read(focusTimerControllerProvider.notifier);
    final hierarchy =
        ref.watch(focusHierarchyProvider).valueOrNull ??
        const <FocusHierarchyItem>[];
    final selectedPath = _buildSelectedPath(hierarchy: hierarchy, state: state);
    final metrics = FocusSessionLayoutMetrics.fromSize(
      MediaQuery.sizeOf(context),
    );
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                metrics.horizontalPadding,
                metrics.topPadding,
                metrics.horizontalPadding,
                metrics.bottomPadding,
              ),
              child: Column(
                children: [
                  const SizedBox(height: kToolbarHeight),
                  IgnorePointer(
                    child: Opacity(
                      opacity: 0,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.04,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: FocusSessionModeTabs(
                            mode: state.mode,
                            pomodoroLabel: l10n.focusModePomodoro,
                            freeLabel: l10n.focusModeFree,
                            enabled: false,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: metrics.modeToTargetSpacing),
                  Hero(
                    tag: FocusSessionHeroTags.targetEntry,
                    child: FocusSessionTargetEntry(
                      enabled: false,
                      hasSelection: selectedPath.isNotEmpty,
                      pathText:
                          selectedPath.isEmpty
                              ? l10n.focusContextOptional
                              : selectedPath,
                      onTap: null,
                    ),
                  ),
                  SizedBox(height: metrics.targetToTimerSpacing),
                  Hero(
                    tag: FocusSessionHeroTags.timerRing,
                    child: FocusSessionTimerRing(
                      state: state,
                      metrics: metrics,
                      l10n: l10n,
                    ),
                  ),
                  SizedBox(height: metrics.timerToControlSpacing),
                  Hero(
                    tag: FocusSessionHeroTags.controls,
                    child: FocusSessionControls(
                      state: state,
                      canStart: true,
                      onStart: controller.startOrResume,
                      onPause: controller.pause,
                      onTerminate: () => _terminateSession(context),
                      l10n: l10n,
                    ),
                  ),
                  const Spacer(),
                  FocusSessionNoteEntry(
                    label: l10n.focusNoteEntry,
                    onTap: () => _openNoteSheet(context),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 4,
              top: 0,
              child: IconButton(
                onPressed: () {
                  controller.pause();
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.arrow_back_rounded),
                tooltip: l10n.commonClose,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _terminateSession(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = ref.read(focusTimerControllerProvider.notifier);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.focusEndTitle),
          content: Text(l10n.focusEndMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.focusTerminate),
            ),
          ],
        );
      },
    );
    if (confirm != true || !context.mounted) {
      return;
    }
    controller.terminate(isAbandoned: false);
    Navigator.of(context).pop();
  }

  Future<void> _openNoteSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _FocusNoteSheet(),
    );
  }
}

class _FocusNoteSheet extends ConsumerStatefulWidget {
  const _FocusNoteSheet();

  @override
  ConsumerState<_FocusNoteSheet> createState() => _FocusNoteSheetState();
}

class _FocusNoteSheetState extends ConsumerState<_FocusNoteSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(focusTimerControllerProvider).noteDraft ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
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
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                        child: TextField(
                          controller: _controller,
                          autofocus: true,
                          minLines: 8,
                          maxLines: 16,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface,
                            height: 1.4,
                          ),
                          decoration: InputDecoration.collapsed(
                            hintText: l10n.focusNoteHint,
                            hintStyle: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                          onChanged:
                              (value) => ref
                                  .read(focusTimerControllerProvider.notifier)
                                  .setNoteDraft(value),
                        ),
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
}

String _buildSelectedPath({
  required List<FocusHierarchyItem> hierarchy,
  required FocusTimerState state,
}) {
  GoalModel? selectedGoal;
  MilestoneModel? selectedMilestone;
  TaskModel? selectedTask;

  for (final goalNode in hierarchy) {
    if (goalNode.goal.id == state.selectedGoalId) {
      selectedGoal = goalNode.goal;
    }
    for (final milestoneNode in goalNode.milestones) {
      if (milestoneNode.milestone.id == state.selectedMilestoneId) {
        selectedMilestone = milestoneNode.milestone;
        selectedGoal ??= goalNode.goal;
      }
      for (final task in milestoneNode.tasks) {
        if (task.id == state.selectedTaskId) {
          selectedTask = task;
          selectedMilestone = milestoneNode.milestone;
          selectedGoal = goalNode.goal;
        }
      }
    }
  }

  final parts = <String>[];
  if (selectedGoal != null) {
    parts.add(selectedGoal.title);
  }
  if (selectedMilestone != null) {
    parts.add(selectedMilestone.title);
  }
  if (selectedTask != null) {
    parts.add(selectedTask.title);
  }
  return parts.join(' > ');
}
