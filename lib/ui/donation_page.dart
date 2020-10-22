import 'package:flutter/material.dart';
import 'package:nexthour/global.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DonationPage extends StatefulWidget {
  @override
  _DonationPageState createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  Widget appBar() {
    return AppBar(
      elevation: 0.0,
      title: Text(
        "Donate",
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      centerTitle: true,
      backgroundColor: primaryColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: Container(
        child: WebView(
          initialUrl: '$donationUrl',
          javascriptMode: JavascriptMode.unrestricted,
//            onWebViewCreated: (WebViewController webViewController) {
//              _controller1 = webViewController;
//            },
        ),
      ),
    );
  }
}
