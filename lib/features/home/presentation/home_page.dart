import 'package:aimgo/app/l10n/generated/app_localizations.dart';
import 'package:aimgo/app/router/route_paths.dart';
import 'package:aimgo/core/constants/layout_tokens.dart';
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
    final theme = Theme.of(context);
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
      body: NestedScrollView(
        headerSliverBuilder:
            (context, innerBoxIsScrolled) => [
              SliverAppBar(
                floating: true,
                snap: true,
                title: Text(l10n.homeTitle),
              ),
            ],
        body: RefreshIndicator(
          onRefresh: controller.refresh,
          child: ListView(
            padding: LayoutTokens.listPagePadding,
            children: [
              Card(
                child: ListTile(
                  title: Text(l10n.homeTodayOverview),
                  subtitle: Text(formatMinutes(state.todayEffectiveMinutes)),
                ),
              ),
              const SizedBox(height: LayoutTokens.sectionGap),
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
                              if (index < 0 ||
                                  index >= state.weekTrend.length) {
                                return const SizedBox.shrink();
                              }
                              return Text(
                                DateFormat(
                                  'E',
                                ).format(state.weekTrend[index].date),
                                style: theme.textTheme.labelSmall,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: LayoutTokens.sectionGap),
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
                                (_, __) => const SizedBox(
                                  width: LayoutTokens.sectionGap,
                                ),
                            itemBuilder: (context, index) {
                              final goal = state.activeGoals[index];
                              final goalCardWidth =
                                  ((MediaQuery.sizeOf(context).width -
                                              (LayoutTokens.pageHorizontal *
                                                  2)) *
                                          0.62)
                                      .clamp(180.0, 240.0)
                                      .toDouble();
                              return Container(
                                width: goalCardWidth,
                                padding: const EdgeInsets.all(
                                  LayoutTokens.cardPadding,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.outlineVariant,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      goal.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(
                                      height: LayoutTokens.sectionGap,
                                    ),
                                    LinearProgressIndicator(
                                      value:
                                          goal.progressRatio
                                              .clamp(0, 1)
                                              .toDouble(),
                                      minHeight: 8,
                                    ),
                                    const SizedBox(
                                      height: LayoutTokens.compactGap,
                                    ),
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
              const SizedBox(height: LayoutTokens.sectionGap),
              _SectionCard(
                title: l10n.homeQuickActions,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final stackVertical = constraints.maxWidth < 380;
                    final continueButton = FilledButton.icon(
                      onPressed: () => context.go(RoutePaths.focus),
                      icon: const Icon(Icons.play_arrow),
                      label: Text(
                        l10n.homeContinueFocus,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                    final goalsButton = OutlinedButton.icon(
                      onPressed: () => context.go(RoutePaths.goals),
                      icon: const Icon(Icons.flag_outlined),
                      label: Text(
                        l10n.homeOpenGoals,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                    if (stackVertical) {
                      return Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: continueButton,
                          ),
                          const SizedBox(height: LayoutTokens.compactGap),
                          SizedBox(width: double.infinity, child: goalsButton),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(child: continueButton),
                        const SizedBox(width: LayoutTokens.sectionGap),
                        Expanded(child: goalsButton),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: LayoutTokens.sectionGap),
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
        padding: const EdgeInsets.all(LayoutTokens.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: LayoutTokens.compactGap),
            child,
          ],
        ),
      ),
    );
  }
}
