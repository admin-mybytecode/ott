import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:intro_slider/dot_animation_enum.dart';
import 'package:nexthour/apidata/apidata.dart';
import 'package:nexthour/global.dart';
import 'package:nexthour/home.dart';

class IntroScreen extends StatefulWidget {
  @override
  IntroScreenState createState() => IntroScreenState();
}

class IntroScreenState extends State<IntroScreen> {
  List<Slide> slides = new List();

  Function goToTab;

  @override
  void initState() {
    super.initState();
    List.generate(homeDataBlocks == null ? 0 : homeDataBlocks.length, (int i) {
      return slides.add(
        new Slide(
          title: "${homeDataBlocks[i]['heading']}",
          styleTitle: TextStyle(
              color: redPrime.withOpacity(0.8),
              fontSize: 25.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'RobotoMono'),
          description: "${homeDataBlocks[i]['detail']}",
          styleDescription: TextStyle(
              color: Colors.grey.withOpacity(0.8),
              fontSize: 16.0,
              fontStyle: FontStyle.normal,
              fontFamily: 'Raleway'),
          pathImage:
              "${APIData.landingPageImageUri}${homeDataBlocks[i]['image']}",
        ),
      );
    });
  }

//  WillPopScope to handle back press.
  Future<bool> onWillPopS() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: "Press again to exit.");
      return Future.value(false);
    }
    return SystemNavigator.pop();
  }

//  After done pressed on intro slider
  void onDonePress() {
    // Back to the first tab
    var router =
        new MaterialPageRoute(builder: (BuildContext context) => new Home());
    Navigator.of(context).push(router);
    //    this.goToTab(0);
  }

//  Counting index and changing UI page dynamically.
  void onTabChangeCompleted(index) {
    // Index of current tab is focused
  }

//  Next button
  Widget renderNextBtn() {
    return Icon(
      Icons.navigate_next,
      color: redPrime.withOpacity(0.7),
      size: 35.0,
    );
  }

//  Done button or last page of intro slider
  Widget renderDoneBtn() {
    return Icon(
      Icons.done,
      color: redPrime.withOpacity(0.7),
      size: 35,
    );
  }

//  Skip button to go directly on last page of intro slider
  Widget renderSkipBtn() {
    return Icon(
      Icons.skip_next,
      color: redPrime.withOpacity(0.7),
      size: 35,
    );
  }

//  Custom tabs
  List<Widget> renderListCustomTabs() {
    List<Widget> tabs = new List();
    for (int i = 0; i < slides.length; i++) {
      Slide currentSlide = slides[i];
      tabs.add(Container(
        width: double.infinity,
        height: double.infinity,
        child: Container(
          child: Stack(
            children: <Widget>[
              Container(
                decoration: new BoxDecoration(
                  color: primaryColor.withOpacity(1.0),
                  borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(0.0),
                      bottomLeft: Radius.circular(0.0)),
                  image: new DecorationImage(
                    fit: BoxFit.cover,
                    colorFilter: new ColorFilter.mode(
                        Colors.black.withOpacity(0.9), BlendMode.dstATop),
                    image: new NetworkImage(currentSlide.pathImage),
                  ),
                ),
              ),
              BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 2,
                  sigmaY: 2,
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Container(
                        child: Text(
                          currentSlide.title,
                          style: currentSlide.styleTitle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(
                        child: Text(
                          currentSlide.description,
                          style: currentSlide.styleDescription,
                          textAlign: TextAlign.center,
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                        ),
                        margin: EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10.0),
                      ),
                    ],
                  ),
                  margin:
                      EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                ),
              ),
            ],
          ),
        ),
      ));
    }
    return tabs;
  }

// Intro slider
  Widget introSlider() {
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: 10,
        sigmaY: 10,
      ),
      child: IntroSlider(
        // List slides
        slides: this.slides,

        // Skip button
        renderSkipBtn: this.renderSkipBtn(),
        //colorSkipBtn: Color(0x33000000),
        highlightColorSkipBtn: Colors.transparent,

        // Next button
        renderNextBtn: this.renderNextBtn(),

        // Done button
        renderDoneBtn: this.renderDoneBtn(),
        onDonePress: this.onDonePress,
        //colorDoneBtn: Color(0x33000000),
        highlightColorDoneBtn: Colors.transparent,

        // Dot indicator
        colorDot: primaryDarkColor.withOpacity(0.5),
        colorActiveDot: redPrime.withOpacity(0.7),
        sizeDot: 8.0,
        typeDotAnimation: dotSliderAnimation.DOT_MOVEMENT,

        // Tabs
        listCustomTabs: this.renderListCustomTabs(),
        backgroundColorAllSlides: primaryColor,
        refFuncGoToTab: (refFunc) {
          this.goToTab = refFunc;
        },

        // Show or hide status bar
        shouldHideStatusBar: true,

        // On tab change completed
        onTabChangeCompleted: this.onTabChangeCompleted,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(child: introSlider(), onWillPop: onWillPopS);
  }
}
