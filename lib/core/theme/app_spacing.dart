/// A 4pt spacing scale. Using these instead of loose numbers keeps rhythm
/// consistent across screens built at different times.
abstract final class AppSpacing {
  static const xxs = 2.0;
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 32.0;
  static const huge = 40.0;
  static const giant = 48.0;
}

abstract final class AppRadius {
  static const sm = 6.0;
  static const md = 10.0;
  static const lg = 14.0;
  static const xl = 20.0;
  static const pill = 999.0;
}

abstract final class AppBreakpoints {
  /// Below this the side navigation collapses into a drawer.
  static const compact = 900.0;

  /// Below this the navigation rail hides its labels.
  static const medium = 1200.0;
}
