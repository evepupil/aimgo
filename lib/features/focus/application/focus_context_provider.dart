import 'package:aimgo/core/services/database/app_database.dart';
import 'package:aimgo/shared/repositories/drift_aimgo_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'focus_models.dart';

final focusHierarchyProvider = StreamProvider.autoDispose<
  List<FocusHierarchyItem>
>((ref) {
  final repository = ref.watch(aimGoRepositoryProvider);
  final database = ref.watch(appDatabaseProvider);

  final triggerStream =
      database
          .customSelect(
            'SELECT 1 AS v',
            readsFrom: {database.goals, database.milestones, database.tasks},
          )
          .watch();

  return triggerStream.asyncMap((_) async {
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
});
