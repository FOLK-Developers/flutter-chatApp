import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatApp/Models/user.dart';
import 'package:chatApp/Pages/AddParticipents.dart';
import 'package:chatApp/Pages/GroupSettingsPage.dart';
import 'package:chatApp/Widgets/ProgressWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'HomePage.dart';


class GroupProfile extends StatelessWidget
{
  final String groupId;
  final List<String> participantsList;
  final List<String> participantsNames;
  final List<String> participantsAbout;
  final List<String> participantsPhotos;

  GroupProfile({Key key , @required this.groupId,@required this.participantsAbout,@required this.participantsPhotos, @required this.participantsList,@required this.participantsNames}) : super (key : key);
  @override
  Widget build(BuildContext context) {
    return GroupprofileScreen(participantsAbout : participantsAbout,participantsPhotos : participantsPhotos,participantsList : participantsList,groupId :groupId,participantsNames:participantsNames);
  }
}
class GroupprofileScreen extends StatefulWidget {

  GroupprofileScreen({Key key, @required this.groupId,@required this.participantsList,@required this.participantsAbout,@required this.participantsPhotos,@required this.participantsNames});
  final List<String> participantsList;
  final List<String> participantsNames;
  final List<String> participantsAbout;
  final List<String> participantsPhotos;
  final String groupId;
  @override
  State<StatefulWidget> createState() =>GroupProfileScreenState (participantsAbout : participantsAbout,participantsPhotos : participantsPhotos,participantsNames : participantsNames,participantsList : participantsList,groupId :groupId);
}

class GroupProfileScreenState extends State<GroupprofileScreen> {

  final String groupId;
  final List<String>participantsList;
  final List<String>participantsNames;
  final List<String> participantsAbout;
  final List<String> participantsPhotos;
  SharedPreferences preferences;
  String currentUserId="";
  bool isconnected= false;

  Future<QuerySnapshot> futureUserssResults;
  String adminId;






  GroupProfileScreenState({Key key, @required this.groupId,@required this.participantsAbout,@required this.participantsPhotos,@required this.participantsNames,@required this.participantsList});



  initState() {
    readCurrentUserId();
    readAllUsers();

  }

  readAllUsers()async
  {
    List<String>hhh;
    DocumentSnapshot admin= await Firestore.instance.collection("groups").document(groupId).get();
    setState(() {
      //futureUserssResults=allFoundGroups;
      adminId=admin["adminId"];
    });
  }

  readCurrentUserId()async {
    preferences = await SharedPreferences.getInstance();
    currentUserId = preferences.getString("id");
  }


