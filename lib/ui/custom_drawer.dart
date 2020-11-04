import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nexthour/ui/login_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:nexthour/apidata/apidata.dart';
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
              ? CachedNetworkImage(
                  imageUrl: "${APIData.profileImageUri}" + "$userImage",
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
              ? CachedNetworkImage(
                  imageUrl: "${APIData.profileImageUri}" + "$userImage",
                  fit: BoxFit.cover,
                )
              : Image.asset(
                  "assets/avatar.png",
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

  Widget profileImage(width) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 0.0),
            child: Container(
              height: 80.0,
              width: 80.0,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(100.0)),
                child: userImage != null
                    ? CachedNetworkImage(
                        imageUrl: "${APIData.profileImageUri}" + "$userImage",
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        "assets/avatar.png",
                        scale: 1.7,
                        fit: BoxFit.cover,
                      ),
              ),
              decoration: BoxDecoration(
                  border: Border.all(width: 0.0),
                  borderRadius: BorderRadius.circular(100.0)),
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: textColor,
                        fontSize: 25.0,
                        fontWeight: FontWeight.w400)),
              ),
              Container(
                width: width * 0.4,
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
                      Icon(Icons.edit, size: 20, color: textColor),
                      SizedBox(
                        width: 10.0,
                      ),
                      Text(
                        "Manage Profile",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: textColor,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

//  Drawer Header
  Widget drawerHeader(width) {
    return Container(
        color: primaryColor,
        width: width,
        height: 100,
        child: DrawerHeader(
          margin: EdgeInsets.fromLTRB(0, 0.0, 0, 0),
          padding: EdgeInsets.all(0.0),
          child: Column(
            children: <Widget>[
              status == "1"
                  ? userPaymentType == "Free"
                      ? profileImage(width)
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
                                              width: 70.0,
                                              child: userImage != null
                                                  ? CachedNetworkImage(
                                                      imageUrl:
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
                                                  ? CachedNetworkImage(
                                                      imageUrl:
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
                  : profileImage(width),
            ],
          ),
          decoration: BoxDecoration(
            color: Colors.transparent,
          ),
        ));
  }

//  Notification
  Widget notification() {
    return ListTile(
      title: Text(
        "Notifications",
        style: TextStyle(
            color: textColor, fontSize: 18.0, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        'Turn on or off notifications.',
        style: TextStyle(
            color: textColor, fontSize: 12.0, fontWeight: FontWeight.w400),
      ),
      trailing: IconButton(
        icon: Icon(Icons.arrow_forward_ios),
        onPressed: () {
          var route =
              MaterialPageRoute(builder: (context) => NotificationsPage());
          Navigator.push(context, route);
        },
      ),
    );
  }

//  My List
  Widget myList() {
    return ListTile(
      title: Text(
        "My List",
        style: TextStyle(
            color: textColor, fontSize: 18.0, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        'Video you wished to watch!',
        style: TextStyle(
            color: textColor, fontSize: 12.0, fontWeight: FontWeight.w400),
      ),
      trailing: IconButton(
        icon: Icon(Icons.arrow_forward_ios),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => BottomNavigationBarController(
                      pageInd: 2,
                    )),
          );
        },
      ),
    );
  }

//  App settings
  Widget appSettings() {
    return ListTile(
      title: Text(
        "App Settings",
        style: TextStyle(
            color: textColor, fontSize: 18.0, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        'Change app behaviour as per your choice.',
        style: TextStyle(
            color: textColor, fontSize: 12.0, fontWeight: FontWeight.w400),
      ),
      trailing: IconButton(
        icon: Icon(Icons.arrow_forward_ios),
        onPressed: () {
          var route =
              MaterialPageRoute(builder: (context) => AppSettingsPage());
          Navigator.push(context, route);
        },
      ),
    );
  }

//  Account
  Widget account() {
    return ListTile(
      title: Text(
        "Account",
        style: TextStyle(
            color: textColor, fontSize: 18.0, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        'Personise your account.',
        style: TextStyle(
            color: textColor, fontSize: 12.0, fontWeight: FontWeight.w400),
      ),
      trailing: IconButton(
        icon: Icon(Icons.arrow_forward_ios),
        onPressed: () {
          _onButtonPressed();
        },
      ),
    );
  }

//  Subscribe
  Widget subscribe() {
    return ListTile(
      title: Text(
        "Subscribe",
        style: TextStyle(
            color: textColor, fontSize: 18.0, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        'Subscribe to videos.',
        style: TextStyle(
            color: textColor, fontSize: 12.0, fontWeight: FontWeight.w400),
      ),
      trailing: IconButton(
        icon: Icon(Icons.arrow_forward_ios),
        onPressed: () {
          _onSubscribe();
        },
      ),
    );
  }

//  Help
  Widget help() {
    return ListTile(
      title: Text(
        "Help!!",
        style: TextStyle(
            color: textColor, fontSize: 18.0, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        'Need help? Connect us.',
        style: TextStyle(
            color: textColor, fontSize: 12.0, fontWeight: FontWeight.w400),
      ),
      trailing: IconButton(
        icon: Icon(Icons.arrow_forward_ios),
        onPressed: () {
          var router = new MaterialPageRoute(
              builder: (BuildContext context) => new HelpPage());
          Navigator.of(context).push(router);
        },
      ),
    );
  }

  // Blog
  Widget blog() {
    return ListTile(
      title: Text(
        "Blogs",
        style: TextStyle(
            color: textColor, fontSize: 18.0, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        'Check our latest blogs.',
        style: TextStyle(
            color: textColor, fontSize: 12.0, fontWeight: FontWeight.w400),
      ),
      trailing: IconButton(
        icon: Icon(Icons.arrow_forward_ios),
        onPressed: () {
          var route = MaterialPageRoute(builder: (context) => BlogPage());
          Navigator.push(context, route);
        },
      ),
    );
  }

  // Donate
  Widget donate() {
    return ListTile(
      title: Text(
        "Donate",
        style: TextStyle(
            color: textColor, fontSize: 18.0, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        'Donate to temples.',
        style: TextStyle(
            color: textColor, fontSize: 12.0, fontWeight: FontWeight.w400),
      ),
      trailing: IconButton(
        icon: Icon(Icons.arrow_forward_ios),
        onPressed: () {
          var route = MaterialPageRoute(builder: (context) => DonationPage());
          Navigator.push(context, route);
        },
      ),
    );
  }

//  Rate Us
  Widget rateUs() {
    return ListTile(
      title: Text(
        "Rate Us.",
        style: TextStyle(
            color: textColor, fontSize: 18.0, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        'Give us your valuable feedback.',
        style: TextStyle(
            color: textColor, fontSize: 12.0, fontWeight: FontWeight.w400),
      ),
      trailing: IconButton(
        icon: Icon(Icons.arrow_forward_ios),
        onPressed: () {
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
      ),
    );
  }

//  Share app
  Widget shareApp() {
    return ListTile(
      title: Text(
        "Share App",
        style: TextStyle(
            color: textColor, fontSize: 18.0, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        'Share app with friends and family.',
        style: TextStyle(
            color: textColor, fontSize: 12.0, fontWeight: FontWeight.w400),
      ),
      trailing: IconButton(
        icon: Icon(Icons.arrow_forward_ios),
        onPressed: () {
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
      ),
    );
  }

//  Sign Out
  Widget signOut() {
    return InkWell(
        child: FlatButton.icon(
      onPressed: () {
        _signOutDialog();
      },
      icon: Icon(
        Icons.logout,
        color: redPrime,
      ),
      label: Text(
        "Logout",
        textAlign: TextAlign.left,
        style: TextStyle(
            color: redPrime, fontSize: 14.0, fontWeight: FontWeight.w600),
      ),
    ));
  }

  // Bottom Sheet after on tapping account
  Widget _buildBottomSheet() {
    return Container(
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(
              'Membership',
              style: TextStyle(
                color: textColor,
              ),
            ),
            onTap: () {
              var router = new MaterialPageRoute(
                  builder: (BuildContext context) => new MembershipPlan());
              Navigator.of(context).push(router);
            },
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 15.0,
              color: primaryDarkColor,
            ),
          ),
          ListTile(
            title: Text(
              'Payment History',
              style: TextStyle(
                color: textColor,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 15.0,
              color: primaryDarkColor,
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
    return SingleChildScrollView(
      child: Container(
        color: primaryColor,
        height: MediaQuery.of(context).size.height * 0.68,
        width: MediaQuery.of(context).size.width,
        child: ListView(
          children: <Widget>[
            notification(),
            Divider(),
            myList(),
            Divider(),
            appSettings(),
            Divider(),
            account(),
            Divider(),
            isAdmin == 1 ? SizedBox.shrink() : subscribe(),
            Divider(),
            help(),
            Divider(),
            blogStatus == 1 ? blog() : SizedBox.shrink(),
            Divider(),
            rateUs(),
            Divider(),
            shareApp(),
            Divider(),
            donationStatus == 1 ? donate() : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

//  Navigation drawer
  Widget drawer(width, height2) {
    return Scaffold(
      appBar: AppBar(
        leading: SizedBox(),
        title: Text('Settings'),
        elevation: 0,
        centerTitle: true,
        actions: [
          Padding(
              padding: EdgeInsets.only(right: 10),
              child: IconButton(
                icon: Icon(Icons.login_outlined),
                onPressed: () {
                  _signOutDialog();
                },
              ))
        ],
      ),
      body: Container(
        color: primaryColor,
        child: ListView(
          children: <Widget>[
            drawerHeader(width),
            drawerBodyContainer(height2),
          ],
        ),
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
    return Container(
      color: primaryColor,
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
            color: Colors.white, //could change this to Color(0xFF737373),
            //so you don't have to change MaterialApp canvasColor
            child: new Container(
                decoration: new BoxDecoration(
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
            backgroundColor: primaryColor,
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
                        style: TextStyle(
                            fontWeight: FontWeight.w600, color: textColor),
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
                      style: TextStyle(color: textColor.withOpacity(0.7)),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      color: Colors.grey,
                      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: textColor),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      deleteFile();
                      var router = new MaterialPageRoute(
                          builder: (BuildContext context) => new LoginPage());
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
                            redPrime.withOpacity(0.9),
                            redPrime.withOpacity(0.8),
                            redPrime.withOpacity(0.7),
                            redPrime.withOpacity(0.6),
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
