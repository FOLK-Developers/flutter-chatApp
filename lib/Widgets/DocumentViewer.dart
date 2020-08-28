import 'package:chatApp/Drawers/ApiServceProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:async';

import 'package:open_file/open_file.dart';



class DocumentView extends StatefulWidget {
  final String url;
  DocumentView({Key key, @required this.url});
  @override
  State createState() => new DocumentViewState(url :url);
}

class DocumentViewState extends State<DocumentView> {

  final String url;
  DocumentViewState({@required this.url,} );

  String localPath;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    ApiServiceProvider.loadPDF(url).then((value){
      setState(() {
        localPath=value;
      });
    });
    //openFile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Document",style: TextStyle(color: Colors.white),),
      ),
      body: localPath !=null
      ?PDFView(filePath: localPath)
      :Center(child: CircularProgressIndicator(),),
    );
  }








  /*String _openResult = 'Unknown';

  Future<void> openFile() async {

    final filePath = 'https://firebasestorage.googleapis.com/v0/b/chatsapp-6f431.appspot.com/o/Chats%20Documents%2F1597304309084?alt=media&token=396ab89c-3fdc-4c9d-8887-252e951a96ab';
    final result = await OpenFile.open(localPath);

    setState(() {
      _openResult = "type=${result.type}  message=${result.message}";
    });
  }*/

 /* @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('open result: $_openResult\n'),
              FlatButton(
                child: Text('Tap to open file'),
                onPressed: openFile,
              ),
            ],
          ),
        ),
      ),
    );
  }*/
}