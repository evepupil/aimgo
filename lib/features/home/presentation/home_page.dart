import 'package:aimgo/app/l10n/generated/app_localizations.dart';
import 'package:aimgo/app/router/route_paths.dart';
import 'package:aimgo/core/utils/time_formatter.dart';
import 'package:aimgo/features/home/application/home_dashboard_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final asyncState = ref.watch(homeDashboardControllerProvider);
    final controller = ref.read(homeDashboardControllerProvider.notifier);
    final state = asyncState.valueOrNull;

    if (asyncState.isLoading && state == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (state == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.homeTitle)),
        body: const SizedBox.shrink(),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.homeTitle)),
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Card(
              child: ListTile(
                title: Text(l10n.homeTodayOverview),
                subtitle: Text(formatMinutes(state.todayEffectiveMinutes)),
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: l10n.homeWeekTrend,
              child: SizedBox(
                height: 180,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          for (var i = 0; i < state.weekTrend.length; i++)
                            FlSpot(i.toDouble(), state.weekTrend[i].minutes),
                        ],
                        isCurved: true,
                        barWidth: 3,
                        dotData: const FlDotData(show: false),
                      ),
                    ],
                    titlesData: FlTitlesData(
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= state.weekTrend.length) {
                              return const SizedBox.shrink();
                            }
                            return Text(
                              DateFormat(
                                'E',
                              ).format(state.weekTrend[index].date),
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: l10n.homeActiveGoals,
              child:
                  state.activeGoals.isEmpty
                      ? Text(l10n.goalsNoGoal)
                      : SizedBox(
                        height: 140,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: state.activeGoals.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final goal = state.activeGoals[index];
                            return Container(
                              width: 220,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.outlineVariant,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    goal.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 10),
                                  LinearProgressIndicator(
                                    value:
                                        goal.progressRatio
                                            .clamp(0, 1)
                                            .toDouble(),
                                    minHeight: 8,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${formatMinutes(goal.effectiveMinutes)} / ${formatMinutes(goal.estimateMinutes)}',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: l10n.homeQuickActions,
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => context.go(RoutePaths.focus),
                      icon: const Icon(Icons.play_arrow),
                      label: Text(l10n.homeContinueFocus),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.go(RoutePaths.goals),
                      icon: const Icon(Icons.flag_outlined),
                      label: Text(l10n.homeOpenGoals),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: l10n.homeRecentSessions,
              child:
                  state.recentSessions.isEmpty
                      ? Text(l10n.goalsNoSearchResult)
                      : Column(
                        children: [
                          for (final item in state.recentSessions)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                item.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                item.path,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Text(
                                formatMinutes(item.session.effectiveMinutes),
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}
