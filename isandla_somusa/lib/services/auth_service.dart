import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../utils/app_constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── Register with email & password ─────────────────────────────────
  Future<UserModel?> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
    required String role,
    String? organisationName,
    String? phone,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await credential.user?.updateDisplayName(displayName);

    final user = UserModel(
      uid: credential.user!.uid,
      email: email.trim(),
      displayName: displayName,
      role: role,
      phone: phone,
      organisationName: organisationName,
      createdAt: DateTime.now(),
    );

    await _db
        .collection(AppConstants.colUsers)
        .doc(user.uid)
        .set(user.toMap());

    return user;
  }

  // ── Sign in with email & password ──────────────────────────────────
  Future<UserModel?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return _fetchUser(credential.user!.uid);
  }

  // ── Google Sign-In ─────────────────────────────────────────────────
  Future<UserModel?> signInWithGoogle({required String role}) async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCred = await _auth.signInWithCredential(credential);
    final uid = userCred.user!.uid;

    // Check if user already exists
    final doc = await _db.collection(AppConstants.colUsers).doc(uid).get();
    if (doc.exists) return UserModel.fromMap(doc.data()!);

    // New Google user — create profile
    final user = UserModel(
      uid: uid,
      email: userCred.user!.email!,
      displayName: userCred.user!.displayName ?? 'User',
      role: role,
      photoUrl: userCred.user!.photoURL,
      createdAt: DateTime.now(),
    );
    await _db.collection(AppConstants.colUsers).doc(uid).set(user.toMap());
    return user;
  }

  // ── Sign out ───────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ── Password reset ─────────────────────────────────────────────────
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // ── Fetch user profile ─────────────────────────────────────────────
  Future<UserModel?> _fetchUser(String uid) async {
    final doc = await _db.collection(AppConstants.colUsers).doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!);
  }

  Future<UserModel?> getCurrentUserModel() async {
    if (currentUser == null) return null;
    return _fetchUser(currentUser!.uid);
  }

  // ── Update user profile ────────────────────────────────────────────
  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    await _db.collection(AppConstants.colUsers).doc(uid).update(data);
  }

  // ── Hash password for local storage (POPIA) ────────────────────────
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }
}
