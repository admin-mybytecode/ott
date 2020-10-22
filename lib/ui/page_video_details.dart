import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:nexthour/apidata/apidata.dart';
import 'package:nexthour/download/download_page.dart';
import 'package:nexthour/download/download_videos.dart';
import 'package:nexthour/download/new_download.dart';
import 'package:nexthour/model/comments_model.dart';
import 'package:nexthour/model/lang_model.dart';
import 'package:nexthour/model/task_info.dart';
import 'package:nexthour/player/iframe_player.dart';
import 'package:nexthour/player/m_player.dart';
import 'package:nexthour/component/item_description.dart';
import 'package:nexthour/component/item_header_video.dart';
import 'package:nexthour/ui/subscription.dart';
import 'package:nexthour/utils/color_loader.dart';
import 'package:nexthour/model/WatchlistModel.dart';
import 'package:nexthour/model/video_data.dart';
import 'package:nexthour/model/seasons.dart';
import 'package:http/http.dart' as http;
import 'package:nexthour/ui/deatiledViewPage.dart';
import 'package:nexthour/player/player_episodes.dart';
import 'package:nexthour/widget/container_border.dart';
import 'package:nexthour/widget/rate_us.dart';
import 'package:nexthour/widget/seasons_tab.dart';
import 'package:nexthour/widget/share_page.dart';
import 'package:nexthour/widget/tab_widget.dart';
import 'package:nexthour/widget/watchlist_container.dart';
import '../global.dart';

var seasonId;
var seasonCount;
var episodesCount;
int episodesCounting = 0;
int _currentIndex = 0;

class VideoGenreDetailsPage extends StatefulWidget {
  VideoGenreDetailsPage(this.game, {Key key}) : super(key: key);

  final VideoDataModel game;

  @override
  _VideoGenreDetailsPageState createState() =>
      new _VideoGenreDetailsPageState();
}

class _VideoGenreDetailsPageState extends State<VideoGenreDetailsPage>
    with TickerProviderStateMixin, RouteAware {
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ScrollController _scrollViewController;
  TabController _tabController;
  int _currentIndex2 = 0;
  TabController _episodeTabController;
  TabController _seasonsTabController;
  bool horizontal = true;
  bool descTextShowFlag = false;
  Seasons selected;
  List<Widget> containers;

  var avId1;
  var avId2;
  var dMsg = '';
  Connectivity connectivity;
  // ignore: cancel_subscriptions
  StreamSubscription<ConnectivityResult> subscription;
  var _connectionStatus = 'Unknown';
  List<CommentsModel> ls;
  var aLangFinalM;
  var aLangFinalS;
  var audioLangIdS;
  final _formKey = new GlobalKey<FormState>();
  final TextEditingController commentsController = new TextEditingController();
  int commentsLen = 0;

// To add movies or tv series in watchlist
  Future<String> addWishlist(type, id, value) async {
    try {
      final addWatchlistResponse = await http.post(APIData.addWatchlist, body: {
        "type": type,
        "id": '$id',
        "value": '$value'
      }, headers: {
        // ignore: deprecated_member_use
        HttpHeaders.AUTHORIZATION: nToken == null ? fullData : nToken
      });
      print(addWatchlistResponse.statusCode);
    } catch (e) {
      print(e);
      return null;
    }
    return null;
  }

  Future<String> getData(currentIndex) async {
    setState(() {
      seasonEpisodeData = null;
    });
    final episodesResponse = await http.get(
        Uri.encodeFull(
            APIData.episodeDataApi + "${widget.game.seasons[currentIndex].id}"),
        headers: {
          // ignore: deprecated_member_use
          HttpHeaders.AUTHORIZATION: nToken == null ? fullData : nToken
        });

    var episodesData = json.decode(episodesResponse.body);

    setState(() {
      seasonEpisodeData = episodesData['episodes'];
    });

    episodesCount = episodesData['episodes'].length;

    return null;
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    _currentIndex2 = 0;
    if (widget.game.datatype == 'T') {
      this.getData(_currentIndex);
    }

    _tabController = TabController(vsync: this, length: 2, initialIndex: 0);
    _seasonsTabController = TabController(
        vsync: this,
        length: widget.game.seasons == null ? 0 : widget.game.seasons.length,
        initialIndex: 0);
    _scrollViewController = new ScrollController();

    _episodeTabController =
        TabController(vsync: this, length: 2, initialIndex: 0);

    connectivity = new Connectivity();
    subscription =
        connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _connectionStatus = result.toString();
      print(_connectionStatus);
      checkConnectionStatus = result.toString();
      if (result == ConnectivityResult.wifi) {
        setState(() {
          _connectionStatus = 'Wi-Fi';
        });
      } else if (result == ConnectivityResult.mobile) {
        _connectionStatus = 'Mobile';
      } else {
        var router = new MaterialPageRoute(
          builder: (BuildContext context) => OfflineDownloadPage(
            key: PageStorageKey('Page4'),
          ),
        );
        Navigator.of(context).push(router);
      }
    });
  }

  @override
  void dispose() {
    _scrollViewController.dispose();
    _tabController.dispose();
    _seasonsTabController.dispose();
    _episodeTabController.dispose();
    super.dispose();
  }

// Genres name Row
  Widget genreNameRow(game) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Text(
                'Name:',
                style: TextStyle(color: Colors.grey, fontSize: 13.0),
              ),
            ),
            Expanded(
              flex: 5,
              child: GestureDetector(
                onTap: () {},
                child: Text(
                  "${game.name}",
                  style: TextStyle(color: textColor, fontSize: 13.0),
                ),
              ),
            ),
          ],
        ));
  }

// Genre details Row
  Widget genresRow(genres) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Text(
                'Genres:',
                style: TextStyle(color: Colors.grey, fontSize: 13.0),
              ),
            ),
            Expanded(
              flex: 5,
              child: GestureDetector(
                onTap: () {},
                child: Text(
                  "$genres",
                  style: TextStyle(color: textColor, fontSize: 13.0),
                ),
              ),
            ),
          ],
        ));
  }

