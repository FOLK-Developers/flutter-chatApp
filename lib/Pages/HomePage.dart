import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatApp/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:chatApp/Pages/ChattingPage.dart';
import 'package:chatApp/models/user.dart';
import 'package:chatApp/Pages/AccountSettingsPage.dart';
import 'package:chatApp/Widgets/ProgressWidget.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';


class HomeScreen extends StatefulWidget {

  final String currentUserId;

  HomeScreen({Key key , @required this.currentUserId}) : super (key : key);

  @override
  State createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {


  TextEditingController searchTextEditingController=TextEditingController();

  homePageHeader()
  {
    return AppBar(
      automaticallyImplyLeading: false,

      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.settings, size: 30.0, color:  Colors.white,),
          onPressed: ()
          {
            Navigator.push(context, MaterialPageRoute(builder: (context) =>Settings()));
          },
        ),
      ],

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
        ),
      ),
    );
  }

  emptyTextFormField()
  {
    searchTextEditingController.clear();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: homePageHeader(),

    );
  }
}



class UserResult extends StatelessWidget
{
  @override
  Widget build(BuildContext context) {

  }
}
