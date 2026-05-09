import 'dart:io';
import 'package:flutter/material.dart';
import '../models/donation_model.dart';
import '../models/request_model.dart';
import '../models/rating_model.dart';
import '../services/donation_service.dart';

class DonationProvider extends ChangeNotifier {
  final DonationService _service = DonationService();

  List<DonationModel> _donations = [];
  List<RequestModel> _requests = [];
  bool _loading = false;
  String? _error;

  List<DonationModel> get donations => _donations;
  List<RequestModel> get requests => _requests;
  bool get loading => _loading;
  String? get error => _error;

  void _setLoading(bool v) { _loading = v; notifyListeners(); }

  Stream<List<DonationModel>> streamAvailable() =>
      _service.streamAvailableDonations();

  Stream<List<DonationModel>> streamMyDonations(String donorId) =>
      _service.streamDonorDonations(donorId);

  Stream<List<RequestModel>> streamMyRequests(String recipientId) =>
      _service.streamRecipientRequests(recipientId);

  Stream<List<RequestModel>> streamIncomingRequests(String donorId) =>
      _service.streamDonorRequests(donorId);

  Future<bool> createDonation(DonationModel donation, {File? imageFile}) async {
    _setLoading(true);
    try {
      await _service.createDonation(donation, imageFile: imageFile);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createRequest(RequestModel request) async {
    _setLoading(true);
    try {
      await _service.createRequest(request);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> respondToRequest(String requestId, String status,
      String donationId, {String? claimedByUid, String? claimedByName}) async {
    _setLoading(true);
    try {
      await _service.respondToRequest(requestId, status, donationId,
          claimedByUid: claimedByUid, claimedByName: claimedByName);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> submitRating(RatingModel rating) async {
    _setLoading(true);
    try {
      await _service.submitRating(rating);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteDonation(String id) async {
    _setLoading(true);
    try {
      await _service.deleteDonation(id);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  String generateId() => _service.generateId();
}
