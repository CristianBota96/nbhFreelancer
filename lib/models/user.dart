import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String profileName;
  final String username;
  final String url;
  final String email;
  final String bio;
  final String phoneNumber;
  final String location;

  User({
    this.id,
    this.profileName,
    this.username,
    this.url,
    this.email,
    this.bio,
    this.phoneNumber,
    this.location,
  });

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      id: doc.documentID,
      email: doc['email'],
      username: doc['username'],
      url: doc['url'],
      profileName: doc['profileName'],
      bio: doc['bio'],
      phoneNumber: doc['phoneNumber'],
      location: doc['location'],
    );
  }
}