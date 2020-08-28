import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:video_player/video_player.dart';

class Player extends StatelessWidget
{

  final String url;


 Player({@required this.url});




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PlayerScreen(url : url),
    );
  }
}

class PlayerScreen extends StatefulWidget {

  final String url;


  PlayerScreen({@required this.url});
  @override
  State createState() => PlayerScreenState(url :url);
}


class PlayerScreenState extends State<PlayerScreen>
{
  final String url;
  PlayerScreenState({@required this.url});

  VideoPlayerController _controller;
  Future<void> _initializeVedioPlayerFuture;


  @override
  void initState() {

    _controller=VideoPlayerController.network(url);
    _initializeVedioPlayerFuture=_controller.initialize();
    _controller.setLooping(true);
    _controller.setVolume(1.0);
    super.initState();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _initializeVedioPlayerFuture,
        builder: (context,snapshot)
        {
          if(snapshot.connectionState==ConnectionState.done)
            {
              return Stack(
                children: <Widget>[

                  SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(width: _controller.value.size?.width??0,height:  _controller.value.size?.height??0,
                        child: VideoPlayer(_controller,) ,
                      ),
                    ),
                  ),
                ],
              );
            }
          else
            {
             return Center(child: Container(child: CircularProgressIndicator()));
            }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
          onPressed: ()
          {
            setState(() {
              if(_controller.value.isPlaying)
                {
                  _controller.pause();
                }
              else {
                _controller.play();
              }
            });
          }
      ),
    );
  }
}