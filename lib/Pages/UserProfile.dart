import 'package:chatApp/Models/user.dart';
import 'package:chatApp/Widgets/ProgressWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'HomePage.dart';


class UserProfile extends StatelessWidget
{
  final String UserId;
  final List<String> contactList;

  UserProfile({Key key , @required this.UserId, @required this.contactList}) : super (key : key);
  @override
  Widget build(BuildContext context) {
   return UserprofileScreen(contactList : contactList,UserId :UserId);
  }
}

class UserprofileScreen extends StatefulWidget {

  UserprofileScreen({Key key, @required this.UserId,@required this.contactList});




  final List<String> contactList;
  final String UserId;
  @override
  State<StatefulWidget> createState() =>UserProfileScreenState (contactList : contactList,UserId :UserId);
}

class UserProfileScreenState extends State<UserprofileScreen> {

  final String UserId;
  final List<String>contactList;
  SharedPreferences preferences;
  String currentUserId="";
  bool isconnected= false;



  UserProfileScreenState({Key key, @required this.UserId,@required this.contactList});



  initState() {
     readCurrentUserId();

  }
  readCurrentUserId()async {
    preferences = await SharedPreferences.getInstance();
    currentUserId = preferences.getString("id");
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream:Firestore.instance.collection("users").document(UserId).snapshots() ,
      builder: (context, snapshot) {
        if(!snapshot.hasData)
          {
            return circularProgress();
          }
        var userData= snapshot.data;
        return NestedScrollView(headerSliverBuilder: (BuildContext context,bool innerBoxedIsScrolled)
            {return <Widget>[
            SliverAppBar(
            pinned: true,
            expandedHeight: 250,
            backgroundColor:Colors.blueAccent ,
            flexibleSpace: FlexibleSpaceBar(
            titlePadding: EdgeInsets.fromLTRB(50, 10, 10, 10),
            title: Text(
             userData["name"],
              style: TextStyle(color: Colors.white),
            ),
              background: Image.network(userData["photoUrl"],fit: BoxFit.cover,),
            ),
            )];

            }, body: Container(
          color: Colors.white,

          child: Padding(

            padding: EdgeInsets.fromLTRB(8, 30, 8, 0),
            child: Container(
              color: Colors.white,
              child: Column(

                children: <Widget>[
                  Material(

                    child:
                    ListTile(
                      title: Text(
                        "Description",
                        style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold,color: Colors.lightBlueAccent),
                      ),
                      subtitle: Text(

                                  "\t\t\t\t"+userData["about"],
                                  style: TextStyle(color: Colors.black54),
                                ),

                    ),

                  ),

                  Padding(
                    padding:EdgeInsets.all(38.0),
                    child: Container(

                      child:ButtonTheme (
                        minWidth: 300,
                        child:(contactList.contains(userData["id"])) ?RaisedButton(
                            color: Colors.red,
                            child: Text("REMOVE",
                              style: TextStyle(color: Colors.white, fontSize: 14.0),
                            ),

                            onPressed:()async
                            {
                              await Firestore.instance.collection("users").document(currentUserId).updateData({"contact list" : FieldValue.arrayRemove([userData["id"]])});
                              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen(currentUserId: currentUserId,) ));
                            }
                         )
                            :RaisedButton(
                          color: Colors.lightBlueAccent,
                          child: Text("ADD",
                            style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
                          ),
                          onPressed: () async
                          {
                            await Firestore.instance.collection("users").document(currentUserId).updateData(
                                {
                                  "contact list" : FieldValue.arrayUnion([userData["id"]]),
                                }

                            );
                            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen(currentUserId: currentUserId,) ));

                          },
                        )

                      ),
                    ),
                  )

                ],
              ),
            ),
          ),
        ),
        );
      }
    );
  }
}
