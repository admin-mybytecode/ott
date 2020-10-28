import 'package:flutter/material.dart';
import 'package:nexthour/global.dart';

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
      body: ListView.builder(
        itemCount: genreData == null ? 0 : genreData.length,
        physics: ClampingScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index1) {
          var genreName = "${genreData[index1]['name']}";
          var isAv = 0;
          for (var y in newVideosListG) {
            for (var x in y.genre) {
              if (genreId == x) {
                isAv = 1;
                break;
              }
            }
          }

          if (isAv == 1) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: new ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.asset(
                      'assets/temple_placeholder.jpg',
                      scale: 2.0,
                    ),
                  ),
                  title: Text(
                    "$genreName",
                    style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 14.0,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.9,
                        color: redPrime),
                  ),
                  subtitle: Text(
                    "Description",
                    style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 10.0,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.9,
                        color: textColor),
                  ),
                  trailing: FlatButton(
                    color: redPrime,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Text(
                      "Donate",
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: Color.fromRGBO(34, 34, 34, 1.0),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25.0))),
                            contentPadding: EdgeInsets.only(top: 10.0),
                            content: Container(
                              width: 300.0,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Enter Amount to Donate",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: whiteColor),
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[],
                                      ),
                                    ],
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      color: Colors.white70,
                                      padding: EdgeInsets.only(
                                          top: 10.0, bottom: 10.0),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextField(),
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      SnackBar(
                                        content: Text("Payment Successful"),
                                      );
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          top: 15.0, bottom: 15.0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(25.0),
                                            bottomRight: Radius.circular(25.0)),
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
                                      child: Text(
                                        "Confirm",
                                        style: TextStyle(color: Colors.white),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            );
          } else {
            return new Padding(
              padding: const EdgeInsets.only(right: 0.0),
            );
          }
        },
      ),
    );
  }
}
