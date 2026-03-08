import 'package:aimgo/app/l10n/generated/app_localizations.dart';
import 'package:aimgo/app/router/route_paths.dart';
import 'package:aimgo/core/constants/layout_tokens.dart';
import 'package:aimgo/features/focus/application/focus_timer_controller.dart';
import 'package:aimgo/features/goals/application/selected_goal_provider.dart';
import 'package:aimgo/features/home/application/home_dashboard_controller.dart';
import 'package:aimgo/features/home/presentation/widgets/home_dashboard_cards.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final asyncState = ref.watch(homeDashboardStateProvider);
    final controller = ref.read(homeDashboardStateProvider.notifier);
    final state = asyncState.valueOrNull;

    if (asyncState.isLoading && state == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (state == null) {
      return Scaffold(
        body: SafeArea(child: Center(child: Text(l10n.homeTitle))),
      );
    }

    final localeName = Localizations.localeOf(context).toLanguageTag();
    final now = DateTime.now();
    final headerDate =
        '${DateFormat.MMMMd(localeName).format(now)}  ${DateFormat.EEEE(localeName).format(now)}';

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: controller.refresh,
          child: ListView(
            padding: LayoutTokens.listPagePadding,
            children: [
              HomeHeaderCard(
                dateLabel: headerDate,
                effectiveMinutes: state.todayEffectiveMinutes,
              ),
              const SizedBox(height: LayoutTokens.sectionGap),
              HomeCurrentGoalCard(
                summary: state.currentGoal,
                onOpenGoals: () => context.go(RoutePaths.goals),
              ),
              const SizedBox(height: LayoutTokens.sectionGap),
              HomeLastSessionCard(
                entry: state.lastSession,
                onContinue: () => _openFocus(context, ref, state),
              ),
              const SizedBox(height: LayoutTokens.sectionGap),
              HomeHeatmapCard(days: state.heatmapDays),
            ],
          ),
        ),
      ),
    );
  }

  void _openFocus(
    BuildContext context,
    WidgetRef ref,
    HomeDashboardState state,
  ) {
    final goalId =
        state.lastSession?.session.goalId ?? state.currentGoal?.goal.id;
    ref.read(selectedGoalIdProvider.notifier).state = goalId;
    ref.read(focusTimerControllerProvider.notifier).selectGoal(goalId);
    context.go(RoutePaths.focus);
  }
}
