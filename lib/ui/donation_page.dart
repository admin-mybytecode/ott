import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nexthour/global.dart';
import 'package:nexthour/model/donation_data.dart';

class DonationPage extends StatefulWidget {
  @override
  _DonationPageState createState() => _DonationPageState();
}

var jsonString =
    '[{ "temple" : [ { "name" : "test", "description": "test", "file": "test_1604863718.jpeg", "bank_account_number": "test", "ifsc": "test", "branch": "test", "address": "test", "id": 8, "updated_at": "2020-11-09 00:58:38", "created_at": "2020-11-09 00:58:38" }]}]';
var parsedjson = jsonDecode(jsonString);
TempleData data = TempleData.fromJson(parsedjson);

class _DonationPageState extends State<DonationPage> {
  Widget appBar() {
    return AppBar(
      leading: SizedBox(),
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
      backgroundColor: primaryColor,
      body: Padding(
        padding: const EdgeInsets.only(bottom: 70),
        child: ListView.builder(
          itemCount: data.temple.length,
          physics: ClampingScrollPhysics(),
          scrollDirection: Axis.vertical,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 6.0,
                shadowColor: redPrime.withOpacity(0.6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Row(
                  children: [
                    // ClipRRect(
                    //   borderRadius: BorderRadius.circular(10.0),
                    //   child: CachedNetworkImage(
                    //     imageUrl: data[index]["image"],
                    //     width: MediaQuery.of(context).size.width * 0.2,
                    //     height: 120,
                    //     fit: BoxFit.cover,
                    //   ),
                    // ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: new ListTile(
                        title: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            data.temple[index].name ?? '',
                            style: TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 14.0,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.9,
                                color: redPrime),
                            maxLines: 2,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            data.temple[index].description ?? '',
                            style: TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 10.0,
                                letterSpacing: 0.9,
                                color: textColor),
                            maxLines: 4,
                          ),
                        ),
                        trailing: Padding(
                          padding: const EdgeInsets.only(top: 25),
                          child: RaisedButton(
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
                                    backgroundColor: primaryColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(25.0))),
                                    contentPadding: EdgeInsets.only(top: 10.0),
                                    content: Container(
                                      width: 300.0,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.max,
                                            children: <Widget>[
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  "Enter Amount to Donate",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: textColor),
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
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: TextField(),
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              SnackBar(
                                                content:
                                                    Text("Payment Successful"),
                                              );
                                              Navigator.pop(context);
                                            },
                                            child: Container(
                                              padding: EdgeInsets.only(
                                                  top: 15.0, bottom: 15.0),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(25.0),
                                                    bottomRight:
                                                        Radius.circular(25.0)),
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomRight,
                                                  stops: [0.1, 0.5, 0.7, 0.9],
                                                  colors: [
                                                    redPrime.withOpacity(0.9),
                                                    redPrime.withOpacity(0.8),
                                                    redPrime.withOpacity(0.7),
                                                    redPrime.withOpacity(0.6),
                                                  ],
                                                ),
                                              ),
                                              child: Text(
                                                "Confirm",
                                                style: TextStyle(
                                                    color: Colors.white),
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
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
