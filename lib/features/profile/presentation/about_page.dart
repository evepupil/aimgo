import 'package:aimgo/app/l10n/generated/app_localizations.dart';
import 'package:aimgo/core/constants/layout_tokens.dart';
import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder:
            (context, innerBoxIsScrolled) => [
              SliverAppBar(
                floating: true,
                snap: true,
                title: Text(l10n.profileAbout),
              ),
            ],
        body: ListView(
          padding: LayoutTokens.listPagePadding,
          children: [
            DecoratedBox(
              decoration: LayoutTokens.tainCardDecoration(theme),
              child: Padding(
                padding: const EdgeInsets.all(LayoutTokens.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.appTitle, style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text(
                      l10n.aboutVersion,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: LayoutTokens.sectionGap),
            DecoratedBox(
              decoration: LayoutTokens.tainCardDecoration(theme),
              child: Padding(
                padding: const EdgeInsets.all(LayoutTokens.cardPadding),
                child: Text(
                  l10n.aboutDescription,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
