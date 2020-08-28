import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatApp/Drawers/HomepageDrawer.dart';
import 'package:chatApp/Models/group.dart';
import 'package:chatApp/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:chatApp/Pages/ChattingPage.dart';
import 'package:chatApp/models/user.dart';
import 'package:chatApp/Pages/AccountSettingsPage.dart';
import 'package:chatApp/Widgets/ProgressWidget.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'CreteGroup.dart';
import 'FindFriend.dart';
import 'GroupChat.dart';
import 'UserProfile.dart';

class HomeScreen extends StatefulWidget {
  final String currentUserId;

  HomeScreen({Key key , @required this.currentUserId}) : super (key : key);

  @override
  State createState() => HomeScreenState(currentUserId :currentUserId);
}

class HomeScreenState extends State<HomeScreen> {

  HomeScreenState({Key key, @required this.currentUserId});
  TextEditingController searchTextEditingController=TextEditingController();
  final ScrollController listScrollController=ScrollController();
  Future<QuerySnapshot> futureContactsResults;

  List<String>contactList=[];
  final String currentUserId;
  var chatlist;

  @override
  void initState() {

    readContactList();

    readAllUsers();

  }

  readContactList()async
  {


    final DocumentSnapshot document= await Firestore.instance.collection("users").document(currentUserId).get();

    List<String> ggg= List.from(document['contact list']);

    setState(() {
      contactList=ggg;
    });

  }


  readAllUsers()
  {
    Future<QuerySnapshot> allFoundGroups= Firestore.instance.collection("users").getDocuments();
    setState(() {
      futureContactsResults=allFoundGroups;
    });
  }


  homePageHeader()
  {
    return AppBar(
      automaticallyImplyLeading: false,

      backgroundColor: Colors.lightBlue,
      iconTheme: new IconThemeData(color: Colors.white),
      bottom: TabBar(
        indicator: UnderlineTabIndicator(borderSide: BorderSide(color: Colors.white,width: 2.0,),
          insets: EdgeInsets.fromLTRB(20, 40, 20, 0),

        ),
        unselectedLabelColor: Colors.grey,
        unselectedLabelStyle: TextStyle(
          color: Colors.grey
        ),

        tabs: <Widget>[
          Tab(
            child: Text(
              "Chats",
              style: TextStyle(fontSize: 27,fontWeight: FontWeight.bold,color: Colors.white,fontFamily:"Signatra"),
            ),
          ),

          Tab(
            child: Text(
              "Contacts",
              style: TextStyle(fontSize: 27,fontWeight: FontWeight.bold,color: Colors.white,fontFamily:"Signatra"),
            ),
          ),
        ],

      ),
      actions: <Widget>[




        PopupMenuButton(
          onSelected:handleClick,
          itemBuilder:(context){
          return{'Create Group','Find Friends', 'Settings'}.map((String choice)
          {
            return PopupMenuItem(
              child: Text(choice),
              value: choice,
          );
          }).toList();
        }
        ),
      ],
      title: Container(

        child: Text(
          "ChatApp",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 29,fontWeight: FontWeight.bold, fontFamily:"Signatra",color: Colors.white ),
        ),
      ),
    );
  }

  void handleClick(String choice)
  {
    switch(choice)
    {
      case 'Find Friends' :
        Navigator.push(context, MaterialPageRoute(builder: (context) => FindFriend(currentUserId: currentUserId,)));
        break;
      case 'Settings' :
        Navigator.push(context, MaterialPageRoute(builder: (context) =>Settings()));
        break;
      case 'Create Group' :
        Navigator.push(context, MaterialPageRoute(builder: (context) => CreateGroup()));
        break;
    }

  }

  displayContacts()
  {
    return FutureBuilder(
        future: futureContactsResults,
        builder:(context,dataSnapshot) {
          if (!dataSnapshot.hasData) {
            return circularProgress();
          }
          List<ContactsResult> allContacts = [];
          dataSnapshot.data.documents.forEach((document) {
            User eachUser = User.fromDocument(document);
            ContactsResult contactsResult = ContactsResult(eachUser,contactList);

            if(contactList.contains(document["id"])) {
              allContacts.add(contactsResult);
            }
          });
          return ListView(children: allContacts);
        }

    );
  }


  Widget createItem(int index, DocumentSnapshot document)
  {
    return Padding(
      padding: EdgeInsets.all(4.0),
      child: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            GestureDetector(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.black,backgroundImage: CachedNetworkImageProvider(document["photoUrl"]),
                ),
                title: Text(
                  document["name"],
                  style: TextStyle(
                    color: Colors.black,fontSize: 16.0, fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  document["lastMsg"],
                  style: TextStyle(
                      color: Colors.grey,fontSize: 14.0, fontStyle: FontStyle.italic
                  ),
                ),

                onTap:(document["type"]==1) ?()
                {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Chat(contactList: contactList,receiverId : document["id"], receiverAvatar : document["photoUrl"], receiverName : document["name"])));
                }
                : ()
                {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => GroupChat(groupId : document["id"])));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  displayChats()
  {
    return Flexible(
        child: currentUserId ==""
            ?  Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                  ),
                )
            : StreamBuilder(
                  stream: Firestore.instance
                      .collection("chats")
                  .document(currentUserId)
                  .collection(currentUserId)
                  .orderBy("lastMsgTym",descending: true).limit(20).snapshots(),
          builder: (context,snapshot)
          {
            if(!snapshot.hasData)
            {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                ),
              );
            }
            else
              {
                chatlist =snapshot.data.documents;
                return ListView.builder(
                  itemBuilder: (context,index) => createItem(index,snapshot.data.documents[index]),
                  itemCount: snapshot.data.documents.length,
                  controller: listScrollController,
                );
              }

          },
        ),
    );

  }



  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: 2,
        child:Scaffold(
          appBar: homePageHeader(),
          //drawer: HomepageDrawer(),
          body:TabBarView(children: <Widget>[
            displayChats(),
            displayContacts(),
            ],
          ),
        ),
    );
  }

}

class ContactsResult extends StatelessWidget{
  final User eachUser;
  final List<String> contactList;
  ContactsResult(this.eachUser,this.contactList);

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
                  backgroundColor: Colors.black,backgroundImage: CachedNetworkImageProvider(eachUser.photoUrl),
                ),
                title: Text(
                  eachUser.name,
                  style: TextStyle(
                    color: Colors.black,fontSize: 16.0, fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  eachUser.about,
                  style: TextStyle(
                      color: Colors.grey,fontSize: 14.0, fontStyle: FontStyle.italic
                  ),
                ),
                onTap: ()
                {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Chat(contactList: contactList,receiverId : eachUser.id, receiverAvatar : eachUser.photoUrl, receiverName : eachUser.name)));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
