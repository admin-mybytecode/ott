import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nexthour/global.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nexthour/apidata/apidata.dart';
import 'package:nexthour/ui/subscription.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nexthour/ui/braintree_payment_page.dart';
import 'package:nexthour/ui/card_details.dart';
import 'package:nexthour/ui/paystack_payment.dart';
import 'package:nexthour/ui/bank_payment.dart';
import 'package:nexthour/ui/razor_payments.dart';
import 'package:nexthour/ui/paytm_payment_page.dart';
import 'package:http/http.dart' as http;

List listPaymentGateways = new List();

class SelectPayment extends StatefulWidget {
  final int indexPer;
  SelectPayment({Key key, this.indexPer}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SelectPaymentState();
  }
}

class SelectPaymentState extends State<SelectPayment>
    with TickerProviderStateMixin, RouteAware {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = new GlobalKey<FormState>();
  ScrollController _scrollViewController;
  TabController _paymentTabController;
  final TextEditingController _coupanController = new TextEditingController();
  var dailyAmount;
  int initialDragTimeStamp;
  int currentDragTimeStamp;
  int timeDelta;
  double initialPositionY;
  double currentPositionY;
  double positionYDelta;
  bool _validate = false;
  bool isDataAvailable = false;
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  String _couponMSG = '';

  // ignore: non_constant_identifier_names
  var validCoupon, percent_off;
  bool isCoupanApplied = true;
  var mFlag = 0;

  Future<String> _applyCoupan() async {
    final applyCoupanResponse = await http.post(
        Uri.encodeFull(
            "https://api.stripe.com/v1/coupons/${_coupanController.text}"),
        headers: {
          // ignore: deprecated_member_use
          HttpHeaders.AUTHORIZATION: "Bearer $stripePass"
        });
    var applyCoupanDetails = json.decode(applyCoupanResponse.body);
    if (applyCoupanResponse.statusCode == 200) {
      validCoupon = applyCoupanDetails['valid'];
      percent_off = applyCoupanDetails['percent_off'];
      Future.delayed(Duration(seconds: 1)).then((_) => Navigator.pop(context));

      if (validCoupon == true) {
        mFlag = 1;
        setState(() {
          _couponMSG = 'Coupan Applied';
          isCoupanApplied = false;
          isDataAvailable = false;
        });
      } else {
        setState(() {
          _couponMSG = 'Coupan has been expired';
          isCoupanApplied = false;
          isDataAvailable = false;
        });
      }
    } else {
      validCoupon = false;
      setState(() {
        _couponMSG = 'Invalid Coupan Code';
        isCoupanApplied = false;
        isDataAvailable = false;
      });
      Future.delayed(Duration(seconds: 1)).then((_) => Navigator.pop(context));
      setState(() {
        isDataAvailable = false;
      });
    }
    return null;
  }

  @override
  void initState() {
    super.initState();

    listPaymentGateways = new List();
    if (stripePayment == 1) {
      listPaymentGateways.add(PaymentGateInfo(title: 'stripe', status: 1));
    }
    if (btreePayment == 1) {
      listPaymentGateways.add(PaymentGateInfo(title: 'btree', status: 1));
    }
    if (paystackPayment == 1) {
      listPaymentGateways.add(PaymentGateInfo(title: 'paystack', status: 1));
    }
    if (bankPayment == 1) {
      listPaymentGateways.add(PaymentGateInfo(title: 'bankPayment', status: 1));
    }
    if (razorPayPaymentStatus == 1) {
      listPaymentGateways
          .add(PaymentGateInfo(title: 'razorPayment', status: 1));
    }
    if (paytmPaymentStatus == 1) {
      listPaymentGateways
          .add(PaymentGateInfo(title: 'paytmPayment', status: 1));
    }

    _paymentTabController = TabController(
        vsync: this,
        length: listPaymentGateways != null ? listPaymentGateways.length : 0,
        initialIndex: 0);
    initializeDateFormatting();
  }

  Future<Null> refreshList() async {
    refreshKey.currentState?.show();
    await Future.delayed(Duration(seconds: 2));
  }

//  Apply coupon forward icon
  Widget applyCouponIcon() {
    return Expanded(
      flex: 1,
      child: Padding(
        padding: EdgeInsets.only(left: 0.0),
        child: Icon(
          Icons.keyboard_arrow_right,
          color: redPrime,
        ),
      ),
    );
  }

//  Gift icon
  Widget giftIcon() {
    return Padding(
      padding: EdgeInsets.only(left: 10.0),
      child: Icon(
        Icons.card_giftcard,
        color: redPrime,
      ),
    );
  }

//  Payment method tas
  Widget paymentMethodTabs() {
    return PreferredSize(
      child: SliverAppBar(
        title: TabBar(
          indicatorSize: TabBarIndicatorSize.tab,
          controller: _paymentTabController,
          isScrollable: true,
          tabs: List<Tab>.generate(
            listPaymentGateways == null ? 0 : listPaymentGateways.length,
            (int index) {
              if (listPaymentGateways[index].appbarTitle == 'stripe') {
                return Tab(
                  child: tabLabelText('Stripe'),
                );
              }
              if (listPaymentGateways[index].appbarTitle == 'btree') {
                return Tab(
                  child: tabLabelText('Braintree'),
                );
              }

              if (listPaymentGateways[index].appbarTitle == 'paystack') {
                return Tab(
                  child: tabLabelText('Paystack'),
                );
              }
              if (listPaymentGateways[index].appbarTitle == 'bankPayment') {
                return Tab(
                  child: tabLabelText('Bank Payment'),
                );
              }
              if (listPaymentGateways[index].appbarTitle == 'razorPayment') {
                return Tab(
                  child: tabLabelText('RazorPay'),
                );
              }
              if (listPaymentGateways[index].appbarTitle == 'paytmPayment') {
                return Tab(
                  child: tabLabelText('Paytm'),
                );
              }
              return null;
            },
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: primaryColor.withOpacity(1.0),
        pinned: true,
        floating: true,
      ),
      preferredSize: Size.fromHeight(0.0),
    );
  }

//  App bar material design
  Widget appbarMaterialDesign() {
    return Material(
      child: Container(
        height: 80.0,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
            stops: [0.1, 0.5, 0.7, 0.9],
            colors: [
              Color.fromRGBO(72, 163, 198, 1.0).withOpacity(0.3),
              Color.fromRGBO(72, 163, 198, 1.0).withOpacity(0.2),
              Color.fromRGBO(72, 163, 198, 1.0).withOpacity(0.1),
              Color.fromRGBO(72, 163, 198, 1.0).withOpacity(0.0),
            ],
          ),
        ),
      ),
    );
  }

//  Select payment text
  Widget selectPaymentText() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 20.0, top: 40.0),
        ),
        Expanded(
          child: Text(
            'Select Payment',
            style: TextStyle(
                color: textColor, fontSize: 18.0, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }

//  Plan name and user name
  Widget planAndUserName(indexPer) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 20.0),
          ),
          Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "${plan_details[indexPer]['name']}",
                    style: TextStyle(
                        color: textColor,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 15.0),
                  ),
                  Text(
                    name,
                    style: TextStyle(
                        color: textColor, fontSize: 12.0, height: 1.3),
                  ),
                ],
              )),
        ],
      ),
    );
  }

