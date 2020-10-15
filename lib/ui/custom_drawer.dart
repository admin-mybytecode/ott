import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:nexthour/apidata/apidata.dart';
import 'package:nexthour/home.dart';
import 'package:nexthour/ui/membership.dart';
import 'package:nexthour/ui/multi_screen_page.dart';
import 'package:nexthour/ui/subscription.dart';
import 'package:nexthour/ui/app_settings.dart';
import 'package:nexthour/global.dart';
import 'package:nexthour/ui/help.dart';
import 'package:nexthour/controller/navigation_bar_controller.dart';
import 'package:nexthour/ui/notifications.dart';
import 'package:nexthour/ui/history_page.dart';
import 'package:nexthour/ui/manage_profile.dart';
import 'package:launch_review/launch_review.dart';
import 'package:share/share.dart';
import 'blog_page.dart';
import 'donation_page.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return CustomDrawerState();
  }
}

class CustomDrawerState extends State<CustomDrawer> {
  String platform;

  void writeToFile(String key, String value) {
    Map<String, String> content = {key: value};
    Map<dynamic, dynamic> jsonFileContent =
        json.decode(jsonFile.readAsStringSync());
    jsonFileContent.addAll(content);
    jsonFile.writeAsStringSync(json.encode(jsonFileContent));
    this.setState(() => fileContent = json.decode(jsonFile.readAsStringSync()));
  }

//  Profile Image
  Widget activeProfileImage(myActScreen) {
    return Column(
      children: <Widget>[
        Container(
          height: 70.0,
          width: MediaQuery.of(context).size.width / 4,
          child: userImage != null
              ? Image.network(
                  "${APIData.profileImageUri}" + "$userImage",
//            scale: 1.7,
                  fit: BoxFit.cover,
                )
              : Image.asset(
                  "assets/avatar.png",
//            scale: 1.7,
                  width: MediaQuery.of(context).size.width / 4.5,
                  fit: BoxFit.cover,
                ),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 1.0)),
        ),
      ],
    );
  }

//    Profile Image

  Widget inactiveProfileImage(inactiveUserName) {
    return Column(
      children: <Widget>[
        Container(
          height: 60.0,
          width: 60.0,
          child: userImage != null
              ? Image.network(
                  "${APIData.profileImageUri}" + "$userImage",
//            scale: 1.7,
                  fit: BoxFit.cover,
                )
              : Image.asset(
                  "assets/avatar.png",
//            scale: 1.5,
                  width: MediaQuery.of(context).size.width / 4.5,
                  fit: BoxFit.cover,
                ),
        ),
        SizedBox(
          height: 10.0,
        ),
        inactiveUserName == null ? userName('N/A') : userName(inactiveUserName),
      ],
    );
  }

// user name
  Widget userName(activeUsername) {
    return Text(activeUsername,
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 14.0,
            fontWeight: FontWeight.w400));
  }

  // Manage Profile
  Widget manageProfile(width) {
    return Container(
        width: width,
        color: primaryDarkColor,
        child: Padding(
            padding: EdgeInsets.only(bottom: 15.0),
            child: InkWell(
              onTap: () {
                var route = MaterialPageRoute(
                    builder: (context) => ManageProfileForm());
                Navigator.push(context, route);
              },
              child: new Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.edit, size: 15, color: Colors.white70),
                  SizedBox(
                    width: 10.0,
                  ),
                  Text(
                    "Manage Profile",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            )));
  }

  Widget profileImage() {
    return Column(
      children: <Widget>[
        Container(
          height: 50.0,
          width: 50.0,
          child: userImage != null
              ? Image.network(
                  "${APIData.profileImageUri}" + "$userImage",
                  scale: 1.7,
                  fit: BoxFit.cover,
                )
              : Image.asset(
                  "assets/avatar.png",
                  scale: 1.7,
                  fit: BoxFit.cover,
                ),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 1.0)),
        ),
        Text(name,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white,
                fontSize: 14.0,
                fontWeight: FontWeight.w400)),
      ],
    );
  }

