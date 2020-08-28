import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chatApp/Widgets/ProgressWidget.dart';
import 'package:chatApp/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';


class CreateGroup extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
            color: Colors.white
        ),
        backgroundColor: Colors.lightBlue,
        title: Text(
          "Create Group",
          style: TextStyle( color: Colors.white,fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: CreateGroupScreen(),
    );
  }
}


class CreateGroupScreen extends StatefulWidget {

  @override
  State createState() => CreateGroupScreenState();
}

class CreateGroupScreenState extends State<CreateGroupScreen>
{
  CreateGroupScreenState({@required this.groupId});

  TextEditingController groupnameTextEditingController;
  TextEditingController aboutGroupTextEditingController;


  bool isLoading=false;
  SharedPreferences preferences;
  String currentUserId;
  String currentUsename;
  String currerntUserPhotoUrl;
  String currentUserAbout;


  String groupId="";
  String groupName="";
  String aboutGroup="";
  String photoUrl="";
  File imageFileAvator;
  final FocusNode groupNameFocusNode=FocusNode();
  final FocusNode aboutgroupNameFocusNode=FocusNode();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getValue();
  }

  getValue()async
  {
    preferences=await SharedPreferences.getInstance();
    currentUserId=preferences.getString("id");
    currentUserAbout=preferences.getString("about");
    currentUsename=preferences.getString("name");
    currerntUserPhotoUrl=preferences.getString("photoUrl");


  }

  Future getImage() async
  {
    File newImagefile=await ImagePicker.pickImage(source: ImageSource.gallery);

    if(newImagefile != null)
    {
      setState(() {
        this.imageFileAvator= newImagefile;

      });
    }
  }

  Future uploadImageToFireStoreAndStorage() async
  {

    groupId=await Firestore.instance.collection("groups").hashCode.toString();
    String mFileName=groupId;
    StorageReference storageReference=FirebaseStorage.instance.ref().child("Group Profile Image").child(mFileName);
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
          Firestore.instance.collection("groups").document(groupId).setData({
            "id" : groupId,
            "adminId" :currentUserId,
            "photoUrl" : photoUrl,
            "description" : aboutGroup,
            "name" : groupName,
            "participants":FieldValue.arrayUnion([currentUserId])
          }).then((data) async
          {
            setState(() {
              isLoading=false;
            });
            Fluttertoast.showToast(msg: "Group created Successfully");
              await Firestore.instance.collection("chats").document(currentUserId).collection(currentUserId).document(groupId).setData({
                "id" : groupId,
                "photoUrl" : photoUrl,
                "name" : groupName,
                "type" : 2,
                "lastMsg":"new group",
                "lastMsgTym":DateTime.now().millisecondsSinceEpoch.toString()
                // send to group profile
              }).then((value) => null );
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

                      (imageFileAvator==null)
                      ? Material(
                        //New Updated Image
                        child:
                          Icon(Icons.people,
                          size: 125,
                            color: Colors.grey,
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
                        icon: Icon(Icons.camera_alt, size: 100.0,color: Colors.white.withOpacity(0.3)),
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
                  Padding(padding: EdgeInsets.all(1.0),child: isLoading ? circularProgress() : Container(),),
                  // User Name

                  Container(
                    child: Text(
                      "Group Name : ",
                      style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold,color: Colors.lightBlueAccent),
                    ),
                    margin: EdgeInsets.only(left: 10.0,bottom: 5.0,top: 10.0),
                  ),
                  Container(
                    child: Theme(
                      data: Theme.of(context).copyWith(primaryColor: Colors.lightBlueAccent),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "eg My Group",
                          contentPadding: EdgeInsets.all(5.0),
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        controller: groupnameTextEditingController,
                        onChanged: (value)
                        {
                          groupName=value;
                        },
                        focusNode: groupNameFocusNode,
                      ),
                    ),
                    margin: EdgeInsets.only(left: 30.0,right: 30.0),
                  ),

                  //About Me...
                  Container(
                    child: Text(
                      ""
                          "Description : ",
                      style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold,color: Colors.lightBlueAccent),
                    ),
                    margin: EdgeInsets.only(left: 10.0,bottom: 5.0,top: 30.0),
                  ),
                  Container(
                    child: Theme(
                      data: Theme.of(context).copyWith(primaryColor: Colors.lightBlueAccent),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "eg hello its our group",
                          contentPadding: EdgeInsets.all(5.0),
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        controller: aboutGroupTextEditingController,
                        onChanged: (value)
                        {
                          aboutGroup=value;
                        },
                        focusNode: aboutgroupNameFocusNode,
                      ),
                    ),
                    margin: EdgeInsets.only(left: 30.0,right: 30.0),
                  ),
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),

              // Buttons....
              Container(
                margin: EdgeInsets.only(top: 50.0,bottom: 1.0),
              ),

              //logout button
              Padding(padding: EdgeInsets.only(left: 50.0,right: 50.0),
                child: RaisedButton(
                  color: Colors.lightBlueAccent,
                  onPressed: uploadImageToFireStoreAndStorage,
                  child: Text(
                    "SAVE",
                    style: TextStyle(color: Colors.white,fontSize: 14.0),
                  ),
                ),
              ),

            ],
          ),
          padding: EdgeInsets.only(left: 15.0,right: 15.0),
        ),
      ],
    );
  }
}
