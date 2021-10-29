import 'package:cloud_firestore/cloud_firestore.dart';

class postmini {
  final bool myPhoto;
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  final dynamic likes;
  final bool addDivider;
  final Timestamp timestamp;
  final String thumb;

  postmini(
      {this.myPhoto = false,
      this.postId,
      this.ownerId,
      this.username,
      this.location,
      this.description,
      this.mediaUrl,
      this.likes,
      this.timestamp,
      this.addDivider = false,
      this.thumb});

  factory postmini.fromDocument(DocumentSnapshot doc) {
    return postmini(
      postId: doc['postId'],
      ownerId: doc['ownerId'],
      username: doc['username'],
      location: doc['location'],
      description: doc['description'],
      mediaUrl: doc['mediaUrl'],
      likes: doc['likes'],
      timestamp: doc["timestamp"],
      thumb: doc["thumb"] ?? "",
    );
  }
}