//  Minimum duration
  Widget minDuration(indexPer) {
    return Expanded(
        flex: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              'Min duration ' +
                  '${plan_details[indexPer]['interval_count']}' +
                  ' days',
              style: TextStyle(color: textColor, fontSize: 12.0, height: 1.3),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.0),
            ),
            Text(
              new DateFormat.yMMMd().format(new DateTime.now()),
              style: TextStyle(color: textColor, fontSize: 12.0, height: 1.5),
            ),
          ],
        ));
  }

//  After applying coupon
  Widget couponProcessing(afterDiscountAmount, indexPer) {
    return Container(
      margin: EdgeInsets.fromLTRB(20.0, 10.0, 20, 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              discountText(),
              Expanded(
                  flex: 1,
                  child: validCoupon == true
                      ? Text(
                          percent_off.toString() + " %",
                          style: TextStyle(
                              color: Colors.white, fontSize: 12.0, height: 1.3),
                        )
                      : Text(
                          "0 %",
                          style: TextStyle(
                              color: Colors.white, fontSize: 12.0, height: 1.3),
                        )),
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          Row(
            children: <Widget>[
              afterDiscountText(),
              Expanded(
                flex: 1,
                child: validCoupon == true
                    ? Text(
                        afterDiscountAmount.toString() +
                            " ${plan_details[indexPer]['currency']}",
                        style: TextStyle(
                            color: Colors.white, fontSize: 12.0, height: 1.3),
                      )
                    : amountText(indexPer),
              ),
            ],
          )
        ],
      ),
    );
  }

