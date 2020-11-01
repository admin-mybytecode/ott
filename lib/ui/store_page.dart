import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nexthour/global.dart';

class StorePage extends StatefulWidget {
  @override
  _StorePageState createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  List<Map> data = [
    {
      "name": "Teej Puja",
      "image":
          "https://www.boldsky.com/img/2017/07/xshutterstock-83999845-12-1499865341.jpg.pagespeed.ic.Y3V94MIATh.jpg",
      "price": "200",
    },
    {
      "name": "Puja Taat",
      "image": "https://miro.medium.com/max/2560/1*01sxpQl9BhNcgAQH-pNLaQ.jpeg",
      "price": "600",
    },
    {
      "name": "Ganpati Puja",
      "image":
          "https://cdn.telanganatoday.com/wp-content/uploads/2018/09/ganesh.jpg",
      "price": "299",
    },
    {
      "name": "Puja Pack",
      "image":
          "https://3.bp.blogspot.com/-NrqQfNwqUnM/UJDvfpvC0tI/AAAAAAAABc4/UTfkktu1Jq4/s1600/Durga+Pooja+Materials.jpg",
      "price": "1999",
    },
    {
      "name": "Teej Puja",
      "image":
          "https://www.boldsky.com/img/2017/07/xshutterstock-83999845-12-1499865341.jpg.pagespeed.ic.Y3V94MIATh.jpg",
      "price": "200",
    },
    {
      "name": "Puja Taat",
      "image": "https://miro.medium.com/max/2560/1*01sxpQl9BhNcgAQH-pNLaQ.jpeg",
      "price": "600",
    },
    {
      "name": "Ganpati Puja",
      "image":
          "https://cdn.telanganatoday.com/wp-content/uploads/2018/09/ganesh.jpg",
      "price": "299",
    },
    {
      "name": "Puja Pack",
      "image":
          "https://3.bp.blogspot.com/-NrqQfNwqUnM/UJDvfpvC0tI/AAAAAAAABc4/UTfkktu1Jq4/s1600/Durga+Pooja+Materials.jpg",
      "price": "1999",
    },
    {
      "name": "Teej Puja",
      "image":
          "https://www.boldsky.com/img/2017/07/xshutterstock-83999845-12-1499865341.jpg.pagespeed.ic.Y3V94MIATh.jpg",
      "price": "200",
    },
    {
      "name": "Puja Taat",
      "image": "https://miro.medium.com/max/2560/1*01sxpQl9BhNcgAQH-pNLaQ.jpeg",
      "price": "600",
    },
    {
      "name": "Ganpati Puja",
      "image":
          "https://cdn.telanganatoday.com/wp-content/uploads/2018/09/ganesh.jpg",
      "price": "299",
    },
    {
      "name": "Puja Pack",
      "image":
          "https://3.bp.blogspot.com/-NrqQfNwqUnM/UJDvfpvC0tI/AAAAAAAABc4/UTfkktu1Jq4/s1600/Durga+Pooja+Materials.jpg",
      "price": "1999",
    }
  ];

  Widget appBar() {
    return AppBar(
      leading: SizedBox(),
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
      backgroundColor: primaryColor,
      body: Padding(
        padding: const EdgeInsets.only(bottom: 70),
        child: GridView.count(
          crossAxisCount: 2,
          children: List.generate(
            data.length,
            (index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  shadowColor: redPrime.withOpacity(0.6),
                  elevation: 6.0,
                  child: ListTile(
                    title: CachedNetworkImage(
                      imageUrl: data[index]["image"],
                      height: 90,
                      width: 100,
                    ),
                    subtitle: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: Container(
                                width: 60,
                                child: Text(
                                  data[index]["name"] ?? '',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '₹' + data[index]["price"],
                                style: TextStyle(fontWeight: FontWeight.bold,),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 90,
                          child: FlatButton(
                            color: redPrime,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "ADD",
                                  style: TextStyle(
                                    fontFamily: 'Lato',
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w600,
                                    color: primaryColor,
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Icon(
                                  Icons.shopping_cart,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ],
                            ),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
