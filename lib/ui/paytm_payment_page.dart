import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:nexthour/apidata/apidata.dart';
import 'package:nexthour/global.dart';
import 'package:nexthour/loading/loading_screen.dart';
import 'package:nexthour/ui/subscription.dart';
import 'package:nexthour/widget/success_ticket.dart';
//import 'package:paytm/paytm.dart';

class PaytmPaymentPage extends StatefulWidget {
  final index;
  PaytmPaymentPage({Key key, this.index}) : super(key: key);

  @override
  _PaytmPaymentPageState createState() => _PaytmPaymentPageState();
}

class _PaytmPaymentPageState extends State<PaytmPaymentPage> {
  String paymentResponse = '';
  bool isBack = false;
  bool isShowing = false;
  var razorResponse;
  var msgResponse;
  var razorSubscriptionResponse;
  String createdDatePaystack ='';
  String createdTimePaystack = '';
  var ind;

  Widget appBar(){
    return AppBar(
      title: Text("Paytm Payment", style: TextStyle(fontSize: 16.0),),
      centerTitle: true,
      backgroundColor: primaryDarkColor.withOpacity(0.98),
    );
  }

  Widget makeListTile1(){
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      leading: Container(
        padding: EdgeInsets.only(right: 20.0),
        decoration: new BoxDecoration(
            border: new Border(
                right: new BorderSide(width: 1.0, color: Colors.white24))),
        child: Icon(FontAwesomeIcons.sortAmountDownAlt, color: Colors.white, size: 20.0,),
      ),
      title: Padding(padding: EdgeInsets.only(top: 10.0),
        child: Text(
          '${plan_details[widget.index]['name']}',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.0),
        ),),
      subtitle:
      Container(
        height: 40.0,
        child:  Column(
          children: <Widget>[
            SizedBox(
              height: 8.0,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Text('Min duration '+ '${plan_details[widget.index]['interval_count']}'+' days', style: TextStyle(color: Colors.white, fontSize: 12.0)),
                ),
              ],
            ),
          ],
        ),
      ),
      trailing:
      Column(
          children:<Widget>[
            Text("Amount: "+'\n' +
                '${plan_details[widget.index]['amount']} ' + '${plan_details[widget.index]['currency']}'),
          ]
      ),
    );
  }

  Widget razorLogoContainer(){
    return Container(
      decoration: BoxDecoration(
          color: primaryDarkColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(10.0)
      ),

      child: ListView(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        physics: ClampingScrollPhysics(),
        children: <Widget>[
          Padding(padding: EdgeInsets.all(50.0),
            child: Image.asset("assets/paytmlogo.png", scale: 1.0, width: 150.0,),
          )
        ],
      ),
    );
  }

  Widget paymentDetailsCard(){
    return Card(
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Container(
        decoration: BoxDecoration(
            color: primaryDarkColor.withOpacity(0.9),
            borderRadius: BorderRadius.circular(10.0)
        ),
        child: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          physics: ClampingScrollPhysics(),
          children: <Widget>[
            makeListTile1()
          ],
        ),
      ),
    );
  }

  Widget _body(){
    return Container(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 20.0,
          ),
          Card(
            elevation: 8.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
            child: razorLogoContainer(),
          ),

          SizedBox(
            height: 30.0,
          ),
          paymentDetailsCard(),

          SizedBox(
            height: 20.0,
          ),
          Padding(padding: EdgeInsets.only(left: 15.0, right: 15.0),
            child: payButtonRow(),
          )
        ],
      ),
    );
  }

  Widget payButtonRow(){
    return Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            onPressed: (){
              if(paytmKey == null){
                Fluttertoast.showToast(msg: "Paytm key not entered.");
                return;
              }else{
                generateCheckSum();
              }
            },
            color: Color.fromRGBO(72, 163, 198, 1.0),
            child: Text(
              "Continue Pay",
              style: TextStyle(color: Colors.white),
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    ind=widget.index;
    return Scaffold(
      appBar: appBar(),
      body: _body(),
    );
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      isBack = true;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }


  goToDialog2() {
    if(isShowing == true) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              WillPopScope(
                  child: AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0))),
                    backgroundColor: Colors.white,
                    title: Text("Saving Payment Info", style: TextStyle(color: primaryColor),),
                    content: Container(
                      height: 70.0,
                      width: 150.0,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ), onWillPop: () async => isBack)
      );
    }else{
      Navigator.pop(context);
    }
  }

  void generateCheckSum() async {
    var url = 'https://us-central1-mrdishant-4819c.cloudfunctions.net/generateCheckSum';

    String orderId = DateTime.now().millisecondsSinceEpoch.toString();

    //Please use your parameters here
    //CHANNEL_ID etc provided to you by paytm

    final response = await http.post(url, headers: {
      "Content-Type": "application/x-www-form-urlencoded"
    }, body: {
      "mid": "ParloS79006455919746",
      "CHANNEL_ID": "WAP",
      'INDUSTRY_TYPE_ID': 'Retail',
      'WEBSITE': 'APPSTAGING',
      'PAYTM_MERCHANT_KEY': '380W#7mf&_SpEgsy',
      'TXN_AMOUNT': '10',
      'ORDER_ID': orderId,
      'CUST_ID': '122',
      'testing': '0'
    });

    //for Testing(Stagging) use this

    //https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=

    //https://securegw.paytm.in/theia/paytmCallback?ORDER_ID=

    String callBackUrl =
        'https://securegw.paytm.in/theia/paytmCallback?ORDER_ID='+orderId;

    print("Response :" + response.body);

    //Parameters are like as per given below

    // Testing (Staging or Production) if true then Stagginh else Production
    // MID provided by paytm
    // ORDERID your system generated order id
    // CUSTOMER ID
    // CHANNEL_ID provided by paytm
    // AMOUNT
    // WEBSITE provided by paytm
    // CallbackURL (As used above)
    // INDUSTRY_TYPE_ID provided by paytm
    // checksum generated now
    //Testing Credentials
    //Mobile number: 7777777777
    //OTP: 489871

//    var paytmResponse = Paytm.startPaytmPayment(
//      true,
//      "ParloS79006455919746",
//      orderId,
//      "122",
//      "WAP",
//      "10",
//      'APPSTAGING',
//      callBackUrl,
//      'Retail',
//      response.body,
//    );
//
//    paytmResponse.then((value) {
//      setState(() {
//        paymentResponse = value.toString();
//      });
//    });
//
//    paytmResponse.then((value) {
//      setState(() {
//        paymentResponse = value.toString();
//        debugPrint("Res: $paymentResponse");
//        if(value['RESPCODE'] == "01"){
//          setState(() {
//            isShowing = true;
//            isBack = false;
//          });
//        sendPaymentDetails(value['ORDERID']);
//        }else{
//          Fluttertoast.showToast(msg: "Payment Failed contact to support");
//        }
//      });
//    });
  }



  goToDialog(subdate, time) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) =>
        new GestureDetector(
          child: Container(
            color: Colors.white.withOpacity(0.05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SuccessTicket(msgResponse, subdate, name, time, ind),
                SizedBox(
                  height: 10.0,
                ),
                FloatingActionButton(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.clear,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => LoadingScreen()));
                  },
                )
              ],
            ),
          ),
        )
    );
  }

  Future <String> sendPaymentDetails(payId) async{
    goToDialog2();
    var am= plan_details[widget.index]['amount'];
    var plan1= plan_details[widget.index]['id'];

    final sendResponse = await http.post(APIData.sendRazorDetails, body: {
      "reference": "$payId",
      "amount": "$am",
      "plan_id": "$plan1",
      "status": "1",
      "method": "Paytm",
    }
        , headers: {
          // ignore: deprecated_member_use
          HttpHeaders.AUTHORIZATION: fullData
          // ignore: deprecated_member_use
        }
    );
    print(sendResponse.statusCode);
    print(sendResponse.body);
    razorResponse = json.decode(sendResponse.body);
    msgResponse = razorResponse['message'];
    razorSubscriptionResponse = razorResponse['subscription'];
    var date  = razorSubscriptionResponse['created_at'];
    var time = razorSubscriptionResponse['created_at'];
    createdDatePaystack = DateFormat('d MMM y').format(DateTime.parse(date));
    createdTimePaystack = DateFormat('HH:mm a').format(DateTime.parse(time));

    if(sendResponse.statusCode == 200){
      setState(() {
        isShowing = false;
      });
      goToDialog(createdDatePaystack, createdTimePaystack);
    }else{
      Fluttertoast.showToast(msg: "Your transaction failed contact to Admin.");
      setState(() {
        isShowing = false;
      });
    }
    return null;
  }
}