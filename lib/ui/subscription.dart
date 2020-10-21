import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:nexthour/apidata/apidata.dart';
import 'package:nexthour/global.dart';
import 'package:nexthour/utils/color_loader.dart';
import 'package:nexthour/ui/select_payment.dart';

// ignore: non_constant_identifier_names
var plan_details;

class SubscriptionPlan extends StatefulWidget {
  @override
  SubscriptionPlanState createState() => SubscriptionPlanState();
}

class SubscriptionPlanState extends State<SubscriptionPlan> {
//  Getting plan details from server
  Future<String> planDetails() async {
    final basicDetails = await http.get(
      Uri.encodeFull(APIData.homeDataApi),
    );
    var homeDataResponseDetails = json.decode(basicDetails.body);
    print(basicDetails.body);
    setState(() {
      plan_details = homeDataResponseDetails['plans'];
    });
    return null;
  }

  @override
  void initState() {
    super.initState();
    this.planDetails();
  }

//  List used to show all the plans using home API
  List<Widget> _buildCards(int count) {
    List<Widget> cards = List.generate(count, (int index) {
      dynamic planAm = plan_details[index]['amount'];
      switch (planAm.runtimeType) {
        case int:
          {
            dailyAmount = plan_details[index]['amount'] /
                plan_details[index]['interval_count'];
            dailyAmountAp = dailyAmount.toStringAsFixed(2);
          }
          break;
        case String:
          {
            dailyAmount = double.parse(plan_details[index]['amount']) /
                double.parse(plan_details[index]['interval_count']);
            dailyAmountAp = dailyAmount.toStringAsFixed(2);
          }
          break;
        case double:
          {
            dailyAmount = double.parse(plan_details[index]['amount']) /
                double.parse(plan_details[index]['interval_count']);
            dailyAmountAp = dailyAmount.toStringAsFixed(2);
          }
          break;
      }

//      Used to check soft delete status so that only active plan can be showed
      dynamic mPlanStatus = plan_details[index]['status'];
      if (mPlanStatus.runtimeType == int) {
        if (plan_details[index]['status'] == 1) {
          return plan_details[index]['delete_status'] == 0
              ? SizedBox.shrink()
              : Container(
                  margin: EdgeInsets.only(top: 10.0),
                  child: subscriptionCards(index, dailyAmountAp),
                );
        } else {
          return SizedBox.shrink();
        }
      } else {
        if (plan_details[index]['status'] == "1") {
          return plan_details[index]['delete_status'] == "0"
              ? SizedBox.shrink()
              : subscriptionCards(index, dailyAmountAp);
        } else {
          return SizedBox.shrink();
        }
      }
    });

    return cards;
  }
////  List used to show all the plans using home API
//    List<Widget> _buildCards(int count) {
//      List<Widget> cards = List.generate(count, (int index) {
//        var dailyAmount =
//            plan_details[index]['amount'] / plan_details[index]['interval_count'];
//
//        String dailyAmountAp = dailyAmount.toStringAsFixed(2);
//
//  //      Used to check soft delete status so that only active plan can be showed
//        if(plan_details[index]['status'] == 1){
//          return plan_details[index]['delete_status'] == 0  ? SizedBox.shrink() : subscriptionCards(index, dailyAmountAp);
//        }else{
//          return SizedBox.shrink();
//        }
//      });
//      return cards;
//    }

//  App bar
  Widget appBar() => AppBar(
        backgroundColor: primaryColor,
        elevation: 0.0,
        title: Text(
          "Subscription Plans",
          style: TextStyle(fontSize: 16.0, color: textColor),
        ),
        centerTitle: true,
      );

//  Subscribe button
  Widget subscribeButton(index) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Material(
            borderRadius: BorderRadius.circular(25.0),
            child: Container(
              height: 40.0,
              width: 150.0,
              decoration: BoxDecoration(
                borderRadius: new BorderRadius.circular(20.0),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomRight,
                  stops: [0.1, 0.5, 0.7, 0.9],
                  colors: [
                    redPrime.withOpacity(0.4),
                    redPrime.withOpacity(0.5),
                    redPrime.withOpacity(0.6),
                    redPrime.withOpacity(0.7),
                  ],
                ),
              ),
              child: new MaterialButton(
                  height: 50.0,
                  splashColor:
                      primaryColor, //Color.fromRGBO(72, 163, 198, 0.9),
                  child: Text(
                    "Subscribe",
                    style: TextStyle(color: whiteColor),
                  ),
                  onPressed: () {
                    //   Working after clicking on subscribe button
                    var router = new MaterialPageRoute(
                        builder: (BuildContext context) => new SelectPayment(
                              indexPer: index,
                            ));
                    Navigator.of(context).push(router);
                  }),
            ),
          ),
          SizedBox(height: 8.0),
        ],
      ),
    );
  }

//  Amount with currency
  Widget amountCurrencyText(index) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "${plan_details[index]['amount']}",
                style: TextStyle(color: Colors.white, fontSize: 25.0),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                width: 3.0,
              ),
              Text('${plan_details[index]['currency']}'),
            ],
          )),
        ]);
  }

//  Daily amount
  Widget dailyAmountIntervalText(dailyAmountAp, index) {
    return Row(children: <Widget>[
      Expanded(
        child: Padding(
          padding: EdgeInsets.only(left: 100.0),
          child: Text(
            "$dailyAmountAp / ${plan_details[index]['interval']}",
            style: TextStyle(color: Colors.white, fontSize: 8.0),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ]);
  }

//  Plan Name
  Widget planNameText(index) {
    return Container(
      height: 35.0,
      color: primaryDarkColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Text(
              '${plan_details[index]['name']}',
              style: TextStyle(
                color: whiteColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

//  Subscription cards
  Widget subscriptionCards(index, dailyAmountAp) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.grey,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 18.0 / 5.0,
            child: Column(
              children: <Widget>[
                planNameText(index),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                ),
                amountCurrencyText(index),
                dailyAmountIntervalText(dailyAmountAp, index),
              ],
            ),
          ),
          subscribeButton(index),
        ],
      ),
    );
  }

// Scaffold body
  Widget scaffoldBody() {
    return plan_details == null
        ? Container(
            child: ColorLoader(),
          )
        : Container(
            color: primaryColor,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: plan_details.length == 0
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      noPlanIcon(),
                      SizedBox(
                        height: 25.0,
                      ),
                      noPlanContainer(),
                    ],
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: _buildCards(plan_details.length),
                    ),
                  ));
  }

  //  Empty watchlist container message
  Widget noPlanContainer() {
    return Padding(
      padding: EdgeInsets.only(left: 50.0, right: 50.0),
      child: Text(
        "No subscription plans available.",
        style: TextStyle(height: 1.5, color: Colors.grey),
        textAlign: TextAlign.center,
      ),
    );
  }

//  Empty watchlist icon
  Widget noPlanIcon() {
    return Image.asset(
      "assets/no_plan.png",
      height: 140,
      width: 160,
    );
  }

//  Empty plan column
  Widget noPlanColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        noPlanIcon(),
        SizedBox(
          height: 25.0,
        ),
        noPlanContainer(),
      ],
    );
  }

//  Build Method
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SafeArea(
      child: Scaffold(
        appBar: appBar(),
        body: scaffoldBody(),
      ),
    );
  }
}
