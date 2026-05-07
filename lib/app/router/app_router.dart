import 'package:aimgo/app/router/route_paths.dart';
import 'package:aimgo/core/widgets/main_tab_shell.dart';
import 'package:aimgo/features/focus/presentation/focus_fullscreen_page.dart';
import 'package:aimgo/features/focus/presentation/focus_page.dart';
import 'package:aimgo/features/goals/presentation/goals_page.dart';
import 'package:aimgo/features/goals/presentation/milestone_progress_page.dart';
import 'package:aimgo/features/home/presentation/home_page.dart';
import 'package:aimgo/features/history/presentation/history_page.dart';
import 'package:aimgo/features/analytics/presentation/analytics_page.dart';
import 'package:aimgo/features/profile/presentation/profile_page.dart';
import 'package:aimgo/features/evaluation/presentation/evaluation_page.dart';
import 'package:aimgo/features/profile/presentation/aimgo_concept_page.dart';
import 'package:aimgo/features/profile/presentation/about_page.dart';
import 'package:aimgo/features/settings/presentation/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RoutePaths.home,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainTabShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.home,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.goals,
                builder: (context, state) => const GoalsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.focus,
                builder: (context, state) => const FocusPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.profile,
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.focusFullscreen,
        pageBuilder:
            (context, state) => _buildFocusFullscreenTransitionPage(
              state: state,
              child: const FocusFullscreenPage(),
            ),
      ),
      GoRoute(
        path: RoutePaths.settings,
        pageBuilder:
            (context, state) => _buildOverlayTransitionPage(
              state: state,
              child: const SettingsPage(),
            ),
      ),
      GoRoute(
        path: RoutePaths.history,
        pageBuilder: (context, state) {
          final initialGoalFilterId = int.tryParse(
            state.uri.queryParameters['goalId'] ?? '',
          );
          return _buildOverlayTransitionPage(
            state: state,
            child: HistoryPage(initialGoalFilterId: initialGoalFilterId),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.evaluation,
        pageBuilder:
            (context, state) => _buildEvaluationTransitionPage(
              state: state,
              child: const EvaluationPage(),
            ),
      ),
      GoRoute(
        path: RoutePaths.analytics,
        pageBuilder:
            (context, state) => _buildOverlayTransitionPage(
              state: state,
              child: const AnalyticsPage(),
            ),
      ),
      GoRoute(
        path: RoutePaths.about,
        pageBuilder:
            (context, state) => _buildOverlayTransitionPage(
              state: state,
              child: const AboutPage(),
            ),
      ),
      GoRoute(
        path: RoutePaths.aimgoConcept,
        pageBuilder:
            (context, state) => _buildOverlayTransitionPage(
              state: state,
              child: const AimGoConceptPage(),
            ),
      ),
      GoRoute(
        path: RoutePaths.goalMilestones,
        pageBuilder: (context, state) {
          final goalId = int.tryParse(
            state.uri.queryParameters['goalId'] ?? '',
          );
          return _buildOverlayTransitionPage(
            state: state,
            child: MilestoneProgressPage(goalId: goalId),
          );
        },
      ),
    ],
  );
});

CustomTransitionPage<void> _buildOverlayTransitionPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 220),
    reverseTransitionDuration: const Duration(milliseconds: 180),
    transitionsBuilder: (context, animation, secondaryAnimation, pageChild) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curvedAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.03),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: pageChild,
        ),
      );
    },
  );
}

CustomTransitionPage<void> _buildFocusFullscreenTransitionPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 260),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondaryAnimation, pageChild) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curvedAnimation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.985, end: 1).animate(curvedAnimation),
          child: pageChild,
        ),
      );
    },
  );
}

NoTransitionPage<void> _buildEvaluationTransitionPage({
  required GoRouterState state,
  required Widget child,
}) {
  return NoTransitionPage<void>(key: state.pageKey, child: child);
}
