import 'package:aimgo/app/l10n/generated/app_localizations.dart';
import 'package:aimgo/features/focus/application/focus_evaluation_draft_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EvaluationPage extends ConsumerWidget {
  const EvaluationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final draft = ref.watch(focusEvaluationDraftProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.evaluationTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            draft == null
                ? l10n.evaluationNoDraft
                : l10n.evaluationPhase3Placeholder,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