//  Drawer Header
  Widget drawerHeader(width) {
    return Container(
        width: width,
        child: DrawerHeader(
          margin: EdgeInsets.fromLTRB(0, 0.0, 0, 0),
          padding: EdgeInsets.all(0.0),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 15.0,
              ),
              status == "1"
                  ? userPaymentType == "Free"
                      ? profileImage()
                      : Container(
                          height: 100,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              physics: ClampingScrollPhysics(),
                              itemCount: mScreenCount,
                              itemBuilder: (BuildContext context, int index) {
                                return InkWell(
                                  child: screenList[index] == '$myActiveScreen'
                                      ? Column(
                                          children: <Widget>[
                                            Container(
                                              height: 70.0,
                                              margin:
                                                  EdgeInsets.only(right: 10.0),
                                              width: 70,
                                              child: userImage != null
                                                  ? Image.network(
                                                      "${APIData.profileImageUri}" +
                                                          "$userImage",
                                                      fit: BoxFit.cover,
                                                    )
                                                  : Image.asset(
                                                      "assets/avatar.png",
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              4.5,
                                                      fit: BoxFit.cover,
                                                    ),
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.white,
                                                      width: 1.0)),
                                            ),
                                            SizedBox(
                                              height: 10.0,
                                            ),
                                            screenList[index] == null
                                                ? Text(
                                                    '${screenList[index]}',
                                                    style: TextStyle(
                                                        fontSize: 12.0,
                                                        color: Colors.white
                                                            .withOpacity(0.7)),
                                                  )
                                                : Text(
                                                    screenList[index],
                                                    style: TextStyle(
                                                        fontSize: 12.0,
                                                        color: Colors.white
                                                            .withOpacity(0.7)),
                                                  ),
                                          ],
                                        )
                                      : Column(
                                          children: <Widget>[
                                            Container(
                                              margin:
                                                  EdgeInsets.only(right: 12.0),
                                              height: 60.0,
                                              width: 60.0,
                                              child: userImage != null
                                                  ? Image.network(
                                                      "${APIData.profileImageUri}" +
                                                          "$userImage",
                                                      fit: BoxFit.cover,
                                                    )
                                                  : Image.asset(
                                                      "assets/avatar.png",
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              4.5,
                                                      fit: BoxFit.cover,
                                                    ),
                                            ),
                                            SizedBox(
                                              height: 10.0,
                                            ),
                                            screenList[index] == null
                                                ? userName(
                                                    "${screenList[index]}")
                                                : userName(screenList[index]),
                                          ],
                                        ),
                                  onTap: () {
                                    setState(() {
                                      myActiveScreen = screenList[index];
                                      screenCount = index + 1;
                                    });
                                    writeToFile("screenName", myActiveScreen);
                                    writeToFile("screenStatus", "YES");
                                    writeToFile("screenCount", "${index + 1}");
                                  },
                                );
                              }),
                        )
                  : profileImage(),
              SizedBox(
                height: 15.0,
              ),
              Container(
                  width: width,
                  color: primaryDarkColor,
                  child: Padding(
                      padding: EdgeInsets.only(bottom: 15.0),
                      child: InkWell(
                        onTap: () {
                          var route = MaterialPageRoute(
                              builder: (context) => ManageProfileForm());
                          Navigator.push(context, route);
                        },
                        child: new Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.edit, size: 15, color: Colors.white70),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              "Manage Profile",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      ))),
            ],
          ),
          decoration: BoxDecoration(
            color: primaryDarkColor,
          ),
        ));
  }

//  Notification
  Widget notification() {
    return Container(
      child: InkWell(
          onTap: () {
            var route =
                MaterialPageRoute(builder: (context) => NotificationsPage());
            Navigator.push(context, route);
          },
          child: Padding(
            padding: EdgeInsets.fromLTRB(10.0, 12.0, 10.0, 12.0),
            child: Row(
              children: <Widget>[
                Icon(Icons.notifications, size: 15, color: Colors.white70),
                SizedBox(
                  width: 10.0,
                ),
                Text(
                  "Notifications",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400),
                ),
              ],
            ),
          )),
      decoration: BoxDecoration(
          border: Border(
        bottom: BorderSide(
          color: Color.fromRGBO(20, 20, 20, 1.0),
          width: 3.0,
        ),
      )),
    );
  }

//  My List
  Widget myList() {
    return Container(
      child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BottomNavigationBarController(
                        pageInd: 2,
                      )),
            );
          },
          child: Padding(
            padding: EdgeInsets.fromLTRB(10.0, 12.0, 10.0, 12.0),
            child: Row(
              children: <Widget>[
                Icon(Icons.check, size: 15, color: Colors.white70),
                SizedBox(
                  width: 10.0,
                ),
                Text(
                  "My List",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400),
                ),
              ],
            ),
          )),
      decoration: BoxDecoration(
          border: Border(
        bottom: BorderSide(
          color: Color.fromRGBO(20, 20, 20, 1.0),
          width: 3.0,
        ),
      )),
    );
  }