// Genre Details Text
  Widget genreDetailsText(game) {
    return Expanded(
      flex: 5,
      child: GestureDetector(
        onTap: () {},
        child: Text(
          "${game.seasons[_currentIndex].description}",
          style: TextStyle(color: Colors.white, fontSize: 13.0),
        ),
      ),
    );
  }

  void getComments() {
    var com = widget.game.comments;
    ls = List<CommentsModel>.generate(com == null ? 0 : com.length,
        (int mComIndex) {
      print(com[mComIndex].cComment);
      return CommentsModel(
        id: com[mComIndex].id,
        cName: com[mComIndex].cName,
        cEmail: com[mComIndex].cEmail,
        cMovieId: com[mComIndex].cMovieId,
        cTvSeriesId: com[mComIndex].cTvSeriesId,
        cComment: com[mComIndex].cComment,
        cCreatedAt: com[mComIndex].cCreatedAt,
        cUpdatedAt: com[mComIndex].cUpdatedAt,
      );
    });
  }

  Widget comments() {
    return ListView.builder(
        itemCount: this.commentsLen,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemBuilder: (context, index) => this._buildRow(index));
  }

  Future<void> addComment(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          contentPadding: EdgeInsets.only(left: 25.0, right: 25.0),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25.0))),
          title: Container(
            alignment: Alignment.topLeft,
            child: Text(
              'Add Comments',
              style: TextStyle(color: redPrime, fontWeight: FontWeight.w600),
            ),
          ),
          content: Container(
            height: MediaQuery.of(context).size.height / 4,
            child: Column(
              children: <Widget>[
                Form(
                  key: _formKey,
                  child: Container(
                    margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: TextFormField(
                      controller: commentsController,
                      maxLines: 4,
                      decoration: new InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(
                            left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
                        hintText: "Comment",
                        errorStyle: TextStyle(fontSize: 10),
                        hintStyle: TextStyle(
                            color: Colors.black.withOpacity(0.4), fontSize: 18),
                      ),
                      style: TextStyle(
                          color: Colors.black.withOpacity(0.7), fontSize: 18),
                      validator: (val) {
                        if (val.length == 0) {
                          return "Comment can not be blank.";
                        }
                        return null;
                      },
                      onSaved: (val) => commentsController.text = val,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                InkWell(
                  child: Container(
                    color: redPrime,
                    height: 45.0,
                    width: 100.0,
                    padding: EdgeInsets.only(
                        left: 15.0, right: 15.0, top: 5.0, bottom: 5.0),
                    child: Center(
                      child: Text(
                        "Post",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  onTap: () {
                    final form = _formKey.currentState;
                    form.save();
                    if (form.validate() == true) {
                      postComment();
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<String> postComment() async {
    final postCommentResponse = await http.post(APIData.postBlogComment, body: {
      "type": '${widget.game.datatype}',
      "id": '${widget.game.id}',
      "comment": '${commentsController.text}',
      "name": '$name',
      "email": '$email',
    }, headers: {
      // ignore: deprecated_member_use
      HttpHeaders.AUTHORIZATION: nToken == null ? fullData : nToken
    });
    print(postCommentResponse.statusCode);
    if (postCommentResponse.statusCode == 200) {
      ls.add(CommentsModel(
          id: widget.game.id,
          cName: name,
          cEmail: email,
          cComment: commentsController.text));
      _updateComments();

      setState(() {
        commentsLen = ls.length;
      });
      commentsController.text = '';

      Fluttertoast.showToast(msg: "Commented Successfully");
      commentsController.text = '';
      Navigator.pop(context);
    } else {
      Fluttertoast.showToast(msg: "Error in commenting");
      commentsController.text = '';
      Navigator.pop(context);
    }

    return null;
  }

  _updateComments() {
    setState(() {
      commentsLen = commentsLen + 1;
    });
  }

  _buildRow(int position) {
//    return Text("Item " + position.toString());
    return Column(
      children: <Widget>[
        SizedBox(
          height: 10.0,
        ),
        Row(
          children: <Widget>[
            ls[position].cName == null
                ? SizedBox.shrink()
                : Text(
                    ls[position].cName,
                    style: TextStyle(fontSize: 13.0),
                  ),
          ],
        ),
        SizedBox(
          height: 3.0,
        ),
        Row(
          children: <Widget>[
            ls[position].cComment == null
                ? SizedBox.shrink()
                : Text(
                    ls[position].cComment,
                    style: TextStyle(
                        fontSize: 12.0, color: textColor.withOpacity(0.6)),
                  ),
          ],
        ),
      ],
    );
  }

  Widget audioLangRow(game) {
    var audioList = mainData['audio'];
    List<LangModel> auLang = List.generate(audioList.length, (int index) {
      return LangModel(
          id: audioList[index]['id'],
          aLanguage: "${audioList[index]['language']}");
    });

    var audioLangIdM = widget.game.aLang;
    if (audioLangIdM == null) {
      audioLangIdM = "Not Available";
    }

    for (var i = 0; i < auLang.length; i++) {
      if ("${auLang[i].id}" == audioLangIdM) {
        aLangFinalM = auLang[i].aLanguage == null ? 'N/A' : auLang[i].aLanguage;
      }
    }
    for (var i = 0; i < auLang.length; i++) {
      if ("${auLang[i].id}" == audioLangIdS) {
        aLangFinalS = auLang[i].aLanguage == null ? 'N/A' : auLang[i].aLanguage;
      }
    }
    if (aLangFinalS == null) {
      aLangFinalS = "Not Available";
    }
    if (aLangFinalM == null) {
      aLangFinalM = "Not Available";
    }
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Text(
                'Audio Language:',
                style: TextStyle(color: Colors.grey, fontSize: 13.0),
              ),
            ),
            Expanded(
              flex: 5,
              child: GestureDetector(
                onTap: () {},
                child: Text(
                  game.datatype == "M" ? "$aLangFinalM" : "$aLangFinalS",
                  style: TextStyle(color: textColor, fontSize: 13.0),
                ),
              ),
            ),
          ],
        ));
  }

// Genre details Container
  Widget genreDetailsContainer(game, genres) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "About",
              style: TextStyle(color: textColor, fontSize: 16.0),
            ),
            Container(
              height: 8.0,
            ),
            genreNameRow(game),
            genresRow(genres),
            game.datatype == "T"
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Details:',
                            style:
                                TextStyle(color: Colors.grey, fontSize: 13.0),
                          ),
                        ),
                        genreDetailsText(game),
                      ],
                    ))
                : SizedBox(
                    width: 0.0,
                  ),
            audioLangRow(widget.game),
          ],
        ),
      ),
      color: primaryColor,
    );
  }

