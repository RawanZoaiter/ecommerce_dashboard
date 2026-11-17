import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/orders/domain/entities/order.dart';
import '../di/injector.dart';
import '../extensions/context_x.dart';
import '../realtime/realtime_service.dart';
import '../router/route_paths.dart';

/// Requirement 4: shows a snackbar the moment a customer places an order, on ANY dashboard page (the orders
/// table itself is updated separately by OrdersCubit). Fed by the private channel `admin.orders`.
class NewOrderToaster extends StatefulWidget {
  const NewOrderToaster({required this.child, super.key});

  final Widget child;

  @override
  State<NewOrderToaster> createState() => _NewOrderToasterState();
}

class _NewOrderToasterState extends State<NewOrderToaster> {
  StreamSubscription<Order>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = sl<RealtimeService>().newOrders().listen(
      _show,
      onError: (Object _) {}, // not an admin, or the connection dropped: never break the page
    );
  }

  void _show(Order order) {
    if (!mounted) return;
    final l10n = context.l10n;
    final name = order.customer.name.isNotEmpty
        ? order.customer.name
        : order.customer.email;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.newOrderToast(order.id, name)),
          action: SnackBarAction(
            label: l10n.newOrderToastAction,
            onPressed: () => context.go(Routes.orderDetails(order.id)),
          ),
        ),
      );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
