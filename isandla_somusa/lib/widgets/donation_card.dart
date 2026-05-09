import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/donation_model.dart';
import '../utils/app_theme.dart';
import '../utils/helpers.dart';

class DonationCard extends StatelessWidget {
  final DonationModel donation;
  final VoidCallback? onTap;
  final double? recipientLat;
  final double? recipientLng;

  const DonationCard({super.key, required this.donation,
      this.onTap, this.recipientLat, this.recipientLng});

  @override
  Widget build(BuildContext context) {
    final expiring = Helpers.isExpiringSoon(donation.expiryDate);
    final expired  = Helpers.isExpired(donation.expiryDate);
    String? distText;
    if (recipientLat != null && recipientLng != null) {
      final km = Helpers.distanceKm(donation.latitude, donation.longitude, recipientLat!, recipientLng!);
      distText = Helpers.formatDistance(km);
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(children: [
              donation.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: donation.imageUrl!,
                      height: 160, width: double.infinity, fit: BoxFit.cover,
                      placeholder: (_, __) => Container(height: 160, color: Colors.grey[200],
                          child: const Center(child: CircularProgressIndicator())),
                      errorWidget: (_, __, ___) => _placeholderImage(),
                    )
                  : _placeholderImage(),
              // Status badge
              Positioned(top: 12, left: 12, child: _StatusBadge(status: donation.status)),
              // Expiry warning
              if (expiring && !expired)
                Positioned(top: 12, right: 12, child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppTheme.warmAmber, borderRadius: BorderRadius.circular(8)),
                  child: const Text('Expiring soon!', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                )),
              // Dietary badges
              Positioned(bottom: 8, right: 8, child: Row(children: [
                if (donation.isHalaal) _DietBadge('H', AppTheme.forestGreen),
                if (donation.isVegetarian) ...[const SizedBox(width: 4), _DietBadge('V', AppTheme.tealGreen)],
              ])),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(donation.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 1, overflow: TextOverflow.ellipsis)),
                _CategoryChip(donation.category),
              ]),
              const SizedBox(height: 4),
              Text(donation.description,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Row(children: [
                Icon(Icons.inventory_2_outlined, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text('${donation.quantity} ${donation.unit}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                const Spacer(),
                Icon(Icons.schedule_outlined, size: 14,
                    color: expiring ? AppTheme.warmAmber : Colors.grey[500]),
                const SizedBox(width: 4),
                Text('Expires ${Helpers.formatDate(donation.expiryDate)}',
                  style: TextStyle(fontSize: 13,
                    color: expiring ? AppTheme.warmAmber : Colors.grey[600],
                    fontWeight: expiring ? FontWeight.w600 : FontWeight.normal)),
              ]),
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.store_outlined, size: 14, color: AppTheme.tealGreen),
                const SizedBox(width: 4),
                Expanded(child: Text(donation.donorName,
                  style: const TextStyle(fontSize: 13, color: AppTheme.tealGreen, fontWeight: FontWeight.w500),
                  maxLines: 1, overflow: TextOverflow.ellipsis)),
                if (distText != null) ...[
                  Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[500]),
                  Text(distText, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                ],
              ]),
              if (donation.donorRating > 0) ...[
                const SizedBox(height: 4),
                Row(children: [
                  ...List.generate(5, (i) => Icon(
                    i < donation.donorRating.round() ? Icons.star : Icons.star_border,
                    size: 14, color: AppTheme.warmAmber)),
                  const SizedBox(width: 4),
                  Text(donation.donorRating.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 12, color: AppTheme.warmAmber)),
                ]),
              ],
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _placeholderImage() => Container(
    height: 160, color: AppTheme.tealGreen.withOpacity(0.1),
    child: const Center(child: Icon(Icons.restaurant, size: 48, color: AppTheme.tealGreen)),
  );
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});
  @override
  Widget build(BuildContext context) {
    Color bg;
    switch (status) {
      case 'available': bg = AppTheme.successGreen; break;
      case 'claimed':   bg = AppTheme.warmAmber; break;
      case 'picked_up': bg = AppTheme.tealGreen; break;
      case 'expired':   bg = Colors.grey; break;
      default:          bg = AppTheme.errorRed;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(Helpers.statusLabel(status),
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String category;
  const _CategoryChip(this.category);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: AppTheme.tealGreen.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(category, style: const TextStyle(fontSize: 11, color: AppTheme.tealGreen)),
  );
}

class _DietBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _DietBadge(this.label, this.color);
  @override
  Widget build(BuildContext context) => CircleAvatar(
    radius: 10, backgroundColor: color,
    child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
  );
}
