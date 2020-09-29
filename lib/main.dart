import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'music.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:volume/volume.dart';
import 'package:flutter/services.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Application Musique',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Application Musique - Franel'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List<Musique> musique_list = [
    Musique('Banlance tion quoi', 'Angèle', 'assets/angele.jpg', 'https://www.auboutdufil.com/get.php?fla=https://archive.org/download/your-friend-ghost-nowhere-known/YourFriendGhost-NowhereKnown.mp3'),
    Musique('Djadja ', 'Aya Nakamura', 'assets/aya.jpg', 'https://www.auboutdufil.com/get.php?fla=music_414.mp3'),
    Musique('Cuba', 'Lefa', 'assets/cuba.jpeg', 'https://www.auboutdufil.com/get.php?fla=https://archive.org/download/mikechinobeatsdemigods/MikeChinoBeats-Demigods.mp3'),
    Musique('Enfant du desert', 'Diams', 'assets/diams.jpeg', 'https://www.auboutdufil.com/get.php?fla=https://archive.org/download/DWK301/Mounika_-_04_-_Soul_Blue_Tango.mp3'),
    Musique('Shape of You', 'Ed Sheeran', 'assets/ed.png', 'https://www.auboutdufil.com/get.php?fla=https://archive.org/download/jamendo-007505/01.mp3')
  ];

  AudioPlayer audioPlayer;
  StreamSubscription positionSubscription;
  StreamSubscription stateSubscription;

  Musique actualMusic;
  Duration position = Duration(seconds: 0);
  Duration duree = Duration(seconds: 0);
  PlayerState status = PlayerState.STOPPED;
  int index = 0;
  bool mute = false;
  int maxVol = 0;
  int currentVol = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    actualMusic = musique_list[index];
    configAudioPlayer();
    initPlatformState();
    updateVolume();
  }

  @override
  Widget build(BuildContext context) {
    double largeur = MediaQuery.of(context).size.width;
    int newVol = getVolumePourcent().toInt();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
        backgroundColor: Colors.blueGrey,
        elevation: 20.0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 250,
              color: Colors.red,
              margin: EdgeInsets.only(top: 20.0),
              child: Image.asset(actualMusic.imagePath),
            ),
            Container(
              margin: EdgeInsets.only(top: 20.0),
              child: Text(
                actualMusic.titre,
                textScaleFactor: 1.5,
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 5.0),
              child: Text(
                actualMusic.auteur,
              ),
            ),
            Container(
              height: largeur / 5,
              margin: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.fast_rewind),
                    onPressed: rewind,
                  ),
                  IconButton(
                    icon: (status != PlayerState.PLAYING) ? Icon(Icons.play_arrow): Icon(Icons.pause),
                    onPressed: (status != PlayerState.PLAYING) ? play : pause,
                    iconSize: 50,
                  ),
                  IconButton(
                    icon: Icon(Icons.fast_forward),
                    onPressed: forward,
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  textWithStyle(fromDuration(position), 0.8),
                  textWithStyle(fromDuration(duree), 0.8)
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 10.0, right: 10.0),
              child: new Slider(
                  value: position.inSeconds.toDouble(),
                  min: 0.0,
                  max: duree.inSeconds.toDouble(),
                  inactiveColor: Colors.grey,
                  activeColor: Colors.deepOrange,
                  onChanged: (double d) {
                    setState(() {
                      audioPlayer.seek(d);
                    });
                  }
              ),
            ),
            Container(
              height: largeur / 5,
              margin: EdgeInsets.only(left: 5.0, right: 5.0, top: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: (mute) ? Icon(Icons.headset_off) : Icon(Icons.headset),
                    onPressed: muted,
                  ),
                  IconButton(
                    icon: Icon(Icons.remove),
                    iconSize: 18,
                    onPressed: () {
                      if (!mute) {
                        Volume.setVol(currentVol-1);
                        updateVolume();
                      }
                    },
                  ),
                  Slider(
                    value: (mute) ? 0.0 : currentVol.toDouble(),
                    min: 0.0,
                    max: maxVol.toDouble(),
                    inactiveColor: (mute)? Colors.red : Colors.grey[500],
                    activeColor: (mute)? Colors.red : Colors.blue,
                    onChanged: (double d) {
                      setState(() {
                        if (!mute) {
                          Volume.setVol(d.toInt());
                          updateVolume();
                        }
                      });
                    },
                  ),
                  Text(
                    (mute) ? 'Mute' : '$newVol%',
                    style: TextStyle(
                      fontSize: 25,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    iconSize: 18,
                    onPressed: () {
                      if (!mute) {
                        Volume.setVol(currentVol+1);
                        updateVolume();
                      }
                    },
                  )
                ],
              ),
            )
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  double getVolumePourcent() {
    return (currentVol / maxVol) * 100;
  }

  /// Initialialiser le volume
  Future<void> initPlatformState() async {
    await Volume.controlVolume(AudioManager.STREAM_MUSIC);
  }

  /// Update le volume
  updateVolume() async {
    maxVol = await Volume.getMaxVol;
    currentVol = await Volume.getVol;
    setState(() {

    });
  }

  /// Définir le volume
  setVol(int i) async {
    await Volume.setVol(i);
  }

  /// Gestion des texte avec style
  Text textWithStyle(String data, double scale) {
    return Text(
      data,
      textScaleFactor: scale,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.black,
        fontSize: 15.0
      ),
    );
  }

  /// Gestion des boutons
  IconButton boutton(IconData icone, double taille, ActionMusic action) {
    return IconButton(
      icon: Icon(icone),
      iconSize: taille,
      color: Colors.white,
      onPressed: () {
        switch(action) {
          case ActionMusic.PLAY:
            play();
            break;
          case ActionMusic.PAUSE:
            pause();
            break;
          case ActionMusic.REWIND:
            rewind();
            break;
          case ActionMusic.FORWARD:
            forward();
            break;
          default: break;
        }
      },
    );
  }

  void configAudioPlayer() {
    audioPlayer = AudioPlayer();
    positionSubscription = audioPlayer.onAudioPositionChanged.listen((event) {
      setState(() {
        position = event;
      });
      if (position >= duree) {
        position = Duration(seconds: 0);
        // Passer à la musique suivante
      }
    });

    stateSubscription = audioPlayer.onPlayerStateChanged.listen((event) {
      if (event == AudioPlayerState.PLAYING) {
        setState(() {
          duree = audioPlayer.duration;
        });
      } else if (event == AudioPlayerState.STOPPED) {
        setState(() {
          status = PlayerState.STOPPED;
        });
      }
    }, onError: (message) {
      print(message);
      setState(() {
        status = PlayerState.STOPPED;
        duree = Duration(seconds: 0);
        position = Duration(seconds: 0);
      });
    });
  }

  Future play() async {
    await audioPlayer.play(actualMusic.musicUrl);
    setState(() {
      status = PlayerState.PLAYING;
    });
  }

  Future pause() async {
    await audioPlayer.pause();
    setState(() {
      status = PlayerState.PAUSED;
    });
  }

  Future muted() async {
    await audioPlayer.mute(!mute);
    setState(() {
      mute = !mute;
    });
  }

  void forward() {
    if (index == musique_list.length - 1) {
      index = 0;
    } else {
      index++;
    }
    actualMusic = musique_list[index];
    audioPlayer.stop();
    configAudioPlayer();
    play();
  }

  void rewind() {
    if (position > Duration(seconds: 3)) {
      audioPlayer.seek(0.0);
    } else {
      if (index == 0) {
        index = musique_list.length - 1;
      } else {
        index--;
      }
    }
    actualMusic = musique_list[index];
    audioPlayer.stop();
    configAudioPlayer();
    play();
  }

  String fromDuration(Duration duration) {
    return duration.toString().split('.').first;
  }
}

enum ActionMusic {
  PLAY,
  PAUSE,
  REWIND,
  FORWARD
}

enum PlayerState {
  PLAYING,
  STOPPED,
  PAUSED
}