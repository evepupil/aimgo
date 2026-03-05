import 'package:aimgo/app/l10n/generated/app_localizations.dart';
import 'package:aimgo/app/router/route_paths.dart';
import 'package:aimgo/core/constants/layout_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder:
            (context, innerBoxIsScrolled) => [
              SliverAppBar(
                floating: true,
                snap: true,
                title: Text(l10n.profileTitle),
                actions: [
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.profileNotificationPlaceholder),
                        ),
                      );
                    },
                    icon: const Icon(Icons.notifications_none_outlined),
                    tooltip: l10n.profileNotifications,
                  ),
                  IconButton(
                    onPressed: () => context.push(RoutePaths.settings),
                    icon: const Icon(Icons.settings_outlined),
                    tooltip: l10n.settingsTitle,
                  ),
                ],
              ),
            ],
        body: ListView(
          padding: LayoutTokens.listPagePadding,
          children: [
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(LayoutTokens.cardPadding),
                leading: const CircleAvatar(
                  radius: 24,
                  child: Icon(Icons.person_outline),
                ),
                title: Text(l10n.profileDefaultName),
                subtitle: Text(l10n.profileWelcome),
              ),
            ),
            const SizedBox(height: LayoutTokens.sectionGap),
            _MenuTile(
              icon: Icons.analytics_outlined,
              title: l10n.profileAnalytics,
              onTap: () => context.push(RoutePaths.analytics),
            ),
            _MenuTile(
              icon: Icons.history,
              title: l10n.profileTimeMachine,
              onTap: () => context.push(RoutePaths.history),
            ),
            _MenuTile(
              icon: Icons.settings_outlined,
              title: l10n.settingsTitle,
              onTap: () => context.push(RoutePaths.settings),
            ),
            _MenuTile(
              icon: Icons.info_outline,
              title: l10n.profileAbout,
              onTap: () => context.push(RoutePaths.about),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
