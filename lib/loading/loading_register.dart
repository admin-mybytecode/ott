import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:nexthour/apidata/apidata.dart';
import 'package:nexthour/global.dart';
import 'package:nexthour/ui/intro_slider.dart';
import 'package:nexthour/model/WatchlistModel.dart';
import 'package:nexthour/model/video_data.dart';
import 'package:nexthour/model/seasons.dart';
import 'package:nexthour/controller/navigation_bar_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoadingRegister extends StatefulWidget {
  final scaffoldKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isSelected;

  LoadingRegister(
      {this.scaffoldKey,
      this.nameController,
      this.emailController,
      this.passwordController,
      this.isSelected});

  @override
  _LoadingRegisterState createState() => _LoadingRegisterState();
}

class _LoadingRegisterState extends State<LoadingRegister> {
  saveNewToken() async {
    // obtain shared preferences
    prefs = await SharedPreferences.getInstance();
// set value
    prefs.setString('token', null);
  }

// Registration
  Future<String> registration() async {
    try {
      var url = APIData.registerApi;
      final register = await http.post(url, body: {
        "name": widget.nameController.text,
        "email": widget.emailController.text,
        "password": widget.passwordController.text,
      });
      if (register.statusCode == 200) {
        print(register.statusCode);
        writeToFile("user", widget.emailController.text);
        writeToFile("pass", widget.passwordController.text);
        loginFromFIle();
        saveNewToken();
      } else {
        if (register.statusCode == 302) {
          registrationError();
          print(register.statusCode);
        } else {
          wentWrong();
          print(register.statusCode);
        }
      }
      return null;
    } catch (e) {
      noNetwork();
      return null;
    }
  }

// Registration error
  void registrationError() {
    Fluttertoast.showToast(msg: "Already Exists");
    Navigator.pop(context);
  }

// Registration error
  void wentWrong() {
    Fluttertoast.showToast(msg: "Error in registration");
    Navigator.pop(context);
  }

// Network error
  void noNetwork() {
    Fluttertoast.showToast(msg: "Please Check Network Connection!");
    Navigator.pop(context);
  }

  // Create file to save login credentials
  void createFile(Map<String, String> content, Directory dir, String fileName) {
    File file = new File(dir.path + "/" + fileName);
    file.createSync();
    setState(() {
      fileExists = true;
    });
    file.writeAsStringSync(json.encode(content));
    this.setState(() => fileContent = json.decode(jsonFile.readAsStringSync()));
  }

// Write into file
  void writeToFile(String key, String value) {
//    print("Writing to file!");
    Map<String, String> content = {key: value};
    if (fileExists) {
//      print("File exists");
      Map<dynamic, dynamic> jsonFileContent =
          json.decode(jsonFile.readAsStringSync());
      jsonFileContent.addAll(content);
      jsonFile.writeAsStringSync(json.encode(jsonFileContent));
    } else {
//      print("File does not exist!");
      createFile(content, dir, fileName);
    }

    this.setState(() => fileContent = json.decode(jsonFile.readAsStringSync()));
//    print(fileContent);
  }

