import 'package:chatApp/Pages/AccountSettingsPage.dart';
import 'package:chatApp/Pages/CreteGroup.dart';
import 'package:chatApp/Pages/FindFriend.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class HomepageDrawer extends StatelessWidget{


  @override
  Widget build(BuildContext context) {
    return image();

  }
}

class image extends StatefulWidget
{
  @override
  State createState() => DrawerState();
  }

class DrawerState extends State<image>{

  SharedPreferences preferences;
  String id="";
  String nickname="";
  String aboutMe="";
  String photoUrl="";

  @override
  void initState() {
    // TODO: implement initState
    readDataFromLocal();
  }

  void readDataFromLocal()async
  {
    preferences=await SharedPreferences.getInstance();
    id=preferences.getString("id");
    nickname=preferences.getString("name");
    aboutMe=preferences.getString("about");
    photoUrl=preferences.getString("photoUrl");

    setState(() {

    });

  }
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.0),
            color: Theme.of(context).primaryColor,

            child:Column(
              children: <Widget>[
                Container(
                  width: 100,
                  height: 100,
                  margin: EdgeInsets.all( 20.0),
                  alignment: Alignment.topLeft,
                  decoration: BoxDecoration(

                    shape: BoxShape.circle,
                    image: DecorationImage(image: NetworkImage(photoUrl),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Text(
                  nickname,
                  style: TextStyle(fontSize: 22.0, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  aboutMe,
                  style: TextStyle( color: Colors.white,),
                ),
              ],
            ),

          ),
          Expanded(

            child: Column(

              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.person_add, color: Colors.lightBlueAccent,),
                  title: Text("Find Friends",style: TextStyle(fontSize: 18.0,color: Colors.lightBlueAccent,),
                  ),
                  onTap: ()
                  {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => FindFriend(currentUserId: id,)));
                  },

                ),
                Divider(color: Theme.of(context).primaryColor ,),

                ListTile(
                  leading: Icon(Icons.create, color: Colors.lightBlueAccent,),
                  title: Text("Create Group",style: TextStyle(fontSize: 18.0,color: Colors.lightBlueAccent,),
                  ),
                  onTap: ()
                  {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CreateGroup()));
                  },
                ),

                Divider(color: Theme.of(context).primaryColor ,),
                ListTile(
                  leading: Icon(Icons.settings,color: Colors.lightBlueAccent,),
                  title: Text("Profile Settings",style: TextStyle(fontSize: 18.0, color: Colors.lightBlueAccent,),),
                  onTap:  ()
                  {
                    Navigator.push(context, MaterialPageRoute(builder: (context) =>Settings()));
                  },

                ),

                Divider(color: Theme.of(context).primaryColor ,),
                ListTile(
                  leading: Icon(Icons.exit_to_app,color: Colors.lightBlueAccent,),
                  title: Text("Logout",style: TextStyle(fontSize: 18.0,color: Colors.lightBlueAccent,),
                  ),
                  onTap: logoutUser,
                ),
                Divider(color: Theme.of(context).primaryColor ,),
              ],
            ),
          ),
        ],
      ),
    );
  }
  final GoogleSignIn googleSignIn=GoogleSignIn();
  Future<Null>logoutUser() async
  {
    await FirebaseAuth.instance.signOut();
    await googleSignIn .disconnect();
    await googleSignIn.signOut();
    this.setState(() {
      //isLoading=false;
    });

    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => MyApp()), (Route<dynamic> route) => false);
  }

}