//  Plan amount
  Widget planAmountText(indexPer, dailyAmountAp) {
    return Expanded(
      flex: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            child: Text(
              "${plan_details[indexPer]['amount']}" +
                  " ${plan_details[indexPer]['currency']}".toUpperCase(),
              style: TextStyle(
                  color: textColor,
                  fontSize: 22.0,
                  fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(
            height: 3.0,
          ),
          Container(
            child: Text(
              '( $dailyAmountAp' +
                  ' ${plan_details[indexPer]['currency']} / ${plan_details[indexPer]['interval']} )',
              style: TextStyle(
                  color: textColor,
                  fontSize: 10.0,
                  letterSpacing: 0.8,
                  height: 1.3,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

//  Logo row
  Widget logoRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: 12.0, right: 10.0),
          child: CachedNetworkImage(
            imageUrl: '${APIData.logoImageUri}${loginConfigData['logo']}',
            width: 150,
          ),
        ),
      ],
    );
  }

//  Discount percent
  Widget discountText() {
    return Expanded(
      flex: 5,
      child: Text(
        "Discount",
        style: TextStyle(color: Colors.white, fontSize: 12.0, height: 1.3),
      ),
    );
  }

//  Amount after discount
  Widget afterDiscountText() {
    return Expanded(
      flex: 5,
      child: Text(
        "After Discount Amount:",
        style: TextStyle(color: Colors.white, fontSize: 12.0, height: 1.3),
      ),
    );
  }

//  Amount
  Widget amountText(indexPer) {
    return Text(
      "${plan_details[indexPer]['amount']}" +
          " ${plan_details[indexPer]['currency']}",
      style: TextStyle(color: primaryDarkColor, fontSize: 12.0, height: 1.3),
    );
  }

//  Tab label text
  Widget tabLabelText(label) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(left: 5.0, right: 5.0),
      child: new Text(
        label,
        style: TextStyle(
            fontFamily: 'Lato',
            fontSize: 13.0,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.9,
            color: Colors.white),
      ),
    );
  }

// Swipe down row
  Widget swipeDownRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          height: 100.0,
        ),
        swipeIconContainer(),
        SizedBox(
          width: 10.0,
        ),
        swipeDownText(),
      ],
    );
  }

// Swipe icon container
  Widget swipeIconContainer() {
    return Container(
      height: 25.0,
      width: 25.0,
      decoration: BoxDecoration(
          border:
              Border.all(width: 2.0, color: Color.fromRGBO(125, 183, 91, 1.0)),
          shape: BoxShape.circle,
          color: primaryDarkColor),
      child: Icon(Icons.keyboard_arrow_down,
          size: 21.0, color: Colors.white.withOpacity(0.7)),
    );
  }

