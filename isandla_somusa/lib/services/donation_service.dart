import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../models/donation_model.dart';
import '../models/request_model.dart';
import '../models/rating_model.dart';
import '../utils/app_constants.dart';

class DonationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  Future<DonationModel> createDonation(DonationModel donation,
      {File? imageFile}) async {
    String? imageUrl;
    if (imageFile != null) {
      imageUrl = await _uploadImage(imageFile, donation.id);
    }
    final withImage =
        imageUrl != null ? donation.copyWith(imageUrl: imageUrl) : donation;
    await _db
        .collection(AppConstants.colDonations)
        .doc(withImage.id)
        .set(withImage.toMap());
    return withImage;
  }

  Future<String> _uploadImage(File file, String donationId) async {
    final ref = _storage
        .ref()
        .child('${AppConstants.storageDonationImages}/$donationId.jpg');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  Stream<List<DonationModel>> streamAvailableDonations() {
    return _db
        .collection(AppConstants.colDonations)
        .where('status', isEqualTo: AppConstants.statusAvailable)
        .snapshots()
        .map((s) {
      final list = s.docs
          .map((d) => DonationModel.fromMap(d.data()))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<List<DonationModel>> streamDonorDonations(String donorId) {
    return _db
        .collection(AppConstants.colDonations)
        .where('donorId', isEqualTo: donorId)
        .snapshots()
        .map((s) {
      final list = s.docs
          .map((d) => DonationModel.fromMap(d.data()))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<void> updateStatus(String id, String status,
      {String? claimedByUid, String? claimedByName}) async {
    final data = <String, dynamic>{'status': status};
    if (claimedByUid != null) {
      data['claimedByUid'] = claimedByUid;
      data['claimedByName'] = claimedByName;
      data['claimedAt'] = Timestamp.now();
    }
    await _db.collection(AppConstants.colDonations).doc(id).update(data);
  }

  Future<void> deleteDonation(String id) async {
    await _db.collection(AppConstants.colDonations).doc(id).delete();
  }

  Future<RequestModel> createRequest(RequestModel request) async {
    await _db
        .collection(AppConstants.colRequests)
        .doc(request.id)
        .set(request.toMap());
    return request;
  }

  Stream<List<RequestModel>> streamRecipientRequests(String recipientId) {
    return _db
        .collection(AppConstants.colRequests)
        .where('recipientId', isEqualTo: recipientId)
        .snapshots()
        .map((s) {
      final list = s.docs
          .map((d) => RequestModel.fromMap(d.data()))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<List<RequestModel>> streamDonorRequests(String donorId) {
    return _db
        .collection(AppConstants.colRequests)
        .where('donorId', isEqualTo: donorId)
        .snapshots()
        .map((s) {
      final list = s.docs
          .map((d) => RequestModel.fromMap(d.data()))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<void> respondToRequest(String requestId, String status,
      String donationId,
      {String? claimedByUid, String? claimedByName}) async {
    final batch = _db.batch();
    batch.update(
      _db.collection(AppConstants.colRequests).doc(requestId),
      {'status': status, 'respondedAt': Timestamp.now()},
    );
    if (status == AppConstants.reqApproved) {
      batch.update(
        _db.collection(AppConstants.colDonations).doc(donationId),
        {
          'status': AppConstants.statusClaimed,
          'claimedByUid': claimedByUid,
          'claimedByName': claimedByName,
          'claimedAt': Timestamp.now(),
        },
      );
    }
    await batch.commit();
  }

  Future<void> submitRating(RatingModel rating) async {
    final batch = _db.batch();
    batch.set(
      _db.collection(AppConstants.colRatings).doc(rating.id),
      rating.toMap(),
    );
    batch.update(
      _db.collection(AppConstants.colRequests).doc(rating.requestId),
      {
        'status': AppConstants.reqCompleted,
        'completedAt': Timestamp.now()
      },
    );
    await batch.commit();
    await _updateUserRating(rating.ratedUserId);
  }

  Future<void> _updateUserRating(String userId) async {
    final ratings = await _db
        .collection(AppConstants.colRatings)
        .where('ratedUserId', isEqualTo: userId)
        .get();
    if (ratings.docs.isEmpty) return;
    final avg = ratings.docs
            .map((d) => (d.data()['score'] as num).toDouble())
            .reduce((a, b) => a + b) /
        ratings.docs.length;
    await _db.collection(AppConstants.colUsers).doc(userId).update({
      'rating': double.parse(avg.toStringAsFixed(1)),
    });
  }

  Stream<List<RatingModel>> streamUserRatings(String userId) {
    return _db
        .collection(AppConstants.colRatings)
        .where('ratedUserId', isEqualTo: userId)
        .snapshots()
        .map((s) => s.docs
            .map((d) => RatingModel.fromMap(d.data()))
            .toList());
  }

  String generateId() => _uuid.v4();
}