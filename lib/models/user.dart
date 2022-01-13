import 'package:cloud_firestore/cloud_firestore.dart';

class UserChat {
  final String id;
  final String nickname;
  final String photoUrl;
  final String createdAt;
  final String aboutMe;

  UserChat({
    required this.id,
    required this.nickname,
    required this.photoUrl,
    required this.createdAt,
    required this.aboutMe
  });

  factory UserChat.fromDocument(DocumentSnapshot doc) {
    return UserChat(
      id: doc.id,
      photoUrl: doc['photoUrl'],
      nickname: doc['nickname'],
      createdAt: doc['createdAt'],
      aboutMe: doc['aboutMe'],
    );
  }
}
