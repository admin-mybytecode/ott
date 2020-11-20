import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:nexthour/apidata/apidata.dart';
import 'package:nexthour/global.dart';
import 'package:nexthour/model/donation_data.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:nexthour/ui/paymentScreen.dart';

class DonationPage extends StatefulWidget {
  @override
  _DonationPageState createState() => _DonationPageState();
}

Future<TempleData> templedata() async {
  var response = await http.get(APIData.templeApi);
  final jsonResponse = json.decode(response.body);
  TempleData templeData = new TempleData.fromJson(jsonResponse);
  return templeData;
}

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
        child: FutureBuilder<TempleData>(
          future: templedata(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data.temple.length,
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ClipRRect(
                            clipBehavior: Clip.antiAlias,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                bottomLeft: Radius.circular(10)),
                            // child: CachedNetworkImage(
                            //   imageUrl: snapshot.data.temple[index].file,
                            //   width: MediaQuery.of(context).size.width * 0.25,
                            //   height: 170,
                            //   fit: BoxFit.cover,
                            //   placeholder: (context, url) => Image.asset(
                            //     'assets/shree-ganesh.jpg',
                            //     fit: BoxFit.cover,
                            //     width: MediaQuery.of(context).size.width * 0.25,
                            //     height: 170,
                            //   ),
                            // ),
                            child: Image.asset(
                              'assets/shree-ganesh.jpg',
                              fit: BoxFit.cover,
                              width: MediaQuery.of(context).size.width * 0.24,
                              height: 170,
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.68,
                            child: new Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  decoration: BoxDecoration(
                                      color: redPrime,
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(10))),
                                  height: 50,
                                  width: double.infinity,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    child: Text(
                                      snapshot.data.temple[index].name ?? '',
                                      style: TextStyle(
                                          fontFamily: 'Lato',
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.9,
                                          color: whiteColor),
                                      maxLines: 2,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      color: redPrime,
                                    ),
                                    Text(
                                      snapshot.data.temple[index].address ?? '',
                                      style: TextStyle(
                                          fontFamily: 'Lato',
                                          fontSize: 14.0,
                                          color: textColor),
                                      maxLines: 2,
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 8.0, left: 5.0),
                                      child: SizedBox(
                                        height: 70,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.41,
                                        child: SingleChildScrollView(
                                          child: Html(
                                            defaultTextStyle:
                                                TextStyle(fontSize: 12),
                                            data: snapshot
                                                .data.temple[index].description,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        RaisedButton(
                                          color: redPrime,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                          ),
                                          child: Text(
                                            "Donate",
                                            style: TextStyle(
                                              fontFamily: 'Lato',
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.w600,
                                              color: primaryColor,
                                            ),
                                          ),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                TextEditingController
                                                    _amountController =
                                                    TextEditingController();
                                                return AlertDialog(
                                                  backgroundColor: primaryColor,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  25.0))),
                                                  contentPadding:
                                                      EdgeInsets.only(
                                                          top: 10.0),
                                                  content: Container(
                                                    width: 300.0,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .stretch,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: <Widget>[
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          children: <Widget>[
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Text(
                                                                "Enter Amount to Donate",
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color:
                                                                        textColor),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        InkWell(
                                                          onTap: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Container(
                                                            color:
                                                                Colors.white70,
                                                            padding:
                                                                EdgeInsets.only(
                                                                    top: 10.0,
                                                                    bottom:
                                                                        10.0),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: TextField(
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 18,
                                                                ),
                                                                controller:
                                                                    _amountController,
                                                                keyboardType:
                                                                    TextInputType
                                                                        .number,
                                                                decoration: InputDecoration(
                                                                    hintText:
                                                                        "Enter Amount",
                                                                    border:
                                                                        UnderlineInputBorder()),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        InkWell(
                                                          onTap: () {
                                                            Navigator.of(
                                                                    context)
                                                                .push(
                                                              MaterialPageRoute(
                                                                builder: (context) =>
                                                                    PaymentScreen(
                                                                        amount:
                                                                            _amountController.text),
                                                              ),
                                                            );
                                                            SnackBar(
                                                              content: Text(
                                                                  "Payment Successful"),
                                                            );
                                                          },
                                                          child: Container(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    top: 15.0,
                                                                    bottom:
                                                                        15.0),
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius: BorderRadius.only(
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          25.0),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          25.0)),
                                                              gradient:
                                                                  LinearGradient(
                                                                begin: Alignment
                                                                    .topCenter,
                                                                end: Alignment
                                                                    .bottomRight,
                                                                stops: [
                                                                  0.1,
                                                                  0.5,
                                                                  0.7,
                                                                  0.9
                                                                ],
                                                                colors: [
                                                                  redPrime
                                                                      .withOpacity(
                                                                          0.9),
                                                                  redPrime
                                                                      .withOpacity(
                                                                          0.8),
                                                                  redPrime
                                                                      .withOpacity(
                                                                          0.7),
                                                                  redPrime
                                                                      .withOpacity(
                                                                          0.6),
                                                                ],
                                                              ),
                                                            ),
                                                            child: Text(
                                                              "Confirm",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
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
                                        InkWell(
                                            onTap: null,
                                            child: Text(
                                              "view details",
                                              style: TextStyle(fontSize: 10),
                                            ))
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Shimmer.fromColors(
                  baseColor: Colors.white,
                  highlightColor: Colors.grey
                      .withOpacity(0.3), //Color.fromRGBO(50, 50, 50, 1.0),
                  child: Card(
                    elevation: 0.0,
                    color: Color.fromRGBO(45, 45, 45, 1.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: 70,
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
