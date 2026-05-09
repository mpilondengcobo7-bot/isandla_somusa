import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/donation_provider.dart';
import '../../providers/notification_provider.dart';
import '../../models/request_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/helpers.dart';
import '../../utils/app_constants.dart';

class DonorRequestsScreen extends StatelessWidget {
  const DonorRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final prov = context.read<DonationProvider>();

    return StreamBuilder<List<RequestModel>>(
      stream: prov.streamIncomingRequests(auth.user!.uid),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        if (!snap.hasData || snap.data!.isEmpty)
          return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.inbox_outlined, size: 80, color: AppTheme.lightGray),
            SizedBox(height: 16),
            Text('No requests yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Requests for your donations will appear here', textAlign: TextAlign.center),
          ]));

        final requests = snap.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (_, i) => _RequestTile(request: requests[i]),
        );
      },
    );
  }
}

class _RequestTile extends StatelessWidget {
  final RequestModel request;
  const _RequestTile({required this.request});

  @override
  Widget build(BuildContext context) {
    final prov = context.read<DonationProvider>();
    final notifProv = context.read<NotificationProvider>();
    final isPending = request.status == AppConstants.reqPending;

    Color statusColor;
    switch (request.status) {
      case 'approved':  statusColor = AppTheme.successGreen; break;
      case 'rejected':  statusColor = AppTheme.errorRed; break;
      case 'completed': statusColor = AppTheme.tealGreen; break;
      default:          statusColor = AppTheme.warmAmber;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(
              radius: 20, backgroundColor: AppTheme.tealGreen.withOpacity(0.1),
              child: const Icon(Icons.person, color: AppTheme.tealGreen),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(request.recipientName, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('Requesting: ${request.donationTitle}',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withOpacity(0.3))),
              child: Text(Helpers.statusLabel(request.status),
                style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            const Icon(Icons.schedule_outlined, size: 14, color: AppTheme.tealGreen),
            const SizedBox(width: 4),
            Text('Pickup: ${request.selectedTimeSlot}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            const Spacer(),
            Text(Helpers.timeAgo(request.createdAt),
              style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          ]),
          if (request.message != null && request.message!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
              child: Text(request.message!, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
            ),
          ],
          if (isPending) ...[
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: OutlinedButton(
                onPressed: () async {
                  await prov.respondToRequest(request.id, AppConstants.reqRejected, request.donationId);
                  await notifProv.saveNotification(
                    userId: request.recipientId,
                    title: 'Request declined',
                    body: 'Your request for "${request.donationTitle}" was declined.',
                    type: 'request', relatedId: request.id,
                  );
                },
                style: OutlinedButton.styleFrom(foregroundColor: AppTheme.errorRed,
                    side: const BorderSide(color: AppTheme.errorRed)),
                child: const Text('Decline'),
              )),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton(
                onPressed: () async {
                  final auth = context.read<AuthProvider>();
                  await prov.respondToRequest(
                    request.id, AppConstants.reqApproved, request.donationId,
                    claimedByUid: request.recipientId, claimedByName: request.recipientName,
                  );
                  await notifProv.saveNotification(
                    userId: request.recipientId,
                    title: 'Request approved!',
                    body: 'Your request for "${request.donationTitle}" has been approved. Pickup: ${request.selectedTimeSlot}',
                    type: 'request', relatedId: request.id,
                  );
                },
                child: const Text('Approve'),
              )),
            ]),
          ],
        ]),
      ),
    );
  }
}