//  Swipe down text
  Widget swipeDownText() {
    return Text(
      "Swipe down wallet to pay",
      style: TextStyle(fontSize: 16.0, color: Colors.white.withOpacity(0.7)),
    );
  }

  //  Bank payment wallet
  Widget bankPaymentWallet(indexPer) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: primaryColor,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(padding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0)),
            swipeDownRow(),
            Dismissible(
                direction: DismissDirection.down,
                key: Key("$indexPer"),
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    return false;
                  } else if (direction == DismissDirection.endToStart) {
                    return true;
                  }
                  if (_coupanController.text == '') {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                BankPaymentPage()));
                  } else {
                    Future.delayed(Duration(seconds: 1)).then((_) {
                      Fluttertoast.showToast(
                          msg: "Coupan is only applicable to Stripe");
                    });
                  }
                  return null;
                },
                child: Padding(
                  padding: EdgeInsets.fromLTRB(120.0, 0.0, 100.0, 0.0),
                  child: Image.asset("assets/bankwallets.png"),
                )),
          ],
        ),
      ),
    );
  }

  //  Razorpay payment wallet
  Widget razorPaymentWallet(indexPer) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: primaryColor,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(padding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0)),
            swipeDownRow(),
            Dismissible(
                direction: DismissDirection.down,
                key: Key("$indexPer"),
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    return false;
                  } else if (direction == DismissDirection.endToStart) {
                    return true;
                  }
                  if (_coupanController.text == '') {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                MyRazorPaymentPage(index: indexPer)));
                  } else {
                    Future.delayed(Duration(seconds: 1)).then((_) {
                      Fluttertoast.showToast(
                          msg: "Coupan is only applicable to Stripe");
                    });
                  }
                  return null;
                },
                child: Padding(
                  padding: EdgeInsets.fromLTRB(120.0, 0.0, 100.0, 0.0),
                  child: Image.asset("assets/razorpay.png"),
                )),
          ],
        ),
      ),
    );
  }

  //  Paytm payment wallet
  Widget paytmPaymentWallet(indexPer) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: primaryColor,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(padding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0)),
            swipeDownRow(),
            Dismissible(
                direction: DismissDirection.down,
                key: Key("$indexPer"),
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    return false;
                  } else if (direction == DismissDirection.endToStart) {
                    return true;
                  }
                  if (_coupanController.text == '') {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                PaytmPaymentPage(index: indexPer)));
                  } else {
                    Future.delayed(Duration(seconds: 1)).then((_) {
                      Fluttertoast.showToast(
                          msg: "Coupan is only applicable to Stripe");
                    });
                  }
                  return null;
                },
                child: Padding(
                  padding: EdgeInsets.fromLTRB(120.0, 0.0, 100.0, 0.0),
                  child: Image.asset("assets/paytm.png"),
                )),
          ],
        ),
      ),
    );
  }

//  Paystack payment wallet
  Widget paystackPaymentWallet(indexPer) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: primaryColor,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(padding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0)),
            swipeDownRow(),
            Dismissible(
                direction: DismissDirection.down,
                key: Key("$indexPer"),
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    return false;
                  } else if (direction == DismissDirection.endToStart) {
                    return true;
                  }
                  if (_coupanController.text == '') {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                PayStackPage(index: indexPer)));
                  } else {
                    Future.delayed(Duration(seconds: 1)).then((_) {
                      Fluttertoast.showToast(
                          msg: "Coupan is only applicable to Stripe");
                    });
                  }
                  return null;
                },
                child: Padding(
                  padding: EdgeInsets.fromLTRB(120.0, 0.0, 100.0, 0.0),
                  child: Image.asset("assets/paystackwallets.png"),
                )),
          ],
        ),
      ),
    );
  }