  @override
  Widget build(BuildContext context) {

    final generateList=List.generate(participantsNames.length, (index) => participantsNames[index]);
    final generateAbout=List.generate(participantsNames.length, (index) => participantsAbout[index]);
    final generatePhoto=List.generate(participantsNames.length, (index) => participantsPhotos[index]);

    return StreamBuilder(
        stream:Firestore.instance.collection("groups").document(groupId).snapshots() ,
        builder: (context, snapshot) {
          if(!snapshot.hasData)
          {
            return circularProgress();
          }
          var groupData= snapshot.data;
          return CustomScrollView(

            slivers:[
              SliverAppBar(
                iconTheme: new IconThemeData(color: Colors.white),
                pinned: true,
                expandedHeight: 250,
                backgroundColor:Colors.blueAccent ,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: EdgeInsets.fromLTRB(50.0, 15, 0, 0),
                  title : RichText(
                    text: TextSpan(
                        children: [
                          TextSpan(text:
                          groupData["name"],
                            style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: "\n"),
                          TextSpan(
                            text: groupData["description"],
                            style: TextStyle(color: Colors.grey,fontSize: 14.0,fontStyle: FontStyle.italic),
                          )
                        ]
                    ),
                  ),

                  background: Image.network(groupData["photoUrl"],fit: BoxFit.cover,),
                ),
                actions: <Widget>[
                  (adminId==currentUserId)
                  ? IconButton(
                    icon: Icon(Icons.edit),
                    color: Colors.white,
                    onPressed: ()
                    {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => GroupSetting(groupId: groupId,)));
                    },
                  )
                      : Container(),

                ],
              ),

                 SliverToBoxAdapter(child: Container(
                   color:Colors.white ,
                   child: Padding(padding: EdgeInsets.fromLTRB(10, 30, 0, 20),
                   child: Text(
                     "Participants :",
                     style: TextStyle(fontStyle: FontStyle.italic,color: Colors.lightBlueAccent,fontSize: 18),
                   ),),
                 ),),


                 SliverFixedExtentList(
                   itemExtent: 80,
                   delegate:SliverChildBuilderDelegate(
                      (context,index) =>
                          Material(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
                              child: Container(
                                color: Colors.white,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.black,backgroundImage: CachedNetworkImageProvider(generatePhoto[index]),
                                  ),
                                  title: Text(generateList[index]),
                                  subtitle: Text(generateAbout[index]),
                                ),
                              ),
                            ),
                          ),
                    childCount: participantsList.length
                  ),

              ),
              SliverFillRemaining(
                child: Container(
                  color: Colors.white,
                  child: (currentUserId==adminId)
                  ? Container(
                    child: Column(
                      children: <Widget>[
                      ButtonTheme(
                      minWidth: 200,
                        child:
                        RaisedButton(
                          color: Colors.lightBlueAccent,
                          onPressed: ()
                          {
                            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => AddParticipants(groupId: groupId,) ));

                          },
                          child: Text(
                            " MANAGE PARTICIPANTS",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),

                    ButtonTheme(
                      minWidth: 200,
                        child:
                        RaisedButton(

                          onPressed: ()
                          {
                          Firestore.instance.collection("groups").document(groupId).updateData({
                          "participants" : FieldValue.arrayRemove([currentUserId])
                          }).then((value) {
                            Firestore.instance.collection("chats").document(currentUserId)
                                .collection(currentUserId)
                                .document(groupId)
                                .delete();
                            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen(currentUserId: currentUserId,)));
                          });
                          },
                          color: Colors.redAccent,

                          child: Text(
                            "EXIT GROUP",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                    )
                      ],
                    ),
                  )
                      : Container(
                    child: Column(
                      children: <Widget>[
                        ButtonTheme(
                          minWidth: 200,

                          child:  RaisedButton(
                          onPressed: ()
                          {
                            Firestore.instance.collection("groups").document(groupId).updateData({
                              "participants" : FieldValue.arrayRemove([currentUserId])
                            }).then((value) {
                              Firestore.instance.collection("chats").document(currentUserId)
                                  .collection(currentUserId)
                                  .document(groupId)
                                  .delete();
                              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen(currentUserId: currentUserId,)));
                            });
                          },

                          color: Colors.redAccent,

                          child: Text(
                            "EXIT GROUP",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        ),
                      ],
                    )
                  )
                ),
              )

            ],
          );
        }
    );

  }
  void handleClick(String value)
  {
    switch(value){
      case 'Add Participants':
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => AddParticipants(groupId: groupId,) ));
        break;
      case 'Settings' :
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => GroupSetting(groupId: groupId,)));
        break;

    }
  }
}

class ContactsResult extends StatelessWidget{
  final User eachUser;
  final String adminId;

  ContactsResult(this.eachUser,this.adminId);

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: EdgeInsets.all(15.0),
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
                trailing: (eachUser.id==adminId) ? Container(
                  decoration: BoxDecoration(border: Border.all(width: 1,color: Colors.lightBlue),borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  child: Text(" Admin ", style: TextStyle(color: Colors.lightBlue),),
                ) : Container()

              ),
            ),
          ],
        ),
      ),
    );

  }

}
