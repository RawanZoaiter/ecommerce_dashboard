/// One or two letters for an avatar, from a name or an email.
///
/// Shared because both [User] and [OrderCustomer] need it and the orders table
/// shows them side by side; two copies would eventually disagree.
String initialsFrom(String source) {
  final trimmed = source.trim();
  if (trimmed.isEmpty) return '?';

  final parts = trimmed.split(RegExp(r'\s+'));
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
}