//  App settings
  Widget appSettings() {
    return InkWell(
        onTap: () {
          var route =
              MaterialPageRoute(builder: (context) => AppSettingsPage());
          Navigator.push(context, route);
        },
        child: Padding(
          padding: EdgeInsets.fromLTRB(10.0, 12.0, 10.0, 12.0),
          child: Row(
            children: <Widget>[
              Text(
                "App Settings",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ));
  }

//  Account
  Widget account() {
    return InkWell(
        onTap: () {
          _onButtonPressed();
        },
        child: Padding(
          padding: EdgeInsets.fromLTRB(10.0, 12.0, 10.0, 12.0),
          child: Row(
            children: <Widget>[
              Text(
                "Account",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ));
  }

//  Subscribe
  Widget subscribe() {
    return InkWell(
        onTap: () {
          _onSubscribe();
        },
        child: Padding(
          padding: EdgeInsets.fromLTRB(10.0, 12.0, 10.0, 12.0),
          child: Row(
            children: <Widget>[
              Text(
                "Subscribe",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ));
  }

//  Help
  Widget help() {
    return InkWell(
        onTap: () {
          var router = new MaterialPageRoute(
              builder: (BuildContext context) => new HelpPage());
          Navigator.of(context).push(router);
        },
        child: Padding(
          padding: EdgeInsets.fromLTRB(10.0, 12.0, 10.0, 12.0),
          child: Row(
            children: <Widget>[
              Text(
                "Help",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ));
  }

  // Blog
  Widget blog() {
    return InkWell(
        onTap: () {
          var route = MaterialPageRoute(builder: (context) => BlogPage());
          Navigator.push(context, route);
        },
        child: Padding(
          padding: EdgeInsets.fromLTRB(10.0, 12.0, 10.0, 12.0),
          child: Row(
            children: <Widget>[
              Text(
                "Blog",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ));
  }

  // Donate
  Widget donate() {
    return InkWell(
        onTap: () {
          var route = MaterialPageRoute(builder: (context) => DonationPage());
          Navigator.push(context, route);
        },
        child: Padding(
          padding: EdgeInsets.fromLTRB(10.0, 12.0, 10.0, 12.0),
          child: Row(
            children: <Widget>[
              Text(
                "Donate",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ));
  }

//  Rate Us
  Widget rateUs() {
    return InkWell(
        onTap: () {
          String os = Platform.operatingSystem; //in your code
          if (os == 'android') {
            if (APIData.androidAppId != '') {
              LaunchReview.launch(
                androidAppId: APIData.androidAppId,
              );
            } else {
              Fluttertoast.showToast(msg: 'PlayStore id not available');
            }
          } else {
            if (APIData.iosAppId != '') {
              LaunchReview.launch(
                  androidAppId: APIData.androidAppId,
                  iOSAppId: APIData.iosAppId);

              LaunchReview.launch(
                  writeReview: false, iOSAppId: APIData.iosAppId);
            } else {
              Fluttertoast.showToast(msg: 'AppStore id not available');
            }
          }
        },
        child: Padding(
          padding: EdgeInsets.fromLTRB(10.0, 12.0, 10.0, 12.0),
          child: Row(
            children: <Widget>[
              Text(
                "Rate Us",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ));
  }

//  Share app
  Widget shareApp() {
    return InkWell(
        onTap: () {
          String os = Platform.operatingSystem; //in your code
          if (os == 'android') {
            if (APIData.androidAppId != '') {
              Share.share(APIData.shareAndroidAppUrl);
            } else {
              Fluttertoast.showToast(msg: 'PlayStore id not available');
            }
          } else {
            if (APIData.iosAppId != '') {
              Share.share(APIData.iosAppId);
            } else {
              Fluttertoast.showToast(msg: 'AppStore id not available');
            }
          }
        },
        child: Padding(
          padding: EdgeInsets.fromLTRB(10.0, 12.0, 10.0, 12.0),
          child: Row(
            children: <Widget>[
              Text(
                "Share app",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ));
  }

//  Sign Out
  Widget signOut() {
    return InkWell(
        onTap: () {
          _signOutDialog();
        },
        child: Padding(
          padding: EdgeInsets.fromLTRB(10.0, 12.0, 10.0, 12.0),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 8,
                child: Text(
                  "Sign Out",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400),
                ),
              ),
              Expanded(
                flex: 1,
                child:
                    Icon(Icons.settings_power, size: 15, color: Colors.white70),
              )
            ],
          ),
        ));
  }

  // Bottom Sheet after on tapping account
  Widget _buildBottomSheet() {
    return Container(
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text('Membership'),
            onTap: () {
              var router = new MaterialPageRoute(
                  builder: (BuildContext context) => new MembershipPlan());
              Navigator.of(context).push(router);
            },
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 15.0,
            ),
          ),
          ListTile(
            title: Text('Payment History'),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 15.0,
            ),
            onTap: () {
              var router = new MaterialPageRoute(
                  builder: (BuildContext context) => new HistoryPage());
              Navigator.of(context).push(router);
            },
          ),
        ],
      ),
      decoration: BoxDecoration(
//        color: Theme.of(context).canvasColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(50.0),
          topRight: const Radius.circular(50.0),
        ),
      ),
    );
  }

//  Drawer body container
  Widget drawerBodyContainer(height2) {
    return Container(
      child: Column(
        children: <Widget>[
          notification(),
          myList(),
          appSettings(),
          account(),
          donationStatus == 1 ? donate() : SizedBox.shrink(),
          blogStatus == 1 ? blog() : SizedBox.shrink(),
          isAdmin == 1 ? SizedBox.shrink() : subscribe(),
          help(),
          rateUs(),
          shareApp(),
          signOut(),
        ],
      ),
      decoration: BoxDecoration(
        color: Color.fromRGBO(34, 34, 34, 1.0),
      ),
    );
  }

//  Navigation drawer
  Widget drawer(width, height2) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                drawerHeader(width),
                drawerBodyContainer(height2),
              ]),
        ],
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      jsonFile = new File(dir.path + "/" + fileName);
      fileExists = jsonFile.existsSync();
      if (fileExists)
        this.setState(
            () => fileContent = json.decode(jsonFile.readAsStringSync()));
    });
  }

  @override
  Widget build(BuildContext context) {
    print("dh:$myActiveScreen");
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double height2 = (height * 76.75) / 100;
    // TODO: implement build
    return SizedBox(
      width: width,
      child: drawer(width, height2),
    );
  }

  void _onSubscribe() {
    var router = new MaterialPageRoute(
        builder: (BuildContext context) => new SubscriptionPlan());
    Navigator.of(context).push(router);
  }

  void _onButtonPressed() {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return new Container(
            height: 150.0,
            color: Colors.transparent, //could change this to Color(0xFF737373),
            //so you don't have to change MaterialApp canvasColor
            child: new Container(
                decoration: new BoxDecoration(
                    color: Color.fromRGBO(34, 34, 34, 1.0),
                    borderRadius: new BorderRadius.only(
                        topLeft: const Radius.circular(10.0),
                        topRight: const Radius.circular(10.0))),
                child: _buildBottomSheet()),
          );
        });
  }

  _signOutDialog() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Color.fromRGBO(34, 34, 34, 1.0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25.0))),
            contentPadding: EdgeInsets.only(top: 10.0),
            content: Container(
              width: 300.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Text(
                        "Sign Out?",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Divider(
                    color: Colors.grey,
                    height: 4.0,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: 30.0, right: 30.0, top: 15.0, bottom: 15.0),
                    child: Text(
                      "Are you sure that you want to logout?",
                      style:
                          TextStyle(color: Color.fromRGBO(155, 155, 155, 1.0)),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      color: Colors.white70,
                      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: Text(
                        "Cancel",
                        style:
                            TextStyle(color: Color.fromRGBO(34, 34, 34, 1.0)),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      deleteFile();
                      var router = new MaterialPageRoute(
                          builder: (BuildContext context) => new Home());
                      Navigator.of(context).push(router);
                    },
                    child: Container(
                      padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(25.0),
                            bottomRight: Radius.circular(25.0)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomRight,
                          stops: [0.1, 0.5, 0.7, 0.9],
                          colors: [
                            Color.fromRGBO(72, 163, 198, 0.4).withOpacity(0.4),
                            Color.fromRGBO(72, 163, 198, 0.3).withOpacity(0.5),
                            Color.fromRGBO(72, 163, 198, 0.2).withOpacity(0.6),
                            Color.fromRGBO(72, 163, 198, 0.1).withOpacity(0.7),
                          ],
                        ),
                      ),
                      child: Text(
                        "Confirm",
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  void deleteFile() {
    File file = new File(dir.path + "/" + fileName);
    file.delete();
    fileExists = false;
  }
}
