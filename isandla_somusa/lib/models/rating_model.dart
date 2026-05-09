import 'package:cloud_firestore/cloud_firestore.dart';

class RatingModel {
  final String id;
  final String requestId;
  final String raterId;
  final String raterName;
  final String ratedUserId;
  final String ratedUserName;
  final double score;
  final String? comment;
  final String sentiment;
  final DateTime createdAt;

  RatingModel({
    required this.id,
    required this.requestId,
    required this.raterId,
    required this.raterName,
    required this.ratedUserId,
    required this.ratedUserName,
    required this.score,
    this.comment,
    this.sentiment = 'neutral',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'requestId': requestId,
    'raterId': raterId,
    'raterName': raterName,
    'ratedUserId': ratedUserId,
    'ratedUserName': ratedUserName,
    'score': score,
    'comment': comment,
    'sentiment': sentiment,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory RatingModel.fromMap(Map<String, dynamic> m) => RatingModel(
    id: m['id'] ?? '',
    requestId: m['requestId'] ?? '',
    raterId: m['raterId'] ?? '',
    raterName: m['raterName'] ?? '',
    ratedUserId: m['ratedUserId'] ?? '',
    ratedUserName: m['ratedUserName'] ?? '',
    score: (m['score'] as num?)?.toDouble() ?? 0.0,
    comment: m['comment'],
    sentiment: m['sentiment'] ?? 'neutral',
    createdAt: (m['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );
}
