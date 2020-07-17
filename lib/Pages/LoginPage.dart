import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chatApp/Pages/HomePage.dart';
import 'package:chatApp/Widgets/ProgressWidget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginScreen extends StatefulWidget {

  LoginScreen({Key key}) : super(key : key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {

  final GoogleSignIn googleSignIn=GoogleSignIn();
  final FirebaseAuth firebaseAuth=FirebaseAuth.instance;
  SharedPreferences preferences;
  bool isloogedIn=false;
  bool isloading=false;
  FirebaseUser currentUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    isSignedIn();
  }

  void isSignedIn() async
  {
    this.setState(() {
      isloogedIn=true;

    });

    preferences=await SharedPreferences.getInstance();
    isloogedIn=await googleSignIn.isSignedIn();

    if(isloogedIn)
      {
        Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen(currentUserId: preferences.getString("id"))));
      }

    this.setState(() {
      isloading=false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
    body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Colors.lightBlueAccent,Colors.purpleAccent],
        ),
      ),
      alignment: Alignment.center,
      child: Column(

        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,

        children: <Widget>[
          Text(
              "My ChatApp",
            style: TextStyle(fontSize: 82.0, color:Colors.white, fontFamily: "Signatra" ),

          ),

          GestureDetector(

            onTap: controlSignIn,

            child: Center(
              child: Column(
                children: <Widget>[
                  Container(
                    width: 270.0,
                    height: 65.0,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                       image : AssetImage("assets/images/google_signin_button.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.all(1.0),
                    child: isloading ?circularProgress() : Container(),
                  ),

                ],
              ),
            ),
          ),


        ],
      ),
    ),

    );
  }

  Future<Null>controlSignIn() async
  {
    preferences=await SharedPreferences.getInstance();

    this.setState(() {
      isloading=true;
    });

    GoogleSignInAccount googlUser=await googleSignIn.signIn();
    GoogleSignInAuthentication googleAuthentication= await googlUser.authentication;

    final AuthCredential credential=GoogleAuthProvider.getCredential(idToken: googleAuthentication.idToken, accessToken: googleAuthentication.accessToken);

    FirebaseUser firebaseUser= (await firebaseAuth.signInWithCredential(credential)).user;

    //Success
    if(firebaseUser!= null)
      {
        final QuerySnapshot resultQuery=await Firestore.instance
            .collection("users").where("id",isEqualTo: firebaseUser.uid).getDocuments();

        final List<DocumentSnapshot> documentSnapshot=resultQuery.documents;

        if(documentSnapshot.length==0)
          {
            Firestore.instance.collection("users").document(firebaseUser.uid).setData(
              {
                "nickname": firebaseUser.displayName,
                "photoUrl":firebaseUser.photoUrl,
                "id":firebaseUser.uid,
                "aboutMe": "i m using the ChatApp",
                "createdDate": DateTime.now().millisecondsSinceEpoch.toString(),
                "chattingWith": null,
              });
            currentUser=firebaseUser;
            await preferences.setString("id", currentUser.uid);
            await preferences.setString("nickname", currentUser.displayName);
            await preferences.setString("photoUrl", currentUser.photoUrl);


          }
        else
          {
            await preferences.setString("id", documentSnapshot[0]["id"]);
            await preferences.setString("nickname", documentSnapshot[0]["nickname"]);
            await preferences.setString("photoUrl", documentSnapshot[0]["photoUrl"]);
            await preferences.setString("aboutMe", documentSnapshot[0]["aboutMe"]);
          }

        Fluttertoast.showToast(msg: "SignIn successful.....");
        this.setState(() {

          isloading=false;

        });

        Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen(currentUserId: firebaseUser.uid,)));
      }
    //failed
    else
      {
        Fluttertoast.showToast(msg: "Try Again.....");
        this.setState(() {

          isloading=false;

        });
      }

  }
}
