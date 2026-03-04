import 'package:flutter/material.dart';

class FeaturePlaceholderPage extends StatelessWidget {
  const FeaturePlaceholderPage({
    required this.title,
    required this.description,
    this.actions = const <Widget>[],
    super.key,
  });

  final String title;
  final String description;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          snap: true,
          title: Text(title),
          actions: actions,
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                description,
                style: textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
