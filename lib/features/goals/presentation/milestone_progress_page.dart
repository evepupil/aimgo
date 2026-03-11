import 'package:aimgo/app/l10n/generated/app_localizations.dart';
import 'package:aimgo/core/constants/layout_tokens.dart';
import 'package:aimgo/core/utils/time_formatter.dart';
import 'package:aimgo/shared/models/planning_models.dart';
import 'package:aimgo/shared/repositories/drift_aimgo_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final milestoneProgressDataProvider = FutureProvider.autoDispose
    .family<_MilestoneProgressData?, int?>((ref, goalId) async {
      final repository = ref.watch(aimGoRepositoryProvider);
      final goals = await repository.listGoals();
      if (goals.isEmpty) {
        return null;
      }

      GoalModel goal;
      if (goalId != null) {
        goal = goals.firstWhere(
          (item) => item.id == goalId,
          orElse: () => goals.first,
        );
      } else {
        goal = goals.first;
      }

      final milestones = await repository.listMilestonesByGoalId(goal.id);
      final items = <_MilestoneProgressItem>[];
      for (final milestone in milestones) {
        final tasks = await repository.listTasksByMilestoneId(milestone.id);
        final completedTaskCount =
            tasks.where((task) => task.isCompleted).length;
        final taskCount = tasks.length;
        final isCompleted = taskCount > 0 && completedTaskCount == taskCount;
        items.add(
          _MilestoneProgressItem(
            milestone: milestone,
            taskCount: taskCount,
            completedTaskCount: completedTaskCount,
            isCompleted: isCompleted,
            completionAt:
                isCompleted
                    ? milestone.completedAt ?? _fallbackCompletionTime(tasks)
                    : null,
          ),
        );
      }

      return _MilestoneProgressData(goal: goal, items: items);
    });

class MilestoneProgressPage extends ConsumerStatefulWidget {
  const MilestoneProgressPage({required this.goalId, super.key});

  final int? goalId;

  @override
  ConsumerState<MilestoneProgressPage> createState() =>
      _MilestoneProgressPageState();
}

