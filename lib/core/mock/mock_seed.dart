import '../../features/auth/domain/entities/user.dart';
import '../../features/inventory/domain/entities/stock_item.dart';
import '../../features/notifications/domain/entities/app_notification.dart';
import '../../features/orders/domain/entities/order.dart';
import '../../features/orders/domain/entities/order_status.dart';
import '../../features/products/domain/entities/category.dart';
import '../../features/products/domain/entities/product.dart';
import '../utils/money.dart';

/// The sample dataset every mock repository reads from.
///
/// One shared set rather than per-feature fixtures, so an order's lines point
/// at products that actually exist and the dashboard's totals add up — the
/// same consistency the real API gives us.
///
/// Stock deliberately copies the backend team's own test setup: most products
/// hold 25, product 3 holds 1 so the "not enough stock" path can be shown, and
/// product 4 has no record at all so the "not available for ordering" path can
/// be shown.
abstract final class MockSeed {
  /// Fixed so the dashboard looks identical on every reload.
  static final DateTime now = DateTime(2026, 11, 2, 14, 30);

  static const List<Category> categories = [
    Category(id: 3, name: 'Desktop Computers'),
    Category(id: 1, name: 'Laptops'),
    Category(id: 2, name: 'Monitors'),
    Category(id: 4, name: 'Peripherals'),
  ];

  static Category _category(int id) =>
      categories.firstWhere((category) => category.id == id);

  static final List<Product> products = [
    _product(
      1,
      'Lenovo ThinkPad E14 Gen 5',
      '14-inch business laptop, Ryzen 7, 16GB RAM, 512GB NVMe SSD.',
      '899.50',
      1,
      daysAgo: 2,
    ),
    _product(
      2,
      'Dell Latitude 5440',
      '14-inch, Intel Core i5-1335U, 16GB RAM, 256GB SSD, backlit keyboard.',
      '1049.00',
      1,
      daysAgo: 3,
    ),
    _product(
      3,
      'Dell XPS 13 Plus',
      'Ultraportable 13.4-inch OLED, Core i7, 32GB RAM, 1TB SSD.',
      '1799.99',
      1,
      daysAgo: 5,
    ),
    _product(
      4,
      'HP EliteBook 840 G10',
      '14-inch, Core i7, 16GB RAM, 512GB SSD, fingerprint reader.',
      '1320.00',
      1,
      daysAgo: 6,
    ),
    _product(
      5,
      'Apple MacBook Air 15"',
      'M3 chip, 16GB unified memory, 512GB SSD, 18-hour battery.',
      '1599.00',
      1,
      daysAgo: 8,
    ),
    _product(
      6,
      'ASUS ProArt Display PA278',
      '27-inch QHD, 100% sRGB, hardware calibration, USB-C 90W.',
      '469.00',
      2,
      daysAgo: 9,
    ),
    _product(
      7,
      'LG UltraFine 32UN880',
      '32-inch 4K UHD ergo monitor with a built-in arm and USB-C hub.',
      '629.50',
      2,
      daysAgo: 11,
    ),
    _product(
      8,
      'Samsung Odyssey G5',
      '27-inch curved QHD gaming monitor, 165Hz, 1ms response.',
      '329.00',
      2,
      daysAgo: 12,
    ),
    _product(
      9,
      'Dell UltraSharp U2723QE',
      '27-inch 4K IPS Black, 98% DCI-P3, built-in KVM switch.',
      '579.99',
      2,
      daysAgo: 14,
    ),
    _product(
      10,
      'HP ProDesk 400 G9 SFF',
      'Small form factor desktop, Core i5-12500, 16GB RAM, 512GB SSD.',
      '749.00',
      3,
      daysAgo: 15,
    ),
    _product(
      11,
      'Apple Mac mini M2',
      'M2 chip, 16GB unified memory, 512GB SSD, two Thunderbolt 4 ports.',
      '1099.00',
      3,
      daysAgo: 17,
    ),
    _product(
      12,
      'Lenovo ThinkCentre M90q',
      'Tiny 1-litre desktop, Core i7, 32GB RAM, 1TB SSD, Wi-Fi 6E.',
      '1250.75',
      3,
      daysAgo: 19,
    ),
    _product(
      13,
      'Logitech MX Master 3S',
      'Wireless performance mouse, 8K DPI, quiet clicks, USB-C.',
      '99.99',
      4,
      daysAgo: 20,
    ),
    _product(
      14,
      'Keychron K3 Pro',
      'Low-profile mechanical keyboard, hot-swappable, QMK/VIA.',
      '94.00',
      4,
      daysAgo: 21,
    ),
    _product(
      15,
      'Anker 737 USB-C Hub',
      '12-in-1 docking station, dual 4K output, 100W pass-through.',
      '189.50',
      4,
      daysAgo: 23,
    ),
    _product(
      16,
      'Logitech Brio 505',
      '1080p business webcam with Show Mode and auto light correction.',
      '129.00',
      4,
      daysAgo: 24,
    ),
    _product(
      17,
      'Acer Swift Go 14',
      '14-inch OLED, Core i7-13700H, 16GB RAM, 1TB SSD.',
      '879.00',
      1,
      daysAgo: 26,
    ),
    _product(
      18,
      'BenQ PD2705U',
      '27-inch 4K designer monitor, Display P3, factory calibrated.',
      '549.00',
      2,
      daysAgo: 28,
    ),
  ];

