import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatApp/Models/group.dart';
import 'package:chatApp/Pages/GroupProfile.dart';
import 'package:chatApp/Widgets/AudioPlayer.dart';
import 'package:chatApp/Widgets/DocumentViewer.dart';
import 'package:chatApp/Widgets/FullImageWidget.dart';
import 'package:chatApp/Widgets/ProgressWidget.dart';
import 'package:chatApp/Widgets/VidioPlayer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GroupChat extends StatelessWidget
{
  final  String groupId;

  GroupChat({
    Key key,
    @required this.groupId,
});



  @override
  Widget build(BuildContext context) {
  return GroupChatScreen(groupId : groupId);
  }
}
class GroupChatScreen extends StatefulWidget
{
  final String groupId;
  GroupChatScreen({Key key,@required this.groupId,}) : super(key : key);

  @override
  State createState() => GroupChatScreenState(groupId : groupId);
}

class GroupChatScreenState extends State<GroupChatScreen>
{
  final String groupId;

  GroupChatScreenState({Key key, @required this.groupId});

  final TextEditingController textEditingController=TextEditingController();
  final TextEditingController ReplytextEditingController=TextEditingController();
  final ScrollController listScrollController=ScrollController();

  final FocusNode focusNode=FocusNode();
  bool isDisplaySticker;
  bool isDisplayShare;
  bool isDisplayReply;
  bool isLoading;

  File imageFile;
  File vedioFile;
  File audioFile;
  File docFile;
  String imageUrl;

  String ReplyTo;
  String ReplyToUser;
  var ReplyIndex;

  String chatId;
  SharedPreferences preferences;
  String id;
  String photoUrl;
  String nickname;
  var listMessage;
  List<String> participantsList= [];
  List<String> participantsNames= [];
  List<String> participantsAbout= [];
  List<String> participantsPhotoUrl=[];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    focusNode.addListener(onFocusChange);
    isDisplaySticker = false;
    isDisplayShare=false;
    isDisplayReply=false;
    isLoading = false;

    chatId="";

