import 'package:aimgo/app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class RemainingDaysText extends StatelessWidget {
  const RemainingDaysText({
    required this.days,
    required this.baseStyle,
    required this.highlightColor,
    this.highlightWeight = FontWeight.w700,
    this.textAlign = TextAlign.right,
    super.key,
  });

  final int days;
  final TextStyle? baseStyle;
  final Color highlightColor;
  final FontWeight highlightWeight;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final valueText = days.toString();
    final fullText = l10n.profileOverviewRemainingDaysValue(valueText);
    final valueIndex = fullText.indexOf(valueText);

    if (valueIndex < 0) {
      return Text(fullText, style: baseStyle, textAlign: textAlign);
    }

    final leading = fullText.substring(0, valueIndex);
    final trailing = fullText.substring(valueIndex + valueText.length);

    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: [
          if (leading.isNotEmpty) TextSpan(text: leading),
          TextSpan(
            text: valueText,
            style: baseStyle?.copyWith(
              color: highlightColor,
              fontWeight: highlightWeight,
            ),
          ),
          if (trailing.isNotEmpty) TextSpan(text: trailing),
        ],
      ),
      textAlign: textAlign,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
