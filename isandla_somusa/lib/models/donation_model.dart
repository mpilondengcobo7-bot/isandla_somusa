import 'package:cloud_firestore/cloud_firestore.dart';

class DonationModel {
  final String id;
  final String donorId;
  final String donorName;
  final String? donorPhoto;
  final String title;
  final String description;
  final String category;
  final int quantity;
  final String unit; // portions / kg / items
  final DateTime expiryDate;
  final String? imageUrl;
  final double latitude;
  final double longitude;
  final String address;
  final List<String> availableTimeSlots;
  final String status; // available | claimed | picked_up | expired | cancelled
  final String? claimedByUid;
  final String? claimedByName;
  final DateTime? claimedAt;
  final DateTime createdAt;
  final double donorRating;
  final bool isHalaal;
  final bool isVegetarian;
  final List<String> allergens;

  DonationModel({
    required this.id,
    required this.donorId,
    required this.donorName,
    this.donorPhoto,
    required this.title,
    required this.description,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.expiryDate,
    this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.availableTimeSlots,
    this.status = 'available',
    this.claimedByUid,
    this.claimedByName,
    this.claimedAt,
    required this.createdAt,
    this.donorRating = 0.0,
    this.isHalaal = false,
    this.isVegetarian = false,
    this.allergens = const [],
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'donorId': donorId,
    'donorName': donorName,
    'donorPhoto': donorPhoto,
    'title': title,
    'description': description,
    'category': category,
    'quantity': quantity,
    'unit': unit,
    'expiryDate': Timestamp.fromDate(expiryDate),
    'imageUrl': imageUrl,
    'latitude': latitude,
    'longitude': longitude,
    'address': address,
    'availableTimeSlots': availableTimeSlots,
    'status': status,
    'claimedByUid': claimedByUid,
    'claimedByName': claimedByName,
    'claimedAt': claimedAt != null ? Timestamp.fromDate(claimedAt!) : null,
    'createdAt': Timestamp.fromDate(createdAt),
    'donorRating': donorRating,
    'isHalaal': isHalaal,
    'isVegetarian': isVegetarian,
    'allergens': allergens,
  };

  factory DonationModel.fromMap(Map<String, dynamic> m) => DonationModel(
    id: m['id'] ?? '',
    donorId: m['donorId'] ?? '',
    donorName: m['donorName'] ?? '',
    donorPhoto: m['donorPhoto'],
    title: m['title'] ?? '',
    description: m['description'] ?? '',
    category: m['category'] ?? '',
    quantity: (m['quantity'] as num?)?.toInt() ?? 0,
    unit: m['unit'] ?? 'portions',
    expiryDate: (m['expiryDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
    imageUrl: m['imageUrl'],
    latitude: (m['latitude'] as num?)?.toDouble() ?? 0.0,
    longitude: (m['longitude'] as num?)?.toDouble() ?? 0.0,
    address: m['address'] ?? '',
    availableTimeSlots: List<String>.from(m['availableTimeSlots'] ?? []),
    status: m['status'] ?? 'available',
    claimedByUid: m['claimedByUid'],
    claimedByName: m['claimedByName'],
    claimedAt: (m['claimedAt'] as Timestamp?)?.toDate(),
    createdAt: (m['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    donorRating: (m['donorRating'] as num?)?.toDouble() ?? 0.0,
    isHalaal: m['isHalaal'] ?? false,
    isVegetarian: m['isVegetarian'] ?? false,
    allergens: List<String>.from(m['allergens'] ?? []),
  );

  DonationModel copyWith({
    String? status,
    String? claimedByUid,
    String? claimedByName,
    DateTime? claimedAt,
    String? imageUrl,
  }) => DonationModel(
    id: id, donorId: donorId, donorName: donorName, donorPhoto: donorPhoto,
    title: title, description: description, category: category,
    quantity: quantity, unit: unit, expiryDate: expiryDate,
    imageUrl: imageUrl ?? this.imageUrl,
    latitude: latitude, longitude: longitude, address: address,
    availableTimeSlots: availableTimeSlots,
    status: status ?? this.status,
    claimedByUid: claimedByUid ?? this.claimedByUid,
    claimedByName: claimedByName ?? this.claimedByName,
    claimedAt: claimedAt ?? this.claimedAt,
    createdAt: createdAt, donorRating: donorRating,
    isHalaal: isHalaal, isVegetarian: isVegetarian, allergens: allergens,
  );
}
