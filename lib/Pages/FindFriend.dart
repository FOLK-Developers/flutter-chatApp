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


class FindFriend extends StatefulWidget {



  final String currentUserId;

  FindFriend({Key key , @required this.currentUserId}) : super (key : key);

  @override
  State createState() => FindFriendState(currentUserId :currentUserId);
}


class FindFriendState extends State<FindFriend> {

FindFriendState({Key key, @required this.currentUserId});



TextEditingController searchTextEditingController=TextEditingController();
Future<QuerySnapshot> futureSearchResults;
Future<QuerySnapshot> futureAllResults;
List<String> contactList=[];
final String currentUserId;


@override
void initState() {
  // TODO: implement initState
  
  readContacts();
  
  readAllUsers();
}

readContacts() async
{
  List<String> ggg = [];
  final QuerySnapshot result= await Firestore.instance.collection("contacts").document(currentUserId).collection("contactlist").getDocuments();
  final List<DocumentSnapshot>documents=result.documents;

  documents.forEach((element) {

    ggg.add(element["id"]);

  });
  setState(() {
    contactList=ggg;
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
    leading: IconButton(
      icon: Icon(Icons.arrow_back,color: Colors.white,),
      onPressed:()
        {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen(currentUserId: currentUserId,) ));
        },
    ),
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
      .where("nickname",isGreaterThanOrEqualTo: username).getDocuments();

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
    onWillPop: ()async
    {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen(currentUserId: currentUserId,) ));
    },
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
          UserResult userResult=UserResult(eachUser,currentUserId);

          if( !contactList.contains(document["id"]) && currentUserId != document["id"]) {
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
          UserResult userResult=UserResult(eachUser,currentUserId);

          if(!contactList.contains(document["id"]) && currentUserId != document["id"]) {
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
  final String currentUserId;

  UserResult(this.eachUser,
              this.currentUserId
      );

  @override
  State createState() => UserResultState(eachUser : eachUser, currentUserId : currentUserId);

}

class UserResultState extends State<UserResult>{

  UserResultState({Key key, @required this.eachUser,this.currentUserId});
  final User eachUser;
  final String currentUserId;
  bool ispressed=false;

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
                trailing: (!ispressed )
                    ? RaisedButton(
                    color: Colors.blueAccent,
                    onPressed: () async
                    {
                       await Firestore.instance.collection("contacts").document(currentUserId).collection("contactlist").document(eachUser.id).setData(
                        {
                          "id" : eachUser.id,
                        }
                      );
                      setState(()=>ispressed=true);
                    },
                    child: Text(
                      "ADD",
                      style: TextStyle(color: Colors.white, fontSize: 14.0),
                    )
                )
                    : RaisedButton(
                    color: Colors.red,
                    onPressed: () async
                     {
                      await Firestore.instance.collection("contacts").document(currentUserId).collection("contactlist").document(eachUser.id).delete();
                      setState(()=>ispressed=false);
                    },
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

