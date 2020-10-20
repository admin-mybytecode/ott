import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:nexthour/apidata/apidata.dart';
import 'package:nexthour/global.dart';
import 'package:nexthour/ui/notifications_details.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class NotificationsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return NotificationsState();
  }
}

class NotificationsState extends State<NotificationsPage> {
  // ignore: unused_field
  String _debugLabelString = "";
  // ignore: unused_field
  bool _enableConsentButton = false;
  var notificationsLen;
  var notificationsArray;
  bool _requireConsent = true;
  var refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    this.getAllNotifications();
    super.initState();
    _handleConsent();
    initPlatformState();
  }

  Future<Null> refreshList() async {
    refreshKey.currentState?.show();
    await Future.delayed(Duration(seconds: 2));
    getAllNotifications();
  }

  Future<void> getAllNotifications() async {
    final notificationsResponse =
        await http.get(Uri.encodeFull(APIData.notificationsApi), headers: {
      // ignore: deprecated_member_use
      HttpHeaders.AUTHORIZATION: nToken == null ? fullData : nToken,
      HttpHeaders.contentTypeHeader: "application/json"
    });
    print(notificationsResponse.statusCode);
    var res = json.decode(notificationsResponse.body);
    setState(() {
      notificationsArray = res['notifications'];
    });

    notificationsLen =
        res['notifications'] == null ? 0 : res['notifications'].length;
    return null;
  }

  Future<void> initPlatformState() async {
    if (!mounted) return;
    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

    OneSignal.shared.setRequiresUserPrivacyConsent(_requireConsent);

    var settings = {
      OSiOSSettings.autoPrompt: false,
      OSiOSSettings.promptBeforeOpeningPushUrl: true
    };

    OneSignal.shared
        .setNotificationReceivedHandler((OSNotification notification) {
      this.setState(() {
        _debugLabelString =
            "Received notification: \n${notification.jsonRepresentation().replaceAll("\\n", "\n")}";
      });
    });

    OneSignal.shared
        .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      this.setState(() {
        _debugLabelString =
            "Opened notification: \n${result.notification.jsonRepresentation().replaceAll("\\n", "\n")}";
      });
    });

    OneSignal.shared
        .setInAppMessageClickedHandler((OSInAppMessageAction action) {
      this.setState(() {
        _debugLabelString =
            "In App Message Clicked: \n${action.jsonRepresentation().replaceAll("\\n", "\n")}";
      });
    });

    OneSignal.shared
        .setSubscriptionObserver((OSSubscriptionStateChanges changes) {
      print("SUBSCRIPTION STATE CHANGED: ${changes.jsonRepresentation()}");
    });

    OneSignal.shared.setPermissionObserver((OSPermissionStateChanges changes) {
      print("PERMISSION STATE CHANGED: ${changes.jsonRepresentation()}");
    });

    OneSignal.shared.setEmailSubscriptionObserver(
        (OSEmailSubscriptionStateChanges changes) {
      print("EMAIL SUBSCRIPTION STATE CHANGED ${changes.jsonRepresentation()}");
    });

    await OneSignal.shared.init(APIData.onSignalAppId, iOSSettings: settings);

    OneSignal.shared
        .setInFocusDisplayType(OSNotificationDisplayType.notification);

    bool requiresConsent = await OneSignal.shared.requiresUserPrivacyConsent();

    this.setState(() {
      _enableConsentButton = requiresConsent;
    });
  }

//  Handle notification permission
  void _handleConsent() {
    print("Setting consent to true");
    OneSignal.shared.consentGranted(true);

    print("Setting state");
    this.setState(() {
      _enableConsentButton = false;
    });
  }

//  App bar
  Widget appBar() {
    return AppBar(
      elevation: 0.0,
      title: Text(
        "Notifications",
        style: TextStyle(fontSize: 16.0),
      ),
      centerTitle: true,
      backgroundColor: primaryColor,
    );
  }

  Widget notificationIconContainer() {
    return Container(
      child: Icon(
        Icons.notifications,
        size: 150.0,
        color: Color.fromRGBO(70, 70, 70, 1.0),
      ),
    );
  }

//  Message when any notification is not available
  Widget message() {
    return Padding(
      padding: EdgeInsets.only(left: 50.0, right: 50.0),
      child: Text(
        "You don't have any notification.",
        style: TextStyle(height: 1.5, color: Colors.white70),
      ),
    );
  }

//  When doesn't have any notification.
  Widget blankNotificationContainer() {
    return Container(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          notificationIconContainer(),
          SizedBox(
            height: 25.0,
          ),
          message(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return RefreshIndicator(
        child: Scaffold(
          backgroundColor: primaryColor,
          appBar: appBar(),
          body: notificationsLen == null
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : notificationsLen == 0
                  ? blankNotificationContainer()
                  : ListView.builder(
                      itemCount:
                          notificationsArray == null ? 0 : notificationsLen,
                      itemBuilder: (context, index) {
                        var subtitle =
                            notificationsArray[index]['data']['data'];
                        return Column(
                          children: <Widget>[
                            ListTile(
                              leading: CircleAvatar(
                                radius: 35.0,
                                backgroundColor: redPrime,
                                child: Text(
                                  "${index + 1}",
                                  style: TextStyle(color: textColor),
                                ),
                              ),
                              title:
                                  Text("${notificationsArray[index]['title']}"),
                              subtitle: Text(
                                "$subtitle",
                                style:
                                    TextStyle(fontSize: 12.0, color: textColor),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () {
                                var router = new MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        NotificationsDetailsPage(
                                          title: notificationsArray[index]
                                              ['title'],
                                          data: subtitle,
                                        ));
                                Navigator.of(context).push(router);
                              },
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            Container(
//                      margin: EdgeInsets.only(left: MediaQuery.of(context).size.width / 4.2),
                              color: primaryDarkColor,
                              height: 0.15,
                            ),
                          ],
                        );
                      }),
        ),
        onRefresh: refreshList);
  }
}
