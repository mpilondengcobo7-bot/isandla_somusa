import 'dart:math';
import 'package:intl/intl.dart';

class Helpers {
  static String formatDate(DateTime dt) =>
      DateFormat('dd MMM yyyy').format(dt);

  static String formatDateTime(DateTime dt) =>
      DateFormat('dd MMM yyyy, HH:mm').format(dt);

  static String timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1)  return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24)   return '${diff.inHours}h ago';
    if (diff.inDays < 7)     return '${diff.inDays}d ago';
    return formatDate(dt);
  }

  static bool isExpiringSoon(DateTime expiry) {
    return expiry.difference(DateTime.now()).inHours <= 24;
  }

  static bool isExpired(DateTime expiry) =>
      expiry.isBefore(DateTime.now());

  /// Haversine formula — returns km
  static double distanceKm(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371.0;
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) *
        sin(dLng / 2) * sin(dLng / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  static double _toRad(double deg) => deg * pi / 180;

  static String formatDistance(double km) =>
      km < 1 ? '${(km * 1000).round()} m away' : '${km.toStringAsFixed(1)} km away';

  static String capitalise(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  static String statusLabel(String status) {
    switch (status) {
      case 'available':  return 'Available';
      case 'claimed':    return 'Claimed';
      case 'picked_up':  return 'Picked up';
      case 'expired':    return 'Expired';
      case 'cancelled':  return 'Cancelled';
      case 'pending':    return 'Pending';
      case 'approved':   return 'Approved';
      case 'rejected':   return 'Rejected';
      case 'completed':  return 'Completed';
      default:           return Helpers.capitalise(status);
    }
  }
}
