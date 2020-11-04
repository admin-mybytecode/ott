import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nexthour/apidata/apidata.dart';
import 'package:nexthour/global.dart';
import 'package:http/http.dart' as http;
import 'package:nexthour/loading/loading_screen.dart';

var userStatus;

class MembershipPlan extends StatefulWidget {
  final int status;
  MembershipPlan({Key key, this.status}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MembershipPlanState();
  }
}

class MembershipPlanState extends State<MembershipPlan> {
  var val;

//  Handle when user click on status button and send status to server if user is subscribed.
  Future<String> stripeUpdateDetails() async {
    final response1 = await http.get(
        Uri.encodeFull(
            APIData.stripeUpdateApi + '$userActivePlan' + '/' + '$val'),
        headers: {
          // ignore: deprecated_member_use
          HttpHeaders.AUTHORIZATION: nToken == null ? fullData : nToken
        });

    var bodyData = json.decode(response1.body);
    print("Stripe Update Responce: " + '$bodyData');
    print(response1.statusCode);

//     This will redirect you to LoadingScreen and update the user status
    if (response1.statusCode == 200) {
      var router = new MaterialPageRoute(
          builder: (BuildContext context) => LoadingScreen());
      Navigator.of(context).push(router);
    }
    return null;
  }

//  Handle when user click on status button and send status to server if user is subscribed.
  Future<String> paypalUpdateDetails() async {
    final paypalUpdateResponse = await http.get(
        Uri.encodeFull(
            APIData.paypalUpdateApi + '$userPaypalPayId' + '/' + '$val'),
        headers: {
          // ignore: deprecated_member_use
          HttpHeaders.AUTHORIZATION: nToken == null ? fullData : nToken
        });
//     This will redirect you to LoadingScreen and update the user status
    if (paypalUpdateResponse.statusCode == 200) {
      var router = new MaterialPageRoute(
          builder: (BuildContext context) => LoadingScreen());
      Navigator.of(context).push(router);
    }
    return null;
  }

//  App bar
  Widget appBar() {
    return AppBar(
      elevation: 0.0,
      title: Text(
        "Membership Plan",
        style: TextStyle(fontSize: 16.0),
      ),
      centerTitle: true,
      backgroundColor: primaryColor,
    );
  }

//  Active plan status row with name
  Widget planStatusRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
//     When current plan is active it shows plan name
        Text("Active Plans : ",
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400)),
        Text(
          userActivePlan == null
              ? userPaymentType == "Free"
                  ? "Free Trial"
                  : 'N/A'
              : '$userActivePlan',
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }

//  Plan expiry date row
  Widget planExpiryDateRow() {
    var date = userExpiryDate;
    String yy = '';
    if (date == null || status != "1") {
      yy = 'N/A';
    } else {
      yy = date.substring(8, 10) +
          "/" +
          date.substring(5, 7) +
          "/" +
          date.substring(0, 4);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          "Plan will expired on : ",
          style: TextStyle(fontSize: 14.0),
        ),
        Text(
          yy,
          style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }

//  Column that contains rows and status button.
  Widget uiColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        planStatusRow(),
        Padding(padding: EdgeInsets.fromLTRB(15.0, 10.0, 16.0, 0.0)),
        planExpiryDateRow(),
        statusButton(),
      ],
    );
  }

//  Scaffold body containing overall UI of this page
  Widget scaffoldBody() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.0, 150.0, 0.0, 20.0),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: primaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          planStatusRow(),
          Padding(padding: EdgeInsets.fromLTRB(15.0, 10.0, 16.0, 0.0)),
          planExpiryDateRow(),
          statusButton(),
        ],
      ),
    );
  }

//  Status button that handle user active status and stop or resume.
  Widget statusButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(15.0, 50.0, 16.0, 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Material(
            child: Container(
              height: 50.0,
              width: 200.0,
              decoration: BoxDecoration(
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

//    This will change the user status after tapping on button and it will also change button
              child: status == "1"
                  ? new MaterialButton(
                      splashColor: redPrime,
                      child: Text(
                        "Stop Subscription",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: _onTap,
                    )
                  : userActivePlan != null
                      ? new MaterialButton(
                          splashColor: redPrime,
                          child: Text(
                            "Resume Subscription",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: _onTap,
                        )
                      : new MaterialButton(
                          splashColor: redPrime,
                          child: Text(
                            "Resume Subscription",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            Fluttertoast.showToast(
                                msg: "You are not Subscribed.");
                          },
                        ),
            ),
          ),
          SizedBox(height: 8.0),
        ],
      ),
    );
  }

  void _onTap() {
    if (userPaymentType == 'stripe') {
      stripeUpdateDetails();
    } else if (userPaymentType == 'paypal') {
      paypalUpdateDetails();
    } else {
      return;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userStatus = widget.status;
  }

  @override
  Widget build(BuildContext context) {
    if (status == "1") {
      val = 0;
    } else {
      val = 1;
    }
    return Scaffold(
      appBar: appBar(),
      body: scaffoldBody(),
    );
  }
}
