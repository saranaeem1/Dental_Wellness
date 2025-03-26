import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  final String id;
  final String userId;
  final int rating;
  final String comment;
  final DateTime timestamp;

  FeedbackModel({
    required this.id,
    required this.userId,
    required this.rating,
    required this.comment,
    required this.timestamp,
  });

  // ✅ Convert FeedbackModel to JSON (for Firestore storage)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'rating': rating,
      'comment': comment,
      'timestamp': timestamp.toUtc(), // Store timestamp in UTC
    };
  }

  // ✅ Convert JSON (from Firestore) to FeedbackModel
  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json['id'],
      userId: json['userId'],
      rating: json['rating'],
      comment: json['comment'],
      timestamp: (json['timestamp'] as Timestamp).toDate(), // Convert Firestore timestamp
    );
  }
}