  static Product _product(
    int id,
    String name,
    String description,
    String price,
    int categoryId, {
    required int daysAgo,
  }) {
    return Product(
      id: id,
      name: name,
      description: description,
      price: Money.parse(price),
      category: _category(categoryId),
      // A deterministic placeholder per product. When it cannot load — offline,
      // or during a demo with no network — the thumbnail falls back to a
      // styled initial, so the table never shows a broken image.
      imageUrl: 'https://picsum.photos/seed/product-$id/400/400',
      createdAt: now.subtract(Duration(days: daysAgo)),
      availability: _availabilityFor(id),
    );
  }

  /// Mirrors the backend team's seeding example.
  static Availability _availabilityFor(int id) => switch (id) {
    3 => const InStock(1),
    4 => const NoStockRecord(),
    8 => const InStock(0),
    13 => const InStock(4),
    _ => const InStock(25),
  };

  static final List<User> users = [
    User(
      id: 1,
      name: 'Admin',
      email: 'admin@example.com',
      role: UserRole.admin,
      createdAt: now.subtract(const Duration(days: 40)),
    ),
    User(
      id: 2,
      name: 'Enass Kadree',
      email: 'enass@example.com',
      role: UserRole.customer,
      createdAt: now.subtract(const Duration(days: 28)),
    ),
    User(
      id: 3,
      name: 'Rawan Zoaiter',
      email: 'rawan@example.com',
      role: UserRole.customer,
      createdAt: now.subtract(const Duration(days: 26)),
    ),
    User(
      id: 4,
      name: 'Batoul Nassar',
      email: 'batoul@example.com',
      role: UserRole.customer,
      createdAt: now.subtract(const Duration(days: 22)),
    ),
    User(
      id: 5,
      name: 'Manar Aljarkas',
      email: 'manar@example.com',
      role: UserRole.customer,
      createdAt: now.subtract(const Duration(days: 19)),
    ),
    User(
      id: 6,
      name: 'Omar Haddad',
      email: 'omar@example.com',
      role: UserRole.customer,
      createdAt: now.subtract(const Duration(days: 15)),
    ),
    User(
      id: 7,
      name: 'Lina Saleh',
      email: 'lina@example.com',
      role: UserRole.customer,
      createdAt: now.subtract(const Duration(days: 9)),
    ),
    User(
      id: 8,
      name: 'Yara Mansour',
      email: 'yara@example.com',
      role: UserRole.customer,
      createdAt: now.subtract(const Duration(days: 4)),
    ),
  ];

  static final User admin = users.first;