//  Stripe payment wallet
  Widget stripePaymentWallet(indexPer) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: primaryColor,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(padding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0)),
            swipeDownRow(),
            Dismissible(
                direction: DismissDirection.down,
                key: Key('$indexPer'),
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    Fluttertoast.showToast(msg: _couponMSG);
                    return false;
                  } else if (direction == DismissDirection.endToStart) {
                    return true;
                  }

                  if (validCoupon != false || _coupanController.text == '') {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => CardDetails(
                                  index1: indexPer,
                                  coupanCode: _coupanController.text,
                                )));
                  }
                  Future.delayed(Duration(seconds: 1)).then((_) {
                    validCoupon == false
                        ? Fluttertoast.showToast(msg: _couponMSG)
                        : SizedBox.shrink();
                  });
                  return null;
                },
                child: Padding(
                  padding: EdgeInsets.fromLTRB(120.0, 0.0, 100.0, 0.0),
                  child: Image.asset("assets/stripe.png"),
                )),
          ],
        ),
      ),
    );
  }

//  Braintree payment wallet
  Widget braintreePayment(indexPer) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: primaryColor,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(padding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 100.0,
                ),
                Container(
                  height: 25.0,
                  width: 25.0,
                  decoration: BoxDecoration(
                      border: Border.all(
                          width: 2.0, color: Color.fromRGBO(125, 183, 91, 1.0)),
                      shape: BoxShape.circle,
                      color: primaryDarkColor),
                  child: Icon(Icons.keyboard_arrow_down,
                      size: 21.0, color: Colors.white.withOpacity(0.7)),
                ),
                SizedBox(
                  width: 10.0,
                ),
                Text(
                  "Swipe down wallet to pay",
                  style: TextStyle(
                      fontSize: 16.0, color: Colors.white.withOpacity(0.7)),
                ),
              ],
            ),
            Dismissible(
                direction: DismissDirection.down,
                key: Key('$indexPer'),
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    return false;
                  } else if (direction == DismissDirection.endToStart) {
                    return true;
                  }
                  if (_coupanController.text == '') {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                BraintreePaymentPage(index: indexPer)));
                  } else {
                    Future.delayed(Duration(seconds: 1)).then((_) {
                      Fluttertoast.showToast(
                          msg: "Coupan is only applicable to Stripe");
                    });
                  }
                  return null;
                },
                child: Padding(
                  padding: EdgeInsets.fromLTRB(120.0, 0.0, 100.0, 0.0),
                  child: Image.asset("assets/braintreewallet.png"),
                )),
          ],
        ),
      ),
    );
  }