// Image
  Widget tapOnMoreLike(moreLikeThis, index) {
    return InkWell(
      child: FadeInImage.assetNetwork(
        image: moreLikeThis[index].box,
        placeholder: 'assets/placeholder_box.jpg',
        height: 150.0,
        fit: BoxFit.cover,
      ),
      onTap: () {
        var router = new MaterialPageRoute(
            builder: (BuildContext context) =>
                new DetailedViewPage(moreLikeThis[index]));
        Navigator.of(context).push(router);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var isAdded = 0;
    if (widget.game.seasons.length != 0) {
      ser = widget.game.datatype == 'T' ? widget.game.seasons[0].id : null;
    }
    for (var i = 0; i < userWatchList.length; i++) {
      for (var j = 0; j < widget.game.seasons.length; j++) {
        if (userWatchList[i].season_id == widget.game.seasons[j].id) {
          isAdded = 1;
          avId1 = widget.game.seasons[j].id;
          break;
        }
      }
      if (isAdded == 1) {
        break;
      }
    }
    var isMovieAdded = 0;
    for (var i = 0; i < userWatchList.length; i++) {
      if (userWatchList[i].wMovieId == widget.game.id) {
        isMovieAdded = 1;
        avId2 = widget.game.id;
        break;
      }
    }
    List moreLikeThis = new List<VideoDataModel>.generate(
        newVideosListG == null ? 0 : newVideosListG.length, (int index) {
      var genreIds2Count = newVideosListG[index].genre.length;
      var genreIds2All = newVideosListG[index].genre;
      for (var j = 0; j < genreIds2Count; j++) {
        var genreIds2 = genreIds2All[j];
        var isAv = 0;
        for (var i = 0; i < widget.game.genre.length; i++) {
          var genreIds = widget.game.genre[i].toString();

          if (genreIds2 == genreIds) {
            isAv = 1;
            break;
          }
        }
        if (isAv == 1) {
          if (widget.game.datatype == newVideosListG[index].datatype) {
            if (widget.game.id != newVideosListG[index].id) {
              return newVideosListG[index];
            }
          }
        }
      }
      return null;
    });
    moreLikeThis.removeWhere((item) => item == null);

    return SafeArea(
      child: WillPopScope(
          child: DefaultTabController(
            length: 2,
            child: Scaffold(
              key: _scaffoldKey,
              body: widget.game.datatype == "T"
                  ? _seasonScrollView(isAdded)
                  : _movieScrollView(isMovieAdded, moreLikeThis),
              backgroundColor: Color.fromRGBO(34, 34, 34, 1.0),
            ),
          ),
          onWillPop: () async {
            return true;
          }),
    );
  }

// Seasons watchlist
  Widget _watchListSeasons(isAdded) => Expanded(
        child: Material(
          child: InkWell(
            onTap: () async {
              var isAdded = 0;
              var setype, seid, sevalue;
              var avId;
              for (var i = 0; i < userWatchList.length; i++) {
                for (var j = 0; j < widget.game.seasons.length; j++) {
                  if (userWatchList[i].season_id == widget.game.seasons[j].id) {
                    isAdded = 1;
                    avId = widget.game.seasons[j].id;
                    break;
                  }
                }
                if (isAdded == 1) {
                  break;
                }
              }

//                                            Add Seasons to watchlist
              if (isAdded != 1) {
                userWatchList.add(WatchlistModel(
                  season_id: widget.game.seasons[0].id,
                ));
                setState(() {
                  isAdded = 1;
                });
                setype = 'S';
                seid = widget.game.seasons[0].id;
                sevalue = 1;
                addWishlist(setype, seid, sevalue);
              } else {
                setState(() {
                  isAdded = 0;
                });
                setype = 'S';
                seid = widget.game.seasons[0].id;
                sevalue = 0;
                addWishlist(setype, seid, sevalue);
                userWatchList.removeWhere((item) => item.season_id == avId);
              }
            },
            child: WishListContainer(isAdded),
          ),
          color: Colors.transparent,
        ),
      );

// Seasons
  Widget _seasonScrollView(isAdded) => NestedScrollView(
        controller: _scrollViewController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          if (widget.game.seasons.length != 0) {
            return <Widget>[
              SliverList(
                  delegate:
                      SliverChildBuilderDelegate((BuildContext context, int j) {
                return new Container(
                  color: Color.fromRGBO(34, 34, 34, 1.0),
                  child: Column(
                    children: <Widget>[
                      new VideoDetailHeader(widget.game),
                      new Padding(
                          padding:
                              const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                          child: new DescriptionText(widget.game.description)),
                      new Padding(
                        padding:
                            const EdgeInsets.fromLTRB(16.0, 26.0, 16.0, 0.0),
                      ),
                      new Row(
                        children: [
                          _watchListSeasons(isAdded),
                          RateUs(widget.game.datatype, widget.game.id),
                          SharePage(APIData.shareSeasonsUri,
                              widget.game.seasons[0].id),
                          widget.game.datatype == 'M'
                              ? DownloadPage(widget.game)
                              : SizedBox.shrink(),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 20.0),
                      )
                    ],
                  ),
                );
              }, childCount: 1)),
              customSliverAppBar(innerBoxIsScrolled),
            ];
          } else {
            return <Widget>[
              SliverList(
                  delegate:
                      SliverChildBuilderDelegate((BuildContext context, int j) {
                return new Container(
                  color: Color.fromRGBO(34, 34, 34, 1.0),
                  child: Column(
                    children: <Widget>[
                      new VideoDetailHeader(widget.game),
                      new Padding(
                          padding:
                              const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                          child: new DescriptionText(widget.game.description)),
                    ],
                  ),
                );
              }, childCount: 1)),
              customSliverAppBar(innerBoxIsScrolled),
            ];
          }
        },
        body: _currentIndex2 == 0 ? AllEpisodes() : MoreDetails(),
      );

// Movies watchlist
  Widget _watchlistMovie(isMovieAdded) => Expanded(
        child: Material(
          child: new InkWell(
            onTap: () {
              var isMovieAdded = 0;
              var motype, moid, movalue;
              var avId;
              for (var i = 0; i < userWatchList.length; i++) {
                if (userWatchList[i].wMovieId == widget.game.id) {
                  isMovieAdded = 1;
                  avId = widget.game.id;
                  break;
                }
              }
              if (isMovieAdded != 1) {
                userWatchList.add(WatchlistModel(
                  wMovieId: widget.game.id,
                ));

                motype = 'M';
                moid = widget.game.id;
                movalue = 1;
                setState(() {
                  isMovieAdded = 1;
                });
                addWishlist(motype, moid, movalue);
              } else {
                motype = 'M';
                moid = widget.game.id;
                movalue = 0;
                setState(() {
                  isMovieAdded = 0;
                });
                addWishlist(motype, moid, movalue);
                userWatchList.removeWhere((item) => item.wMovieId == avId);
              }
            },
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                isMovieAdded == 1
                    ? Icon(
                        Icons.check,
                        size: 30.0,
                        color: redPrime,
                      )
                    : Icon(
                        Icons.add,
                        size: 30.0,
                        color: primaryDarkColor,
                      ),
                new Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                ),
                new Text(
                  "My List",
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.0,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          color: Colors.transparent,
        ),
      );

// Movies
  Widget _movieScrollView(isMovieAdded, moreLikeThis) => NestedScrollView(
      controller: _scrollViewController,
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverList(
              delegate:
                  SliverChildBuilderDelegate((BuildContext context, int j) {
            return new Container(
              color: primaryColor,
              child: Column(
                children: <Widget>[
                  new VideoDetailHeader(widget.game),
                  new Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                      child: new DescriptionText(widget.game.description)),
                  new Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 26.0, 16.0, 0.0),
                  ),
                  new Row(
                    children: [
                      _watchlistMovie(isMovieAdded),
                      RateUs(widget.game.datatype, widget.game.id),
                      SharePage(APIData.shareMovieUri, widget.game.id),
                      widget.game.datatype == 'M'
                          ? DownloadPage(widget.game)
                          : SizedBox.shrink(),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 20.0),
                  )
                ],
              ),
            );
          }, childCount: 1)),
          SliverAppBar(
            titleSpacing: 0.00,
            elevation: 0.0,
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CustomBorder(),
                new TabBar(
                    onTap: (currentIndex) {
                      setState(() {
                        _currentIndex = currentIndex;
                      });
                    },
                    indicator: UnderlineTabIndicator(
                      borderSide: BorderSide(color: redPrime, width: 2.5),
                      insets: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 46.0),
                    ),
                    indicatorColor: Colors.orangeAccent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorWeight: 3.0,
                    indicatorPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    unselectedLabelColor: Color.fromRGBO(95, 95, 95, 1.0),
                    tabs: [
                      TabWidget('MORE LIKE THIS'),
                      TabWidget('MORE DETAILS'),
                    ]),
              ],
            ),
            backgroundColor: primaryColor,
            pinned: true,
            floating: true,
            forceElevated: innerBoxIsScrolled,
            automaticallyImplyLeading: false,
          ),
        ];
      },
      body: Container(
        color: primaryColor,
        child: TabBarView(children: <Widget>[
          new ListView(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            children: <Widget>[
              Container(
                color: primaryColor,
                height: 300.0,
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  scrollDirection: Axis.horizontal,
                  children: List<Padding>.generate(
                      moreLikeThis == null ? 0 : moreLikeThis.length,
                      (int index) {
                    return new Padding(
                      padding:
                          EdgeInsets.only(right: 2.5, left: 2.5, bottom: 5.0),
                      child: moreLikeThis[index] == null
                          ? Container()
                          : tapOnMoreLike(moreLikeThis, index),
                    );
                  }),
                ),
              )
            ],
          ),
          MoreDetails()
        ]),
      ));

