import 'dart:async';

import 'package:audioplayer/audioplayer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_media_notification/flutter_media_notification.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:nexthour/apidata/music_api.dart';
import 'package:nexthour/global.dart';
import 'package:nexthour/model/musicpage_state.dart';
import 'package:nexthour/utils/appcolor.dart';
import 'package:provider/provider.dart';

AudioPlayer audioPlayer;

typedef void OnError(Exception exception);

// ignore: must_be_immutable
class AudioApp extends StatefulWidget {
  AudioState audioState;
  AudioApp(this.audioState);
  @override
  AudioAppState createState() => AudioAppState();
}

@override
class AudioAppState extends State<AudioApp> {
  Duration duration;
  Duration position;

  get durationText =>
      duration != null ? duration.toString().split('.').first : '';

  get positionText =>
      position != null ? position.toString().split('.').first : '';

  bool isMuted = false;

  StreamSubscription _positionSubscription;
  StreamSubscription _audioPlayerStateSubscription;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    initAudioPlayer();
  }

  @override
  void dispose() {
    _positionSubscription.cancel();
    _audioPlayerStateSubscription.cancel();
    super.dispose();
  }

  void initAudioPlayer() {
    if (audioPlayer == null) {
      audioPlayer = AudioPlayer();
    }
    setState(() {
      if (checker == "Haa") {
        stop(widget.audioState);
        play(widget.audioState);
      }
      if (checker == "Nahi") {
        if (Provider.of<AudioState>(context, listen: false).playerState ==
            PlayerState.playing) {
          play(widget.audioState);
        } else {
          //Using (Hack) Play() here Else UI glitch is being caused, Will try to find better solution.
          play(widget.audioState);
          pause(widget.audioState);
        }
      }
    });

    _positionSubscription = audioPlayer.onAudioPositionChanged.listen((p) {
      if (mounted) setState(() => position = p);
    });

    _audioPlayerStateSubscription =
        audioPlayer.onPlayerStateChanged.listen((s) {
      if (s == AudioPlayerState.PLAYING) {
        {
          if (mounted) setState(() => duration = audioPlayer.duration);
        }
      } else if (s == AudioPlayerState.STOPPED) {
        onComplete();
        if (mounted)
          setState(() {
            position = duration;
          });
      }
    }, onError: (msg) {
      if (mounted)
        setState(() {
          Provider.of<AudioState>(context, listen: false)
              .state(PlayerState.stopped);
          duration = Duration(seconds: 0);
          position = Duration(seconds: 0);
        });
    });
  }

  Future play(AudioState playerstate) async {
    await audioPlayer.play(kUrl);
    MediaNotification.showNotification(
        title: title, author: artist, isPlaying: true);
    if (mounted)
      setState(() {
        playerstate.state(PlayerState.playing);
      });
  }

  Future pause(AudioState playerstate) async {
    await audioPlayer.pause();
    MediaNotification.showNotification(
        title: title, author: artist, isPlaying: false);
    setState(() {
      playerstate.state(PlayerState.paused);
    });
  }

  Future stop(AudioState playerstate) async {
    await audioPlayer.stop();
    if (mounted)
      setState(() {
        playerstate.state(PlayerState.stopped);
        position = Duration();
      });
  }

  Future mute(bool muted) async {
    await audioPlayer.mute(muted);
    if (mounted)
      setState(() {
        isMuted = muted;
      });
  }

  void onComplete() {
    if (mounted)
      setState(() {
        Provider.of<AudioState>(context, listen: false)
            .state(PlayerState.stopped);
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      });
  }

  @override
  Widget build(BuildContext context) {
    final playerstate = Provider.of<AudioState>(context, listen: false);
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        title: GradientText(
          "Now Playing",
          shaderRect: Rect.fromLTWH(13.0, 0.0, 100.0, 50.0),
          gradient: LinearGradient(colors: [
            redPrime,
            primaryDarkColor,
          ]),
          style: TextStyle(
            color: accent,
            fontSize: 25,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 14.0),
          child: IconButton(
            icon: Icon(
              Icons.keyboard_arrow_down,
              size: 32,
              color: redPrime,
            ),
            onPressed: () => Navigator.pop(context, false),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10.0, bottom: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: CachedNetworkImage(
                    imageUrl: image,
                    height: MediaQuery.of(context).size.height * 0.30,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  GradientText(
                    title,
                    shaderRect: Rect.fromLTWH(13.0, 0.0, 100.0, 50.0),
                    gradient: LinearGradient(colors: [
                      redPrime,
                      primaryDarkColor,
                    ]),
                    textScaleFactor: 2.5,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      album + "  |  " + artist,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: redPrime.withOpacity(0.6),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Material(
                color: primaryColor,
                child: _buildPlayer(playerstate),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayer(AudioState playerstate) => Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: ListView(
            children: [
              duration != null
                  ? Slider(
                      activeColor: redPrime,
                      inactiveColor: redPrime.withOpacity(0.2),
                      value: position?.inMilliseconds?.toDouble() ?? 0.0,
                      onChanged: (double value) {
                        return audioPlayer.seek((value / 1000).roundToDouble());
                      },
                      min: 0.0,
                      max: duration.inMilliseconds.toDouble())
                  : SizedBox(),
              position != null ? _buildProgressView() : SizedBox(),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            redPrime,
                            primaryDarkColor.withOpacity(0.4),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(100)),
                    child: Consumer<AudioState>(
                      builder: (_, playerstate, __) => IconButton(
                        onPressed:
                            playerstate.playerState == PlayerState.playing
                                ? () => pause(playerstate)
                                : () => play(playerstate),
                        iconSize: 40.0,
                        icon: Icon(
                            playerstate.playerState == PlayerState.playing
                                ? MdiIcons.pause
                                : MdiIcons.play),
                        color: primaryDarkColor,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding:
                    const EdgeInsets.only(top: 20.0, left: 100, right: 100),
                child: Builder(builder: (context) {
                  return FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0)),
                      color: primaryDarkColor.withOpacity(0.2),
                      onPressed: () {
                        showBottomSheet(
                            context: context,
                            builder: (context) => Container(
                                  decoration: BoxDecoration(
                                      color: primaryDarkColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.only(
                                          topLeft: const Radius.circular(18.0),
                                          topRight:
                                              const Radius.circular(18.0))),
                                  height: 400,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 10.0),
                                        child: Row(
                                          children: <Widget>[
                                            IconButton(
                                                icon: Icon(
                                                  Icons.arrow_back_ios,
                                                  color: redPrime,
                                                  size: 20,
                                                ),
                                                onPressed: () =>
                                                    {Navigator.pop(context)}),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 42.0),
                                                child: Center(
                                                  child: Text(
                                                    "Lyrics",
                                                    style: TextStyle(
                                                      color: redPrime,
                                                      fontSize: 30,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      lyrics != "null"
                                          ? Expanded(
                                              flex: 1,
                                              child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(6.0),
                                                  child: Center(
                                                    child:
                                                        SingleChildScrollView(
                                                      child: Text(
                                                        lyrics,
                                                        style: TextStyle(
                                                          fontSize: 16.0,
                                                          color: redPrime
                                                              .withOpacity(0.7),
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                  )),
                                            )
                                          : Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 120.0),
                                              child: Center(
                                                child: Container(
                                                  child: Text(
                                                    "No Lyrics available ;(",
                                                    style: TextStyle(
                                                        color: redPrime
                                                            .withOpacity(0.5),
                                                        fontSize: 25),
                                                  ),
                                                ),
                                              ),
                                            ),
                                    ],
                                  ),
                                ));
                      },
                      child: Text(
                        "Lyrics",
                        style: TextStyle(color: redPrime),
                      ));
                }),
              ),
            ],
          ),
        ),
      );

  Row _buildProgressView() => Row(mainAxisSize: MainAxisSize.min, children: [
        Text(
          position != null
              ? "${positionText ?? ''} ".replaceFirst("0:0", "0")
              : duration != null
                  ? durationText
                  : '',
          style: TextStyle(fontSize: 18.0, color: redPrime.withOpacity(0.5)),
        ),
        Spacer(),
        Text(
          position != null
              ? "${durationText ?? ''}".replaceAll("0:", "")
              : duration != null
                  ? durationText
                  : '',
          style: TextStyle(fontSize: 18.0, color: redPrime.withOpacity(0.5)),
        )
      ]);
}
