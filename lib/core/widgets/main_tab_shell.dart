import 'package:aimgo/app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainTabShell extends StatelessWidget {
  const MainTabShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.tabHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.flag_outlined),
            selectedIcon: const Icon(Icons.flag),
            label: l10n.tabGoals,
          ),
          NavigationDestination(
            icon: const Icon(Icons.timer_outlined),
            selectedIcon: const Icon(Icons.timer),
            label: l10n.tabFocus,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l10n.tabProfile,
          ),
        ],
      ),
    );
  }
}
