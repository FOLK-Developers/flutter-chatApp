import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatApp/Pages/UserProfile.dart';
import 'package:chatApp/Widgets/AudioPlayer.dart';
import 'package:chatApp/Widgets/DocumentViewer.dart';
import 'package:chatApp/Widgets/VidioPlayer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chatApp/Widgets/FullImageWidget.dart';
import 'package:chatApp/Widgets/ProgressWidget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Chat extends StatelessWidget {

  final String receiverId;
  final String receiverAvatar;
  final String receiverName;
  final List<String> contactList;

  Chat({
    Key key ,
    @required this.contactList,
    @required this.receiverId,
    @required this.receiverAvatar,
    @required this.receiverName,
});




  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar:  AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.lightBlue,
        centerTitle: false,
       titleSpacing: 0.0,

        title: GestureDetector(
          onTap: ()
          {
            Navigator.push(context, MaterialPageRoute(builder: (context) =>UserProfile( contactList : contactList,UserId: receiverId,)));
          },
          child: Padding(
            padding: EdgeInsets.all(0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[

                Padding(
                  padding: EdgeInsets.all(8.0),
                  child:  CircleAvatar(
                    backgroundColor: Colors.black,
                    backgroundImage: CachedNetworkImageProvider(receiverAvatar),
                  ),
                ),

                   Column(
                     children: <Widget>[
                       Text(
                        receiverName,
                        style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                        ),
                     ],
                   ),

              ],
            ),
          ),
        ),
      ),
      body: ChatScreen(receiverId : receiverId,receiverName: receiverName, receiverAvatar :receiverAvatar),

    );
  }
}

class ChatScreen extends StatefulWidget {

  final String receiverId;
  final String receiverName;
  final String receiverAvatar;

  ChatScreen({
    Key key,@required this.receiverId, @required this.receiverAvatar,@required this.receiverName
}) : super(key :key);

  @override
  State createState() => ChatScreenState(receiverId : receiverId,receiverName:receiverName, receiverAvatar :receiverAvatar);
}




class ChatScreenState extends State<ChatScreen> {

  final String receiverId;
  final String receiverName;
  final String receiverAvatar;


  ChatScreenState({
    Key key,@required this.receiverId, @required this.receiverAvatar,@required this.receiverName
  });

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
  var ReplyIndex;




  String chatId;
  SharedPreferences preferences;
  String id;
  String photoUrl;
  String nickname;
  var listMessage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    focusNode.addListener(onFocusChange);
    isDisplaySticker=false;
    isDisplayReply=false;
    isDisplayShare=false;
    isLoading=false;

    chatId="";

