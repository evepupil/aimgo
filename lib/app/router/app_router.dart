import 'package:aimgo/app/router/route_paths.dart';
import 'package:aimgo/core/widgets/main_tab_shell.dart';
import 'package:aimgo/features/focus/presentation/focus_page.dart';
import 'package:aimgo/features/goals/presentation/goals_page.dart';
import 'package:aimgo/features/home/presentation/home_page.dart';
import 'package:aimgo/features/history/presentation/history_page.dart';
import 'package:aimgo/features/profile/presentation/profile_page.dart';
import 'package:aimgo/features/evaluation/presentation/evaluation_page.dart';
import 'package:aimgo/features/settings/presentation/settings_page.dart';
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
        path: RoutePaths.settings,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: RoutePaths.history,
        builder: (context, state) => const HistoryPage(),
      ),
      GoRoute(
        path: RoutePaths.evaluation,
        builder: (context, state) => const EvaluationPage(),
      ),
    ],
  );
});
