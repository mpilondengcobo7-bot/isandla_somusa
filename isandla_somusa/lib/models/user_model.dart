import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String role; // donor | recipient | admin
  final String? phone;
  final String? photoUrl;
  final String? organisationName;
  final double? latitude;
  final double? longitude;
  final String? address;
  final double rating;
  final int totalDonations;
  final int totalPickups;
  final bool isVerified;
  final bool isActive;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    this.phone,
    this.photoUrl,
    this.organisationName,
    this.latitude,
    this.longitude,
    this.address,
    this.rating = 0.0,
    this.totalDonations = 0,
    this.totalPickups = 0,
    this.isVerified = false,
    this.isActive = true,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'email': email,
    'displayName': displayName,
    'role': role,
    'phone': phone,
    'photoUrl': photoUrl,
    'organisationName': organisationName,
    'latitude': latitude,
    'longitude': longitude,
    'address': address,
    'rating': rating,
    'totalDonations': totalDonations,
    'totalPickups': totalPickups,
    'isVerified': isVerified,
    'isActive': isActive,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory UserModel.fromMap(Map<String, dynamic> m) => UserModel(
    uid: m['uid'] ?? '',
    email: m['email'] ?? '',
    displayName: m['displayName'] ?? '',
    role: m['role'] ?? 'recipient',
    phone: m['phone'],
    photoUrl: m['photoUrl'],
    organisationName: m['organisationName'],
    latitude: (m['latitude'] as num?)?.toDouble(),
    longitude: (m['longitude'] as num?)?.toDouble(),
    address: m['address'],
    rating: (m['rating'] as num?)?.toDouble() ?? 0.0,
    totalDonations: (m['totalDonations'] as num?)?.toInt() ?? 0,
    totalPickups: (m['totalPickups'] as num?)?.toInt() ?? 0,
    isVerified: m['isVerified'] ?? false,
    isActive: m['isActive'] ?? true,
    createdAt: (m['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );

  UserModel copyWith({
    String? displayName,
    String? phone,
    String? photoUrl,
    String? organisationName,
    double? latitude,
    double? longitude,
    String? address,
    double? rating,
    int? totalDonations,
    int? totalPickups,
    bool? isVerified,
    bool? isActive,
  }) => UserModel(
    uid: uid,
    email: email,
    displayName: displayName ?? this.displayName,
    role: role,
    phone: phone ?? this.phone,
    photoUrl: photoUrl ?? this.photoUrl,
    organisationName: organisationName ?? this.organisationName,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    address: address ?? this.address,
    rating: rating ?? this.rating,
    totalDonations: totalDonations ?? this.totalDonations,
    totalPickups: totalPickups ?? this.totalPickups,
    isVerified: isVerified ?? this.isVerified,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt,
  );
}
