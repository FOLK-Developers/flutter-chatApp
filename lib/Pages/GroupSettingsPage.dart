
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatApp/Pages/GroupProfile.dart';
import 'package:chatApp/Widgets/ProgressWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GroupSetting extends StatelessWidget
{
  final String groupId;
  GroupSetting({Key key, @required this.groupId}) : super(key :key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
            color: Colors.white
        ),
        backgroundColor: Colors.lightBlue,
        title: Text(
          "Group Settings",
          style: TextStyle( color: Colors.white,fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: GroupSettingsScreen(groupId : groupId),
    );
  }
}

class GroupSettingsScreen extends StatefulWidget {
  final String groupId;
  GroupSettingsScreen({@required this.groupId});
  @override
  State createState() => GroupSettingsScreenState(groupId : groupId);
}

class GroupSettingsScreenState extends State<GroupSettingsScreen>{

  final String groupId;

  GroupSettingsScreenState({@required this.groupId});

  TextEditingController groupnameTextEditingController;
  TextEditingController descriptionTextEditingController;
  bool isLoading=false;
  String groupname="";
  String description="";
  String photoUrl="";
  File imageFileAvator;
  final FocusNode groupNameFocusNode=FocusNode();
  final FocusNode descriptionNameFocusNode=FocusNode();

  List<String> participantsList=[];


  @override
  void initState() {
    readData();
  }

  readData() async
  {
    DocumentSnapshot data= await Firestore.instance.collection("groups").document(groupId).get();
    photoUrl= data["photoUrl"];
    groupname= data["name"];
    description=data["description"];
    participantsList= List.from(data["participants"]);

    groupnameTextEditingController=TextEditingController(text: groupname);
    descriptionTextEditingController=TextEditingController(text: description);
    setState(() {

    });
  }

  Future getImage() async
  {
    File newImagefile=await ImagePicker.pickImage(source: ImageSource.gallery);

    if(newImagefile != null)
    {
      setState(() {
        this.imageFileAvator= newImagefile;
        isLoading=true;
      });
    }

    uploadImageToFireStoreAndStorage();
  }

  Future uploadImageToFireStoreAndStorage() async
  {
    String mFileName=groupId;
    StorageReference storageReference=FirebaseStorage.instance.ref().child("Users Profile Image").child(mFileName);
    StorageUploadTask storageUploadTask=storageReference.putFile(imageFileAvator);
    StorageTaskSnapshot storageTaskSnapshot;
    storageUploadTask.onComplete.then((value)
    {
      if(value.error== null)
      {
        storageTaskSnapshot=value;
        storageTaskSnapshot.ref.getDownloadURL().then((newImageDownloadUrl)
        {
          photoUrl=newImageDownloadUrl;
          Firestore.instance.collection("groups").document(groupId).updateData({
            "photoUrl" : photoUrl,
            "description" : description,
            "name": groupname
          }).then((data) async
          {
            for(var i= 0; i<participantsList.length;i++)
              {
                Firestore.instance.collection("chats").document(participantsList[i]).collection(participantsList[i]).document(groupId).updateData({
                  "name":groupname,
                  "photoUrl":photoUrl,
                });
              }

            setState(() {
              isLoading=false;
            });
            Fluttertoast.showToast(msg: "Updated Successfully");
          });


        },onError: (errorMsg)
        {
          setState(() {
            isLoading=false;
          });
          Fluttertoast.showToast(msg: "Error occured in getting Download Url.");
        });

      }


    },onError: (errorMsg)
    {
      setState(() {
        isLoading=false;
      });
      Fluttertoast.showToast(msg: errorMsg.toString());
    });
  }

