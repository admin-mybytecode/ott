import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nexthour/global.dart';

class DonationPage extends StatefulWidget {
  @override
  _DonationPageState createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  List<Map> data = [
    {
      "name": "Siddhivinayak temple",
      "image":
          "https://www.mygoldguide.in/sites/default/files/Mumbais-Wealthiest-Temple-Shri-Sidhivinayak_600x410.jpg",
      "Description":
          "Shree Siddhivinayak Temple, dedicated to Lord Ganesha, is an iconic place of worship in Mumbai. The shrine, which is more than 200 years old, is one of the richest temples in India and frequented by celebrities, Bollywood stars, politicians, and commoners alike."
    },
    {
      "name": "Dagadusheth halwai ganapati",
      "image":
          "https://upload.wikimedia.org/wikipedia/commons/thumb/c/cb/DagduHalwai2013.jpg/1200px-DagduHalwai2013.jpg",
      "Description":
          "Shree Siddhivinayak Temple, dedicated to Lord Ganesha, is an iconic place of worship in Mumbai. The shrine, which is more than 200 years old, is one of the richest temples in India and frequented by celebrities, Bollywood stars, politicians, and commoners alike."
    },
    {
      "name": "Iskon Temple",
      "image":
          "https://www.trawell.in/admin/images/upload/148027305ISKCONTemple_Main.jpg",
      "Description":
          "Shree Siddhivinayak Temple, dedicated to Lord Ganesha, is an iconic place of worship in Mumbai. The shrine, which is more than 200 years old, is one of the richest temples in India and frequented by celebrities, Bollywood stars, politicians, and commoners alike."
    },
    {
      "name": "Siddhivinayak temple",
      "image":
          "https://www.mygoldguide.in/sites/default/files/Mumbais-Wealthiest-Temple-Shri-Sidhivinayak_600x410.jpg",
      "Description":
          "Shree Siddhivinayak Temple, dedicated to Lord Ganesha, is an iconic place of worship in Mumbai. The shrine, which is more than 200 years old, is one of the richest temples in India and frequented by celebrities, Bollywood stars, politicians, and commoners alike."
    },
    {
      "name": "Dagadusheth halwai ganapati",
      "image":
          "https://upload.wikimedia.org/wikipedia/commons/thumb/c/cb/DagduHalwai2013.jpg/1200px-DagduHalwai2013.jpg",
      "Description":
          "Shree Siddhivinayak Temple, dedicated to Lord Ganesha, is an iconic place of worship in Mumbai. The shrine, which is more than 200 years old, is one of the richest temples in India and frequented by celebrities, Bollywood stars, politicians, and commoners alike."
    },
    {
      "name": "Iskon Temple",
      "image":
          "https://www.trawell.in/admin/images/upload/148027305ISKCONTemple_Main.jpg",
      "Description":
          "Shree Siddhivinayak Temple, dedicated to Lord Ganesha, is an iconic place of worship in Mumbai. The shrine, which is more than 200 years old, is one of the richest temples in India and frequented by celebrities, Bollywood stars, politicians, and commoners alike."
    },
    {
      "name": "Siddhivinayak temple",
      "image":
          "https://www.mygoldguide.in/sites/default/files/Mumbais-Wealthiest-Temple-Shri-Sidhivinayak_600x410.jpg",
      "Description":
          "Shree Siddhivinayak Temple, dedicated to Lord Ganesha, is an iconic place of worship in Mumbai. The shrine, which is more than 200 years old, is one of the richest temples in India and frequented by celebrities, Bollywood stars, politicians, and commoners alike."
    },
    {
      "name": "Dagadusheth halwai ganapati",
      "image":
          "https://upload.wikimedia.org/wikipedia/commons/thumb/c/cb/DagduHalwai2013.jpg/1200px-DagduHalwai2013.jpg",
      "Description":
          "Shree Siddhivinayak Temple, dedicated to Lord Ganesha, is an iconic place of worship in Mumbai. The shrine, which is more than 200 years old, is one of the richest temples in India and frequented by celebrities, Bollywood stars, politicians, and commoners alike."
    },
    {
      "name": "Iskon Temple",
      "image":
          "https://www.trawell.in/admin/images/upload/148027305ISKCONTemple_Main.jpg",
      "Description":
          "Shree Siddhivinayak Temple, dedicated to Lord Ganesha, is an iconic place of worship in Mumbai. The shrine, which is more than 200 years old, is one of the richest temples in India and frequented by celebrities, Bollywood stars, politicians, and commoners alike."
    },
    {
      "name": "Siddhivinayak temple",
      "image":
          "https://www.mygoldguide.in/sites/default/files/Mumbais-Wealthiest-Temple-Shri-Sidhivinayak_600x410.jpg",
      "Description":
          "Shree Siddhivinayak Temple, dedicated to Lord Ganesha, is an iconic place of worship in Mumbai. The shrine, which is more than 200 years old, is one of the richest temples in India and frequented by celebrities, Bollywood stars, politicians, and commoners alike."
    },
    {
      "name": "Dagadusheth halwai ganapati",
      "image":
          "https://upload.wikimedia.org/wikipedia/commons/thumb/c/cb/DagduHalwai2013.jpg/1200px-DagduHalwai2013.jpg",
      "Description":
          "Shree Siddhivinayak Temple, dedicated to Lord Ganesha, is an iconic place of worship in Mumbai. The shrine, which is more than 200 years old, is one of the richest temples in India and frequented by celebrities, Bollywood stars, politicians, and commoners alike."
    },
    {
      "name": "Iskon Temple",
      "image":
          "https://www.trawell.in/admin/images/upload/148027305ISKCONTemple_Main.jpg",
      "Description":
          "Shree Siddhivinayak Temple, dedicated to Lord Ganesha, is an iconic place of worship in Mumbai. The shrine, which is more than 200 years old, is one of the richest temples in India and frequented by celebrities, Bollywood stars, politicians, and commoners alike."
    },
  ];

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
          itemCount: data.length,
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: CachedNetworkImage(
                        imageUrl: data[index]["image"],
                        width: MediaQuery.of(context).size.width * 0.2,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: new ListTile(
                        title: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            data[index]["name"].toString() ?? '',
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
                            data[index]["Description"] ?? '',
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
                                    backgroundColor:
                                        Color.fromRGBO(34, 34, 34, 1.0),
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
                                                    redPrime.withOpacity(0.4),
                                                    redPrime.withOpacity(0.5),
                                                    redPrime.withOpacity(0.6),
                                                    redPrime.withOpacity(0.7),
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
