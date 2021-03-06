import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_media_notification/flutter_media_notification.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:nexthour/apidata/music_api.dart';
import 'package:nexthour/global.dart';
import 'package:nexthour/model/musicpage_state.dart';
import 'package:provider/provider.dart';
import 'music_player.dart';

class Musify extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AppState();
  }
}

class AppState extends State<Musify> {
  TextEditingController searchBar = TextEditingController();
  bool fetchingSongs = false;
  bool cancelSearch = searchedList.isNotEmpty;
  bool tapped = false;
  var currentId;

  void initState() {
    super.initState();

    MediaNotification.setListener('play', () {
      setState(() {
        audioPlayer.play(kUrl);
      });
    });

    MediaNotification.setListener('pause', () {
      setState(() {
        audioPlayer.pause();
      });
    });

    MediaNotification.setListener("close", () {
      audioPlayer.stop();
      dispose();
      checker = "Nahi";
      MediaNotification.hideNotification();
    });
  }

  search() async {
    String searchQuery = searchBar.text;
    if (searchQuery.isEmpty) return;
    fetchingSongs = true;
    setState(() {});
    await fetchSongsList(searchQuery);
    fetchingSongs = false;
    setState(() {});
  }

  getSongDetails(String id, var context, AudioState playerstate) async {
    if (currentId == id) {
      setState(() {
        checker = "Nahi";
      });
      tapped = false;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AudioApp(playerstate),
        ),
      );
    } else {
      try {
        await fetchSongDetails(id);
        print(kUrl);
      } catch (e) {
        artist = "Unknown";
        print(e);
      }
      setState(() {
        checker = "Haa";
      });
      currentId = id;
      tapped = false;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AudioApp(playerstate),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final playerstate = Provider.of<AudioState>(context, listen: false);
    return Container(
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        backgroundColor: Colors.transparent,
        bottomNavigationBar: kUrl != ""
            ? Padding(
                padding: const EdgeInsets.only(bottom: 75, left: 15, right: 15),
                child: Container(
                  height: 70,
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    elevation: 3.0,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: GestureDetector(
                        onTap: () {
                          checker = "Nahi";
                          if (kUrl != "") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AudioApp(playerstate)),
                            );
                          }
                        },
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 8.0,
                              ),
                              child: IconButton(
                                color: primaryColor,
                                icon: Icon(
                                  MdiIcons.appleKeyboardControl,
                                  size: 22,
                                ),
                                onPressed: null,
                                disabledColor: redPrime,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 0.0, top: 7, bottom: 7, right: 15),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: CachedNetworkImage(
                                  imageUrl: image,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 0.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    title,
                                    style: TextStyle(
                                        color: redPrime,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    artist,
                                    style: TextStyle(
                                        color: redPrime, fontSize: 15),
                                  )
                                ],
                              ),
                            ),
                            Spacer(),
                            Consumer<AudioState>(
                              builder: (_, playerstate, __) => IconButton(
                                icon: playerstate.playerState ==
                                        PlayerState.playing
                                    ? Icon(MdiIcons.pauseCircleOutline)
                                    : Icon(MdiIcons.playCircleOutline),
                                color: redPrime,
                                splashColor: Colors.transparent,
                                onPressed: () {
                                  setState(() {
                                    if (playerstate.playerState ==
                                        PlayerState.playing) {
                                      audioPlayer.pause();
                                      playerstate.state(PlayerState.paused);
                                      MediaNotification.showNotification(
                                          title: title,
                                          author: artist,
                                          isPlaying: false);
                                    } else if (playerstate.playerState ==
                                        PlayerState.paused) {
                                      audioPlayer.play(kUrl);
                                      playerstate.state(PlayerState.playing);
                                      MediaNotification.showNotification(
                                          title: title,
                                          author: artist,
                                          isPlaying: true);
                                    }
                                  });
                                },
                                iconSize: 45,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : SizedBox.shrink(),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(padding: EdgeInsets.only(bottom: 70.0)),
              Center(
                child: Row(children: <Widget>[
                  Expanded(
                    child: Center(
                      child: GradientText(
                        "Audio",
                        gradient: LinearGradient(colors: [
                          redPrime,
                          primaryDarkColor,
                        ]),
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                child: Card(
                  elevation: 3.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: TextField(
                      onSubmitted: (String value) {
                        search();
                      },
                      controller: searchBar,
                      style: TextStyle(
                        fontSize: 16,
                        color: redPrime,
                      ),
                      cursorColor: redPrime,
                      decoration: InputDecoration(
                        fillColor: Colors.transparent,
                        filled: true,
                        prefixIcon: IconButton(
                          icon: Icon(
                            Icons.cancel_outlined,
                            color: redPrime,
                          ),
                          onPressed: () => setState(() {
                            if (cancelSearch == true) {
                              cancelSearch = !cancelSearch;
                            } else {
                              cancelSearch = searchedList.isEmpty;
                            }
                            searchBar.text = "";
                          }),
                        ),
                        suffixIcon: IconButton(
                          icon: fetchingSongs
                              ? SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          redPrime),
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.search,
                                  color: redPrime,
                                ),
                          color: redPrime,
                          onPressed: () {
                            cancelSearch = searchedList.isNotEmpty;
                            search();
                          },
                        ),
                        border: InputBorder.none,
                        hintText: "Search...",
                        hintStyle: TextStyle(
                          color: redPrime,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              cancelSearch && searchBar.text.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: searchedList.length,
                      itemBuilder: (BuildContext ctxt, int index) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 5, bottom: 5),
                          child: Card(
                            color: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            elevation: 2.0,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10.0),
                              onTap: () {
                                if (tapped == false) {
                                  tapped = true;
                                  getSongDetails(searchedList[index]["id"],
                                      context, playerstate);
                                }
                              },
                              onLongPress: () {
                                topSongs();
                              },
                              splashColor: redPrime,
                              hoverColor: redPrime,
                              focusColor: redPrime,
                              highlightColor: redPrime,
                              child: Column(
                                children: <Widget>[
                                  ListTile(
                                    leading: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(
                                        MdiIcons.musicNoteOutline,
                                        size: 30,
                                        color: redPrime,
                                      ),
                                    ),
                                    title: Text(
                                      (searchedList[index]['title'])
                                          .toString()
                                          .split("(")[0]
                                          .replaceAll("&quot;", "\"")
                                          .replaceAll("&amp;", "&"),
                                      style: TextStyle(color: textColor),
                                    ),
                                    subtitle: Text(
                                      searchedList[index]['more_info']
                                          ["singers"],
                                      style: TextStyle(color: textColor),
                                    ),
                                    // trailing: IconButton(
                                    //   color: accent,
                                    //   icon: Icon(MdiIcons.downloadOutline),
                                    //   onPressed: () => downloadSong(searchedList[index]["id"]),
                                    // ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : FutureBuilder(
                      future: topSongs(),
                      builder: (context, data) {
                        if (data.hasData)
                          return Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 30.0, bottom: 10, left: 20),
                                  child: Text(
                                    "Top 15 Songs",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize: 22,
                                      color: redPrime,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.6,
                                  child: GridView.builder(
                                    scrollDirection: Axis.vertical,
                                    itemCount: 15,
                                    itemBuilder: (context, index) {
                                      return getTopSong(
                                          data.data[index]["image"],
                                          data.data[index]["title"],
                                          data.data[index]["more_info"]
                                                  ["artistMap"]
                                              ["primary_artists"][0]["name"],
                                          data.data[index]["id"],
                                          playerstate);
                                    },
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        return Center(
                            child: Padding(
                          padding: const EdgeInsets.all(35.0),
                          child: CircularProgressIndicator(
                            valueColor:
                                new AlwaysStoppedAnimation<Color>(redPrime),
                          ),
                        ));
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getTopSong(String image, String title, String subtitle, String id,
      AudioState playerstate) {
    return InkWell(
      onTap: () async {
        if (tapped == false) {
          tapped = true;
          await getSongDetails(id, context, playerstate);
        }
      },
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: CachedNetworkImage(
              imageUrl: image,
              width: MediaQuery.of(context).size.width * 0.32,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              title
                  .split("(")[0]
                  .replaceAll("&amp;", "&")
                  .replaceAll("&#039;", "'")
                  .replaceAll("&quot;", "\""),
              style: TextStyle(
                color: textColor,
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Text(
              subtitle,
              style: TextStyle(
                color: textColor.withOpacity(0.5),
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
