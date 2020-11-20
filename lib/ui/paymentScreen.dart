import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:paytm/paytm.dart';
import 'package:nexthour/global.dart';

class PaymentScreen extends StatefulWidget {
  final String amount;
  PaymentScreen({this.amount, key}) : super(key: key);
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String paymentResponse;
  // //Live
  // String mid = "LIVE_MID_HERE";
  // String PAYTM_MERCHANT_KEY = "LIVE_KEY_HERE";
  // String website = "DEFAULT";
  // bool testing = false;

  //Testing
  String mid = "LcWxji22236369682386";
  String paytmMerchantKey = "rRD76zTkPnFDWWMc";
  String website = "WEBSTAGING";
  bool testing = true;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        elevation: 0.0,
        title: const Text('Paymet types'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // paymentResponse != null
              //     ? Text('Response: $paymentResponse\n')
              //     : Container(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 6.0,
                  color: redPrime,
                  child: InkWell(
                    onTap: () {
                      generateTxnToken(0, widget.amount);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Icon(
                              Icons.account_balance_wallet,
                              color: primaryColor,
                            ),
                          ),
                          Text(
                            "Paytm Wallet",
                            style: TextStyle(
                              color: whiteColor,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 6.0,
                  color: redPrime,
                  child: InkWell(
                    onTap: () {
                      generateTxnToken(1, widget.amount);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Icon(
                              Icons.money_outlined,
                              color: primaryColor,
                            ),
                          ),
                          Text(
                            "Pay using Net Banking",
                            style: TextStyle(
                              color: whiteColor,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 6.0,
                  color: redPrime,
                  child: InkWell(
                    onTap: () {
                      generateTxnToken(2, widget.amount);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Icon(
                              Icons.wallet_membership_outlined,
                              color: primaryColor,
                            ),
                          ),
                          Text(
                            "Pay using UPI",
                            style: TextStyle(
                              color: whiteColor,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 6.0,
                  color: redPrime,
                  child: InkWell(
                    onTap: () {
                      generateTxnToken(3, widget.amount);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Icon(
                              Icons.credit_card_outlined,
                              color: primaryColor,
                            ),
                          ),
                          Text(
                            "Pay using Credit Card",
                            style: TextStyle(
                              color: whiteColor,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              loading == true
                  ? Center(
                      child: CircularProgressIndicator(
                      backgroundColor: Colors.black.withOpacity(0.4),
                    ))
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  void generateTxnToken(int mode, String amount) async {
    setState(() {
      loading = true;
    });
    String orderId = DateTime.now().millisecondsSinceEpoch.toString();

    String callBackUrl = (testing
            ? 'https://securegw-stage.paytm.in'
            : 'https://securegw.paytm.in') +
        '/theia/paytmCallback?ORDER_ID=' +
        orderId;

    var url = 'https://desolate-anchorage-29312.herokuapp.com/generateTxnToken';

    var body = json.encode({
      "mid": mid,
      "key_secret": paytmMerchantKey,
      "website": website,
      "orderId": orderId,
      "amount": amount.toString(),
      "callbackUrl": callBackUrl,
      "custId": "122",
      "mode": mode.toString(),
      "testing": testing ? 0 : 1
    });

    try {
      final response = await http.post(
        url,
        body: body,
        headers: {'Content-type': "application/json"},
      );
      print("Response is");
      print(response.body);
      String txnToken = response.body;
      setState(() {
        paymentResponse = txnToken;
      });

      var paytmResponse = Paytm.payWithPaytm(
          mid, orderId, txnToken, amount.toString(), callBackUrl, testing);

      paytmResponse.then((value) {
        print(value);
        setState(() {
          loading = false;
          paymentResponse = value.toString();
        });
      });
    } catch (e) {
      print(e);
    }
  }
}