  // Login from file
  Future<String> loginFromFIle() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        if (fileExists) {
          final accessToken = await http.post(APIData.tokenApi, body: {
            "email": fileContent['user'],
            "password": fileContent['pass'],
          });
          var user = json.decode(accessToken.body);
          final response = await http.get(APIData.userProfileApi,
              // ignore: deprecated_member_use
              headers: {
                // ignore: deprecated_member_use
                HttpHeaders.AUTHORIZATION: "Bearer ${user['access_token']}!"
              });
          final menuResponse =
              await http.get(Uri.encodeFull(APIData.topMenu), headers: {
            // ignore: deprecated_member_use
            HttpHeaders.AUTHORIZATION: "Bearer ${user['access_token']}!"
          });
          topMData = json.decode(menuResponse.body);

          final movieResponse2 =
              await http.get(Uri.encodeFull(APIData.allMovies), headers: {
            // ignore: deprecated_member_use
            HttpHeaders.AUTHORIZATION: "Bearer ${user['access_token']}!"
          });

          var mDataC = json.decode(movieResponse2.body);
          final sliderResponse =
              await http.get(Uri.encodeFull(APIData.sliderApi), headers: {
            // ignore: deprecated_member_use
            HttpHeaders.AUTHORIZATION: "Bearer ${user['access_token']}!"
          });
          final showWatchlistResponse =
              await http.get(Uri.encodeFull(APIData.watchListApi), headers: {
            // ignore: deprecated_member_use
            HttpHeaders.AUTHORIZATION: "Bearer ${user['access_token']}!"
          });
          var showWatchlistData = json.decode(showWatchlistResponse.body);

          sliderResponseData = json.decode(sliderResponse.body);
          sliderData = sliderResponseData['slider'];

          final basicDetails = await http.get(
            Uri.encodeFull(APIData.homeDataApi),
          );
          homeApiResponseData = json.decode(basicDetails.body);

          showWatchlist = showWatchlistData['wishlist'];

          showPaymentGateway = homeApiResponseData['config'];

          stripePayment = showPaymentGateway['stripe_payment'];
          if (stripePayment == "1") {
            stripePayment = 1;
          }
          btreePayment = showPaymentGateway['braintree'];
          if (btreePayment == "1") {
            btreePayment = 1;
          }
          paystackPayment = showPaymentGateway['paystack'];
          if (paystackPayment == "1") {
            paystackPayment = 1;
          }
          bankPayment = showPaymentGateway['bankdetails'];
          if (bankPayment == "1") {
            bankPayment = 1;
          }
          download = showPaymentGateway['download'];
          if (download == "1") {
            download = 1;
          }
//          paytmPaymentStatus=showPaymentGateway['paytm_payment'];
          paytmPaymentStatus = 0;
          razorPayPaymentStatus = showPaymentGateway['razorpay_payment'];
          if (razorPayPaymentStatus == "1") {
            razorPayPaymentStatus = 1;
          }

          accountNo = showPaymentGateway['account_no'];
          branchName = showPaymentGateway['branch'];
          bankAccountName = showPaymentGateway['account_name'];
          bankIFSCCode = showPaymentGateway['ifsc_code'];
          bankName = showPaymentGateway['bank_name'];
          wEmail = showPaymentGateway['w_email'];
          donationUrl = showPaymentGateway['donation_link'];
          donationStatus = showPaymentGateway['donation'];
          blogStatus = showPaymentGateway['blog'];
          fbLoginStatus = showPaymentGateway['fb_login'];
          videoCommentsStatus = showPaymentGateway['comments'];
          if (fbLoginStatus == "1") {
            fbLoginStatus = 1;
          }
          final compData =
              await http.get(Uri.encodeFull(APIData.movieTvApi), headers: {
            // ignore: deprecated_member_use
            HttpHeaders.AUTHORIZATION: "Bearer ${user['access_token']}!"
          });
          var aData = json.decode(compData.body);
          List aData2 = aData['data'];

          final mainResponse2 =
              await http.get(Uri.encodeFull(APIData.allDataApi), headers: {
            // ignore: deprecated_member_use
            HttpHeaders.AUTHORIZATION: "Bearer ${user['access_token']}!"
          });

          final stripeDetailsResponse =
              await http.get(Uri.encodeFull(APIData.stripeDetailApi), headers: {
            // ignore: deprecated_member_use
            HttpHeaders.AUTHORIZATION: "Bearer ${user['access_token']}!"
          });
          stripeData = json.decode(stripeDetailsResponse.body);
          print(stripeData);
          if (stripeData != "error") {
            stripeKey = stripeData['key'];
            stripePass = stripeData['pass'];
            payStackKey = stripeData['paystack'];
            razorPayKey = stripeData['razorkey'];
            paytmKey = stripeData['paytmkey'];
            razorPayKey = stripeData['razorkey'];
            paytmKey = stripeData['paytmkey'];
            paytmMerchantKey = stripeData['paytmpass'];
          }

          final response2 = await http.get(
            Uri.encodeFull(APIData.faq),
          );
          faqApiData = json.decode(response2.body);
          faqHelp = faqApiData['faqs'];

          var mainData2 = json.decode(mainResponse2.body);
          var genreData2 = mainData2['genre'];

          var dataLen = aData2.length == null ? 0 : aData2.length;
          searchIds2.clear();
          if (dataLen != null) {
            for (var all = 0; all < dataLen; all++) {
              searchIds2.add(aData2[all]);
            }
          }

          var singleId;
          userWatchListOld = List<VideoDataModel>.generate(
              searchIds2 == null ? 0 : dataLen, (int index) {
            var type = searchIds2[index]['type'];

            var description = searchIds2[index]['detail'];

            var t = description;

            var genreIdbyM = searchIds2[index]['genre_id'];

            singleId = genreIdbyM == null ? null : genreIdbyM.split(",");

            double convrInStart;
            dynamic vRating = searchIds2[index]['rating'];
            switch (vRating.runtimeType) {
              case double:
                {
                  double tmdbrating = searchIds2[index]['rating'] == null
                      ? 0
                      : searchIds2[index]['rating'];
                  convrInStart = tmdbrating != null ? tmdbrating / 2 : 0;
                }
                break;
              case int:
                {
                  var tmdbrating = searchIds2[index]['rating'] == null
                      ? 0
                      : searchIds2[index]['rating'];
                  convrInStart = tmdbrating != null ? tmdbrating / 2 : 0;
                }
                break;
              case String:
                {
                  var tmdbrating = searchIds2[index]['rating'] == null
                      ? 0
                      : double.parse(searchIds2[index]['rating']);
                  convrInStart = tmdbrating != null ? tmdbrating / 2 : 0;
                }
                break;
            }

            var idTM;
            List<dynamic> se2;

            if (type == "T") {
              se2 = searchIds2[index]['seasons'] as List<dynamic>;
            } else {
              se2 = searchIds2[index]['movie_series'] as List<dynamic>;
              idTM = searchIds2[index]['comments'];
              videoLink = searchIds2[index]['video_link'];

              iFrameURL = videoLink == null ? null : videoLink['iframeurl'];
              iReadyUrl = videoLink == null ? null : videoLink['ready_url'];
              vUrl360 = videoLink == null ? null : videoLink['url_360'];
              vUrl480 = videoLink == null ? null : videoLink['url_480'];
              vUrl720 = videoLink == null ? null : videoLink['url_720'];
              vUrl1080 = videoLink == null ? null : videoLink['url_1080'];
            }

            return VideoDataModel(
              id: searchIds2[index]['id'],
              name: '${searchIds2[index]['title']}',
              box: type == "T"
                  ? "${APIData.tvImageUriTv}" +
                      "${searchIds2[index]['thumbnail']}"
                  : "${APIData.movieImageUri}" +
                      "${searchIds2[index]['thumbnail']}",
              cover: type == "T"
                  ? "${APIData.tvImageUriPosterTv}" +
                      "${searchIds2[index]['poster']}"
                  : "${APIData.movieImageUriPosterMovie}" +
                      "${searchIds2[index]['poster']}",
              description: '$t',
              datatype: type,
              rating: convrInStart,
              screenshots: List.generate(3, (int seriesIndex) {
                return type == "T"
                    ? "${APIData.tvImageUriPosterTv}" +
                        "${searchIds2[index]['poster']}"
                    : "${APIData.movieImageUriPosterMovie}" +
                        "${searchIds2[index]['poster']}";
              }),
              url: '${searchIds2[index]['trailer_url']}',
              menuId: 1,
              genre: List.generate(singleId == null ? 0 : singleId.length,
                  (int genreIndex) {
                return "${singleId[genreIndex]}";
              }),
              genres: List.generate(genreData2 == null ? 0 : genreData2.length,
                  (int genresIndex) {
                var genreId2 = genreData2[genresIndex]['id'].toString();
                var zx = List.generate(singleId == null ? 0 : singleId.length,
                    (int xyz) {
                  return "${singleId[xyz]}";
                });
                var isAv2 = 0;
                for (var y in zx) {
                  if (genreId2 == y) {
                    isAv2 = 1;
                    break;
                  }
                }
                if (isAv2 == 1) {
                  if (genreData2[genresIndex]['name'] == null) {
                    return null;
                  } else {
                    return "${genreData2[genresIndex]['name']}";
                  }
                }
                return null;
              }),
              seasons:
                  List<Seasons>.generate(se2 == null ? 0 : se2.length, (int s) {
                if (type == "T") {
                  return new Seasons(
                    id: se2[s]['id'],
                    sTvSeriesId: se2[s]['tv_series_id'],
                    sSeasonNo: se2[s]['season_no'],
                    thumbnail: se2[s]['thumbnail'],
                    cover: se2[s]['poster'],
                    description: se2[s]['detail'],
                    sActorId: se2[s]['actor_id'],
                    language: se2[s]['a_language'],
                    type: se2[s]['type'],
                  );
                } else {
                  return null;
                }
              }),
              maturityRating: '${searchIds2[index]['maturity_rating']}',
              duration: type == "T"
                  ? 'Not Available'
                  : '${searchIds2[index]['duration']}',
              released: type == "T"
                  ? 'Not Available'
                  : '${searchIds2[index]['released']}',
            );
          });

          userWatchList = List<WatchlistModel>.generate(
              showWatchlist == null ? 0 : showWatchlist.length, (int index) {
            return showWatchlist[index]['season_id'] != null
                ? WatchlistModel(
                    id: showWatchlist[index]['id'],
                    wUserId: int.parse(showWatchlist[index]['user_id']),
                    season_id: int.parse(showWatchlist[index]['season_id']),
                    added: showWatchlist[index]['added'],
                    wCreatedAt: '${showWatchlist[index]['created_at']}',
                    wUpdatedAt: '${showWatchlist[index]['updated_at']}',
                  )
                : new WatchlistModel(
                    id: showWatchlist[index]['id'],
                    wUserId: int.parse(showWatchlist[index]['user_id']),
                    wMovieId: int.parse(showWatchlist[index]['movie_id']),
                    added: showWatchlist[index]['added'],
                    wCreatedAt: '${showWatchlist[index]['created_at']}',
                    wUpdatedAt: '${showWatchlist[index]['updated_at']}',
                  );
          });

          setState(() {
            loginConfigData = homeApiResponseData['config'];
            blogResponse = homeApiResponseData['blogs'];
            topMenuData = topMData['menu'];
            menuList = topMenuData.length;
            fullData = "Bearer ${user['access_token']}!";
            mDataCount = mDataC['movie'];
            movieDataLength = mDataCount.length;
          });

          dataUser = json.decode(response.body);
          setState(() {
            userDetail = dataUser['user'];
            isAdmin = userDetail['is_admin'];
            userId = userDetail['id'];
            userName = userDetail['name'];
            userEmail = userDetail['email'];
            userMobile = userDetail['mobile'];
            userDOB = userDetail['dob'];
            userImage = userDetail['image'];
            userCreatedAt = userDetail['created_at'];
            stripeCustomerId = userDetail['stripe_id'];
            userActivePlan = dataUser['current_subscription'];
            userExpiryDate = dataUser['end'];
            status = dataUser['active'];
            downloadLimit = dataUser['limit'];
            mScreenCount = dataUser['screen'];
            userPaymentType = dataUser['payment'];
            userPaypalHistory = dataUser['paypal'];
            userStripeHistory = userDetail['subscriptions'];
            userPlanStart = dataUser['start'] != null
                ? DateTime.parse(dataUser['start'])
                : 'N/A';
            userPlanEnd = dataUser['end'] != null
                ? DateTime.parse(dataUser['end'])
                : 'N/A';
            currentDate = dataUser['current_date'] != null
                ? DateTime.parse(dataUser['current_date'])
                : 'N/A';
            dynamic dLimit = dataUser['limit'];
            switch (dLimit.runtimeType) {
              case int:
                downloadLimit = dLimit;
                break;
              case String:
                downloadLimit = int.parse(dLimit);
                break;
            }

            dynamic scCount = dataUser['screen'];
            switch (scCount.runtimeType) {
              case int:
                mScreenCount = scCount;
                break;
              case String:
                mScreenCount = int.parse(scCount);
                break;
            }
            if (blogStatus == "1") {
              blogStatus = 1;
            }
            if (isAdmin == "1") {
              isAdmin = 1;
            }
            if (donationStatus == "1") {
              donationStatus = 1;
            }
          });

          setState(() {
            showWatchlist = showWatchlistData['wishlist'];
            userId = userDetail['id'];
            code = dataUser['code'];
            name = userName;
            nameInitial = userName[0];
            email = userEmail;
            expiryDate = userExpiryDate;
            if (isAdmin == "1" || isAdmin == 1) {
              status = "1";
              userName = "Admin";
            } else {
              name = userName;
            }
            if (userMobile == null) {
              mobile = "N/A";
            } else {
              mobile = userMobile;
            }
            if (userDOB == null) {
              dob = "N/A";
            } else {
              dob = userDOB;
            }
            if (userCreatedAt == null) {
              created_at = "N/A";
            } else {
              created_at = userCreatedAt;
            }
            if (userActivePlan == null) {
              activePlan = "N/A";
            } else {
              activePlan = userActivePlan;
            }
            if (userExpiryDate == null) {
              expiryDate = '';
            } else {
              expiryDate = userExpiryDate;
            }
            if (expiryDate == '' ||
                expiryDate == 'N/A' ||
                userExpiryDate == null ||
                status == 0) {
              difference = null;
            }
          });

          var router = new MaterialPageRoute(
              builder: (BuildContext context) =>
                  new BottomNavigationBarController());
          Navigator.of(context).push(router);

          return (accessToken.body);
        } else {
          final basicDetails = await http.get(
            Uri.encodeFull(APIData.homeDataApi),
          );
          homeApiResponseData = json.decode(basicDetails.body);

          setState(() {
            loginImageData = homeApiResponseData['login_img'];
            loginConfigData = homeApiResponseData['config'];
            homeDataBlocks = homeApiResponseData['blocks'];
          });

          if (homeDataBlocks != null) {
            var router = new MaterialPageRoute(
                builder: (BuildContext context) => new IntroScreen());
            Navigator.of(context).push(router);
          }
        }
      }
    } catch (e) {
      print(e);
    }

    return (null);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(Duration(seconds: 2), () {
      registration();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryDarkColor,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              loginConfigData == null
                  ? Image.asset("assets/logo.png")
                  : Image.network(
                      '${APIData.logoImageUri}${loginConfigData['logo']}',
                      scale: 0.9,
                    ),
              SizedBox(
                height: 20.0,
              ),
              CircularProgressIndicator(),
            ],
          )
        ],
      ),
    );
  }
}
