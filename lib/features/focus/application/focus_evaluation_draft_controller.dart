import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'focus_models.dart';

final focusEvaluationDraftProvider =
    NotifierProvider<FocusEvaluationDraftController, FocusEvaluationDraft?>(
      FocusEvaluationDraftController.new,
    );

final class FocusEvaluationDraftController
    extends Notifier<FocusEvaluationDraft?> {
  @override
  FocusEvaluationDraft? build() {
    return null;
  }

  void setDraft(FocusEvaluationDraft draft) {
    state = draft;
  }

  void clear() {
    state = null;
  }
}
