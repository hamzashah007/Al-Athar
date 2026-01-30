import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String placeId;
  final String placeName;
  final String? placeImage;
  final String? message;
  final DateTime? timestamp;
  final bool read;

  AppNotification({
    required this.id,
    required this.placeId,
    required this.placeName,
    this.placeImage,
    this.message,
    this.timestamp,
    this.read = false,
  });

  factory AppNotification.fromMap(Map<String, dynamic> map, String id) {
    DateTime? ts;
    final rawTs = map['timestamp'];
    if (rawTs is Timestamp) {
      ts = rawTs.toDate();
    } else if (rawTs is DateTime) {
      ts = rawTs;
    } else {
      ts = null;
    }
    return AppNotification(
      id: id,
      placeId: map['placeId'] ?? '',
      placeName: map['placeName'] ?? '',
      placeImage: map['placeImage'],
      message: map['message'],
      timestamp: ts,
      read: map['read'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'placeId': placeId,
      'placeName': placeName,
      'placeImage': placeImage,
      'message': message,
      'timestamp': timestamp ?? FieldValue.serverTimestamp(),
      'read': read,
    };
  }
}
