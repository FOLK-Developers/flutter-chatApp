import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatApp/Drawers/HomepageDrawer.dart';
import 'package:chatApp/Models/user.dart';
import 'package:chatApp/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:chatApp/Pages/ChattingPage.dart';

import 'package:chatApp/Pages/AccountSettingsPage.dart';
import 'package:chatApp/Widgets/ProgressWidget.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'HomePage.dart';


class AddParticipants extends StatefulWidget {



  final String groupId;

  AddParticipants({Key key , @required this.groupId}) : super (key : key);

  @override
  State createState() => AddParticipantsState(groupId : groupId);
}


class AddParticipantsState extends State<AddParticipants> {

  AddParticipantsState({Key key, @required this.groupId});



  TextEditingController searchTextEditingController=TextEditingController();
  Future<QuerySnapshot> futureSearchResults;
  Future<QuerySnapshot> futureAllResults;
  String currentUserId;
  List<String> participantsList=[];
  final String groupId;


  @override
  void initState() {
    // TODO: implement initState

    readContacts();

    readAllUsers();
  }

  readContacts() async
  {
    List<String> ggg = [];
    String cutt;
    final DocumentSnapshot result= await Firestore.instance.collection("groups").document(groupId).get();
    ggg=List.from(result["participants"]);
    cutt=result["adminId"];
    setState(() {
      participantsList=ggg;
      currentUserId=cutt;
    });
  }

  readAllUsers()
  {
    Future<QuerySnapshot> allFoundUsers= Firestore.instance.collection("users")
        .getDocuments();

    setState(() {
      futureAllResults=allFoundUsers;
    });
  }

  FindFriendHeader()
  {
    return AppBar(
      automaticallyImplyLeading: false,


      backgroundColor: Colors.lightBlue,

      title: Container(
        margin: new EdgeInsets.only(bottom: 4.0),
        child: TextFormField(
          style: TextStyle(fontSize: 18.0, color: Colors.white),
          controller: searchTextEditingController,
          decoration: InputDecoration(
            hintText: "Search here....",
            hintStyle: TextStyle(color: Colors.white),
            enabledBorder: UnderlineInputBorder(

              borderSide: BorderSide(color: Colors.grey),

            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            filled: true,
            prefixIcon: Icon(Icons.person_pin,color: Colors.white,size: 30.0,),
            suffixIcon: IconButton(
              icon: Icon(Icons.clear, color: Colors.white,),
              onPressed: emptyTextFormField,
            ),
          ),
          onFieldSubmitted: controlSearching,
        ),
      ),
    );
  }



  controlSearching(String username)
  {
    Future<QuerySnapshot> allFoundUsers= Firestore.instance.collection("users")
        .where("name",isGreaterThanOrEqualTo: username).getDocuments();

    setState(() {
      futureSearchResults=allFoundUsers;
    });
  }

  emptyTextFormField()
  {
    searchTextEditingController.clear();
  }


  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return WillPopScope(
      /*onWillPop: ()async
      {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen(currentUserId: currentUserId,) ));
      },*/
      child: Scaffold(
        appBar: FindFriendHeader(),
        body: futureSearchResults==null ? displayNoSearchResultScreen() : displayUserFoundScreen(),
      ),
    );
  }

  displayUserFoundScreen()
  {
    return FutureBuilder(
        future: futureSearchResults,
        builder:(context,dataSnapshot)
        {
          if(!dataSnapshot.hasData)
          {
            return circularProgress();
          }
          List<UserResult> searchUserResult=[];
          dataSnapshot.data.documents.forEach((document)
          {
            User eachUser=User.fromDocument(document);
            UserResult userResult=UserResult(eachUser,groupId,participantsList);

            if(document["id"] != currentUserId) {
              searchUserResult.add(userResult);
            }
          });
          return ListView(children:searchUserResult);
        }
    );
  }

  displayNoSearchResultScreen()
  {

    return FutureBuilder(
        future: futureAllResults,
        builder: (context,dataSnapshot)
        {
          if(!dataSnapshot.hasData)
          {
            return circularProgress();
          }
          List<UserResult> searchUserResult=[];
          dataSnapshot.data.documents.forEach((document)
          {
            User eachUser=User.fromDocument(document);
            UserResult userResult=UserResult(eachUser,groupId,participantsList);

            if(currentUserId !=document["id"]) {
              searchUserResult.add(userResult);
            }
          });
          return ListView(children:searchUserResult);
        }
    );

  }
}

