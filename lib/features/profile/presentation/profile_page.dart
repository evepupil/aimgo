import 'package:aimgo/app/l10n/generated/app_localizations.dart';
import 'package:aimgo/app/router/route_paths.dart';
import 'package:aimgo/core/constants/layout_tokens.dart';
import 'package:aimgo/core/utils/time_formatter.dart';
import 'package:aimgo/features/profile/application/profile_dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final asyncData = ref.watch(profileDashboardProvider);

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
                    onPressed: () => ref.invalidate(profileDashboardProvider),
                    icon: const Icon(Icons.refresh),
                    tooltip: l10n.goalsFilterReset,
                  ),
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
        body: asyncData.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error:
              (error, stack) => Center(
                child: Text(error.toString(), textAlign: TextAlign.center),
              ),
          data:
              (data) => RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(profileDashboardProvider);
                  await ref.read(profileDashboardProvider.future);
                },
                child: ListView(
                  padding: LayoutTokens.listPagePadding,
                  children: [
                    _IdentityPanel(
                      title: l10n.profileDefaultName,
                      status: _resolveStatus(l10n, data),
                      streakLabel: l10n.profileStreakDays(
                        data.streakDays.toString(),
                      ),
                      activeGoalLabel: l10n.profileActiveGoals(
                        data.activeGoalCount.toString(),
                      ),
                      overdueLabel:
                          data.overdueTaskCount > 0
                              ? l10n.profileOverdueTasks(
                                data.overdueTaskCount.toString(),
                              )
                              : null,
                    ),
                    const SizedBox(height: 12),
                    _OverviewStrip(
                      items: [
                        _OverviewItem(
                          title: l10n.profileOverviewWeekFocus,
                          value: formatMinutes(data.totalEstimateMinutes),
                        ),
                        _OverviewItem(
                          title: l10n.profileOverviewTasksDone,
                          value: data.focusSessionCount.toString(),
                        ),
                        _OverviewItem(
                          title: l10n.profileOverviewMilestonesDone,
                          value: formatMinutes(data.focusDurationMinutes),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _Section(
                      title: l10n.profileSectionQuickAccess,
                      children: [
                        _ActionRow(
                          icon: Icons.history,
                          title: l10n.historyTitle,
                          onTap: () => context.push(RoutePaths.history),
                        ),
                        _ActionRow(
                          icon: Icons.analytics_outlined,
                          title: l10n.profileAnalytics,
                          onTap: () => context.push(RoutePaths.analytics),
                        ),
                        _ActionRow(
                          icon: Icons.alt_route,
                          title: l10n.goalsMilestoneProgress,
                          onTap: () => context.push(RoutePaths.goalMilestones),
                        ),
                        _ActionRow(
                          icon: Icons.checklist_outlined,
                          title: l10n.profilePendingItems,
                          trailingText:
                              data.pendingTaskCount == 0
                                  ? l10n.profilePendingNone
                                  : data.pendingTaskCount.toString(),
                          onTap: () => context.go(RoutePaths.goals),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _Section(
                      title: l10n.settingsTitle,
                      children: [
                        _ActionRow(
                          icon: Icons.settings_outlined,
                          title: l10n.settingsTitle,
                          onTap: () => context.push(RoutePaths.settings),
                        ),
                        _ActionRow(
                          icon: Icons.info_outline,
                          title: l10n.profileAbout,
                          onTap: () => context.push(RoutePaths.about),
                        ),
                        _ActionRow(
                          icon: Icons.tag_outlined,
                          title: l10n.profileVersionLabel,
                          trailingText: l10n.aboutVersion,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _Section(
                      title: l10n.profileSectionAbout,
                      children: [
                        _ActionRow(
                          icon: Icons.notifications_none_outlined,
                          title: l10n.profileNotifications,
                          subtitle: l10n.profileNotificationPlaceholder,
                          onTap: () => context.push(RoutePaths.settings),
                        ),
                        _ActionRow(
                          icon: Icons.shield_outlined,
                          title: l10n.settingsBackupRestore,
                          onTap: () => context.push(RoutePaths.settings),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
        ),
      ),
    );
  }

  String _resolveStatus(AppLocalizations l10n, ProfileDashboardData data) {
    if (data.overdueTaskCount > 0) {
      return l10n.profileStatusOverdue(data.overdueTaskCount.toString());
    }
    if (data.pendingTaskCount > 0) {
      return l10n.profileStatusPending(data.pendingTaskCount.toString());
    }
    if (data.streakDays > 0) {
      return l10n.profileStatusOnTrack;
    }
    return l10n.profileStatusStartToday;
  }
}

class _IdentityPanel extends StatelessWidget {
  const _IdentityPanel({
    required this.title,
    required this.status,
    required this.streakLabel,
    required this.activeGoalLabel,
    required this.overdueLabel,
  });

  final String title;
  final String status;
  final String streakLabel;
  final String activeGoalLabel;
  final String? overdueLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 20, child: Icon(Icons.person_outline)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      status,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  streakLabel,
                  style: theme.textTheme.labelMedium,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _CompactTag(text: activeGoalLabel),
              if (overdueLabel != null)
                _CompactTag(text: overdueLabel!, emphasized: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompactTag extends StatelessWidget {
  const _CompactTag({required this.text, this.emphasized = false});

  final String text;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor =
        emphasized
            ? const Color(0xFFB71C1C)
            : theme.colorScheme.onSurface.withValues(alpha: 0.86);
    final bgColor =
        emphasized
            ? const Color(0xFFFFEBEE)
            : theme.colorScheme.surface.withValues(alpha: 0.78);
    final borderColor =
        emphasized
            ? const Color(0xFFFFCDD2).withValues(alpha: 0.65)
            : theme.colorScheme.outlineVariant.withValues(alpha: 0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: emphasized ? Border.all(color: borderColor) : null,
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(color: textColor),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _OverviewStrip extends StatelessWidget {
  const _OverviewStrip({required this.items});

  final List<_OverviewItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dividerColor = theme.colorScheme.outlineVariant.withValues(
      alpha: 0.52,
    );
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                child: Column(
                  children: [
                    Text(
                      items[i].title,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      items[i].value,
                      style: theme.textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            if (i != items.length - 1)
              Container(width: 1, height: 32, color: dividerColor),
          ],
        ],
      ),
    );
  }
}

class _OverviewItem {
  const _OverviewItem({required this.title, required this.value});

  final String title;
  final String value;
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final divider = theme.colorScheme.outlineVariant.withValues(alpha: 0.42);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.84),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i != children.length - 1)
                  Divider(height: 1, thickness: 1, color: divider),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailingText,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? trailingText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rowContent = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 11),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.82),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.9,
                      ),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (trailingText != null)
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 130),
              child: Text(
                trailingText!,
                textAlign: TextAlign.right,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.9,
                  ),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (onTap != null) ...[
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ],
      ),
    );

    if (onTap == null) {
      return rowContent;
    }
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: rowContent,
    );
  }
}
