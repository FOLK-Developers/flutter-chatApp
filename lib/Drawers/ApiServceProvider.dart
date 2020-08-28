import 'dart:io';

import 'package:http/http.dart'as http;
import 'package:path_provider/path_provider.dart';


class ApiServiceProvider
{
  static final String BASEURL="https://firebasestorage.googleapis.com/v0/b/chatsapp-6f431.appspot.com/o/Chats%20Documents%2F1597475354071?alt=media&token=a02e9874-f7df-4dda-baa6-4c6a306ea176";

  static Future<String>loadPDF(String url)async
  {
    var response= await http.get(url);

    var dir =await getApplicationDocumentsDirectory();
    File file=new File("${dir.path}/file.pdf");
    file.writeAsBytesSync(response.bodyBytes,flush: true);
    return file.path;
  }
}