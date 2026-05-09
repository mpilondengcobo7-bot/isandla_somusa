import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../providers/auth_provider.dart';
import '../../providers/donation_provider.dart';
import '../../models/request_model.dart';
import '../../models/rating_model.dart';
import '../../services/ai_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_constants.dart';
import '../../utils/helpers.dart';

class RecipientRequestsScreen extends StatelessWidget {
  const RecipientRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final prov = context.read<DonationProvider>();

    return StreamBuilder<List<RequestModel>>(
      stream: prov.streamMyRequests(auth.user!.uid),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        if (!snap.hasData || snap.data!.isEmpty)
          return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.assignment_outlined, size: 80, color: AppTheme.lightGray),
            SizedBox(height: 16),
            Text('No requests yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Browse donations and send a request to get started', textAlign: TextAlign.center),
          ]));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snap.data!.length,
          itemBuilder: (_, i) => _RecipientRequestTile(request: snap.data![i]),
        );
      },
    );
  }
}

class _RecipientRequestTile extends StatelessWidget {
  final RequestModel request;
  const _RecipientRequestTile({required this.request});

  Color get _statusColor {
    switch (request.status) {
      case 'approved':  return AppTheme.successGreen;
      case 'rejected':  return AppTheme.errorRed;
      case 'completed': return AppTheme.tealGreen;
      default:          return AppTheme.warmAmber;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(request.donationTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              maxLines: 2)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _statusColor.withOpacity(0.3))),
              child: Text(Helpers.statusLabel(request.status),
                style: TextStyle(color: _statusColor, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.schedule_outlined, size: 14, color: AppTheme.tealGreen),
            const SizedBox(width: 4),
            Text('Pickup: ${request.selectedTimeSlot}', style: const TextStyle(fontSize: 13)),
            const Spacer(),
            Text(Helpers.timeAgo(request.createdAt),
              style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          ]),
          if (request.status == AppConstants.reqApproved) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.successGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.successGreen.withOpacity(0.3))),
              child: const Row(children: [
                Icon(Icons.check_circle_outline, color: AppTheme.successGreen, size: 18),
                SizedBox(width: 8),
                Expanded(child: Text('Approved! Please arrive at the pickup address at your selected time.',
                  style: TextStyle(fontSize: 13, color: AppTheme.successGreen))),
              ]),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () => _showRatingDialog(context),
              icon: const Icon(Icons.star_outline),
              label: const Text('Mark as collected & rate'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.warmAmber),
            ),
          ],
          if (request.status == AppConstants.reqCompleted)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Row(children: [
                Icon(Icons.verified, color: AppTheme.tealGreen, size: 16),
                SizedBox(width: 6),
                Text('Completed — thank you!',
                  style: TextStyle(color: AppTheme.tealGreen, fontWeight: FontWeight.w500, fontSize: 13)),
              ]),
            ),
        ]),
      ),
    );
  }

  void _showRatingDialog(BuildContext context) {
    double _stars = 5;
    final _commentCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rate this donation'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('How was your experience with this donor?'),
          const SizedBox(height: 16),
          RatingBar.builder(
            initialRating: 5, minRating: 1, itemCount: 5,
            itemBuilder: (_, __) => const Icon(Icons.star, color: AppTheme.warmAmber),
            onRatingUpdate: (r) => _stars = r,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentCtrl, maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Leave a comment (optional)',
              border: OutlineInputBorder()),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final auth  = context.read<AuthProvider>();
              final prov  = context.read<DonationProvider>();
              final comment = _commentCtrl.text;
              final sentiment = comment.isNotEmpty ? AiService.analyseSentiment(comment) : 'neutral';
              final rating = RatingModel(
                id: prov.generateId(),
                requestId: request.id,
                raterId: auth.user!.uid,
                raterName: auth.user!.displayName,
                ratedUserId: request.donorId,
                ratedUserName: '',
                score: _stars,
                comment: comment.isEmpty ? null : comment,
                sentiment: sentiment,
                createdAt: DateTime.now(),
              );
              await prov.submitRating(rating);
            },
            child: const Text('Submit rating'),
          ),
        ],
      ),
    );
  }
}
