import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nexthour/global.dart';
import 'package:nexthour/controller/navigation_bar_controller.dart';
import 'package:nexthour/ui/deatiledViewPage.dart';
import 'package:nexthour/utils/card_seperator.dart';
import 'package:nexthour/utils/ratings.dart';

var found = false;

class SearchResultList extends StatefulWidget {
  SearchResultList({Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return new _SearchResultState();
  }
}

class _SearchResultState extends State<SearchResultList> {
  TextEditingController searchController = new TextEditingController();
  String filter;
  var focusNode = new FocusNode();
  bool descTextShowFlag = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {
        filter = searchController.text;
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<Map> data = [
    {
      "name": "Documentary",
      "Description":
          "Shree Siddhivinayak Temple, dedicated to Lord Ganesha, is an iconic place of worship in Mumbai. The shrine, which is more than 200 years old, is one of the richest temples in India and frequented by celebrities, Bollywood stars, politicians, and commoners alike."
    },
    {
      "name": "God Ganesh",
      "Description":
          "Shree Siddhivinayak Temple, dedicated to Lord Ganesha, is an iconic place of worship in Mumbai. The shrine, which is more than 200 years old, is one of the richest temples in India and frequented by celebrities, Bollywood stars, politicians, and commoners alike."
    },
    {
      "name": "Iskon Temple",
      "Description":
          "Shree Siddhivinayak Temple, dedicated to Lord Ganesha, is an iconic place of worship in Mumbai. The shrine, which is more than 200 years old, is one of the richest temples in India and frequented by celebrities, Bollywood stars, politicians, and commoners alike."
    },
    {
      "name": "Siddhivinayak temple",
      "Description":
          "Shree Siddhivinayak Temple, dedicated to Lord Ganesha, is an iconic place of worship in Mumbai. The shrine, which is more than 200 years old, is one of the richest temples in India and frequented by celebrities, Bollywood stars, politicians, and commoners alike."
    },
  ];

//  App bar
  Widget appBar() {
    return AppBar(
      elevation: 0.0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => BottomNavigationBarController(
                      pageInd: 0,
                    )),
          );
        },
      ),
      title: searchField(),
      backgroundColor: primaryColor,
      actions: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: searchController.text == ''
              ? new IconButton(
                  icon:
                      new Icon(Icons.search, color: textColor.withOpacity(0.3)),
                  onPressed: () {
                    FocusScope.of(context).requestFocus(focusNode);
                  },
                )
              : new IconButton(
                  icon: new Icon(Icons.clear,
                      color: Colors.grey.withOpacity(1.0)),
                  onPressed: () {
                    searchController.clear();
                  },
                ),
        )
      ],
    );
  }

// Search TexField
  Widget searchField() {
    return TextField(
      focusNode: focusNode,
      controller: searchController,
      style: TextStyle(
        fontSize: 18.0,
        color: textColor,
      ),
      decoration: InputDecoration(
        hintStyle: TextStyle(color: Colors.grey),
        hintText: 'Search for a show, movie, etc.',
        border: InputBorder.none,
      ),
    );
  }

// No result found page ui container
  Widget noResultFound() {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 15.0,
      ),
      child: InkWell(
        child: Stack(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.all(10.0),
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "No Result Found.",
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                    new Padding(padding: EdgeInsets.only(top: 10.0)),
                    Text(
                      "We can't find any item matching your search.",
                      style: TextStyle(fontSize: 14.0, color: Colors.white54),
                      textAlign: TextAlign.left,
                    )
                  ],
                )),
          ],
        ),
      ),
    );
  }

// Default search page UI container
  Widget defaultSearchPage() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
      child: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Find what to watch next.",
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Search for shows for the commute, movies to help unwind, or your go-to genres.",
              style: TextStyle(fontSize: 14.0, color: textColor),
              textAlign: TextAlign.left,
            ),
          ),
          Divider(
            height: 30,
            color: redPrime,
            thickness: 2,
            indent: 8.0,
            endIndent: 8.0,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Categories",
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: GridView.builder(
              itemCount: data.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
              ),
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  elevation: 3.0,
                  color: primaryColor,
                  child: Center(
                    child: FlatButton(
                      child: Text(
                        data[index]["name"],
                        style: TextStyle(color: textColor),
                        textAlign: TextAlign.center,
                      ),
                      onPressed: () {},
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

// Default place holder image
  Widget defaultPlaceHolderImage(index) {
    return Container(
      alignment: FractionalOffset.centerLeft,
      child: new Hero(
        tag: "planet-hero-${userWatchListOld[index].name}",
        child: new ClipRRect(
          borderRadius: new BorderRadius.circular(8.0),
          child: new CachedNetworkImage(
            imageUrl: userWatchListOld[index].box,
            height: 140.0,
            width: 110.0,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

// search item column
  Widget searchItemColumn(index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        new Container(height: 4.0),
        new Text(
          userWatchListOld[index].name,
          style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600),
          maxLines: 1,
        ),
        new Container(height: 10.0),
        new Text(
          userWatchListOld[index].description,
          style: TextStyle(color: textColor),
          maxLines: 2,
        ),
        new Separator(),
        new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Expanded(
              flex: 1,
              child: new Container(
                child: new Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      new RatingInformationSearch(userWatchListOld[index])
                    ]),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Widget gridView(genreList) {
  //   return ListView.builder(itemBuilder: ,);
  // }

// List container
  Widget listContainer(index) {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 15.0,
      ),
      child: InkWell(
        child: Stack(
          children: <Widget>[
            new Container(
              child: new Container(
                margin: new EdgeInsets.fromLTRB(76.0, 16.0, 16.0, 16.0),
                constraints: new BoxConstraints.expand(),
                child: searchItemColumn(index),
              ),
              height: 140.0,
              margin: new EdgeInsets.only(left: 46.0),
              decoration: new BoxDecoration(
                color: primaryColor,
                shape: BoxShape.rectangle,
                borderRadius: new BorderRadius.circular(8.0),
                boxShadow: <BoxShadow>[
                  new BoxShadow(
                    color: primaryColor,
                    blurRadius: 10.0,
                    offset: new Offset(0.0, 10.0),
                  ),
                ],
              ),
            ),
            defaultPlaceHolderImage(index),
          ],
        ),
        onTap: () {
          var router = new MaterialPageRoute(
              builder: (BuildContext context) =>
                  new DetailedViewPage(userWatchListOld[index]));
          Navigator.of(context).push(router);
        },
      ),
    );
  }

// Search result item column
  Widget searchResultItemColumn() {
    return Column(
      children: <Widget>[
        new Expanded(
            child: searchController.text == ''
                ? defaultSearchPage()
                : Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: ListView.builder(
                      itemCount: userWatchListOld.length,
                      itemBuilder: (context, index) {
                        return '${userWatchListOld[index].name}'
                                .toLowerCase()
                                .contains(filter.toLowerCase())
                            ? listContainer(index)
                            : Container();
                      },
                    ))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
//    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    if (searchController.text == '' || searchController.text == null) {
      found = true;
    } else {
      for (var i = 0; i < userWatchListOld.length; i++) {
        var watchName = '${userWatchListOld[i].name}';
        var watchListItemName =
            watchName.toLowerCase().contains(filter.toLowerCase());
        if (watchListItemName == true) {
          found = true;
          break;
        } else {
          found = false;
        }
      }
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: appBar(),
      body: found == false ? noResultFound() : searchResultItemColumn(),
      backgroundColor: primaryColor,
    );
  }
}
