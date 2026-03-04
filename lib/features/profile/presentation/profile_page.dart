import 'package:aimgo/app/l10n/generated/app_localizations.dart';
import 'package:aimgo/app/router/route_paths.dart';
import 'package:aimgo/core/widgets/feature_placeholder_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FeaturePlaceholderPage(
      title: l10n.profileTitle,
      description: l10n.phase0ReadyDescription,
      actions: [
        IconButton(
          onPressed: () => context.push(RoutePaths.settings),
          icon: const Icon(Icons.settings_outlined),
          tooltip: l10n.settingsTitle,
        ),
      ],
    );
  }
}
