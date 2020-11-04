import 'package:flutter/material.dart';
import 'package:nexthour/global.dart';
import 'package:share/share.dart';

// Share tab
class SharePage extends StatelessWidget {
  SharePage(this.shareType, this.shareId);
  final shareType;
  final shareId;

  Widget shareText() {
    return Text(
      "Share",
      style: TextStyle(
        fontFamily: 'Lato',
        fontSize: 12.0,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.0,
        color: textColor,
      ),
    );
  }

  Widget shareTabColumn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Ink(
            decoration: ShapeDecoration(
              color: redPrime,
              shape: CircleBorder(),
            ),
            child: IconButton(
              color: primaryColor,
              icon: Icon(Icons.share_outlined),
              onPressed: () => Share.share('$shareType' + '$shareId'),
            ),
          ),
        ),
        shareText(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Material(
      child: shareTabColumn(),
      color: primaryColor,
    ));
  }
}
