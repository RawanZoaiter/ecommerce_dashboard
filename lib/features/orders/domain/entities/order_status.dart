/// Order lifecycle, with the transition table from guide §5.14 encoded.
///
/// The dashboard only ever offers buttons for [nextStates]. Hiding a
/// disallowed move is not a substitute for the server's check — it still
/// answers 409 — but it keeps an admin from discovering the rule by being
/// refused.
enum OrderStatus {
  pending,
  confirmed,
  shipped,
  delivered,
  cancelled;

  static OrderStatus fromApi(String? value) {
    return OrderStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => OrderStatus.pending,
    );
  }

  String get apiValue => name;

  /// Which statuses an admin may move this order to, in the order the buttons
  /// should appear.
  List<OrderStatus> get nextStates => switch (this) {
    OrderStatus.pending => const [OrderStatus.confirmed, OrderStatus.cancelled],
    OrderStatus.confirmed => const [OrderStatus.shipped, OrderStatus.cancelled],
    OrderStatus.shipped => const [OrderStatus.delivered],
    OrderStatus.delivered || OrderStatus.cancelled => const [],
  };

  /// Delivered and cancelled are terminal.
  bool get isFinal => nextStates.isEmpty;

  /// Position in the happy path, used to draw the timeline. Cancelled is not
  /// on that path and reports -1.
  int get timelineIndex => switch (this) {
    OrderStatus.pending => 0,
    OrderStatus.confirmed => 1,
    OrderStatus.shipped => 2,
    OrderStatus.delivered => 3,
    OrderStatus.cancelled => -1,
  };

  /// The happy path itself, for drawing the timeline rail.
  static const List<OrderStatus> happyPath = [
    OrderStatus.pending,
    OrderStatus.confirmed,
    OrderStatus.shipped,
    OrderStatus.delivered,
  ];
}