    readLocal();
  }

  readLocal()async
  {
    preferences= await SharedPreferences.getInstance();
    id=preferences.getString("id") ?? "";
    nickname=preferences.getString("name");
    photoUrl=preferences.getString("photoUrl");


    if(id.hashCode <= receiverId.hashCode)
    {
      chatId='$id-$receiverId';

    }
    else
      {
        chatId='$receiverId-$id';
      }
    setState(() {

    });
  }

  onFocusChange()
  {
    if(focusNode.hasFocus)
      {
        //hide sticker when keyboard
        setState(() {
          isDisplayReply=false;
          isDisplaySticker=false;
          isDisplayShare=false;
        });
      }
  }

  @override
  Widget build(BuildContext context)
  {
    return WillPopScope(
      child: Stack(
        children: <Widget>[
          
          Column(
            children: <Widget>[
              createListMessages(),
              // show sticker
              (isDisplaySticker ? createSickers() : isDisplayShare ? createShare() : Container()),
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
                child: Text(ReplyTo,
                  style: TextStyle(fontStyle: FontStyle.italic,color: Colors.white,fontWeight: FontWeight.bold),
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

  createLoading()
  {
    return Positioned(
        child: isLoading ? circularProgress() : Container(),
    );
  }

  Future<bool> onBackPress()
  {
    if(isDisplaySticker || isDisplayShare || isDisplayReply)
      {
        setState(() {
          isDisplaySticker=false;
          isDisplayShare=false;
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

  void getSticker()
  {
    focusNode.unfocus();
    setState(() {
      isDisplayShare = false;
      isDisplaySticker = !isDisplaySticker;
    });
  }
  void getShare()
  {
    focusNode.unfocus();
    setState(() {
      isDisplaySticker=false;
      isDisplayShare = !isDisplayShare;
    });
  }

  createListMessages()
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
            .document("private")
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
                       : (document["type"]==2)? Container(
                                      child: Image.asset(
                                        "images/${document['content']}.gif",
                                        width: 100.0,
                                        height: 100.0,
                                        fit: BoxFit.cover,
                                      ),
                                      margin: EdgeInsets.only(bottom: isLastMsgRight(index) ? 20.0 : 10.0, right: 10.0),
                                    )
              : (document["type"]==3) ?Container(
                    child: FlatButton(
                    child:Material(
                    child: CachedNetworkImage(
                    errorWidget: (context, url,error) => Material(
                    child: Image.asset("images/img_not_available.jpeg",width: 200.0,height: 200.0,fit: BoxFit.fill,),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    clipBehavior: Clip.hardEdge,
                    ),
                    imageUrl: "https://firebasestorage.googleapis.com/v0/b/chatsapp-6f431.appspot.com/o/Files%2Fvd.png?alt=media&token=a946abf3-e1bf-43b8-86aa-ec8bad3886e5",
                    width: 200.0,
                    height: 150.0,
                    fit: BoxFit.fill,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    //clipBehavior: Clip.hardEdge,
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
                    child:Material(
                    child: CachedNetworkImage(
                    errorWidget: (context, url,error) => Material(
                    child: Image.asset("images/img_not_available.jpeg",width: 200.0,height: 200.0,fit: BoxFit.fill,),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    clipBehavior: Clip.hardEdge,
                    ),
                    imageUrl: "https://firebasestorage.googleapis.com/v0/b/chatsapp-6f431.appspot.com/o/Files%2Fmp3%20file.jpeg?alt=media&token=5d8b6127-48c2-4b90-b5d9-228d8add26ff",
                    width: 150.0,
                    height: 160.0,
                    fit: BoxFit.fill,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    //clipBehavior: Clip.hardEdge,
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
              :(document['type']==5) ?Container(
                //Document files
                child: FlatButton(
                  child:Material(
                    child: CachedNetworkImage(
                      errorWidget: (context, url,error) => Material(
                        child: Image.asset("images/img_not_available.jpeg",width: 200.0,height: 200.0,fit: BoxFit.fill,),
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        clipBehavior: Clip.hardEdge,
                      ),
                      imageUrl: "https://firebasestorage.googleapis.com/v0/b/chatsapp-6f431.appspot.com/o/Files%2Fdocfile.png?alt=media&token=9f9b60b7-5d28-4eb3-92bc-119f9e35730a",
                      width: 130.0,
                      height: 160.0,
                      fit: BoxFit.fill,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    //clipBehavior: Clip.hardEdge,
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
              :GestureDetector(
                onTap: ()
                {
                  listScrollController.jumpTo(document['index'].toDouble());
                },
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[

                      Container(
                        child: Text(document["replyto"],
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
                  ReplyIndex=index;
                });


              }
          },
          child: Container(
            child: Column(
              children: <Widget>[
                Row(
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
                                imageUrl: receiverAvatar,
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
                            child: Text(
                              document["content"],
                              style: TextStyle(color: Colors.black,fontWeight: FontWeight.w400),
                            ),
                            padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                            width: 200.0,
                            decoration: BoxDecoration(color: Colors.grey[200],borderRadius: BorderRadius.circular(8.0)),
                            margin: EdgeInsets.only(left: 10.0),
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
                              margin: EdgeInsets.only(left: 10.0),
                            )
                        //Gif
                        :(document["type"]==2) ? Container(
                          child: Image.asset(
                            "images/${document['content']}.gif",
                            width: 100.0,
                            height: 100.0,
                            fit: BoxFit.cover,
                          ),
                          margin: EdgeInsets.only(left: 10.0),
                        )
                    : (document["type"]==3) ?Container(
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
                            imageUrl:"https://firebasestorage.googleapis.com/v0/b/chatsapp-6f431.appspot.com/o/Files%2Fvd.png?alt=media&token=a946abf3-e1bf-43b8-86aa-ec8bad3886e5" ,
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
                      margin: EdgeInsets.only(left: 10.0),
                    )
                    :(document["type"]==4)
                    ?Container(
                      //Audio files
                      child: FlatButton(
                        child:Material(
                          child: CachedNetworkImage(
                            errorWidget: (context, url,error) => Material(
                              child: Image.asset("images/img_not_available.jpeg",width: 200.0,height: 200.0,fit: BoxFit.fill,),
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              clipBehavior: Clip.hardEdge,
                            ),
                            imageUrl: "https://firebasestorage.googleapis.com/v0/b/chatsapp-6f431.appspot.com/o/Files%2Fmp3%20file.jpeg?alt=media&token=5d8b6127-48c2-4b90-b5d9-228d8add26ff",
                            width: 150.0,
                            height: 160.0,
                            fit: BoxFit.fill,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          //clipBehavior: Clip.hardEdge,
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
                    : document['type']==5 ?Container(
                      //Document Files
                      child: FlatButton(
                        child:Material(
                          child: CachedNetworkImage(
                            errorWidget: (context, url,error) => Material(
                              child: Image.asset("images/img_not_available.jpeg",width: 200.0,height: 200.0,fit: BoxFit.fill,),
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              clipBehavior: Clip.hardEdge,
                            ),
                            imageUrl: "https://firebasestorage.googleapis.com/v0/b/chatsapp-6f431.appspot.com/o/Files%2Fdocfile.png?alt=media&token=9f9b60b7-5d28-4eb3-92bc-119f9e35730a",
                            width: 130.0,
                            height: 160.0,
                            fit: BoxFit.fill,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          //clipBehavior: Clip.hardEdge,
                        ),
                        onPressed: ()
                        {
                          //Navigator.push(context, MaterialPageRoute(
                             // builder: (context) =>PlayerAudio(url : document["content"])
                          //));
                        },
                      ),
                      margin: EdgeInsets.only(bottom: isLastMsgRight(index) ? 20.0 : 10.0, right: 10.0),
                    )
                    :Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[

                          Container(
                            child: Text(document["replyto"],
                              style: TextStyle(fontStyle: FontStyle.italic,color: Colors.black54),
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
                      padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
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


  void onReplyMessage(String contentMsg,int type)
  {
    String chtMsg;
    if(contentMsg != "")
    {
      ReplytextEditingController.clear();
      textEditingController.clear();
      setState(() {
        isDisplayReply=false;
      });
      var docRef=Firestore.instance.collection("messages")
          .document("private")
          .collection(chatId)
          .document(DateTime.now().millisecondsSinceEpoch.toString());
      Firestore.instance.runTransaction((transaction)async
      {
        await transaction.set(docRef,
          {
            "idFrom" : id,
            "idTo": receiverId,
            "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
            "content": contentMsg,
            "type": type,
            "replyto":ReplyTo,
            "index":ReplyIndex

          },);
      });
      setState(() {
        chtMsg="Reply";
        updatechats(chtMsg, type);
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
    //type=2 sticker

    if(contentMsg != "")
      {
        ReplytextEditingController.clear();
        textEditingController.clear();
        var docRef=Firestore.instance.collection("messages")
            .document("private")
            .collection(chatId)
            .document(DateTime.now().millisecondsSinceEpoch.toString());
        Firestore.instance.runTransaction((transaction)async
        {
          await transaction.set(docRef,
            {
              "idFrom" : id,
              "idTo": receiverId,
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
          updatechats(chtMsg, type);
        });
        listScrollController.animateTo(0.0, duration: Duration(microseconds: 300), curve: Curves.easeOut);
      }
    else
      {
        Fluttertoast.showToast(msg: "Empty Message cannot be send");
      }
  }

  void updatechats(String Msg, int type)
  {


    Firestore.instance.collection("chats").document(id).collection(id).document(receiverId).setData({
      "id": receiverId,
      "photoUrl": receiverAvatar,
      "name": receiverName,
      "lastMsg" :Msg,
      "type" : 1,
      "lastMsgTym":DateTime.now().millisecondsSinceEpoch.toString()
    }).then((value) => {
      Firestore.instance.collection("chats").document(receiverId).collection(receiverId).document(id).setData({
        "id": id,
        "photoUrl":photoUrl,
        "name": nickname,
        "lastMsg" :Msg,
        "type" : 1,
        "lastMsgTym":DateTime.now().millisecondsSinceEpoch.toString()
      })
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
    StorageReference storageReference= FirebaseStorage.instance.ref().child("Chats Documents").child(fileName);
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
    StorageReference storageReference= FirebaseStorage.instance.ref().child("Chats Audios").child(fileName);
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
    StorageReference storageReference= FirebaseStorage.instance.ref().child("Chats Videos").child(fileName);
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



  uploadImageFile()async
  {
    String fileName=DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference storageReference= FirebaseStorage.instance.ref().child("Chats Images").child(fileName);

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
}
