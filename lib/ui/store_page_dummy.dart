import 'package:flutter/material.dart';
import 'package:nexthour/global.dart';
import 'package:webview_flutter/webview_flutter.dart';

class StorePage extends StatefulWidget {
  @override
  _StorePageState createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  Widget appBar() {
    return AppBar(
      elevation: 0.0,
      title: Text(
        "Store",
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
          initialUrl: 'storeURL',
          javascriptMode: JavascriptMode.unrestricted,
//            onWebViewCreated: (WebViewController webViewController) {
//              _controller1 = webViewController;
//            },
        ),
      ),
    );
  }
}
