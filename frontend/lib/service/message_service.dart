import 'package:cloud_firestore/cloud_firestore.dart';

class MessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get messages from Firestore.
  /// If [receiverId] is null, it fetches broadcast messages (receiver_id is null).
  /// If [receiverId] is provided, it fetches messages for that specific user.
  Stream<List<Map<String, dynamic>>> listenToMessages({int? userId}) {
    // We want broadcast messages (receiver_id == null) OR messages for this user
    // Since Firestore doesn't support OR on null values easily across collections without multiple queries,
    // we fetch recently updated messages from the 'messages' collection.
    
    return _firestore.collection('messages')
        .orderBy('created_at', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).where((data) {
        // Filter in memory for broadcast or specific user
        final receiverId = data['receiver_id'];
        if (receiverId == null) return true; // Broadcast
        if (userId != null && receiverId == userId) return true; // Private
        return false;
      }).toList();
    });
  }

  /// Mark a message as read (if needed, locally or in metadata)
  /// For now, we'll just handle display.
}