  static final List<Order> orders = [
    _order(31, 2, OrderStatus.pending, {1: 1, 13: 2}, hoursAgo: 3),
    _order(30, 7, OrderStatus.pending, {6: 2}, hoursAgo: 7),
    _order(29, 5, OrderStatus.confirmed, {5: 1, 15: 1}, hoursAgo: 11),
    _order(28, 3, OrderStatus.shipped, {9: 2, 14: 1}, hoursAgo: 20),
    _order(27, 8, OrderStatus.pending, {11: 1}, hoursAgo: 26),
    _order(26, 4, OrderStatus.delivered, {2: 1, 16: 2}, hoursAgo: 32),
    _order(25, 6, OrderStatus.cancelled, {3: 1}, hoursAgo: 38),
    _order(24, 2, OrderStatus.delivered, {7: 1}, hoursAgo: 44),
    _order(23, 5, OrderStatus.confirmed, {10: 1, 13: 1}, hoursAgo: 52),
    _order(22, 7, OrderStatus.shipped, {12: 1}, hoursAgo: 60),
    _order(21, 3, OrderStatus.delivered, {17: 1, 14: 2}, hoursAgo: 70),
    _order(20, 8, OrderStatus.delivered, {18: 1}, hoursAgo: 80),
    _order(19, 4, OrderStatus.cancelled, {5: 1, 6: 1}, hoursAgo: 92),
    _order(18, 6, OrderStatus.delivered, {8: 2}, hoursAgo: 104),
    _order(17, 2, OrderStatus.confirmed, {15: 2, 16: 1}, hoursAgo: 118),
    _order(16, 5, OrderStatus.delivered, {11: 1, 13: 1}, hoursAgo: 130),
    _order(15, 7, OrderStatus.shipped, {1: 2}, hoursAgo: 142),
    _order(14, 3, OrderStatus.delivered, {9: 1}, hoursAgo: 156),
    _order(13, 8, OrderStatus.pending, {2: 1, 14: 1}, hoursAgo: 168),
    _order(12, 4, OrderStatus.delivered, {10: 2}, hoursAgo: 180),
  ];

  static Order _order(
    int id,
    int userId,
    OrderStatus status,
    Map<int, int> quantities, {
    required int hoursAgo,
  }) {
    final customer = users.firstWhere((user) => user.id == userId);
    final lines = quantities.entries.map((entry) {
      final product = products.firstWhere(
        (candidate) => candidate.id == entry.key,
      );
      return OrderLine(
        productId: product.id,
        name: product.name,
        quantity: entry.value,
        unitPrice: product.price,
      );
    }).toList();

    return Order(
      id: id,
      status: status,
      // Summed exactly the way the server would, in minor units.
      total: Money.sum(lines.map((line) => line.lineTotal)),
      customer: OrderCustomer(
        id: customer.id,
        name: customer.name,
        email: customer.email,
      ),
      lines: lines,
      createdAt: now.subtract(Duration(hours: hoursAgo)),
    );
  }

  static final List<StockItem> stock = products
      .map(
        (product) => StockItem(
          productId: product.id,
          productName: product.name,
          imageUrl: product.imageUrl,
          quantityOnHand: switch (product.availability) {
            InStock(:final quantity) => quantity,
            NoStockRecord() => null,
            AvailabilityUnknown() => null,
          },
          updatedAt: now.subtract(Duration(hours: product.id * 3)),
        ),
      )
      .toList();

  static final List<AppNotification> notifications = [
    AppNotification(
      id: 9,
      kind: NotificationKind.orderStatusChanged,
      title: 'Order #28 shipped',
      body: 'Rawan Zoaiter was notified that order #28 is on its way.',
      orderId: 28,
      createdAt: now.subtract(const Duration(hours: 2)),
    ),
    AppNotification(
      id: 8,
      kind: NotificationKind.lowStock,
      title: 'Dell XPS 13 Plus is nearly out',
      body: 'Only 1 unit left in the inventory service.',
      createdAt: now.subtract(const Duration(hours: 5)),
    ),
    AppNotification(
      id: 7,
      kind: NotificationKind.lowStock,
      title: 'Samsung Odyssey G5 is sold out',
      body: 'Quantity on hand reached 0.',
      createdAt: now.subtract(const Duration(hours: 9)),
    ),
    AppNotification(
      id: 6,
      kind: NotificationKind.orderStatusChanged,
      title: 'Order #29 confirmed',
      body: 'Stock was reserved for every item in the order.',
      orderId: 29,
      createdAt: now.subtract(const Duration(hours: 12)),
      readAt: now.subtract(const Duration(hours: 10)),
    ),
    AppNotification(
      id: 5,
      kind: NotificationKind.orderStatusChanged,
      title: 'Order #25 cancelled',
      body: 'The reserved quantity was returned to the inventory service.',
      orderId: 25,
      createdAt: now.subtract(const Duration(hours: 36)),
      readAt: now.subtract(const Duration(hours: 30)),
    ),
    AppNotification(
      id: 4,
      kind: NotificationKind.other,
      title: 'HP EliteBook 840 G10 has no stock record',
      body: 'Customers cannot order it until a quantity is registered.',
      createdAt: now.subtract(const Duration(hours: 48)),
      readAt: now.subtract(const Duration(hours: 40)),
    ),
  ];
}
