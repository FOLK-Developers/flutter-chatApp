import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:video_player/video_player.dart';

class PlayerAudio extends StatelessWidget
{

  final String url;
  PlayerAudio({@required this.url});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PlayerAudioScreen(url : url),
    );
  }
}

class PlayerAudioScreen extends StatefulWidget {

  final String url;


  PlayerAudioScreen({@required this.url});
  @override
  State createState() => PlayerAudioScreenState(url :url);
}


class PlayerAudioScreenState extends State<PlayerAudioScreen>
{
  final String url;
  Duration duration= Duration();
  Duration position= Duration();

  PlayerAudioScreenState({@required this.url});

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
                    child: SizedBox(width:0,height:0,
                      child: VideoPlayer(_controller,) ,
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[

                    Container(
                      width: 200.0,
                      height: 200.0,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image : AssetImage("assets/images/audioPlayer.png"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    slider(),


                    //Slider(max:_controller.value.duration.inSeconds.toDouble(),value: position.inSeconds.toDouble(),min: 0.0 , onChanged: null),

                    InkWell(
                        //fillColor: Colors.blue,
                        child: Icon(_controller.value.isPlaying ? Icons.pause_circle_outline : Icons.play_circle_outline,color:Colors.blue,size: 100),
                        //shape: CircleBorder(),
                        onTap: () {
                          setState(() {
                            if (_controller.value.isPlaying) {
                              _controller.pause();
                            }
                            else {
                              _controller.play();
                            }


                            _controller.addListener(() {

                              setState(() {
                                position=_controller.value.position;
                              });

                            });

                          });
                        }
                        )

                  ],
                )
              ],
            );
          }
          else
          {
            return Center(child: Container(child: CircularProgressIndicator()));
          }
        },
      ),
    );
  }

  Widget slider()
  {
    return Slider.adaptive(
      min: 0.0,
      value: position.inSeconds.toDouble(),
      max: _controller.value.duration.inSeconds.toDouble(),
      onChanged: (double value)
      {
        setState(() {

          _controller.seekTo(new Duration(seconds: value.toInt()));

        });
      },
    );
  }
}