    readLocal();
    readPartcipantslist();

  }

  readLocal()async
  {
    preferences= await SharedPreferences.getInstance();
    id=preferences.getString("id") ?? "";
    nickname=preferences.getString("name");
    photoUrl=preferences.getString("photoUrl");




      chatId=groupId;

    setState(() {

    });
  }

  onFocusChange()
  {
    if(focusNode.hasFocus)
    {
      //hide sticker when keyboard
      setState(() {
        isDisplaySticker=false;
        isDisplayShare=false;
        isDisplayReply=false;
      });
    }
  }




  Widget grpChatbody()
  {
    return WillPopScope(
      child: Stack(
        children: <Widget>[

          Column(
            children: <Widget>[
              createMessageList(),
              // show sticker
              (isDisplaySticker ? createSickers() :isDisplayShare ? createShare() : Container()),
              (isDisplayReply ? createReply():createInput()),
            ],
          ),
          createLoading(),
        ],
      ),

      onWillPop: onBackPress,
    );
  }

  createReply()
  {
    return Container(
      child: Column(

        children: <Widget>[
          Container(
              width: double.infinity,
              child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 15, 20, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(ReplyToUser,
                        style: TextStyle(fontStyle: FontStyle.italic,color: Colors.purpleAccent,fontWeight: FontWeight.bold),
                      ),
                      Text(ReplyTo,
                        style: TextStyle(fontStyle: FontStyle.italic,color: Colors.white,fontWeight: FontWeight.bold),
                      ),
                    ],
                  )
              ),
              decoration:BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.only(topRight: Radius.circular(40),topLeft: Radius.circular(40)))
          ),
          Container(
            child: Row(
              children: <Widget>[
                Material(
                  //Pick Image
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 1.0),
                    child: IconButton(
                      icon: Icon(Icons.image),
                      color: Colors.lightBlueAccent,
                      onPressed:getImage,
                    ),
                  ),
                  color: Colors.white,
                ),
                Material(
                  //Emogi
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 1.0),
                    child: IconButton(
                      icon: Icon(Icons.face),
                      color: Colors.lightBlueAccent,
                      onPressed: getSticker,
                    ),
                  ),
                  color: Colors.white,
                ),

                //TextField
                Flexible(
                  child: Container(
                    child: TextField(
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 15.0
                      ),
                      controller: ReplytextEditingController,
                      decoration: InputDecoration.collapsed(
                          hintText: "Write here",
                          hintStyle: TextStyle(color: Colors.grey)
                      ),
                      // focusNode: focusNode,
                    ),
                  ),
                ),

                Material(
                  //Emogi
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 1.0),
                    child: IconButton(
                      icon: Icon(Icons.share),
                      color: Colors.lightBlueAccent,
                      onPressed: getShare,
                    ),
                  ),
                  color: Colors.white,
                ),



                // Send Btn
                Material(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 8.0),
                    child: IconButton(
                      icon:Icon(Icons.send),
                      color: Colors.lightBlueAccent,
                      onPressed:()=> onReplyMessage(ReplytextEditingController.text,6),
                    ),
                  ),
                  color: Colors.white,
                )
              ],
            ),
            width: double.infinity,
            //height: 50.0,
            decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(
                      color: Colors.grey,width: 0.5
                  )
              ),
              color: Colors.white,
            ),
          ),
        ],
      ),



    );
  }

  Future<bool> onBackPress()
  {
    if(isDisplaySticker || isDisplayShare|| isDisplayReply)
    {
      setState(() {
        isDisplayShare=false;
        isDisplaySticker=false;
        isDisplayReply=false;
      });
    }
    else
    {
      Navigator.pop(context);
    }
    return Future.value(false);
  }

  createShare()
  {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            child: Row(
              children: <Widget>[

                Column(
                  children: <Widget>[
                    FlatButton(
                      child: Image.asset("assets/images/headphones.png",width: 50.0,height: 50.0,),
                      onPressed: getAudio,

                    ),
                    Text(
                      "Audio",
                      style: TextStyle(color: Colors.black45),
                    )
                  ],
                ),

                Column(
                  children: <Widget>[
                    FlatButton(
                      child: Image.asset("assets/images/video-player.png",width: 50.0,height: 50.0,),
                      onPressed: getVedio,

                    ),
                    Text(
                      "Videos",
                      style: TextStyle(color: Colors.black45),
                    )
                  ],
                ),

                Column(
                  children: <Widget>[
                    FlatButton(
                      child: Image.asset("assets/images/doc.png",width: 50.0,height: 50.0,),
                      onPressed: getDocument,

                    ),
                    Text(
                      "Documents",
                      style: TextStyle(color: Colors.black45),
                    )
                  ],
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,

            ),
            margin: EdgeInsets.only(top:20.0,bottom: 20),

          )
        ],
      ),
      margin: EdgeInsets.only(left: 10.0,right: 10,bottom: 5),

      decoration:BoxDecoration(color: Colors.grey[300],borderRadius: BorderRadius.circular(8.0)) ,

    );
  }

  createSickers()
  {
    return Container(
      child: Column(
        children: <Widget>[

          Row(
            children: <Widget>[

              FlatButton(
                onPressed:()=> onSendMessage("mimi1",2),
                child: Image.asset(
                  "images/mimi1.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed:()=> onSendMessage("mimi2",2),
                child: Image.asset(
                  "images/mimi2.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed:()=> onSendMessage("mimi3",2),
                child: Image.asset(
                  "images/mimi3.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),

          Row(
            children: <Widget>[

              FlatButton(
                onPressed: ()=> onSendMessage("mimi4",2),
                child: Image.asset(
                  "images/mimi4.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed:()=> onSendMessage("mimi5",2),
                child: Image.asset(
                  "images/mimi5.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed:()=> onSendMessage("mimi6",2),
                child: Image.asset(
                  "images/mimi6.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),

          Row(
            children: <Widget>[

              FlatButton(
                onPressed:()=> onSendMessage("mimi7",2),
                child: Image.asset(
                  "images/mimi7.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed:()=> onSendMessage("mimi8",2),
                child: Image.asset(
                  "images/mimi8.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed:()=> onSendMessage("mimi9",2),
                child: Image.asset(
                  "images/mimi9.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),

        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      ),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey,width: 0.5)),color: Colors.white),
      padding: EdgeInsets.all(5.0),
      height: 180.0,
    );
  }

  createLoading()
  {
    return Positioned(
      child: isLoading ? circularProgress() : Container(),
    );
  }

  createInput()
  {
    return Container(
      child: Row(
        children: <Widget>[
          Material(
            //Pick Image
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(Icons.image),
                color: Colors.lightBlueAccent,
                onPressed:getImage,
              ),
            ),
            color: Colors.white,
          ),
          Material(
            //Emogi
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(Icons.face),
                color: Colors.lightBlueAccent,
                onPressed: getSticker,
              ),
            ),
            color: Colors.white,
          ),

          //TextField
          Flexible(
            child: Container(
              child: TextField(
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 15.0
                ),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                    hintText: "Write here",
                    hintStyle: TextStyle(color: Colors.grey)
                ),
                focusNode: focusNode,
              ),
            ),
          ),

          Material(
            //Emogi
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(Icons.share),
                color: Colors.lightBlueAccent,
                onPressed: getShare,
              ),
            ),
            color: Colors.white,
          ),

          // Send Btn
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon:Icon(Icons.send),
                color: Colors.lightBlueAccent,
                onPressed:()=> onSendMessage(textEditingController.text,0),
              ),
            ),
            color: Colors.white,
          )
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: BoxDecoration(
        border: Border(
            top: BorderSide(
                color: Colors.grey,width: 0.5
            )
        ),
        color: Colors.white,
      ),
    );
  }
  void getSticker()
  {
    focusNode.unfocus();
    setState(() {
      isDisplaySticker = !isDisplaySticker;
    });
  }
  void getShare()
  {
    focusNode.unfocus();
    setState(() {
      isDisplayShare = !isDisplayShare;
    });
  }

  Future getImage()async
  {
    imageFile= await ImagePicker.pickImage(source: ImageSource.gallery);
    if(imageFile != null)
    {
      isLoading=true;
    }
    uploadImageFile();

  }
  uploadImageFile()async
  {
    String fileName=DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference storageReference= FirebaseStorage.instance.ref().child("Group Chats Images").child(fileName);

    StorageUploadTask storageUploadTask =storageReference.putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot=await storageUploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl){
      imageUrl=downloadUrl;
      setState(() {
        isLoading=false;
        onSendMessage(imageUrl,1);
      });
    },onError: (error){
      setState(() {
        isLoading=false;
      });
      Fluttertoast.showToast(msg: error);
    });
  }


  Future getVedio()async
  {
    vedioFile= await ImagePicker.pickVideo(source: ImageSource.gallery);
    if( vedioFile!= null)
    {
      isLoading=true;
    }
    uploadVedioFile();

  }

  Future getDocument()async
  {
    docFile=await FilePicker.getFile(
        type: FileType.custom,
        allowedExtensions: ['pdf','doc']
    );
    if( docFile!= null)
    {
      isLoading=true;
    }

    uploadDocFile();

  }

  uploadDocFile()async
  {
    String fileName=DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference storageReference= FirebaseStorage.instance.ref().child("Group Chats Documents").child(fileName);
    StorageUploadTask storageUploadTask = storageReference.putFile(docFile);
    StorageTaskSnapshot storageTaskSnapshot=await storageUploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl){
      imageUrl=downloadUrl;
      setState(() {
        isLoading=false;
        onSendMessage(imageUrl,5);
      });
    },onError: (error){
      setState(() {
        isLoading=false;
      });
      Fluttertoast.showToast(msg: error);
    });
  }


  Future getAudio()async
  {
    audioFile=await FilePicker.getFile(
      type: FileType.audio,

      //allowedExtensions: ['mp3','m4a']
    );
    if( audioFile!= null)
    {
      isLoading=true;
    }

    uploadAudioFile();

  }

  uploadAudioFile()async
  {
    String fileName=DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference storageReference= FirebaseStorage.instance.ref().child("Group Chats Audios").child(fileName);
    StorageUploadTask storageUploadTask = storageReference.putFile(audioFile);
    StorageTaskSnapshot storageTaskSnapshot=await storageUploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl){
      imageUrl=downloadUrl;
      setState(() {
        isLoading=false;
        onSendMessage(imageUrl,4);
      });
    },onError: (error){
      setState(() {
        isLoading=false;
      });
      Fluttertoast.showToast(msg: error);
    });
  }


  uploadVedioFile()async
  {
    String fileName=DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference storageReference= FirebaseStorage.instance.ref().child("Group Chats Videos").child(fileName);
    StorageUploadTask storageUploadTask = storageReference.putFile(vedioFile);
    StorageTaskSnapshot storageTaskSnapshot=await storageUploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl){
      imageUrl=downloadUrl;
      setState(() {
        isLoading=false;
        onSendMessage(imageUrl,3);
      });
    },onError: (error){
      setState(() {
        isLoading=false;
      });
      Fluttertoast.showToast(msg: error);
    });
  }






  createMessageList()
  {
    return Flexible(
      child: chatId ==""
          ?  Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                  ),
                )
          : StreamBuilder(
        stream: Firestore.instance
            .collection("messages")
            .document("group")
            .collection(chatId)
            .orderBy("timestamp",descending: true).limit(20).snapshots(),
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
          else{
            listMessage=snapshot.data.documents;
            return ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemBuilder: (context,index) => createItem(index,snapshot.data.documents[index]),
              itemCount: snapshot.data.documents.length,
              reverse: true,
              controller: listScrollController,
            );
          }
        },

      ),

    );
  }

  bool isLastMsgLeft(int index)
  {
    if((index>0 && listMessage !=null && listMessage[index-1]["idFrom"] != id) || index ==0)
    {
      return true;
    }
    else
    {
      return false;
    }
  }

  bool isLastMsgRight(int index)
  {
    if((index>0 && listMessage !=null && listMessage[index-1]["idFrom"] == id) || index ==0)
    {
      return true;
    }
    else
    {
      return false;
    }
  }

  Widget createItem(int index, DocumentSnapshot document)
  {
    if(document["idFrom"]==id)
    {
      return GestureDetector(

        onHorizontalDragUpdate: (details)
        {
          if(details.delta.dx>0)
          {
            setState(() {
              isDisplayReply=true;
              if(document["type"]==0)
              {
                ReplyTo=document['content'];
              }
              if(document["type"]==1)
              {
                ReplyTo="image";
              }
              if(document["type"]==2)
              {
                ReplyTo="sticker";
              }
              if(document["type"]==3)
              {
                ReplyTo="video";
              }
              if(document["type"]==4)
              {
                ReplyTo="audio";
              }
              if(document["type"]==5)
              {
                ReplyTo="document";
              }
              if(document["type"]==6)
              {
                ReplyTo=document['content'];
              }
              ReplyToUser="You";
              ReplyIndex=index;
            });
          }
        },







        child: Row(
          children: <Widget>[
            document["type"]==0
            //Text Mesg
                ? Container(
              child: Text(
                    document["content"],
                    style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500),
                  ),
              padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
              width: 200.0,
              decoration: BoxDecoration(color: Colors.lightBlueAccent,borderRadius: BorderRadius.circular(8.0)),
              margin: EdgeInsets.only(bottom: isLastMsgRight(index) ? 20.0 : 10.0, right: 10.0),
            )

            //Image files
                : document["type"]==1
                ? Container(
              child: FlatButton(
                child: Material(
                  child: CachedNetworkImage(
                    placeholder: (context,url) => Container(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                      ),
                      width: 200.0,
                      height: 200.0,
                      padding: EdgeInsets.all(70.0),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      ),
                    ),
                    errorWidget: (context, url,error) => Material(
                      child: Image.asset("images/img_not_available.jpeg",width: 200.0,height: 200.0,fit: BoxFit.cover,),
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      clipBehavior: Clip.hardEdge,
                    ),
                    imageUrl: document["content"],
                    width: 200.0,
                    height: 200.0,
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  clipBehavior: Clip.hardEdge,
                ),
                onPressed: ()
                {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) =>FullPhoto(url : document["content"])
                  ));
                },
              ),
              margin: EdgeInsets.only(bottom: isLastMsgRight(index) ? 20.0 : 10.0, right: 10.0),
            )
            //Gif
                : (document["type"]==2)
            ?Container(
              child: Image.asset(
                "images/${document['content']}.gif",
                width: 100.0,
                height: 100.0,
                fit: BoxFit.cover,
              ),
              margin: EdgeInsets.only(bottom: isLastMsgRight(index) ? 20.0 : 10.0, right: 10.0),
            )
            :(document['type']==3)
            ?Container(
              child: FlatButton(
                child: Material(
                  child: CachedNetworkImage(
                    placeholder: (context,url) => Container(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                      ),
                      width: 200.0,
                      height: 150.0,
                      padding: EdgeInsets.all(70.0),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      ),
                    ),
                    errorWidget: (context, url,error) => Material(
                      child: Image.asset("images/img_not_available.jpeg",width: 200.0,height: 200.0,fit: BoxFit.cover,),
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      clipBehavior: Clip.hardEdge,
                    ),
                    imageUrl: "https://firebasestorage.googleapis.com/v0/b/chatsapp-6f431.appspot.com/o/Files%2Fvd.png?alt=media&token=a946abf3-e1bf-43b8-86aa-ec8bad3886e5",
                    width: 200.0,
                    height: 150.0,
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  clipBehavior: Clip.hardEdge,
                ),
                onPressed: ()
                {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) =>Player(url : document["content"])
                  ));
                },
              ),
              margin: EdgeInsets.only(bottom: isLastMsgRight(index) ? 20.0 : 10.0, right: 10.0),
            )
            :(document["type"]==4)
            ?Container(
              child: FlatButton(
                child: Material(
                  child: CachedNetworkImage(
                    placeholder: (context,url) => Container(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                      ),
                      width: 150.0,
                      height: 160.0,
                      padding: EdgeInsets.all(70.0),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      ),
                    ),
                    errorWidget: (context, url,error) => Material(
                      child: Image.asset("images/img_not_available.jpeg",width: 200.0,height: 200.0,fit: BoxFit.cover,),
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      clipBehavior: Clip.hardEdge,
                    ),
                    imageUrl: "https://firebasestorage.googleapis.com/v0/b/chatsapp-6f431.appspot.com/o/Files%2Fmp3%20file.jpeg?alt=media&token=5d8b6127-48c2-4b90-b5d9-228d8add26ff",
                    width: 150.0,
                    height: 160.0,
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  clipBehavior: Clip.hardEdge,
                ),
                onPressed: ()
                {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) =>PlayerAudio(url : document["content"])
                  ));
                },
              ),
              margin: EdgeInsets.only(bottom: isLastMsgRight(index) ? 20.0 : 10.0, right: 10.0),
            )
            :(document['type']==5)
            ? Container(
              child: FlatButton(
                child: Material(
                  child: CachedNetworkImage(
                    placeholder: (context,url) => Container(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                      ),
                      width: 130.0,
                      height: 160.0,
                      padding: EdgeInsets.all(70.0),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      ),
                    ),
                    errorWidget: (context, url,error) => Material(
                      child: Image.asset("images/img_not_available.jpeg",width: 200.0,height: 200.0,fit: BoxFit.cover,),
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      clipBehavior: Clip.hardEdge,
                    ),
                    imageUrl: "https://firebasestorage.googleapis.com/v0/b/chatsapp-6f431.appspot.com/o/Files%2Fdocfile.png?alt=media&token=9f9b60b7-5d28-4eb3-92bc-119f9e35730a",
                    width: 200.0,
                    height: 200.0,
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  clipBehavior: Clip.hardEdge,
                ),
                onPressed: ()
                {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) =>DocumentView(url:document["content"])
                  ));
                },
              ),
              margin: EdgeInsets.only(bottom: isLastMsgRight(index) ? 20.0 : 10.0, right: 10.0),
            )
            :Container(
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[

                Container(
                child: Text(document["replytoMsg"],
                style: TextStyle(fontStyle: FontStyle.italic,color: Colors.black54),
                ),
                width: 180,
                padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.5),borderRadius: BorderRadius.only(topLeft: Radius.circular(8),topRight: Radius.circular(8))),
                ),
                Container(
                child: Text(
                document["content"],
                style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500),
                  ),

                  )

                  ],
                  ),
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  width: 200.0,
                  decoration: BoxDecoration(color: Colors.lightBlueAccent,borderRadius: BorderRadius.circular(8)),
                  margin: EdgeInsets.only(bottom: isLastMsgRight(index) ? 20.0 : 10.0, right: 10.0),
                  ),
          ],
          mainAxisAlignment: MainAxisAlignment.end,
        ),
      );
    }

    //Reciever Side
    else
    {
      return GestureDetector(

        onHorizontalDragUpdate: (details)
        {
          if(details.delta.dx>0)
          {
            setState(() {
              isDisplayReply=true;
              if(document["type"]==0)
              {
                ReplyTo=document['content'];
              }
              if(document["type"]==1)
              {
                ReplyTo="image";
              }
              if(document["type"]==2)
              {
                ReplyTo="sticker";
              }
              if(document["type"]==3)
              {
                ReplyTo="video";
              }
              if(document["type"]==4)
              {
                ReplyTo="audio";
              }
              if(document["type"]==5)
              {
                ReplyTo="document";
              }
              if(document["type"]==6)
              {
                ReplyTo=document['content'];
              }
              ReplyToUser=document["senderName"];
              ReplyIndex=index;
            });
          }
        },


        child: Container(
          child: Column(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[

                  Material(
                    // display profile image
                    child: CachedNetworkImage(
                      placeholder: (context,url) => Container(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                        ),
                        width: 35.0,
                        height: 35.0,
                        padding: EdgeInsets.all(10.0),
                      ),
                      imageUrl:document["senderImage"] ,
                      width: 35.0,
                      height: 35.0,
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(18.0),
                    ),
                    clipBehavior: Clip.hardEdge,
                  ),

                  // display Mgs
                  document["type"]==0
                  //Text Mesg
                      ? Container(
                    child: RichText(
                      text: TextSpan(
                          children: [
                            TextSpan(text:
                            document["senderName"],
                              style: TextStyle(color: Colors.purpleAccent.withOpacity(0.5),fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: "\n"),
                            TextSpan(
                              text: document["content"],
                              style: TextStyle(color: Colors.black,fontWeight: FontWeight.w400),
                            )
                          ]
                      ),

                    ),
                    padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                    width: 200.0,
                    decoration: BoxDecoration(color: Colors.grey[200],borderRadius: BorderRadius.circular(8.0)),
                    margin: EdgeInsets.only(left: 10.0),
                  )
                  //Image files
                      : document["type"]==1
                      ? Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: Text(
                            document["senderName"],
                            style: TextStyle(color: Colors.purpleAccent.withOpacity(0.5),fontWeight: FontWeight.bold),
                          ),
                          padding: EdgeInsets.only(left: 10),
                        ),
                        FlatButton(
                          child: Material(
                            child: CachedNetworkImage(
                              placeholder: (context,url) => Container(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                                ),
                                width: 200.0,
                                height: 200.0,
                               // padding: EdgeInsets.all(70.0),
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                ),
                              ),
                              errorWidget: (context, url,error) => Material(
                                child: Image.asset("images/img_not_available.jpeg",width: 200.0,height: 200.0,fit: BoxFit.cover,),
                                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                clipBehavior: Clip.hardEdge,
                              ),
                              imageUrl: document["content"],
                              width: 200.0,
                              height: 200.0,
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                            clipBehavior: Clip.hardEdge,
                          ),
                          onPressed: ()
                          {
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context) =>FullPhoto(url : document["content"])
                            ));
                          },
                        ),
                      ],
                    ),
                    margin: EdgeInsets.only(left: 10.0),

                    decoration:BoxDecoration(color: Colors.grey[200],borderRadius: BorderRadius.circular(8.0)) ,
                  )
                  //Gif
                      :(document["type"]==2)
                      ? Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: Text(
                            document["senderName"],
                            style: TextStyle(color: Colors.purpleAccent.withOpacity(0.5),fontWeight: FontWeight.bold),
                          ),
                          padding: EdgeInsets.only(left: 10),
                        ),
                        Image.asset(
                          "images/${document['content']}.gif",
                          width: 100.0,
                          height: 100.0,
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),
                    margin: EdgeInsets.only(left: 10.0),
                    decoration:BoxDecoration(color: Colors.grey[200],borderRadius: BorderRadius.circular(8.0)) ,

                  )
                      :(document["type"]==3)
                  ?Container(
                    //Vedio
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: Text(
                            document["senderName"],
                            style: TextStyle(color: Colors.purpleAccent.withOpacity(0.5),fontWeight: FontWeight.bold),
                          ),
                          padding: EdgeInsets.only(left: 10),
                        ),
                        FlatButton(
                          child: Material(
                            child: CachedNetworkImage(
                              placeholder: (context,url) => Container(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                                ),
                                width: 200.0,
                                height: 150.0,
                                // padding: EdgeInsets.all(70.0),
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                ),
                              ),
                              errorWidget: (context, url,error) => Material(
                                child: Image.asset("images/img_not_available.jpeg",width: 200.0,height: 200.0,fit: BoxFit.cover,),
                                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                clipBehavior: Clip.hardEdge,
                              ),
                              imageUrl: "https://firebasestorage.googleapis.com/v0/b/chatsapp-6f431.appspot.com/o/Files%2Fvd.png?alt=media&token=a946abf3-e1bf-43b8-86aa-ec8bad3886e5",
                              width: 200.0,
                              height: 150.0,
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                            clipBehavior: Clip.hardEdge,
                          ),
                          onPressed: ()
                          {
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context) =>Player(url : document["content"])
                            ));
                          },
                        ),
                      ],
                    ),
                    margin: EdgeInsets.only(left: 10.0),

                    decoration:BoxDecoration(color: Colors.grey[200],borderRadius: BorderRadius.circular(8.0)) ,
                  )
                      :(document["type"]==4)
                  ?Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: Text(
                            document["senderName"],
                            style: TextStyle(color: Colors.purpleAccent.withOpacity(0.5),fontWeight: FontWeight.bold),
                          ),
                          padding: EdgeInsets.only(left: 10),
                        ),
                        FlatButton(
                          child: Material(
                            child: CachedNetworkImage(
                              placeholder: (context,url) => Container(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                                ),
                                width: 150.0,
                                height: 160.0,
                                // padding: EdgeInsets.all(70.0),
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                ),
                              ),
                              errorWidget: (context, url,error) => Material(
                                child: Image.asset("images/img_not_available.jpeg",width: 200.0,height: 200.0,fit: BoxFit.cover,),
                                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                clipBehavior: Clip.hardEdge,
                              ),
                              imageUrl: "https://firebasestorage.googleapis.com/v0/b/chatsapp-6f431.appspot.com/o/Files%2Fmp3%20file.jpeg?alt=media&token=5d8b6127-48c2-4b90-b5d9-228d8add26ff",
                              width: 150.0,
                              height: 160.0,
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                            clipBehavior: Clip.hardEdge,
                          ),
                          onPressed: ()
                          {
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context) =>PlayerAudio(url : document["content"])
                            ));
                          },
                        ),
                      ],
                    ),
                    margin: EdgeInsets.only(left: 10.0),

                    decoration:BoxDecoration(color: Colors.grey[200],borderRadius: BorderRadius.circular(8.0)) ,
                  )
                  :(document['type']==5)
                  ?Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: Text(
                            document["senderName"],
                            style: TextStyle(color: Colors.purpleAccent.withOpacity(0.5),fontWeight: FontWeight.bold),
                          ),
                          padding: EdgeInsets.only(left: 10),
                        ),
                        FlatButton(
                          child: Material(
                            child: CachedNetworkImage(
                              placeholder: (context,url) => Container(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                                ),
                                width: 130.0,
                                height: 160.0,
                                // padding: EdgeInsets.all(70.0),
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                ),
                              ),
                              errorWidget: (context, url,error) => Material(
                                child: Image.asset("images/img_not_available.jpeg",width: 200.0,height: 200.0,fit: BoxFit.cover,),
                                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                clipBehavior: Clip.hardEdge,
                              ),
                              imageUrl: "https://firebasestorage.googleapis.com/v0/b/chatsapp-6f431.appspot.com/o/Files%2Fdocfile.png?alt=media&token=9f9b60b7-5d28-4eb3-92bc-119f9e35730a",
                              width: 130.0,
                              height: 160.0,
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                            clipBehavior: Clip.hardEdge,
                          ),
                          onPressed: ()
                          {
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context) =>DocumentView(url:document["content"])
                            ));
                          },
                        ),
                      ],
                    ),
                    margin: EdgeInsets.only(left: 10.0),

                    decoration:BoxDecoration(color: Colors.grey[200],borderRadius: BorderRadius.circular(8.0)) ,
                  )

                 :Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[

                        Text(
                          document["senderName"],
                          style: TextStyle(color: Colors.purpleAccent.withOpacity(0.5),fontWeight: FontWeight.bold),
                        ),

                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                document["replyToUser"],
                                style: TextStyle(color: Colors.purpleAccent.withOpacity(0.3), ),
                              ),
                              Text(document["replytoMsg"],
                                style: TextStyle(fontStyle: FontStyle.italic,fontSize:11,color: Colors.black54),
                              ),
                            ],
                          ),
                          width: 180,
                          padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.5),borderRadius: BorderRadius.only(topLeft: Radius.circular(8),topRight: Radius.circular(8))),
                        ),
                        Container(
                          child: Text(
                            document["content"],
                            style: TextStyle(color: Colors.black,fontWeight: FontWeight.w400),
                          ),

                        )

                      ],
                    ),
                    padding: EdgeInsets.all(8.0),
                    width: 200.0,
                    decoration: BoxDecoration(color: Colors.grey[200],borderRadius: BorderRadius.circular(8)),
                    margin: EdgeInsets.only(left: 10.0),
                  ),

                ],

              ),

              //Msg time

              Container(
                child: Text(
                  DateFormat(" dd MMMM, yyyy - hh:mm:aa")
                      .format(DateTime.fromMillisecondsSinceEpoch(int.parse(document["timestamp"]))),
                  style: TextStyle(color: Colors.grey, fontSize: 12.0,fontStyle: FontStyle.italic),
                ),
                margin: EdgeInsets.only(left: 50.0,bottom: 5.0),
              )

            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
          margin: EdgeInsets.only(bottom: 10.0),
        ),
      );

    }
  }


  void onReplyMessage(String contentMsg,int type)
  {
    String chtMsg;
    // type=0 text
    //type=1 image
    //type=3 sticker

    if(contentMsg != "")
    {
      textEditingController.clear();
      ReplytextEditingController.clear();
      setState(() {
        isDisplayReply=false;
      });
      var docRef=Firestore.instance.collection("messages")
          .document("group")
          .collection(chatId)
          .document(DateTime.now().millisecondsSinceEpoch.toString());
      Firestore.instance.runTransaction((transaction)async
      {
        await transaction.set(docRef,
          {
            "idFrom" : id,
            "senderName":nickname,
            "senderImage": photoUrl,
            "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
            "content": contentMsg,
            "type": type,
            "replytoMsg":ReplyTo,
            "replyToUser":ReplyToUser,
            "index":ReplyIndex

          },);
      });
      setState(() {
        chtMsg="Reply";
        updateGroupchats(chtMsg, type);
      });
      listScrollController.animateTo(0.0, duration: Duration(microseconds: 300), curve: Curves.easeOut);
    }
    else
    {
      Fluttertoast.showToast(msg: "Empty Message cannot be send");
    }
  }


  void onSendMessage(String contentMsg,int type)
  {
    String chtMsg;
    // type=0 text
    //type=1 image
    //type=3 sticker

    if(contentMsg != "")
    {
      textEditingController.clear();
      var docRef=Firestore.instance.collection("messages")
          .document("group")
          .collection(chatId)
          .document(DateTime.now().millisecondsSinceEpoch.toString());
      Firestore.instance.runTransaction((transaction)async
      {
        await transaction.set(docRef,
          {
            "idFrom" : id,
            "senderName":nickname,
            "senderImage": photoUrl,
            "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
            "content": contentMsg,
            "type": type,

          },);
      });
      setState(() {
        if(type==0)
        {
          chtMsg=contentMsg;
        }
        else if(type== 1 )
        {
          chtMsg= "image";
        }
        else if(type==2)
        {
          chtMsg ="sticker";
        }
        else if(type==3){
          chtMsg="video";
        }
        else if(type==4)
        {
          chtMsg="audio";
        }
        else if(type==5)
        {
          chtMsg="document";
        }
        updateGroupchats(chtMsg, type);
      });
      listScrollController.animateTo(0.0, duration: Duration(microseconds: 300), curve: Curves.easeOut);
    }
    else
    {
      Fluttertoast.showToast(msg: "Empty Message cannot be send");
    }
  }
  void updateGroupchats(String Msg,int  type){
    for(var i=0; i < participantsList.length; i++)
      {
        Firestore.instance.collection("chats").document(participantsList[i]).collection(participantsList[i]).document(groupId).updateData({
          "lastMsg":Msg,
          "lastMsgTym" : DateTime.now().millisecondsSinceEpoch.toString(),
        });

      }


  }

  readPartcipantslist() async
  {
    List<String> names=[];
    List<String> about=[];
    List<String> photos=[];

    final DocumentSnapshot documentSnapshot= await Firestore.instance.collection("groups").document(groupId).get();
    List <String> ggg=List.from(documentSnapshot["participants"]);

    QuerySnapshot data= await Firestore.instance.collection("users").getDocuments();
    List<DocumentSnapshot>doc=data.documents;

    doc.forEach((element) {
      if(ggg.contains(element["id"]))
        {
          names.add(element["name"]);
          about.add(element['about']);
          photos.add(element["photoUrl"]);
        }
    });

    setState(() {
      participantsList=ggg;
      participantsNames=names;
      participantsAbout=about;
      participantsPhotoUrl=photos;
    });





    /*List<String> ggg = [];
    final QuerySnapshot result= await Firestore.instance.collection("group connections").document("participants").collection(groupId).getDocuments();
    final List<DocumentSnapshot>documents=result.documents;

    documents.forEach((element) {

      ggg.add(element["id"]);

    });

    setState(() {
      participantsList=ggg;

    });*/

  }


  GchatScreen()
  {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.lightBlue,
        centerTitle: false,
        titleSpacing: 0.0,
        title:StreamBuilder(
            stream: Firestore.instance.collection("groups").document(groupId).snapshots(),
            builder: (context, snapshot) {
              return ListTile(
                onTap: ()
                {
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>GroupProfile( participantsPhotos: participantsPhotoUrl,participantsAbout: participantsAbout,participantsNames: participantsNames,participantsList : participantsList,groupId: groupId,)));
                },
                leading: Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child:  CircleAvatar(
                          backgroundColor: Colors.black,
                          backgroundImage: CachedNetworkImageProvider(snapshot.data["photoUrl"]),
                        ),
                      ),


                      title : Text(
                            snapshot.data["name"],
                            style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                          ),





              );
            }
        ),

      ),
        body:grpChatbody(),
    );

  }
  @override
  Widget build(BuildContext context) {
    return GchatScreen();
  }
}
