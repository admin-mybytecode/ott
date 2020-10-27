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
            return new Padding(
              padding: const EdgeInsets.only(
                  top: 0.0, bottom: 0.0, left: 0.0, right: 0.0),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
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
                    onPressed: () {},
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
