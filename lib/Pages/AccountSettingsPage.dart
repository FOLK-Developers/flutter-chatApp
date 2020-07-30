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



class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        backgroundColor: Colors.lightBlue,
        title: Text(
          "Account Settings",
              style: TextStyle( color: Colors.white,fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: SettingsScreen(),
    );
  }
}


class SettingsScreen extends StatefulWidget {
  @override
  State createState() => SettingsScreenState();
}



class SettingsScreenState extends State<SettingsScreen> {

  TextEditingController nicknameTextEditingController;
  TextEditingController aboutMeTextEditingController;


  bool isLoading=false;SharedPreferences preferences;
  String id="";
  String nickname="";
  String aboutMe="";
  String photoUrl="";
  File imageFileAvator;
  final FocusNode nickNameFocusNode=FocusNode();
  final FocusNode aboutMeNameFocusNode=FocusNode();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    readDataFromLocal();
  }

  void readDataFromLocal()async
  {
    preferences=await SharedPreferences.getInstance();
    id=preferences.getString("id");
    nickname=preferences.getString("nickname");
    aboutMe=preferences.getString("aboutMe");
    photoUrl=preferences.getString("photoUrl");

    nicknameTextEditingController=TextEditingController(text: nickname);
    aboutMeTextEditingController=TextEditingController(text: aboutMe);

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
    String mFileName=id;
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
            Firestore.instance.collection("users").document(id).updateData({
              "photoUrl" : photoUrl,
              "aboutMe" : aboutMe,
              "nickname" : nickname,
            }).then((data) async
            {
              await preferences.setString("photoUrl", photoUrl);
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


          Firestore.instance.collection("users").document(id).updateData({
            "photoUrl" : photoUrl,
            "aboutMe" : aboutMe,
            "nickname" : nickname,
          }).then((data) async
          {
            await preferences.setString("photoUrl", photoUrl);
            await preferences.setString("aboutMe", aboutMe);
            await preferences.setString("nickname", nickname);
            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(msg: "Updated Successfully");
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
    nickNameFocusNode.unfocus();
    aboutMeNameFocusNode.unfocus();
    setState(() {
      isLoading=false;
    });

    Firestore.instance.collection("users").document(id).updateData({
      "photoUrl" : photoUrl,
      "aboutMe" : aboutMe,
      "nickname" : nickname,
    }).then((data) async
    {
      await preferences.setString("photoUrl", photoUrl);
      await preferences.setString("aboutMe", aboutMe);
      await preferences.setString("nickname", nickname);
      setState(() {
        isLoading = false;
      });
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
                      (imageFileAvator==null)
                          ? (photoUrl != "")

                          ? Material(
                              //to display existing Image..
                              child: CachedNetworkImage(
                                placeholder: (context,url) =>Container(
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

                          : Icon(Icons.account_circle, size: 90.0, color: Colors.grey,)

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
                      "Profile Name : ",
                      style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold,color: Colors.lightBlueAccent),
                    ),
                    margin: EdgeInsets.only(left: 10.0,bottom: 5.0,top: 10.0),
                  ),
                  Container(
                    child: Theme(
                        data: Theme.of(context).copyWith(primaryColor: Colors.lightBlueAccent),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "eg Amit Verma",
                            contentPadding: EdgeInsets.all(5.0),
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          controller: nicknameTextEditingController,
                          onChanged: (value)
                          {
                            nickname=value;
                          },
                          focusNode: nickNameFocusNode,
                        ),
                    ),
                    margin: EdgeInsets.only(left: 30.0,right: 30.0),
                  ),

                  //About Me...
                  Container(
                    child: Text(
                      ""
                          "About Me : ",
                      style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold,color: Colors.lightBlueAccent),
                    ),
                    margin: EdgeInsets.only(left: 10.0,bottom: 5.0,top: 30.0),
                  ),
                  Container(
                    child: Theme(
                      data: Theme.of(context).copyWith(primaryColor: Colors.lightBlueAccent),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "eg hello i m Amit Verma",
                          contentPadding: EdgeInsets.all(5.0),
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        controller: aboutMeTextEditingController,
                        onChanged: (value)
                        {
                          aboutMe=value;
                        },
                        focusNode: aboutMeNameFocusNode,
                      ),
                    ),
                    margin: EdgeInsets.only(left: 30.0,right: 30.0),
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
                margin: EdgeInsets.only(top: 50.0,bottom: 1.0),
              ),

              //logout button
              Padding(padding: EdgeInsets.only(left: 50.0,right: 50.0),
              child: RaisedButton(
                color: Colors.red,
                onPressed: logoutUser,
                child: Text(
                  "LOGOUT",
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

  final GoogleSignIn googleSignIn=GoogleSignIn();
  Future<Null>logoutUser() async
  {
    await FirebaseAuth.instance.signOut();
    await googleSignIn .disconnect();
    await googleSignIn.signOut();
    this.setState(() {
      isLoading=false;
    });

    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => MyApp()), (Route<dynamic> route) => false);
  }
}
