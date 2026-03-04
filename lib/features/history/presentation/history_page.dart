import 'package:aimgo/app/l10n/generated/app_localizations.dart';
import 'package:aimgo/core/widgets/feature_placeholder_page.dart';
import 'package:flutter/widgets.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FeaturePlaceholderPage(
      title: l10n.historyTitle,
      description: l10n.phase3HistoryPlaceholder,
    );
  }
}
