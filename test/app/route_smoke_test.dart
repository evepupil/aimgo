import 'package:aimgo/app/app.dart';
import 'package:aimgo/app/router/app_router.dart';
import 'package:aimgo/app/router/route_paths.dart';
import 'package:aimgo/core/services/database/app_database.dart';
import 'package:aimgo/core/services/local_storage_service.dart';
import 'package:aimgo/features/analytics/presentation/analytics_page.dart';
import 'package:aimgo/features/evaluation/presentation/evaluation_page.dart';
import 'package:aimgo/features/focus/application/focus_evaluation_draft_controller.dart';
import 'package:aimgo/features/focus/application/focus_models.dart';
import 'package:aimgo/features/focus/presentation/focus_fullscreen_page.dart';
import 'package:aimgo/features/focus/presentation/focus_page.dart';
import 'package:aimgo/features/goals/presentation/goals_page.dart';
import 'package:aimgo/features/goals/presentation/milestone_progress_page.dart';
import 'package:aimgo/features/history/presentation/history_page.dart';
import 'package:aimgo/features/home/presentation/home_page.dart';
import 'package:aimgo/features/profile/presentation/about_page.dart';
import 'package:aimgo/features/profile/presentation/aimgo_concept_page.dart';
import 'package:aimgo/features/profile/presentation/profile_page.dart';
import 'package:aimgo/features/settings/presentation/settings_page.dart';
import 'package:aimgo/shared/models/planning_models.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late AppDatabase database;

  Future<void> pumpApp(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final localStorageService = await LocalStorageService.create();
    database = AppDatabase(executor: NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        localStorageServiceProvider.overrideWithValue(localStorageService),
        appDatabaseProvider.overrideWithValue(database),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await database.close();
    });

    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const AimGoApp()),
    );
    // Let the initial route and its async providers settle.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('every declared route builds without throwing', (tester) async {
    await pumpApp(tester);
    final router = container.read(appRouterProvider);

    // Initial location is /home.
    expect(find.byType(HomePage), findsOneWidget);
    expect(tester.takeException(), isNull);

    // path -> expected page widget that should be present after navigation.
    final routeCases = <String, Type>{
      RoutePaths.goals: GoalsPage,
      RoutePaths.focus: FocusPage,
      RoutePaths.profile: ProfilePage,
      RoutePaths.settings: SettingsPage,
      RoutePaths.history: HistoryPage,
      RoutePaths.analytics: AnalyticsPage,
      RoutePaths.about: AboutPage,
      RoutePaths.aimgoConcept: AimGoConceptPage,
      RoutePaths.goalMilestones: MilestoneProgressPage,
      RoutePaths.focusFullscreen: FocusFullscreenPage,
    };

    for (final entry in routeCases.entries) {
      router.go(entry.key);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(
        find.byType(entry.value),
        findsWidgets,
        reason: 'route ${entry.key} should build ${entry.value}',
      );
      expect(
        tester.takeException(),
        isNull,
        reason: 'route ${entry.key} threw while building',
      );
    }
  });

  testWidgets('evaluation route renders when a draft is present', (
    tester,
  ) async {
    await pumpApp(tester);

    container
        .read(focusEvaluationDraftProvider.notifier)
        .setDraft(
          FocusEvaluationDraft(
            sessionId: 1,
            durationMinutes: 25,
            startedAt: DateTime(2026, 3, 4, 20, 0),
            endedAt: DateTime(2026, 3, 4, 20, 25),
            focusTargetLevel: FocusTargetLevel.goal,
            focusMode: FocusMode.pomodoro,
          ),
        );

    final router = container.read(appRouterProvider);
    router.go(RoutePaths.evaluation);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(EvaluationPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