class UserResult extends StatefulWidget
{
  final User eachUser;
  final String groupId;
  final List<String> participantsList;

  UserResult(this.eachUser,
      this.groupId,
      this.participantsList
      );

  @override
  State createState() => UserResultState(eachUser : eachUser, groupId : groupId,participantsList :participantsList);

}

class UserResultState extends State<UserResult>{

  UserResultState({Key key, @required this.eachUser,this.groupId,this.participantsList});
  final User eachUser;
  final String groupId;
  final List<String> participantsList;
  bool ispressed=false;

  String groupName ="";
  String groupPhotoUrl="";



  @override
  void initState() {
    readGroupDetails();
  }
  readGroupDetails()async
  {
    DocumentSnapshot documentSnapshot=await Firestore.instance.collection("groups").document(groupId).get();
    setState(() {
      groupName=documentSnapshot["name"];
      groupPhotoUrl=documentSnapshot["photoUrl"];
    });
  }

  updateDataonFirestore()
  {
    Firestore.instance.collection("groups").document(groupId).updateData({
      "participants" : FieldValue.arrayUnion([eachUser.id])
    }).then((value){
      Firestore.instance.collection("chats").document(eachUser.id).collection(eachUser.id).document(groupId).setData({
        "id" : groupId,
        "lastMsg": "You are added to this group",
        "lastMsgTym":DateTime.now().millisecondsSinceEpoch.toString(),
        "name": groupName,
        "photoUrl": groupPhotoUrl,
        "type": 2
      });
      setState(() {
        ispressed=true;
      });
    });
  }
  removeParticipant()
  {
    Firestore.instance.collection("groups").document(groupId).updateData({
      "participants" : FieldValue.arrayRemove([eachUser.id])
    }).then((value){
      Firestore.instance.collection("chats").document(eachUser.id).collection(eachUser.id).document(groupId).delete();
      setState(() {
        ispressed=false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: EdgeInsets.all(4.0),
      child: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            GestureDetector(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.black,
                  backgroundImage: CachedNetworkImageProvider(
                      eachUser.photoUrl),
                ),
                trailing: (!ispressed && ! participantsList.contains(eachUser.id))
                    ? RaisedButton(
                    color: Colors.blueAccent,
                   onPressed: () => updateDataonFirestore(),
                    child: Text(
                      "ADD",
                      style: TextStyle(color: Colors.white, fontSize: 14.0),
                    )
                )
                    : RaisedButton(
                    color: Colors.red,
                    onPressed: ()=>removeParticipant(),
                    child: Text(
                      "REMOVE",
                      style: TextStyle(color: Colors.white, fontSize: 14.0),
                    )

                ),
                title: Text(
                  eachUser.name,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  eachUser.about,
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14.0,
                      fontStyle: FontStyle.italic
                  ),
                ),

              ),
            ),
          ],
        ),
      ),
    );


  }
}








/*class UserResult extends StatelessWidget {
  final User eachUser;

  UserResult(this.eachUser);
  @override
  Widget build(BuildContext context) {
    bool ispressed = false;

    return Padding(
      padding: EdgeInsets.all(4.0),
      child: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            GestureDetector(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.black,
                  backgroundImage: CachedNetworkImageProvider(
                      eachUser.photoUrl),
                ),
                trailing: (!ispressed)
                    ? RaisedButton(
                    color: Colors.blueAccent,
                    onPressed: () {
                      ispressed = true;
                    },
                    child: Text(
                      "ADD",
                      style: TextStyle(color: Colors.white, fontSize: 14.0),
                    )
                )
                    : RaisedButton(
                    color: Colors.red,
                    child: Text(
                      "REMOVE",
                      style: TextStyle(color: Colors.white, fontSize: 14.0),
                    )

                ),
                title: Text(
                  eachUser.nickname,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  eachUser.aboutMe,
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14.0,
                      fontStyle: FontStyle.italic
                  ),
                ),

              ),
            ),
          ],
        ),
      ),
    );
  }
}*/