  void updateData()
  {
    groupNameFocusNode.unfocus();
    descriptionNameFocusNode.unfocus();
    setState(() {
      isLoading=false;
    });

    Firestore.instance.collection("groups").document(groupId).updateData({
      "photoUrl" : photoUrl,
      "name" : groupname,
      "description" : description,
    }).then((data) async
    {
      for(var i= 0; i<participantsList.length;i++)
      {
        Firestore.instance.collection("chats").document(participantsList[i]).collection(participantsList[i]).document(groupId).updateData({
          "name":groupname,
          "photoUrl":photoUrl,
        });
      }

      setState(() {
        isLoading=false;
      });
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => GroupProfile(groupId: groupId,participantsList: participantsList,) ));
      Fluttertoast.showToast(msg: "Updated Successfully");
    });

  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          child: Column(
            children: <Widget>[

              Container(
                child: Center(
                  child: Stack(
                    children: <Widget>[
                      (imageFileAvator == null)
                      ? Material(
                        //to display existing Image..
                        child: CachedNetworkImage(
                          placeholder: (context, url) =>
                              Container(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.lightBlueAccent
                                  ),
                                ),
                                width: 200.0,
                                height: 200.0,
                                padding: EdgeInsets.all(20.0),
                              ),
                          imageUrl: photoUrl,
                          width: 200.0,
                          height: 200.0,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(125.0)),
                        clipBehavior: Clip.hardEdge,
                      )

                          : Material(
                        //New Updated Image
                        child: Image.file(
                          imageFileAvator,
                          width: 200.0,
                          height: 200.0,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(125.0)),
                        clipBehavior: Clip.hardEdge,
                      ),

                      IconButton(
                        icon: Icon(Icons.camera_alt, size: 100.0,
                            color: Colors.white.withOpacity(0.3)),
                        onPressed: getImage,
                        padding: EdgeInsets.all(0.0),
                        splashColor: Colors.transparent,
                        highlightColor: Colors.grey,
                        iconSize: 200.0,

                      ),
                    ],
                  ),
                ),
                width: double.infinity,
                margin: EdgeInsets.all(20.0),
              ),

              //Input Fields
              Column(
                children: <Widget>[
                  Padding(padding: EdgeInsets.all(1.0),
                    child: isLoading ? circularProgress() : Container(),),
                  // User Name

                  Container(
                    child: Text(
                      "Group Name : ",
                      style: TextStyle(fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          color: Colors.lightBlueAccent),
                    ),
                    margin: EdgeInsets.only(left: 10.0, bottom: 5.0, top: 10.0),
                  ),
                  Container(
                    child: Theme(
                      data: Theme.of(context).copyWith(
                          primaryColor: Colors.lightBlueAccent),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "eg my Group",
                          contentPadding: EdgeInsets.all(5.0),
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        controller: groupnameTextEditingController,
                        onChanged: (value) {
                          groupname = value;
                        },
                        focusNode: groupNameFocusNode,
                      ),
                    ),
                    margin: EdgeInsets.only(left: 30.0, right: 30.0),
                  ),

                  //About Me...
                  Container(
                    child: Text(
                      ""
                          "Description : ",
                      style: TextStyle(fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          color: Colors.lightBlueAccent),
                    ),
                    margin: EdgeInsets.only(left: 10.0, bottom: 5.0, top: 30.0),
                  ),
                  Container(
                    child: Theme(
                      data: Theme.of(context).copyWith(
                          primaryColor: Colors.lightBlueAccent),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "eg hello this is a group",
                          contentPadding: EdgeInsets.all(5.0),
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        controller: descriptionTextEditingController,
                        onChanged: (value) {
                          description = value;
                        },
                        focusNode: descriptionNameFocusNode,
                      ),
                    ),
                    margin: EdgeInsets.only(left: 30.0, right: 30.0),
                  ),
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),

              // Buttons....
              Container(
                child: FlatButton(
                  onPressed: updateData,
                  child: Text(
                    "UPDATE",
                    style: TextStyle(fontSize: 16.0),
                  ),
                  color: Colors.lightBlueAccent,
                  highlightColor: Colors.grey,
                  splashColor: Colors.transparent,
                  textColor: Colors.white,
                  padding: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 10.0),
                ),
                margin: EdgeInsets.only(top: 50.0, bottom: 1.0),
              ),

            ],
          ),
          padding: EdgeInsets.only(left: 15.0, right: 15.0),
        ),
      ],
    );
  }
}