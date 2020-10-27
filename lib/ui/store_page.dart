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
      body: GridView.count(
        crossAxisCount: 2,
        children: List.generate(
          100,
          (index) {
            return Card(
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.asset(
                      'assets/store_item_placeholder.jpg',
                      scale: 2.5,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Item $index',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '₹ 1000',
                        ),
                      ),
                    ],
                  ),
                  FlatButton(
                    color: redPrime,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Text(
                      "ADD",
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
