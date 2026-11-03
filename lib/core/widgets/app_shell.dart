import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../extensions/context_x.dart';
import '../router/route_paths.dart';
import '../settings/settings_cubit.dart';
import '../theme/app_spacing.dart';
import 'user_avatar.dart';

class _NavItem {
  const _NavItem({
    required this.route,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final String route;
  final IconData icon;
  final IconData activeIcon;
  final String Function(BuildContext context) label;
}

/// Only the sections backed by an endpoint appear here.
final List<_NavItem> _navItems = [
  _NavItem(
    route: Routes.dashboard,
    icon: Icons.space_dashboard_outlined,
    activeIcon: Icons.space_dashboard,
    label: (context) => context.l10n.navDashboard,
  ),
  _NavItem(
    route: Routes.products,
    icon: Icons.inventory_2_outlined,
    activeIcon: Icons.inventory_2,
    label: (context) => context.l10n.navProducts,
  ),
  _NavItem(
    route: Routes.orders,
    icon: Icons.receipt_long_outlined,
    activeIcon: Icons.receipt_long,
    label: (context) => context.l10n.navOrders,
  ),
];

/// The frame every signed-in screen sits in.
///
/// Three layouts off one widget tree: a labelled sidebar on desktop, an
/// icon-only rail on laptops, and a drawer on narrow windows.
class AppShell extends StatelessWidget {
  const AppShell({required this.location, required this.child, super.key});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isCompact = context.isCompact;

    return Scaffold(
      drawer: isCompact
          ? Drawer(child: _Sidebar(location: location, showLabels: true))
          : null,
      body: SafeArea(
        child: Row(
          children: [
            if (!isCompact)
              _Sidebar(location: location, showLabels: context.isExpanded),
            Expanded(
              child: Column(
                children: [
                  _TopBar(showMenuButton: isCompact),
                  Expanded(child: child),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.location, required this.showLabels});

  final String location;
  final bool showLabels;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: showLabels ? 252 : 76,
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: BorderDirectional(
          end: BorderSide(color: context.semantic.border),
        ),
      ),
      child: Column(
        children: [
          _Brand(showLabels: showLabels),
          const Divider(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              children: [
                for (final item in _navItems)
                  _NavTile(
                    item: item,
                    showLabel: showLabels,
                    // A details route such as /orders/5 must keep the Orders
                    // entry highlighted, so this is a prefix match.
                    isActive:
                        location == item.route ||
                        location.startsWith('${item.route}/'),
                  ),
              ],
            ),
          ),
          const Divider(),
          _AccountTile(showLabels: showLabels),
        ],
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({required this.showLabels});

  final bool showLabels;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        mainAxisAlignment: showLabels
            ? MainAxisAlignment.start
            : MainAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: context.colors.primary,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              Icons.storefront,
              size: 20,
              color: context.colors.onPrimary,
            ),
          ),
          if (showLabels) ...[
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                context.l10n.appTitle,
                style: context.text.titleSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.item,
    required this.showLabel,
    required this.isActive,
  });

  final _NavItem item;
  final bool showLabel;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final label = item.label(context);
    final color = isActive
        ? context.colors.onPrimaryContainer
        : context.colors.onSurfaceVariant;

    final tile = Material(
      color: isActive ? context.colors.primaryContainer : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () {
          // Close the drawer first on narrow layouts, otherwise it stays open
          // over the page the user just navigated to.
          if (context.isCompact && Scaffold.of(context).isDrawerOpen) {
            Navigator.of(context).pop();
          }
          context.go(item.route);
        },
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: showLabel ? AppSpacing.md : AppSpacing.sm,
            vertical: AppSpacing.md - 1,
          ),
          child: Row(
            mainAxisAlignment: showLabel
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              Icon(
                isActive ? item.activeIcon : item.icon,
                size: 21,
                color: color,
              ),
              if (showLabel) ...[
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    label,
                    style: context.text.labelLarge?.copyWith(color: color),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: showLabel ? tile : Tooltip(message: label, child: tile),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({required this.showLabels});

  final bool showLabels;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state.user;
    if (user == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        mainAxisAlignment: showLabels
            ? MainAxisAlignment.start
            : MainAxisAlignment.center,
        children: [
          UserAvatar(initials: user.initials, seed: user.email),
          if (showLabels) ...[
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user.name,
                    style: context.text.titleSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    context.l10n.accountRoleAdmin,
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: context.l10n.accountSignOut,
              onPressed: () => context.read<AuthCubit>().signOut(),
              icon: const Icon(Icons.logout, size: 18),
            ),
          ],
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.showMenuButton});

  final bool showMenuButton;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    final l10n = context.l10n;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(bottom: BorderSide(color: context.semantic.border)),
      ),
      child: Row(
        children: [
          if (showMenuButton)
            Builder(
              builder: (context) => IconButton(
                onPressed: Scaffold.of(context).openDrawer,
                icon: const Icon(Icons.menu),
              ),
            ),
          const Spacer(),
          IconButton(
            tooltip: l10n.prefsLanguage,
            onPressed: context.read<SettingsCubit>().toggleLocale,
            icon: Text(
              settings.isArabic ? 'EN' : 'ع',
              style: context.text.labelLarge?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
          IconButton(
            tooltip: l10n.prefsTheme,
            onPressed: context.read<SettingsCubit>().toggleThemeMode,
            icon: Icon(
              settings.themeMode == ThemeMode.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
          ),
          if (showMenuButton)
            IconButton(
              tooltip: l10n.accountSignOut,
              onPressed: () => context.read<AuthCubit>().signOut(),
              icon: const Icon(Icons.logout),
            ),
        ],
      ),
    );
  }
}
