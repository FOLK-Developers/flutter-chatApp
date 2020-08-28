import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String name;
  final String photoUrl;
  final String lastseen;
  final List<String> contactList;
  final String about;

  User({
    this.id,
    this.name,
    this.photoUrl,
    this.lastseen,
    this.about,
    this.contactList
  });

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      id: doc.documentID,
      photoUrl: doc['photoUrl'],
      name: doc['name'],
      lastseen: doc['last seen'],
      about: doc['about'],
    );
  }
}