//  Sliver List
  Widget _sliverList(dailyAmountAp, afterDiscountAmount) {
    return SliverList(
        delegate: SliverChildBuilderDelegate((BuildContext context, int j) {
      return new Container(
          color: primaryColor,
          child: Column(children: <Widget>[
            new Container(
              color: primaryColor,
              child: Column(
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      appbarMaterialDesign(),
                      Container(
                        margin: EdgeInsets.only(top: 60.0),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20.0),
                              topRight: Radius.circular(20.0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            AspectRatio(
                              aspectRatio: validCoupon == true
                                  ? 16.0 / 15.0
                                  : 16.0 / 13.0,
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(
                                        0.0, 10.0, 0.0, 0.0),
                                  ),
                                  selectPaymentText(),
                                  planAndUserName(widget.indexPer),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(
                                        0.0, 10.0, 0.0, 0.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.only(left: 20.0),
                                        ),
                                        minDuration(widget.indexPer),
                                        planAmountText(
                                            widget.indexPer, dailyAmountAp),
                                      ],
                                    ),
                                  ),
                                  Padding(padding: EdgeInsets.only(top: 40.0)),
                                  Container(
                                    margin: EdgeInsets.only(
                                        left: 20.0, right: 20.0),
                                    height: 50.0,
                                    width: MediaQuery.of(context).size.width,
                                    child: InkWell(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Expanded(
                                              flex: 5,
                                              child: InkWell(
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    giftIcon(),
                                                    Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 10.0),
                                                        child: isCoupanApplied
                                                            ? Text(
                                                                "Apply Coupon",
                                                                style: TextStyle(
                                                                    color:
                                                                        textColor),
                                                              )
                                                            : Text(
                                                                _coupanController
                                                                    .text,
                                                                textAlign:
                                                                    TextAlign
                                                                        .left,
                                                                style: TextStyle(
                                                                    color:
                                                                        textColor),
                                                              ))
                                                  ],
                                                ),
                                                onTap: _couponDialog,
                                              )),
                                          applyCouponIcon(),
                                        ],
                                      ),
                                      onTap: _couponDialog,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 2.0,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ),
                                  Container(
                                      height: 30.0,
                                      child: isCoupanApplied
                                          ? SizedBox.shrink()
                                          : Padding(
                                              padding:
                                                  EdgeInsets.only(left: 40.0),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: <Widget>[
                                                  validCoupon == true
                                                      ? Icon(
                                                          FontAwesomeIcons
                                                              .solidCheckCircle,
                                                          color: redPrime,
                                                          size: 13.0,
                                                        )
                                                      : Icon(
                                                          FontAwesomeIcons
                                                              .solidTimesCircle,
                                                          color: Colors.red,
                                                          size: 13.0,
                                                        ),
                                                  SizedBox(
                                                    width: 10.0,
                                                  ),
                                                  Text(
                                                    _couponMSG,
                                                    style: TextStyle(
                                                        color:
                                                            validCoupon == true
                                                                ? redPrime
                                                                : Colors.grey,
                                                        fontSize: 12.0,
                                                        letterSpacing: 0.7),
                                                  ),
                                                ],
                                              ),
                                            )),
                                  validCoupon == true
                                      ? couponProcessing(
                                          afterDiscountAmount, widget.indexPer)
                                      : SizedBox.shrink(),
                                ],
                              ),
                            ),
                            Container(
                              height: 2.0,
                              color: primaryColor,
                            ),
                          ],
                        ),
                      ),
                      new Positioned(
                        top: 8.0,
                        left: 4.0,
                        child: new BackButton(color: Colors.white),
                      ),
                      logoRow(),
                    ],
                  ),
                ],
              ),
            ),
          ]));
    },
            addAutomaticKeepAlives: true,
            addRepaintBoundaries: true,
            addSemanticIndexes: true,
            childCount: 1));
  }

//  Scaffold body
  Widget _scaffoldBody(dailyAmountAp, afterDiscountAmount) {
    return NestedScrollView(
      physics: ClampingScrollPhysics(),
      controller: _scrollViewController,
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          _sliverList(dailyAmountAp, afterDiscountAmount),
          paymentMethodTabs(),
        ];
      },
      body: _nestedScrollViewBody(),
    );
  }

//  NestedScrollView body
  Widget _nestedScrollViewBody() {
    return listPaymentGateways.length == 0
        ? Center(
            child: Text(
              "No payment method available",
              style: TextStyle(color: textColor),
            ),
          )
        : TabBarView(
            controller: _paymentTabController,
            physics: PageScrollPhysics(),
            children: List<Widget>.generate(
                listPaymentGateways == null ? 0 : listPaymentGateways.length,
                (int index) {
              if (listPaymentGateways[index].appbarTitle == 'btree') {
                return InkWell(
                  child: braintreePayment(widget.indexPer),
                );
              }
              if (listPaymentGateways[index].appbarTitle == 'stripe') {
                return InkWell(
                  child: stripePaymentWallet(widget.indexPer),
                );
              }
              if (listPaymentGateways[index].appbarTitle == 'paystack') {
                return InkWell(
                  child: paystackPaymentWallet(widget.indexPer),
                );
              }
              if (listPaymentGateways[index].appbarTitle == 'bankPayment') {
                return InkWell(
                  child: bankPaymentWallet(widget.indexPer),
                );
              }
              if (listPaymentGateways[index].appbarTitle == 'razorPayment') {
                return InkWell(
                  child: razorPaymentWallet(widget.indexPer),
                );
              }
              if (listPaymentGateways[index].appbarTitle == 'paytmPayment') {
                return InkWell(
                  child: paytmPaymentWallet(widget.indexPer),
                );
              }
              return null;
            }));
  }