class _MilestoneProgressPageState extends ConsumerState<MilestoneProgressPage> {
  _MilestoneProgressSort _sort = _MilestoneProgressSort.completionTime;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final asyncData = ref.watch(milestoneProgressDataProvider(widget.goalId));

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder:
            (context, innerBoxIsScrolled) => [
              SliverAppBar(
                floating: true,
                snap: true,
                title: Text(l10n.goalsMilestoneProgress),
                actions: [
                  IconButton(
                    onPressed:
                        () => ref.invalidate(
                          milestoneProgressDataProvider(widget.goalId),
                        ),
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
            ],
        body: asyncData.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error:
              (error, stack) => Center(
                child: Text(error.toString(), textAlign: TextAlign.center),
              ),
          data: (data) {
            if (data == null) {
              return Center(child: Text(l10n.goalsNoGoal));
            }
            if (data.items.isEmpty) {
              return Center(child: Text(l10n.milestoneProgressEmpty));
            }

            final sortedItems = _sortItems(data.items);
            final completedItems = data.items
                .where((item) => item.isCompleted)
                .toList(growable: false);
            final completionRate =
                data.items.isEmpty
                    ? 0
                    : (completedItems.length / data.items.length);
            DateTime? latestCompletionAt;
            for (final item in completedItems) {
              final completedAt = item.completionAt;
              if (completedAt == null) {
                continue;
              }
              if (latestCompletionAt == null ||
                  completedAt.isAfter(latestCompletionAt)) {
                latestCompletionAt = completedAt;
              }
            }

            return ListView(
              padding: LayoutTokens.listPagePadding,
              children: [
                DecoratedBox(
                  decoration: LayoutTokens.tainCardDecoration(
                    Theme.of(context),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(LayoutTokens.cardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.goal.title,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: LayoutTokens.sectionGap),
                        Row(
                          children: [
                            Expanded(
                              child: _SummaryCell(
                                title: l10n.milestoneProgressSummaryCompleted,
                                value:
                                    '${completedItems.length}/${data.items.length}',
                              ),
                            ),
                            Expanded(
                              child: _SummaryCell(
                                title: l10n.milestoneProgressSummaryRate,
                                value:
                                    '${(completionRate * 100).toStringAsFixed(1)}%',
                              ),
                            ),
                            Expanded(
                              child: _SummaryCell(
                                title: l10n.milestoneProgressSummaryLatest,
                                value:
                                    latestCompletionAt == null
                                        ? l10n.milestoneProgressNotAvailable
                                        : DateFormat(
                                          'MM-dd HH:mm',
                                        ).format(latestCompletionAt),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: LayoutTokens.sectionGap),
                _MilestoneSortTabs(
                  selectedSort: _sort,
                  onSortChanged: (sort) {
                    setState(() {
                      _sort = sort;
                    });
                  },
                ),
                const SizedBox(height: LayoutTokens.sectionGap),
                Text(
                  l10n.milestoneProgressTimelineTitle,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: LayoutTokens.compactGap),
                for (var i = 0; i < sortedItems.length; i++)
                  _MilestoneTimelineTile(
                    item: sortedItems[i],
                    isLast: i == sortedItems.length - 1,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<_MilestoneProgressItem> _sortItems(List<_MilestoneProgressItem> items) {
    if (_sort == _MilestoneProgressSort.manual) {
      final sorted = [...items];
      sorted.sort((a, b) {
        final sortCompare = a.milestone.sortOrder.compareTo(
          b.milestone.sortOrder,
        );
        if (sortCompare != 0) {
          return sortCompare;
        }
        return a.milestone.id.compareTo(b.milestone.id);
      });
      return sorted;
    }

    final completed = items
        .where((item) => item.isCompleted)
        .toList(growable: false);
    final pending = items
        .where((item) => !item.isCompleted)
        .toList(growable: false);
    final sortedCompleted = [...completed]..sort((a, b) {
      final left = a.completionAt;
      final right = b.completionAt;
      if (left == null && right == null) {
        return a.milestone.id.compareTo(b.milestone.id);
      }
      if (left == null) {
        return 1;
      }
      if (right == null) {
        return -1;
      }
      return left.compareTo(right);
    });
    final sortedPending = [...pending]..sort((a, b) {
      final sortCompare = a.milestone.sortOrder.compareTo(
        b.milestone.sortOrder,
      );
      if (sortCompare != 0) {
        return sortCompare;
      }
      return a.milestone.id.compareTo(b.milestone.id);
    });
    return [...sortedCompleted, ...sortedPending];
  }
}

enum _MilestoneProgressSort { completionTime, manual }

class _SummaryCell extends StatelessWidget {
  const _SummaryCell({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _MilestoneTimelineTile extends StatelessWidget {
  const _MilestoneTimelineTile({required this.item, required this.isLast});

  final _MilestoneProgressItem item;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final completed = item.isCompleted;
    final accentColor = completed ? theme.colorScheme.primary : theme.colorScheme.outline;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 22,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: completed ? accentColor : theme.colorScheme.surface,
                    border: Border.all(color: accentColor, width: 2),
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.only(top: 4),
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: LayoutTokens.sectionGap),
              child: DecoratedBox(
                decoration: LayoutTokens.tainCardDecoration(theme),
                child: Padding(
                  padding: const EdgeInsets.all(LayoutTokens.cardPadding),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.milestone.title,
                      style: theme.textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      completed
                          ? l10n.historyStatusCompleted
                          : l10n.milestoneProgressInProgress,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color:
                            completed
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${l10n.milestoneProgressTasks}: ${item.completedTaskCount}/${item.taskCount}',
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      '${formatMinutes(item.milestone.effectiveMinutes)} / ${formatMinutes(item.milestone.estimateMinutes)}',
                      style: theme.textTheme.bodySmall,
                    ),
                    if (item.completionAt != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        '${l10n.milestoneProgressCompletedAt}: ${DateFormat('yyyy-MM-dd HH:mm').format(item.completionAt!)}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MilestoneSortTabs extends StatelessWidget {
  const _MilestoneSortTabs({
    required this.selectedSort,
    required this.onSortChanged,
  });

  final _MilestoneProgressSort selectedSort;
  final void Function(_MilestoneProgressSort) onSortChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final tabs = {
      _MilestoneProgressSort.completionTime:
          l10n.milestoneProgressSortByCompletion,
      _MilestoneProgressSort.manual: l10n.milestoneProgressSortByPlan,
    };

    return DecoratedBox(
      decoration: LayoutTokens.tainCardDecoration(theme),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            for (final entry in tabs.entries)
              Expanded(
                child: GestureDetector(
                  onTap: () => onSortChanged(entry.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color:
                          selectedSort == entry.key
                              ? theme.colorScheme.primary.withValues(alpha: 0.1)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      entry.value,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            selectedSort == entry.key
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                        fontWeight:
                            selectedSort == entry.key
                                ? FontWeight.w700
                                : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

DateTime? _fallbackCompletionTime(List<TaskModel> tasks) {
  if (tasks.isEmpty) {
    return null;
  }
  DateTime latest = tasks.first.updatedAt;
  for (var i = 1; i < tasks.length; i++) {
    if (tasks[i].updatedAt.isAfter(latest)) {
      latest = tasks[i].updatedAt;
    }
  }
  return latest;
}

final class _MilestoneProgressData {
  const _MilestoneProgressData({required this.goal, required this.items});

  final GoalModel goal;
  final List<_MilestoneProgressItem> items;
}

final class _MilestoneProgressItem {
  const _MilestoneProgressItem({
    required this.milestone,
    required this.taskCount,
    required this.completedTaskCount,
    required this.isCompleted,
    required this.completionAt,
  });

  final MilestoneModel milestone;
  final int taskCount;
  final int completedTaskCount;
  final bool isCompleted;
  final DateTime? completionAt;
}
