import 'package:aimgo/app/l10n/generated/app_localizations.dart';
import 'package:aimgo/core/constants/layout_tokens.dart';
import 'package:aimgo/core/utils/time_formatter.dart';
import 'package:aimgo/features/focus/application/focus_context_provider.dart';
import 'package:aimgo/features/focus/application/focus_evaluation_draft_controller.dart';
import 'package:aimgo/features/focus/application/focus_models.dart';
import 'package:aimgo/features/goals/application/progress_sync_service.dart';
import 'package:aimgo/shared/models/planning_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EvaluationPage extends ConsumerStatefulWidget {
  const EvaluationPage({super.key});

  @override
  ConsumerState<EvaluationPage> createState() => _EvaluationPageState();
}

class _EvaluationPageState extends ConsumerState<EvaluationPage> {
  final TextEditingController _noteController = TextEditingController();
  int _efficiencyPercent = 60;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final draft = ref.watch(focusEvaluationDraftProvider);
    final hierarchy = ref.watch(focusHierarchyProvider).valueOrNull ?? const [];

    if (draft == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.evaluationTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(l10n.evaluationNoDraft, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    final durationMinutes = draft.durationMinutes;
    final effectiveMinutes = durationMinutes * (_efficiencyPercent / 100);
    final focusPath = _buildFocusPath(
      hierarchy: hierarchy,
      goalId: draft.goalId,
      milestoneId: draft.milestoneId,
      taskId: draft.taskId,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.evaluationTitle),
        actions: [
          IconButton(
            onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            tooltip: l10n.commonClose,
          ),
        ],
      ),
      body: ListView(
        padding: LayoutTokens.listPagePadding,
        children: [
          _EvaluationPanel(
            child: Padding(
              padding: const EdgeInsets.all(LayoutTokens.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.evaluationSummaryTitle,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: LayoutTokens.compactGap),
                  Text(
                    '${l10n.evaluationDuration}: ${formatMinutes(durationMinutes)}',
                  ),
                  const SizedBox(height: 4),
                  Text(
                    focusPath.isEmpty ? l10n.focusContextEmpty : focusPath,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: LayoutTokens.sectionGapLarge),
          _EvaluationPanel(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Text(
                      l10n.evaluationEfficiencyLabel(
                        _efficiencyPercent.toString(),
                      ),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  Slider(
                    value: _efficiencyPercent.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 100,
                    label: '$_efficiencyPercent%',
                    onChanged:
                        _isSubmitting
                            ? null
                            : (value) {
                              setState(() {
                                _efficiencyPercent = value.round();
                              });
                            },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final value in const [20, 40, 60, 80, 100])
                          ChoiceChip(
                            label: Text('$value%'),
                            selected: _efficiencyPercent == value,
                            onSelected:
                                _isSubmitting
                                    ? null
                                    : (_) {
                                      setState(() {
                                        _efficiencyPercent = value;
                                      });
                                    },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Text(
                      '${l10n.evaluationEffectiveDuration}: ${formatMinutes(effectiveMinutes)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: LayoutTokens.sectionGapLarge),
          _EvaluationPanel(
            child: Padding(
              padding: const EdgeInsets.all(LayoutTokens.cardPadding),
              child: TextField(
                controller: _noteController,
                minLines: 3,
                maxLines: 6,
                enabled: !_isSubmitting,
                decoration: InputDecoration(
                  labelText: l10n.evaluationNoteLabel,
                ),
              ),
            ),
          ),
          const SizedBox(height: LayoutTokens.sectionGapLarge),
          FilledButton(
            onPressed:
                _isSubmitting
                    ? null
                    : () => _submitEvaluation(skipEfficiency: false),
            child:
                _isSubmitting
                    ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : Text(l10n.evaluationSubmit),
          ),
          const SizedBox(height: LayoutTokens.compactGap),
          OutlinedButton(
            onPressed:
                _isSubmitting
                    ? null
                    : () => _submitEvaluation(skipEfficiency: true),
            child: Text(l10n.evaluationSkip),
          ),
        ],
      ),
    );
  }

  Future<void> _submitEvaluation({required bool skipEfficiency}) async {
    final l10n = AppLocalizations.of(context)!;
    final draft = ref.read(focusEvaluationDraftProvider);
    if (draft == null || _isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });
    try {
      if (draft.sessionId <= 0) {
        throw StateError('Invalid draft session id');
      }
      await ref
          .read(progressSyncServiceProvider)
          .updateSessionAndSync(
            UpdateFocusSessionInput(
              id: draft.sessionId,
              goalId: draft.goalId,
              milestoneId: draft.milestoneId,
              taskId: draft.taskId,
              durationMinutes: draft.durationMinutes,
              efficiencyPercent: skipEfficiency ? 60 : _efficiencyPercent,
              focusTargetLevel: draft.focusTargetLevel,
              note: _normalizeNullable(_noteController.text),
            ),
          );
      ref.read(focusEvaluationDraftProvider.notifier).clear();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.evaluationSaved)));
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.evaluationSaveFailed)));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _buildFocusPath({
    required List<FocusHierarchyItem> hierarchy,
    required int? goalId,
    required int? milestoneId,
    required int? taskId,
  }) {
    FocusHierarchyItem? goalNode;
    for (final item in hierarchy) {
      if (item.goal.id == goalId) {
        goalNode = item;
        break;
      }
    }
    if (goalNode == null) {
      return '';
    }

    final path = <String>[goalNode.goal.title];
    FocusMilestoneItem? milestoneNode;
    if (milestoneId != null) {
      for (final item in goalNode.milestones) {
        if (item.milestone.id == milestoneId) {
          milestoneNode = item;
          break;
        }
      }
      if (milestoneNode != null) {
        path.add(milestoneNode.milestone.title);
      }
    }

    if (taskId != null && milestoneNode != null) {
      for (final task in milestoneNode.tasks) {
        if (task.id == taskId) {
          path.add(task.title);
          break;
        }
      }
    }

    return path.join(' > ');
  }

  String? _normalizeNullable(String source) {
    final value = source.trim();
    return value.isEmpty ? null : value;
  }
}

class _EvaluationPanel extends StatelessWidget {
  const _EvaluationPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(LayoutTokens.radiusMedium),
      ),
      child: child,
    );
  }
}
