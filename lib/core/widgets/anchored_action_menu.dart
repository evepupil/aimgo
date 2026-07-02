import 'dart:math' as math;
import 'dart:ui';

import 'package:aimgo/app/theme/daybook_extension.dart';
import 'package:aimgo/core/constants/layout_tokens.dart';
import 'package:flutter/material.dart';

class AnchoredMenuItem<T> {
  const AnchoredMenuItem({
    required this.value,
    required this.child,
    this.height = 44,
  });

  final T value;
  final Widget child;
  final double height;
}

Future<T?> showAnchoredActionMenu<T>({
  required BuildContext context,
  required GlobalKey anchorKey,
  required List<AnchoredMenuItem<T>> items,
}) {
  final anchorContext = anchorKey.currentContext;
  if (anchorContext == null) {
    return Future.value(null);
  }

  final renderBox = anchorContext.findRenderObject() as RenderBox?;
  if (renderBox == null || !renderBox.attached) {
    return Future.value(null);
  }

  final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
  final anchorTopLeft = renderBox.localToGlobal(Offset.zero, ancestor: overlay);
  final anchorRect = anchorTopLeft & renderBox.size;

  return showGeneralDialog<T>(
    context: context,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierDismissible: true,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 100),
    pageBuilder: (dialogContext, _, __) {
      final theme = Theme.of(dialogContext);
      final mediaQuery = MediaQuery.of(dialogContext);
      final size = mediaQuery.size;
      final safeTop = mediaQuery.padding.top;
      final safeBottom = mediaQuery.padding.bottom;
      final menuWidth = math.min(size.width * 0.72, size.width - 24);
      final right = math.max(12.0, size.width - anchorRect.right);
      final left = math.max(12.0, size.width - right - menuWidth);
      final estimatedHeight = items.fold<double>(
        0,
        (sum, item) => sum + item.height,
      );
      final topCandidate = anchorRect.bottom + 8;
      final maxTop = size.height - safeBottom - estimatedHeight - 12;
      final top =
          maxTop <= safeTop + 12
              ? safeTop + 12
              : math.min(topCandidate, maxTop);

      return _AnchoredActionMenuSheet<T>(
        items: items,
        left: left,
        top: top,
        width: menuWidth,
        theme: theme,
      );
    },
    transitionBuilder: (dialogContext, animation, secondaryAnimation, child) {
      return child;
    },
  );
}

class _AnchoredActionMenuSheet<T> extends StatelessWidget {
  const _AnchoredActionMenuSheet({
    required this.items,
    required this.left,
    required this.top,
    required this.width,
    required this.theme,
  });

  final List<AnchoredMenuItem<T>> items;
  final double left;
  final double top;
  final double width;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final daybook = DaybookColors.of(context);
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).pop(),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: ColoredBox(color: daybook.scrim),
              ),
            ),
          ),
          Positioned(
            left: left,
            top: top,
            width: width,
            child: Material(
              color: theme.colorScheme.surface,
              surfaceTintColor: Colors.transparent,
              borderRadius: BorderRadius.circular(LayoutTokens.radiusLarge),
              elevation: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(LayoutTokens.radiusLarge),
                  border: Border.all(color: daybook.rule),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.14),
                      blurRadius: 28,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(LayoutTokens.radiusLarge),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var index = 0; index < items.length; index++) ...[
                        _AnchoredActionMenuTile<T>(item: items[index]),
                        if (index != items.length - 1)
                          Divider(
                            height: 1,
                            thickness: 1,
                            indent: 14,
                            endIndent: 14,
                            color: daybook.rule,
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnchoredActionMenuTile<T> extends StatelessWidget {
  const _AnchoredActionMenuTile({required this.item});

  final AnchoredMenuItem<T> item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pop(item.value),
      child: SizedBox(
        height: item.height,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Align(alignment: Alignment.centerLeft, child: item.child),
        ),
      ),
    );
  }
}
