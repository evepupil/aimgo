import 'package:aimgo/shared/repositories/drift_aimgo_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'focus_models.dart';

final focusHierarchyProvider = FutureProvider<List<FocusHierarchyItem>>((
  ref,
) async {
  final repository = ref.watch(aimGoRepositoryProvider);
  final goals = await repository.listGoals();
  final result = <FocusHierarchyItem>[];

  for (final goal in goals) {
    final milestones = await repository.listMilestonesByGoalId(goal.id);
    final milestoneItems = <FocusMilestoneItem>[];

    for (final milestone in milestones) {
      final tasks = await repository.listTasksByMilestoneId(milestone.id);
      milestoneItems.add(
        FocusMilestoneItem(milestone: milestone, tasks: tasks),
      );
    }

    result.add(FocusHierarchyItem(goal: goal, milestones: milestoneItems));
  }
  return result;
});