//  Coupon Dialog
  _couponDialog() {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => new GestureDetector(
              child: Container(
                color: Colors.black.withOpacity(0.6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    AlertDialog(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(20.0))),
                      content: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: TextFormField(
                                style: TextStyle(color: textColor),
                                controller: _coupanController,
                                decoration: InputDecoration(
                                  focusColor: textColor,
                                  hintStyle: TextStyle(color: textColor),
                                  hintText: "Enter Coupon Code",
                                  errorText: _validate ? "Enter Coupon" : null,
                                ),
                                validator: (val) {
                                  if (val.length == 0) {
                                    return 'Please Enter Coupon Code';
                                  } else {
                                    return null;
                                  }
                                },
                                onSaved: (val) => _coupanController.text = val,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: isDataAvailable
                                  ? CircularProgressIndicator()
                                  : RaisedButton(
                                      color: redPrime,
                                      child: Text(
                                        "Apply",
                                        style: TextStyle(color: textColor),
                                      ),
                                      onPressed: () {
                                        final form = _formKey.currentState;
                                        form.save();
                                        if (form.validate() == true) {
                                          SystemChannels.textInput
                                              .invokeMethod('TextInput.hide');
                                          _applyCoupan();
                                          isDataAvailable = true;
                                        }
                                      },
                                    ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    FloatingActionButton(
                      backgroundColor: primaryColor,
                      child: Icon(
                        Icons.clear,
                        color: Colors.black87,
                      ),
                      onPressed: () {
                        SystemChannels.textInput.invokeMethod('TextInput.hide');
                        setState(() {
                          isCoupanApplied = true;
                          _couponMSG = '';
                          _coupanController.text = '';
                          validCoupon = '';
                          isDataAvailable = false;
                        });
                        Future.delayed(Duration(seconds: 1))
                            .then((_) => Navigator.pop(context));
                      },
                    )
                  ],
                ),
              ),
            ));
  }

//  Build method
  @override
  Widget build(BuildContext context) {
    var dailyAmount1;
    var intervalCount;
    dynamic planAm = plan_details[widget.indexPer]['amount'];
    switch (planAm.runtimeType) {
      case int:
        dailyAmount1 = planAm;
        break;
      case String:
        dailyAmount1 = double.parse(planAm);
        break;
      case double:
        dailyAmount1 = double.parse(planAm);
        break;
    }
    dynamic interCount = plan_details[widget.indexPer]['interval_count'];
    switch (interCount.runtimeType) {
      case int:
        intervalCount = interCount;
        break;
      case String:
        intervalCount = int.parse(interCount);
        break;
    }
    var dailyAmount = dailyAmount1 / intervalCount;
    String dailyAmountAp = dailyAmount.toStringAsFixed(2);
    var amountOff = validCoupon == true
        ? (percent_off / 100) * plan_details[widget.indexPer]['amount']
        : 0;
    var afterDiscountAmount = validCoupon == true
        ? plan_details[widget.indexPer]['amount'] - amountOff
        : 0;

    return SafeArea(
      child: WillPopScope(
          child: DefaultTabController(
            length: 2,
            child: Scaffold(
              backgroundColor: primaryColor,
              key: _scaffoldKey,
              body: _scaffoldBody(dailyAmountAp, afterDiscountAmount),
            ),
          ),
          onWillPop: () async {
            return true;
          }),
    );
  }
}

class PaymentGateInfo {
  String title;
  int status;

  PaymentGateInfo({this.title, this.status});
}
