import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  final String groupId;
  final String adminId;
  final String groupName;
  final String photoUrl;
  final String aboutGroup;


  Group({ this.groupId,
      this.adminId,
      this.groupName,
      this.photoUrl,
      this.aboutGroup,} );

  factory Group.fromDocument(DocumentSnapshot doc) {
    return Group(
      groupId: doc.documentID,
      photoUrl: doc['photoUrl'],
      groupName: doc['groupName'],
      adminId: doc['adminId'],
      aboutGroup: doc['aboutGroup'],
    );
  }
}