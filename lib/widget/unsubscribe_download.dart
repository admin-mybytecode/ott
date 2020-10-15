import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UnsubscribeDownload extends StatefulWidget {
  @override
  _UnsubscribeDownloadState createState() => _UnsubscribeDownloadState();
}

class _UnsubscribeDownloadState extends State<UnsubscribeDownload> {

  //  Download text
  Widget downloadText(){
    return Text(
      "Download",
      style: TextStyle(
          fontFamily: 'Lato',
          fontSize: 12.0,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.0,
          color: Colors.white
        // color: Colors.white
      ),
    );
  }

//  Rate us column
  Widget rateUsTabColumn(){
    return Column(
      mainAxisAlignment:
      MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          Icons.file_download,
          size: 30.0,
          color: Colors.white,
        ),
        new Padding(
          padding:
          const EdgeInsets.fromLTRB(
              0.0, 0.0, 0.0, 10.0),
        ),
        downloadText(),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        child: new InkWell(
          onTap: () {
            Fluttertoast.showToast(msg: "You are not subscribed.");
          },
          child: rateUsTabColumn(),
        ),
        color: Colors.transparent,
      ),
    );
  }
}
