import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();

  UserModel? _user;
  bool _loading = false;
  String? _error;

  UserModel? get user => _user;
  bool get loading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  bool get isDonor => _user?.role == 'donor';
  bool get isRecipient => _user?.role == 'recipient';
  bool get isAdmin => _user?.role == 'admin';

  void _setLoading(bool v) { _loading = v; notifyListeners(); }
  void _setError(String? e) { _error = e; notifyListeners(); }

  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
    required String role,
    String? organisationName,
    String? phone,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      _user = await _service.registerWithEmail(
        email: email,
        password: password,
        displayName: displayName,
        role: role,
        organisationName: organisationName,
        phone: phone,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _setError(_friendlyError(e.toString()));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    _setLoading(true);
    _setError(null);
    try {
      _user = await _service.signInWithEmail(email: email, password: password);
      notifyListeners();
      return _user != null;
    } catch (e) {
      _setError(_friendlyError(e.toString()));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithGoogle({required String role}) async {
    _setLoading(true);
    _setError(null);
    try {
      _user = await _service.signInWithGoogle(role: role);
      notifyListeners();
      return _user != null;
    } catch (e) {
      _setError(_friendlyError(e.toString()));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _service.signOut();
    _user = null;
    notifyListeners();
  }

  Future<void> loadCurrentUser() async {
    _user = await _service.getCurrentUserModel();
    notifyListeners();
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    if (_user == null) return;
    await _service.updateProfile(_user!.uid, data);
    await loadCurrentUser();
  }

  Future<void> sendPasswordReset(String email) async {
    await _service.sendPasswordReset(email);
  }

  String _friendlyError(String raw) {
    if (raw.contains('user-not-found'))    return 'No account found with this email.';
    if (raw.contains('wrong-password'))    return 'Incorrect password. Please try again.';
    if (raw.contains('email-already'))     return 'An account already exists with this email.';
    if (raw.contains('weak-password'))     return 'Password is too weak.';
    if (raw.contains('network-request'))   return 'No internet connection.';
    if (raw.contains('too-many-requests')) return 'Too many attempts. Please try again later.';
    return 'Something went wrong. Please try again.';
  }
}