//  Tab bar for seasons page and episodes and more details tabs
  Widget tabBar() {
    return TabBar(
        onTap: (currentIndex2) {
          setState(() {
            _currentIndex2 = currentIndex2;
          });
        },
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: Colors.white70, width: 2.5),
          insets: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
        ),
        indicatorColor: Colors.orangeAccent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorWeight: 3.0,
        unselectedLabelColor: primaryColor,
        tabs: [
          TabWidget('EPISODES'),
          TabWidget('MORE DETAILS'),
        ]);
  }

  //  Episode title
  Widget episodeTitle(i) {
    return Text('Episode ${seasonEpisodeData[i]['episode_no']}',
        style: TextStyle(fontSize: 14.0, color: Colors.white));
  }

  //  Episode subtitle
  Widget episodeSubtitle(i) {
    return Text(
      '${seasonEpisodeData[i]['title']}',
      style: TextStyle(
        fontSize: 12.0,
      ),
    );
  }

  Future<Null> _prepare() async {
    final tasks = await FlutterDownloader.loadTasks();
    tasks?.forEach((task) {
      for (TaskInfo info in dTasks) {
        if (info.hdLink == task.url) {
          info.taskId = task.taskId;
          info.status = task.status;
          info.progress = task.progress;
        }
      }
    });

    permissionReady = await _checkPermission();
    dLocalPath = localPath;

    setState(() {
      isLoading = false;
    });
  }

  TargetPlatform platform;

  Future<bool> _checkPermission() async {
    if (platform == TargetPlatform.android) {
      PermissionStatus permission = await PermissionHandler()
          .checkPermissionStatus(PermissionGroup.storage);
      if (permission != PermissionStatus.granted) {
        Map<PermissionGroup, PermissionStatus> permissions =
            await PermissionHandler()
                .requestPermissions([PermissionGroup.storage]);
        if (permissions[PermissionGroup.storage] == PermissionStatus.granted) {
          return true;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  Widget episodeDetails(i) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              top: 10.0,
            ),
            child: Text(
              '${seasonEpisodeData[i]['detail']}',
              style: TextStyle(fontSize: 12.0),
            ),
          ),
          Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  top: 10.0,
                ),
                child: Text(
                  'Released: ' + '${seasonEpisodeData[i]['released']}',
                  style: TextStyle(fontSize: 12.0),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
        ],
      ),
    );
  }

  //  Play button for particular episode.
  Widget gestureDetector(i) {
    return GestureDetector(
      child: Icon(
        Icons.play_circle_outline,
        color: Colors.white,
        size: 35.0,
      ),
      onTap: () {
        if (status == "1") {
          mReadyUrl = seasonEpisodeData[i]['video_link']['ready_url'];
          mUrl360 = seasonEpisodeData[i]['video_link']['url_360'];
          mUrl480 = seasonEpisodeData[i]['video_link']['url_480'];
          mUrl720 = seasonEpisodeData[i]['video_link']['url_720'];
          mUrl1080 = seasonEpisodeData[i]['video_link']['url_1080'];
          mIFrameUrl = seasonEpisodeData[i]['video_link']['iframeurl'];
          var title = seasonEpisodeData[i]['title'];

          if (mIFrameUrl != null ||
              mReadyUrl != null ||
              mUrl360 != null ||
              mUrl480 != null ||
              mUrl720 != null ||
              mUrl1080 != null) {
            if (mIFrameUrl != null) {
              var matchIFrameUrl = mIFrameUrl.substring(0, 24);
              if (matchIFrameUrl == 'https://drive.google.com' ||
                  mIFrameUrl.substring(mReadyUrl.length - 4) == ".mp4") {
                var ind = mIFrameUrl.lastIndexOf('d/');
                var t = "$mIFrameUrl".trim().substring(ind + 2);
                var rep = t.replaceAll('/preview', '');
                var newurl =
                    "https://www.googleapis.com/drive/v3/files/$rep?alt=media&key=${APIData.googleDriveApi}";
                if (userPaymentType == "Free") {
                  freeTrial(newurl, "CUSTOM", title);
                } else {
                  getAllScreens(newurl, "CUSTOM", title);
                }
              } else {
                if (userPaymentType == "Free") {
                  freeTrial(mIFrameUrl, "EMD", title);
                } else {
                  getAllScreens(mIFrameUrl, "EMD", title);
                }
              }
            } else if (mReadyUrl != null) {
              var checkMp4 = seasonEpisodeData[i]['video_link']['ready_url']
                  .substring(mReadyUrl.length - 4);
              var checkMpd = seasonEpisodeData[i]['video_link']['ready_url']
                  .substring(mReadyUrl.length - 4);
              var checkWebm = seasonEpisodeData[i]['video_link']['ready_url']
                  .substring(mReadyUrl.length - 5);
              var checkMkv = seasonEpisodeData[i]['video_link']['ready_url']
                  .substring(mReadyUrl.length - 4);
              var checkM3u8 = seasonEpisodeData[i]['video_link']['ready_url']
                  .substring(mReadyUrl.length - 5);

              if (seasonEpisodeData[i]['video_link']['ready_url']
                      .substring(0, 18) ==
                  "https://vimeo.com/") {
                if (userPaymentType == "Free") {
                  freeTrial(seasonEpisodeData[i]['id'], "JS", title);
                } else {
                  getAllScreens(seasonEpisodeData[i]['id'], "JS", title);
                }
              } else if (seasonEpisodeData[i]['video_link']['ready_url']
                      .substring(0, 29) ==
                  'https://www.youtube.com/embed') {
                if (userPaymentType == "Free") {
                  freeTrial(mReadyUrl, "EMD", title);
                } else {
                  getAllScreens(mReadyUrl, "EMD", title);
                }
              } else if (seasonEpisodeData[i]['video_link']['ready_url']
                      .substring(0, 23) ==
                  'https://www.youtube.com') {
                if (userPaymentType == "Free") {
                  freeTrial(seasonEpisodeData[i]['id'], "JS", title);
                } else {
                  getAllScreens(seasonEpisodeData[i]['id'], "JS", title);
                }
              } else if (checkMp4 == ".mp4" ||
                  checkMpd == ".mpd" ||
                  checkWebm == ".webm" ||
                  checkMkv == ".mkv" ||
                  checkM3u8 == ".m3u8") {
                if (userPaymentType == "Free") {
                  freeTrial(mReadyUrl, "CUSTOM", title);
                } else {
                  getAllScreens(mReadyUrl, "CUSTOM", title);
                }
              } else {
//                print("Ep1 URL: ${seasonEpisodeData[i]['video_link']['ready_url']}");
                if (userPaymentType == "Free") {
                  freeTrial(seasonEpisodeData[i]['id'], "JS", title);
                } else {
                  getAllScreens(seasonEpisodeData[i]['id'], "JS", title);
                }

//                var router = new MaterialPageRoute(
//                  builder: (BuildContext context) =>  PlayerEpisode(
//                    id : seasonEpisodeData[i]['video_link']['id'],
//                  ),
//                );
//                Navigator.of(context).push(router);
              }
            } else if (mUrl360 != "null" ||
                mUrl480 != "null" ||
                mUrl720 != "null" ||
                mUrl1080 != "null") {
              _showDialog(i);
            } else {
              if (userPaymentType == "Free") {
                freeTrial(seasonEpisodeData[i]['id'], "JS", title);
              } else {
                getAllScreens(seasonEpisodeData[i]['id'], "JS", title);
              }
//              var router = new MaterialPageRoute(
//                builder: (BuildContext context) => PlayerEpisode(
//                  id : seasonEpisodeData[i]['video_link']['id'],
//                ),
//              );
//              Navigator.of(context).push(router);
            }
          } else {
            Fluttertoast.showToast(msg: "Video URL doesn't exist");
          }
        } else {
          _showMsg();
        }
      },
    );
  }

  //  Generate list of episodes
  Widget episodesList() {
    return Padding(
      padding:
          const EdgeInsets.only(top: 0.0, bottom: 0.0, left: 0.0, right: 0.0),
      child: Column(
        children: List.generate(
            seasonEpisodeData == null ? 0 : seasonEpisodeData.length, (int i) {
          _prepare();
          dTasks = [];
          dItems = [];
          dTasks.add(
            TaskInfo(
                eIndex: i,
                name: "${seasonEpisodeData[i]['title']}",
                ifLink: "${seasonEpisodeData[i]['video_link']['iframeurl']}",
                hdLink: "${seasonEpisodeData[i]['video_link']['ready_url']}",
                link360: "${seasonEpisodeData[i]['video_link']['url_360']}",
                link480: "${seasonEpisodeData[i]['video_link']['url_480']}",
                link720: "${seasonEpisodeData[i]['video_link']['url_720']}",
                link1080: "${seasonEpisodeData[i]['video_link']['url_1080']}"),
          );
          dItems.add(ItemHolder(name: dTasks[0].name, task: dTasks[0]));

          return Container(
            child: Column(
              children: <Widget>[
                new Container(
                  decoration: new BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color.fromRGBO(34, 34, 34, 1.0),
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
                new Row(
                  textDirection: TextDirection.ltr,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: gestureDetector(i),
                    ),
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: 10.0,
                          ),
                          episodeTitle(i),
                          episodeSubtitle(i),
                          episodeDetails(i),
                        ],
                      ),
                    ),
                    DownloadEpisodePage(
                        widget.game,
                        widget.game.seasons[cSeasonIndex].id,
                        seasonEpisodeData[i],
                        dTasks,
                        dItems,
                        TaskInfo(
                            eIndex: i,
                            name: "${seasonEpisodeData[i]['title']}",
                            ifLink:
                                "${seasonEpisodeData[i]['video_link']['iframeurl']}",
                            hdLink:
                                "${seasonEpisodeData[i]['video_link']['ready_url']}",
                            link360:
                                "${seasonEpisodeData[i]['video_link']['url_360']}",
                            link480:
                                "${seasonEpisodeData[i]['video_link']['url_480']}",
                            link720:
                                "${seasonEpisodeData[i]['video_link']['url_720']}",
                            link1080:
                                "${seasonEpisodeData[i]['video_link']['url_1080']}"))
                  ],
                ),
              ],
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomRight,
                stops: [0.1, 0.5, 0.7, 0.9],
                colors: [
                  Color.fromRGBO(72, 163, 198, 0.4).withOpacity(0.0),
                  Color.fromRGBO(72, 163, 198, 0.3).withOpacity(0.1),
                  Color.fromRGBO(72, 163, 198, 0.2).withOpacity(0.2),
                  Color.fromRGBO(72, 163, 198, 0.1).withOpacity(0.3),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

//    This widget show the list of all episodes of particular seasons .

  // ignore: non_constant_identifier_names
  Widget AllEpisodes() {
    if (seasonEpisodeData == null) {
      return Container(
        child: ColorLoader(),
      );
    } else {
      List moreLikeThis = new List<VideoDataModel>.generate(
          newVideosListG == null ? 0 : newVideosListG.length, (int index) {
        var genreIds2Count = newVideosListG[index].genre.length;
        var genreIds2All = newVideosListG[index].genre;
        for (var j = 0; j < genreIds2Count; j++) {
          var genreIds2 = genreIds2All[j];
          var isAv = 0;
          for (var i = 0; i < widget.game.genre.length; i++) {
            var genreIds = widget.game.genre[i].toString();

            if (genreIds2 == genreIds) {
              isAv = 1;
              break;
            }
          }
          if (isAv == 1) {
            if (widget.game.datatype == newVideosListG[index].datatype) {
              if (widget.game.id != newVideosListG[index].id) {
                return newVideosListG[index];
              }
            }
          }
        }
        return null;
      });

      moreLikeThis.removeWhere((item) => item == null);
      return Container(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              tabBar(),
              episodesList(),
              cusAlsoWatchedText(),
              moreLikeThisSeasons(moreLikeThis),
            ],
          ),
        ),
        color: Color.fromRGBO(34, 34, 34, 1.0),
      );
    }
  }

  //  More like this video for seasons
  Widget moreLikeThisSeasons(moreLikeThis) {
    return ListView(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      children: <Widget>[
        Container(
          height: 300.0,
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            scrollDirection: Axis.horizontal,
            children: List<Padding>.generate(
                moreLikeThis == null ? 0 : moreLikeThis.length, (int index) {
              return new Padding(
                padding: EdgeInsets.only(right: 2.5, left: 2.5, bottom: 5.0),
                child: moreLikeThis[index] == null
                    ? Container()
                    : InkWell(
                        child: FadeInImage.assetNetwork(
                          image: moreLikeThis[index].box,
                          placeholder: 'assets/placeholder_box.jpg',
                          height: 150.0,
                          fit: BoxFit.cover,
                        ),
                        onTap: () {
                          var router = new MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  new DetailedViewPage(moreLikeThis[index]));
                          Navigator.of(context).push(router);
                        },
                      ),
              );
            }),
          ),
        )
      ],
    );
  }

  Widget cusAlsoWatchedText() {
    return Container(
      child: new Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 5.0),
        child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              new Text(
                "Customers also watched",
                style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 14.0,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.9,
                    color: Colors.white),
              ),
            ]),
      ),
    );
  }

  void _showMsg() {
    if (userPaypalHistory.length == 0 || userStripeHistory == null) {
      dMsg = "Watch unlimited movies, TV shows and videos in HD or SD quality."
          " You don't have subscribe.";
    } else {
      dMsg = "Watch unlimited movies, TV shows and videos in HD or SD quality."
          " You don't have any active subscription plan.";
    }
    // set up the button
    Widget cancelButton = FlatButton(
      child: Text(
        "Cancel",
        style: TextStyle(color: redPrime, fontSize: 16.0),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    Widget subscribeButton = FlatButton(
      child: Text(
        "Subscribe",
        style: TextStyle(color: redPrime, fontSize: 16.0),
      ),
      onPressed: () {
        Navigator.pop(context);
        var router = new MaterialPageRoute(
            builder: (BuildContext context) => new SubscriptionPlan());
        Navigator.of(context).push(router);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      contentPadding:
          EdgeInsets.only(top: 10.0, left: 16.0, right: 16.0, bottom: 0.0),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Subscribe Plans",
            style: TextStyle(color: Colors.black),
          ),
        ],
      ),
      content: Row(
        children: <Widget>[
          Flexible(
            flex: 1,
            fit: FlexFit.loose,
            child: Text(
              "$dMsg",
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          )
        ],
      ),
      actions: [
        subscribeButton,
        cancelButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  getAllScreens(mVideoUrl, type, title) async {
    var screensRes;
    var resCode;
    final getAllScreensResponse =
        await http.get(Uri.encodeFull(APIData.showScreensApi), headers: {
      // ignore: deprecated_member_use
      HttpHeaders.AUTHORIZATION: nToken == null ? fullData : nToken
    });
    print(getAllScreensResponse.statusCode);
    print(getAllScreensResponse.body);
    resCode = getAllScreensResponse.statusCode;
    screensRes = json.decode(getAllScreensResponse.body);

    setState(() {
      screenUsed1 = screensRes['screen']['screen_1_used'];
      screenUsed2 = screensRes['screen']['screen_2_used'];
      screenUsed3 = screensRes['screen']['screen_3_used'];
      screenUsed4 = screensRes['screen']['screen_4_used'];

      activeScreen = screensRes['screen']['activescreen'];
      screenUsed1 = screensRes['screen']['screen_1_used'];
      screenUsed2 = screensRes['screen']['screen_2_used'];
      screenUsed3 = screensRes['screen']['screen_3_used'];
      screenUsed4 = screensRes['screen']['screen_4_used'];
    });

    if (resCode == 200) {
      if (fileContent["screenCount"] == "1") {
        if (screenUsed1 == "YES") {
          Fluttertoast.showToast(msg: "Profile already in use.");
          return false;
        } else {
          updateScreens(fileContent['screenName'], fileContent['screenCount']);
          if (type == "CUSTOM") {
            var router = new MaterialPageRoute(
                builder: (BuildContext context) => MyCustomPlayer(
                      url: mVideoUrl,
                      title: title,
                    ));
            Navigator.of(context).push(router);
          } else if (type == "EMD") {
            var router = new MaterialPageRoute(
                builder: (BuildContext context) =>
                    IFramePlayerPage(url: mVideoUrl));
            Navigator.of(context).push(router);
          } else if (type == "JS") {
            var router = new MaterialPageRoute(
              builder: (BuildContext context) => PlayerEpisode(
                id: mVideoUrl,
              ),
            );
            Navigator.of(context).push(router);
          }
        }
      } else if (fileContent["screenCount"] == "2") {
        if (screenUsed2 == "YES") {
          Fluttertoast.showToast(msg: "Profile already in use.");
          return false;
        } else {
          updateScreens(fileContent['screenName'], fileContent['screenCount']);
          if (type == "CUSTOM") {
            var router = new MaterialPageRoute(
                builder: (BuildContext context) => MyCustomPlayer(
                      url: mVideoUrl,
                      title: title,
                    ));
            Navigator.of(context).push(router);
          } else if (type == "EMD") {
            var router = new MaterialPageRoute(
                builder: (BuildContext context) =>
                    IFramePlayerPage(url: mVideoUrl));
            Navigator.of(context).push(router);
          } else if (type == "JS") {
            var router = new MaterialPageRoute(
              builder: (BuildContext context) => PlayerEpisode(
                id: mVideoUrl,
              ),
            );
            Navigator.of(context).push(router);
          }
        }
      } else if (fileContent["screenCount"] == "3") {
        if (screenUsed3 == "YES") {
          Fluttertoast.showToast(msg: "Profile already in use.");
          return false;
        } else {
          updateScreens(fileContent['screenName'], fileContent['screenCount']);
          if (type == "CUSTOM") {
            var router = new MaterialPageRoute(
                builder: (BuildContext context) => MyCustomPlayer(
                      url: mVideoUrl,
                      title: title,
                    ));
            Navigator.of(context).push(router);
          } else if (type == "EMD") {
            var router = new MaterialPageRoute(
                builder: (BuildContext context) =>
                    IFramePlayerPage(url: mVideoUrl));
            Navigator.of(context).push(router);
          } else if (type == "JS") {
            var router = new MaterialPageRoute(
              builder: (BuildContext context) => PlayerEpisode(
                id: mVideoUrl,
              ),
            );
            Navigator.of(context).push(router);
          }
        }
      } else if (fileContent["screenCount"] == "4") {
        if (screenUsed4 == "YES") {
          Fluttertoast.showToast(msg: "Profile already in use.");
          return false;
        } else {
          updateScreens(fileContent['screenName'], fileContent['screenCount']);
          if (type == "CUSTOM") {
            var router = new MaterialPageRoute(
                builder: (BuildContext context) => MyCustomPlayer(
                      url: mVideoUrl,
                      title: title,
                    ));
            Navigator.of(context).push(router);
          } else if (type == "EMD") {
            var router = new MaterialPageRoute(
                builder: (BuildContext context) =>
                    IFramePlayerPage(url: mVideoUrl));
            Navigator.of(context).push(router);
          } else if (type == "JS") {
            var router = new MaterialPageRoute(
              builder: (BuildContext context) => PlayerEpisode(
                id: mVideoUrl,
              ),
            );
            Navigator.of(context).push(router);
          }
        }
      }
    }
  }

  freeTrial(videoURL, type, title) {
    if (type == "EMD") {
      var router = new MaterialPageRoute(
          builder: (BuildContext context) => IFramePlayerPage(url: mIFrameUrl));
      Navigator.of(context).push(router);
    } else if (type == "CUSTOM") {
      var router1 = new MaterialPageRoute(
          builder: (BuildContext context) => new MyCustomPlayer(
                url: videoURL,
                title: title,
                downloadStatus: 1,
              ));
      Navigator.of(context).push(router1);
    } else {
      var router = new MaterialPageRoute(
        builder: (BuildContext context) => PlayerEpisode(
          id: videoURL,
        ),
      );
      Navigator.of(context).push(router);
    }
  }

  updateScreens(screen, count) async {
    final updateScreensResponse =
        await http.post(APIData.updateScreensApi, body: {
      "macaddress": '$ip',
      "screen": '$screen',
      "count": '$count',
    }, headers: {
      // ignore: deprecated_member_use
      HttpHeaders.AUTHORIZATION: nToken == null ? fullData : nToken
    });

    print(updateScreensResponse.statusCode);
    print("Update Screen");
    if (updateScreensResponse.statusCode == 200) {
      print(updateScreensResponse.body);
    }
  }

  void _showDialog(i) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            backgroundColor: Color.fromRGBO(250, 250, 250, 1.0),
            title: Text(
              "Video Quality",
              style: TextStyle(
                  color: Color.fromRGBO(72, 163, 198, 1.0),
                  fontWeight: FontWeight.w600,
                  fontSize: 20.0),
              textAlign: TextAlign.center,
            ),
            content: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    "Select Video Format in which you want to play video.",
                    style: TextStyle(
                        color: Colors.black.withOpacity(0.7), fontSize: 12.0),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  seasonEpisodeData[i]['video_link']['url_360'] == null
                      ? SizedBox.shrink()
                      : Padding(
                          padding: EdgeInsets.only(left: 50.0, right: 50.0),
                          child: RaisedButton(
                            hoverColor: Colors.red,
                            splashColor: Color.fromRGBO(49, 131, 41, 1.0),
                            highlightColor: Color.fromRGBO(72, 163, 198, 1.0),
                            color: redPrime,
                            child: Container(
                              alignment: Alignment.center,
                              width: 100.0,
                              height: 30.0,
                              child: Text("360"),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              print(
                                  "season Url: ${seasonEpisodeData[i]['video_link']['url_360']}");
                              var hdUrl =
                                  seasonEpisodeData[i]['video_link']['url_360'];
                              var hdTitle = seasonEpisodeData[i]['title'];
                              if (userPaymentType == "Free") {
                                freeTrial(hdUrl, "CUSTOM", hdTitle);
                              } else {
                                getAllScreens(hdUrl, "CUSTOM", hdTitle);
                              }
                            },
                          ),
                        ),
                  seasonEpisodeData[i]['video_link']['url_480'] == null
                      ? SizedBox.shrink()
                      : Padding(
                          padding: EdgeInsets.only(left: 50.0, right: 50.0),
                          child: RaisedButton(
                            color: redPrime,
                            hoverColor: Colors.red,
                            splashColor: Color.fromRGBO(49, 131, 41, 1.0),
                            highlightColor: Color.fromRGBO(72, 163, 198, 1.0),
                            child: Container(
                              alignment: Alignment.center,
                              width: 100.0,
                              height: 30.0,
                              child: Text("480"),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              print(
                                  "season Url: ${seasonEpisodeData[i]['video_link']['url_480']}");
                              var hdUrl =
                                  seasonEpisodeData[i]['video_link']['url_480'];
                              var hdTitle = seasonEpisodeData[i]['title'];
                              if (userPaymentType == "Free") {
                                freeTrial(hdUrl, "CUSTOM", hdTitle);
                              } else {
                                getAllScreens(hdUrl, "CUSTOM", hdTitle);
                              }
                            },
                          ),
                        ),
                  seasonEpisodeData[i]['video_link']['url_720'] == null
                      ? SizedBox.shrink()
                      : Padding(
                          padding: EdgeInsets.only(left: 50.0, right: 50.0),
                          child: RaisedButton(
                            hoverColor: Colors.red,
                            splashColor: Color.fromRGBO(49, 131, 41, 1.0),
                            highlightColor: Color.fromRGBO(72, 163, 198, 1.0),
                            color: redPrime,
                            child: Container(
                              alignment: Alignment.center,
                              width: 100.0,
                              height: 30.0,
                              child: Text("720"),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              print(
                                  "season Url: ${seasonEpisodeData[i]['video_link']['url_720']}");
                              var hdUrl =
                                  seasonEpisodeData[i]['video_link']['url_720'];
                              var hdTitle = seasonEpisodeData[i]['title'];
                              if (userPaymentType == "Free") {
                                freeTrial(hdUrl, "CUSTOM", hdTitle);
                              } else {
                                getAllScreens(hdUrl, "CUSTOM", hdTitle);
                              }
                            },
                          ),
                        ),
                  seasonEpisodeData[i]['video_link']['url_1080'] == null
                      ? SizedBox.shrink()
                      : Padding(
                          padding: EdgeInsets.only(left: 50.0, right: 50.0),
                          child: RaisedButton(
                            hoverColor: Colors.red,
                            splashColor: Color.fromRGBO(49, 131, 41, 1.0),
                            highlightColor: Color.fromRGBO(72, 163, 198, 1.0),
                            color: redPrime,
                            child: Container(
                              alignment: Alignment.center,
                              width: 100.0,
                              height: 30.0,
                              child: Text("1080"),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              print(
                                  "season Url: ${seasonEpisodeData[i]['video_link']['url_1080']}");
                              var hdUrl = seasonEpisodeData[i]['video_link']
                                  ['url_1080'];
                              var hdTitle = seasonEpisodeData[i]['title'];
                              if (userPaymentType == "Free") {
                                freeTrial(hdUrl, "CUSTOM", hdTitle);
                              } else {
                                getAllScreens(hdUrl, "CUSTOM", hdTitle);
                              }
                            },
                          ),
                        ),
                ],
              ),
            ));
      },
    );
  }

