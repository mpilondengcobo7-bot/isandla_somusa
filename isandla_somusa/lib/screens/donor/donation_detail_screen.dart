import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/donation_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/donation_provider.dart';
import '../../providers/notification_provider.dart';
import '../../models/request_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_constants.dart';
import '../../utils/helpers.dart';
import '../../utils/validators.dart';

class DonationDetailScreen extends StatefulWidget {
  final DonationModel donation;
  final bool isRecipientView;
  const DonationDetailScreen({super.key, required this.donation, this.isRecipientView = false});
  @override
  State<DonationDetailScreen> createState() => _DonationDetailScreenState();
}

class _DonationDetailScreenState extends State<DonationDetailScreen> {
  String? _selectedSlot;
  final _msgCtrl = TextEditingController();

  @override
  void dispose() { _msgCtrl.dispose(); super.dispose(); }

  Future<void> _sendRequest() async {
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a pickup time slot')));
      return;
    }
    final auth  = context.read<AuthProvider>();
    final prov  = context.read<DonationProvider>();
    final notif = context.read<NotificationProvider>();
    final id = prov.generateId();

    final request = RequestModel(
      id: id,
      donationId: widget.donation.id,
      donationTitle: widget.donation.title,
      recipientId: auth.user!.uid,
      recipientName: auth.user!.displayName,
      recipientPhoto: auth.user!.photoUrl,
      donorId: widget.donation.donorId,
      selectedTimeSlot: _selectedSlot!,
      message: Validators.sanitise(_msgCtrl.text),
      createdAt: DateTime.now(),
    );

    final ok = await prov.createRequest(request);
    if (!mounted) return;
    if (ok) {
      await notif.saveNotification(
        userId: widget.donation.donorId,
        title: 'New food request!',
        body: '${auth.user!.displayName} requested "${widget.donation.title}"',
        type: 'request', relatedId: id,
      );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request sent! Waiting for donor approval.'),
            backgroundColor: AppTheme.successGreen));
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.donation;
    final expiring = Helpers.isExpiringSoon(d.expiryDate);
    final auth = context.read<AuthProvider>();
    final isDonorOwner = auth.user?.uid == d.donorId;

    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 260,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: d.imageUrl != null
                ? CachedNetworkImage(imageUrl: d.imageUrl!, fit: BoxFit.cover)
                : Container(color: AppTheme.tealGreen.withOpacity(0.2),
                    child: const Icon(Icons.restaurant, size: 80, color: AppTheme.tealGreen)),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Title + status
              Row(children: [
                Expanded(child: Text(d.title,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: d.status == 'available' ? AppTheme.successGreen : AppTheme.warmAmber,
                    borderRadius: BorderRadius.circular(20)),
                  child: Text(Helpers.statusLabel(d.status),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              ]),
              const SizedBox(height: 8),
              Text(d.description, style: TextStyle(color: Colors.grey[600], fontSize: 15, height: 1.5)),
              const SizedBox(height: 16),
              // Info grid
              _InfoRow(Icons.inventory_2_outlined, 'Quantity', '${d.quantity} ${d.unit}'),
              _InfoRow(Icons.category_outlined, 'Category', d.category),
              _InfoRow(Icons.schedule_outlined, 'Expires',
                Helpers.formatDate(d.expiryDate),
                valueColor: expiring ? AppTheme.warmAmber : null),
              _InfoRow(Icons.location_on_outlined, 'Pickup address', d.address),
              // Dietary
              if (d.isHalaal || d.isVegetarian) ...[
                const SizedBox(height: 8),
                Wrap(spacing: 8, children: [
                  if (d.isHalaal) _DietTag('Halaal', AppTheme.forestGreen),
                  if (d.isVegetarian) _DietTag('Vegetarian', AppTheme.tealGreen),
                ]),
              ],
              const SizedBox(height: 16),
              // Donor info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.tealGreen.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  CircleAvatar(backgroundColor: AppTheme.tealGreen,
                    child: Text(d.donorName[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(d.donorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (d.donorRating > 0) Row(children: [
                      ...List.generate(5, (i) => Icon(
                        i < d.donorRating.round() ? Icons.star : Icons.star_border,
                        size: 14, color: AppTheme.warmAmber)),
                      Text(' ${d.donorRating.toStringAsFixed(1)}',
                        style: const TextStyle(fontSize: 12)),
                    ]),
                  ])),
                ]),
              ),
              // Time slots
              const SizedBox(height: 20),
              const Text('Available pickup times',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 8,
                children: d.availableTimeSlots.map((slot) {
                  final sel = _selectedSlot == slot;
                  return ChoiceChip(
                    label: Text(slot),
                    selected: sel,
                    onSelected: widget.isRecipientView && d.status == 'available'
                        ? (_) => setState(() => _selectedSlot = slot)
                        : null,
                    selectedColor: AppTheme.tealGreen.withOpacity(0.15),
                    labelStyle: TextStyle(color: sel ? AppTheme.tealGreen : null),
                  );
                }).toList()),
              // Request form (recipient only)
              if (widget.isRecipientView && d.status == 'available' && !isDonorOwner) ...[
                const SizedBox(height: 20),
                TextFormField(
                  controller: _msgCtrl, maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Message to donor (optional)',
                    hintText: 'Tell the donor a bit about yourself or your need...',
                    prefixIcon: Icon(Icons.message_outlined),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _sendRequest,
                  icon: const Icon(Icons.send_outlined),
                  label: const Text('Send request'),
                ),
              ],
              // Donor actions
              if (isDonorOwner && d.status == 'available') ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () async {
                    final ok = await context.read<DonationProvider>().deleteDonation(d.id);
                    if (ok && mounted) Navigator.pop(context);
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Remove donation'),
                  style: OutlinedButton.styleFrom(foregroundColor: AppTheme.errorRed,
                      side: const BorderSide(color: AppTheme.errorRed)),
                ),
              ],
              const SizedBox(height: 32),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color? valueColor;
  const _InfoRow(this.icon, this.label, this.value, {this.valueColor});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 18, color: AppTheme.tealGreen),
      const SizedBox(width: 10),
      Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
      Expanded(child: Text(value,
        style: TextStyle(fontSize: 14, color: valueColor ?? Colors.grey[700]),
        maxLines: 2)),
    ]),
  );
}

class _DietTag extends StatelessWidget {
  final String label; final Color color;
  const _DietTag(this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3))),
    child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
  );
}
