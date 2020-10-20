import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nexthour/global.dart';
import 'package:nexthour/model/video_data.dart';
import 'package:nexthour/controller/navigation_bar_controller.dart';
import 'package:nexthour/ui/ItemList.dart';
import 'package:nexthour/widget/blank_watchlist_container.dart';

//    This page shows the user watchlist
var listSize;

class MyListPage extends StatefulWidget {
  final int index;
  const MyListPage({Key key, this.index}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MyListPageState();
  }
}

class MyListPageState extends State<MyListPage> {
  List<VideoDataModel> itemList;
  var index1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this._itemList();
  }

//  Nested scroll view body that shows watchlist page
  Widget _listView() {
    return Container(
      color: primaryColor,
      child: ListView(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        physics: ClampingScrollPhysics(),
        padding: EdgeInsets.all(4.0),
        children: itemList
            .map(
              // ignore: non_constant_identifier_names
              (Video) => ItemList(
                item: Video,
//              index: index1,
              ),
            )
            .toList(),
      ),
    );
  }

//  App bar title
  Widget appBarTitle() {
    return Text(
      "My List",
      style: TextStyle(fontSize: 16.0),
    );
  }

//  Flexible space bar
  Widget flexibleSpaceBar() {
    return new FlexibleSpaceBar(
        background: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        removeWatchHeaderContainer(),
      ],
    ));
  }

//  Message on the the top of page to remove item
  Widget removeWatchHeaderContainer() {
    return Container(
        margin: EdgeInsets.fromLTRB(0.0, 60.0, 0.0, 10.0),
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  FontAwesomeIcons.longArrowAltLeft,
                  color: textColor.withOpacity(0.5),
                  size: 20,
                ),
                SizedBox(
                  width: 10.0,
                ),
                Text(
                  "Swipe right or left to remove from wishlist",
                  style: TextStyle(
                      letterSpacing: 0.7, color: textColor.withOpacity(0.5)),
                ),
                SizedBox(
                  width: 10.0,
                ),
                Icon(
                  FontAwesomeIcons.longArrowAltRight,
                  color: textColor.withOpacity(0.5),
                  size: 20,
                ),
              ],
            ),
            SizedBox(
              height: 10.0,
            ),
          ],
        ));
  }

//  Sliver app bar
  Widget sliverAppBar() {
    return SliverAppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => BottomNavigationBarController()),
          );
        },
      ),
      title: appBarTitle(),
      centerTitle: true,
      flexibleSpace: flexibleSpaceBar(),
      pinned: true,
      floating: true,
      expandedHeight: 120,
      backgroundColor: primaryColor,
    );
  }

//  Scaffold body
  Widget _nestedScrollView() {
    return NestedScrollView(
      //        controller: _scrollViewController,
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          sliverAppBar(),
        ];
      },
      body: _listView(),
    );
  }

  @override
  Widget build(BuildContext context) {
//    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    itemList = _itemList();
    itemList.removeWhere((value) => value == null);
    return SafeArea(
      child: Scaffold(
          body: userWatchList.length == 0
              ? WatchlistContainer()
              : _nestedScrollView()),
    );
  }

  List<VideoDataModel> _itemList() {
    return List<VideoDataModel>.generate(
        userWatchListOld == null ? 0 : userWatchListOld.length, (int index) {
      if (userWatchListOld[index].datatype == "T") {
        var s = userWatchListOld[index].seasons;
        String genres = userWatchListOld[index].genres.toString();
        genres = genres.replaceAll("[", "").replaceAll("]", "");
        userWatchListOld[index].genres.removeWhere((value) => value == null);
        for (var k = 0; k < s.length; k++) {
          for (var i = 0; i < userWatchList.length; i++) {
            if (s[k].id == userWatchList[i].season_id) {
              return VideoDataModel(
                id: userWatchListOld[index].id,
                name: userWatchListOld[index].name,
                box: userWatchListOld[index].box,
                cover: userWatchListOld[index].cover,
                description: userWatchListOld[index].description,
                datatype: userWatchListOld[index].datatype,
                rating: userWatchListOld[index].rating,
                screenshots: userWatchListOld[index].screenshots,
                url: userWatchListOld[index].url,
                iFrameLink: userWatchListOld[index].iFrameLink,
                readyUrl: userWatchListOld[index].readyUrl,
                url360: userWatchListOld[index].url360,
                url480: userWatchListOld[index].url480,
                url720: userWatchListOld[index].url720,
                url1080: userWatchListOld[index].url1080,
                menuId: userWatchListOld[index].menuId,
                genre: userWatchListOld[index].genre,
                genres: userWatchListOld[index].genres,
                seasons: userWatchListOld[index].seasons,
                maturityRating: userWatchListOld[index].maturityRating,
                duration: userWatchListOld[index].duration,
                released: userWatchListOld[index].released,
              );
            }
          }
        }
      } else {
        String genres = userWatchListOld[index].genres.toString();
        genres = genres.replaceAll("[", "").replaceAll("]", "");
        userWatchListOld[index].genres.removeWhere((value) => value == null);
        for (var i = 0; i < userWatchList.length; i++) {
          if (userWatchListOld[index].id == userWatchList[i].wMovieId) {
            return new VideoDataModel(
              id: userWatchListOld[index].id,
              name: userWatchListOld[index].name,
              box: userWatchListOld[index].box,
              cover: userWatchListOld[index].cover,
              description: userWatchListOld[index].description,
              datatype: userWatchListOld[index].datatype,
              rating: userWatchListOld[index].rating,
              screenshots: userWatchListOld[index].screenshots,
              url: userWatchListOld[index].url,
              iFrameLink: userWatchListOld[index].iFrameLink,
              readyUrl: userWatchListOld[index].readyUrl,
              url360: userWatchListOld[index].url360,
              url480: userWatchListOld[index].url480,
              url720: userWatchListOld[index].url720,
              url1080: userWatchListOld[index].url1080,
              menuId: userWatchListOld[index].menuId,
              genre: userWatchListOld[index].genre,
              genres: userWatchListOld[index].genres,
              seasons: userWatchListOld[index].seasons,
              maturityRating: userWatchListOld[index].maturityRating,
              duration: userWatchListOld[index].duration,
              released: userWatchListOld[index].released,
            );
          }
        }
      }
      return null;
    });
  }
}