//    This widget show the episodes  and genre details of particular seasons .
  // ignore: non_constant_identifier_names
  Widget MoreDetails() {
    widget.game.genres.removeWhere((value) => value == null);
    String genres = widget.game.genres.toString();
    genres = genres.replaceAll("[", "").replaceAll("]", "");
    return new Container(
      child: new SingleChildScrollView(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            widget.game.datatype == "T"
                ? new TabBar(
                    onTap: (currentIndex2) {
                      setState(() {
                        _currentIndex2 = currentIndex2;
                      });
                    },
                    indicator: UnderlineTabIndicator(
                      borderSide: BorderSide(color: Colors.white70, width: 2.5),
                      insets: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                    ),
                    indicatorColor: Colors.orangeAccent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorWeight: 3.0,
                    unselectedLabelColor: Color.fromRGBO(95, 95, 95, 1.0),
                    tabs: [
                        TabWidget('EPISODES'),
                        TabWidget('MORE DETAILS'),
                      ])
                : SizedBox(
                    width: 0.0,
                  ),
            genreDetailsContainer(widget.game, genres),
//            Container(
//              color: primaryDarkColor,
//              height: 8.0,
//            ),
//            Padding(
//              padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 15.0, bottom: 15.0),
//              child: Column(
//                crossAxisAlignment: CrossAxisAlignment.start,
//                mainAxisAlignment: MainAxisAlignment.start,
//                children: <Widget>[
//                  Row(
//                    crossAxisAlignment: CrossAxisAlignment.center,
//                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                    children: <Widget>[
//                      Text("Comments", textAlign: TextAlign.center,
//                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.0),
//                      ),
//                      ButtonTheme(
//                        minWidth: 60.0,
//                        height: 25.0,
//                        child: RaisedButton(
//                            elevation: 10.0,
//                            color: greenPrime,
//                            padding: EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
//                            child: Text("Add"),
//                            onPressed: (){
//                              addComment(context);
//                            }),
//                      ),
//                    ],
//                  ),
//                  comments(),
//                ],
//              ),
//            )
          ],
        ),
      ),
      color: primaryColor,
    );
  }

  Widget customSliverAppBar(innerBoxIsScrolled) {
    return SliverAppBar(
      elevation: 0.0,
      title: new TabBar(
        onTap: (currentIndex) {
          setState(() {
            _currentIndex = currentIndex;
          });
          setState(() {
            seasonId = widget.game.seasons[currentIndex].id;
          });
          setState(() {
            ser = widget.game.seasons[currentIndex].id;
          });
          getData(currentIndex);
        },
        indicatorSize: TabBarIndicatorSize.tab,
        //    indicatorColor: Color.fromRGBO(125,183,91, 1.0),
        indicator: new BubbleTabIndicator(
          indicatorHeight: 25.0,
          indicatorColor: Color.fromRGBO(125, 183, 91, 1.0),
          tabBarIndicatorSize: TabBarIndicatorSize.tab,
        ),
        controller: _seasonsTabController,
        isScrollable: true,

        tabs: List<Tab>.generate(
          widget.game.seasons == null ? 0 : widget.game.seasons.length,
          (int index) {
            return Tab(
              child: SeasonsTab(widget.game.seasons[index].sSeasonNo),
            );
          },
        ),
      ),
      backgroundColor: Color.fromRGBO(34, 34, 34, 1.0).withOpacity(1.0),
      pinned: false,
      floating: true,
      forceElevated: innerBoxIsScrolled,
      automaticallyImplyLeading: false,
    );
  }
}
