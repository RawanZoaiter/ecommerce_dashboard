import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/inventory/presentation/pages/inventory_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/orders/presentation/pages/order_details_page.dart';
import '../../features/orders/presentation/pages/orders_page.dart';
import '../../features/products/presentation/pages/new_product_page.dart';
import '../../features/products/presentation/pages/product_details_page.dart';
import '../../features/products/presentation/pages/products_page.dart';
import '../../features/users/presentation/pages/users_page.dart';
import '../widgets/app_shell.dart';
import 'route_paths.dart';

/// Builds the router and keeps it in step with the session.
///
/// The redirect is the only place that decides who may see what: an anonymous
/// visitor is sent to the login screen, and a signed-in admin never lands back
/// on it. Hiding a route is a convenience, not security — the server checks the
/// role on every request regardless (guide §5.6).
GoRouter createRouter(AuthCubit authCubit) {
  return GoRouter(
    initialLocation: Routes.dashboard,
    refreshListenable: _CubitRefresh(authCubit.stream),
    redirect: (context, state) {
      final status = authCubit.state.status;
      final goingToLogin = state.matchedLocation == Routes.login;

      // Still restoring a stored session: hold position until it resolves,
      // so the login screen does not flash for an already signed-in admin.
      if (status == AuthStatus.unknown) return null;

      if (status == AuthStatus.unauthenticated) {
        return goingToLogin ? null : Routes.login;
      }

      return goingToLogin ? Routes.dashboard : null;
    },
    routes: [
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginPage(),
      ),
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(
            path: Routes.dashboard,
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: Routes.products,
            builder: (context, state) => const ProductsPage(),
            routes: [
              // Declared before ':id' so "new" is not parsed as an id.
              GoRoute(
                path: 'new',
                builder: (context, state) => const NewProductPage(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) => ProductDetailsPage(
                  productId: int.parse(state.pathParameters['id']!),
                ),
              ),
            ],
          ),
          GoRoute(
            path: Routes.orders,
            builder: (context, state) => const OrdersPage(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) => OrderDetailsPage(
                  orderId: int.parse(state.pathParameters['id']!),
                ),
              ),
            ],
          ),
          GoRoute(
            path: Routes.inventory,
            builder: (context, state) => const InventoryPage(),
          ),
          GoRoute(
            path: Routes.users,
            builder: (context, state) => const UsersPage(),
          ),
          GoRoute(
            path: Routes.notifications,
            builder: (context, state) => const NotificationsPage(),
          ),
        ],
      ),
    ],
  );
}

/// Bridges a cubit stream to the [Listenable] go_router expects.
class _CubitRefresh extends ChangeNotifier {
  _CubitRefresh(Stream<AuthState> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
