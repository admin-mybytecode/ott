import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nexthour/global.dart';
import 'package:nexthour/ui/music_player.dart';
import 'package:nexthour/ui/page_video.dart';
import 'package:nexthour/ui/search.dart';
import 'apidata/apidata.dart';

DateTime currentBackPressTime;

class PageHome extends StatefulWidget {
  PageHome({
    Key key,
  }) : super(key: key);

  @override
  _PageHomeState createState() => new _PageHomeState();
}

class _PageHomeState extends State<PageHome>
    with SingleTickerProviderStateMixin, RouteAware {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ScrollController _scrollViewController;
  TabController _tabController;
  List<Widget> containers =
      List<Widget>.generate(menuList == null ? 0 : menuList, (int index) {
    menuId = topMenuData[index]['id'];
    menuDataListLength = 0;
    return new VideosPage(
      mId: menuId,
    );
  });

//  Handle back press
  Future<bool> onWillPopS() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: "Press again to exit.");
      return Future.value(false);
    }
    audioPlayer.stop();
    return SystemNavigator.pop();
  }

//  init state
  @override
  void initState() {
    super.initState();
    _scrollViewController = new ScrollController();
    _tabController = TabController(
        vsync: this, length: menuList == null ? 0 : menuList, initialIndex: 0);
  }

  @override
  void dispose() {
    _scrollViewController.dispose();
    _tabController.dispose();
    super.dispose();
  }

//  Setting logo image
  Widget logoImage() {
    return CachedNetworkImage(
      imageUrl: '${APIData.logoImageUri}${loginConfigData['logo']}',
      width: 160,
    );
  }

//  Scaffold body when menu length is 0.
  Widget scaffoldBodyMenuNull() {
    return WillPopScope(
      child: Text("No data Available"),
      onWillPop: () async {
        return false;
      },
    );
  }

//  Sliver app bar
  Widget _sliverAppBar(innerBoxIsScrolled) {
    return SliverAppBar(
        actions: [
          IconButton(
            icon: Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: Icon(Icons.search),
            ),
            onPressed: () {
              var router = new MaterialPageRoute(
                  builder: (BuildContext context) => SearchResultList());
              Navigator.of(context).push(router);
            },
          ),
        ],
        elevation: 10.0,
        title: Image.asset(
          'assets/logo.png',
          height: 100,
          width: 100,
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        pinned: true,
        floating: true,
        forceElevated: innerBoxIsScrolled,
        automaticallyImplyLeading: false,

//   Tabs used on home page
        bottom: TabBar(
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorColor: redPrime,
          controller: _tabController,
          isScrollable: true,
          tabs: List<Tab>.generate(
            menuList == null ? 0 : menuList,
            (int index) {
              return Tab(
                child: new Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(left: 5.0, right: 5.0),
                  child: new Text(
                    '${topMenuData[index]['name']}',
                    style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 13.0,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.9,
                        color: redPrime),
                  ),
                ),
              );
            },
          ),
        ));
  }

//  Scaffold body
  Widget _scaffoldBody() {
    return NestedScrollView(
      controller: _scrollViewController,
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          _sliverAppBar(innerBoxIsScrolled),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: containers,
      ),
    );
  }

//  When menu length is 0.
  Widget safeAreaMenuNull() {
    return SafeArea(
      child: Scaffold(body: scaffoldBodyMenuNull()),
    );
  }

//  When menu length is not 0
  Widget safeArea() {
    return SafeArea(
      child: WillPopScope(
          child: DefaultTabController(
              length: menuList == null ? 0 : menuList,
              child: Scaffold(
                key: _scaffoldKey,
                body: _scaffoldBody(),
              )),
          onWillPop: onWillPopS),
    );
  }

// Build method
  @override
  Widget build(BuildContext context) {
    return menuList == null ? safeAreaMenuNull() : safeArea();
  }
}
