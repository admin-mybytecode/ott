import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nexthour/apidata/apidata.dart';
import 'package:nexthour/download/download_videos.dart';
import 'package:nexthour/global.dart';
import 'package:nexthour/model/comments_model.dart';
import 'package:nexthour/ui/intro_slider.dart';
import 'package:nexthour/model/WatchlistModel.dart';
import 'package:nexthour/model/video_data.dart';
import 'package:nexthour/model/seasons.dart';
import 'package:nexthour/controller/navigation_bar_controller.dart';
import 'package:nexthour/ui/multi_screen_page.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock/wakelock.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  Animation<double> containerGrowAnimation;
  AnimationController _screenController;
  Animation<Color> fadeScreenAnimation;
  bool _visible = false;
  bool _visible2 = false;
  bool _visible3 = false;
  StreamSubscription<ConnectivityResult> subscription;

  // ignore: unused_field
  String _debugLabelString = "";

  // ignore: unused_field
  bool _enableConsentButton = false;
  bool _requireConsent = true;

  getValuesSF() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      boolValue = prefs.getBool('boolValue');
    });
  }

  saveNewToken() async {
    // obtain shared preferences
    prefs = await SharedPreferences.getInstance();
    prefs.setString('token', null);
  }

  Future<Null> setLocalPath() async {
    setState(() {
      localPath = APIData.localPath;
    });
  }

  Future<String> getMyData() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        getApplicationDocumentsDirectory().then((Directory directory) {
          dir = directory;
          jsonFile = new File(dir.path + "/" + fileName);
          fileExists = jsonFile.existsSync();
          if (fileExists)
            this.setState(
                () => fileContent = json.decode(jsonFile.readAsStringSync()));
        });
        loginFromFIle();
        initPlatformState();
        Timer(Duration(seconds: 1), () {
          setState(() {
            _visible = true;
          });
        });
        _visible3 = true;
      } else {
        var router = new MaterialPageRoute(
            builder: (BuildContext context) => OfflineDownloadPage(
                  key: PageStorageKey('Page4'),
                ));
        Navigator.of(context).push(router);
      }
    } on SocketException catch (e3) {
      debugPrint(e3.toString());
      var router = new MaterialPageRoute(
          builder: (BuildContext context) => OfflineDownloadPage(
                key: PageStorageKey('Page4'),
              ));
      Navigator.of(context).push(router);
      return null;
    } on Exception catch (e4) {
      print("Exception $e4");
      return null;
    }
    return (null);
  }

  @override
  void initState() {
    super.initState();
    this._handleConsent();
    this.getValuesSF();
    this.setLocalPath();
    Wakelock.enable();
    getMyData();
  }

  @override
  void dispose() {
    _screenController.dispose();
    subscription.cancel();
    super.dispose();
  }

//  This FUTURE is used to login automatically through file that already save email and password
  Future<String> loginFromFIle() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var dio = Dio();
        Response basicDetails = await dio.get(APIData.homeDataApi);
        homeApiResponseData = basicDetails.data;
        setState(() {
          loginImageData = homeApiResponseData['login_img'];
          loginConfigData = homeApiResponseData['config'];
          homeDataBlocks = homeApiResponseData['blocks'];
          showPaymentGateway = homeApiResponseData['config'];
          fbLoginStatus = showPaymentGateway['fb_login'];
          if (fbLoginStatus == "1") {
            fbLoginStatus = 1;
          }
        });
        setState(() {
          _visible2 = true;
        });
        if (fileExists) {
          Response accessToken = await dio.post(APIData.tokenApi, data: {
            "email": fileContent['user'],
            "password": fileContent['pass'],
          });
          var user = accessToken.data;

          saveNewToken();

          Response response = await dio.get(APIData.userProfileApi,
              options: Options(method: 'GET', headers: {
                // ignore: deprecated_member_use
                HttpHeaders.AUTHORIZATION: "Bearer ${user['access_token']}!",
                HttpHeaders.contentTypeHeader: "application/json"
              }));

          Response getAllScreensResponse = await dio.get(APIData.showScreensApi,
              options: Options(method: 'GET', headers: {
                // ignore: deprecated_member_use
                HttpHeaders.AUTHORIZATION: "Bearer ${user['access_token']}!",
                HttpHeaders.contentTypeHeader: "application/json"
              }));

          var screensRes = getAllScreensResponse.data;
          var scr = screensRes['screen'];
          if (scr != null) {
            setState(() {
              screen1 = screensRes['screen']['screen1'] == null
                  ? "Screen1"
                  : screensRes['screen']['screen1'];
              screen2 = screensRes['screen']['screen2'] == null
                  ? "Screen2"
                  : screensRes['screen']['screen2'];
              screen3 = screensRes['screen']['screen3'] == null
                  ? "Screen3"
                  : screensRes['screen']['screen3'];
              screen4 = screensRes['screen']['screen4'] == null
                  ? "Screen4"
                  : screensRes['screen']['screen4'];
            });
          }

          Response menuResponse = await dio.get(APIData.topMenu,
              options: Options(method: 'GET', headers: {
                // ignore: deprecated_member_use
                HttpHeaders.AUTHORIZATION: "Bearer ${user['access_token']}!",
              }));
//          var topMDatanew = json.decode(menuResponse2.data);
          topMData = menuResponse.data;

          Response allMovieApiResponse = await dio.get(APIData.allMovies,
              options: Options(method: 'GET', headers: {
                // ignore: deprecated_member_use
                HttpHeaders.AUTHORIZATION: "Bearer ${user['access_token']}!",
                HttpHeaders.contentTypeHeader: "application/json"
              }));

          var allMovieDataResponse = allMovieApiResponse.data;

          Response sliderResponse = await dio.get(APIData.sliderApi,
              options: Options(method: 'GET', headers: {
                // ignore: deprecated_member_use
                HttpHeaders.AUTHORIZATION: "Bearer ${user['access_token']}!",
                HttpHeaders.contentTypeHeader: "application/json"
              }));

          Response showWatchlistResponse = await dio.get(APIData.watchListApi,
              options: Options(method: 'GET', headers: {
                // ignore: deprecated_member_use
                HttpHeaders.AUTHORIZATION: "Bearer ${user['access_token']}!",
                HttpHeaders.contentTypeHeader: "application/json"
              }));

          var showWatchlistData = showWatchlistResponse.data;

          sliderResponseData = sliderResponse.data;
          sliderData = sliderResponseData['slider'];

          showWatchlist = showWatchlistData['wishlist'];

          setState(() {
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
          });

          Response compData = await dio.get(APIData.movieTvApi,
              options: Options(method: 'GET', headers: {
                // ignore: deprecated_member_use
                HttpHeaders.AUTHORIZATION: "Bearer ${user['access_token']}!",
                HttpHeaders.contentTypeHeader: "application/json"
              }));

          var aData = compData.data;
          List aData2 = aData['data'];

          Response mainResponse2 = await dio.get(APIData.allDataApi,
              options: Options(method: 'GET', headers: {
                // ignore: deprecated_member_use
                HttpHeaders.AUTHORIZATION: "Bearer ${user['access_token']}!",
                HttpHeaders.contentTypeHeader: "application/json"
              }));

          Response stripeDetailsResponse =
              await dio.get(APIData.stripeDetailApi,
                  options: Options(method: 'GET', headers: {
                    // ignore: deprecated_member_use
                    HttpHeaders.AUTHORIZATION:
                        "Bearer ${user['access_token']}!",
                    HttpHeaders.contentTypeHeader: "application/json"
                  }));

          stripeData = stripeDetailsResponse.data;

          if (stripeData != "error") {
            stripeKey = stripeData['key'];
            stripePass = stripeData['pass'];
            payStackKey = stripeData['paystack'];
            razorPayKey = stripeData['razorkey'];
            paytmKey = stripeData['paytmkey'];
            paytmMerchantKey = stripeData['paytmpass'];
          }

          Response response2 = await dio.get(APIData.faq);
          faqApiData = response2.data;
          faqHelp = faqApiData['faqs'];

          var mainData2 = mainResponse2.data;
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
              idTM = searchIds2[index]['comments'];
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
              iFrameLink: "$iFrameURL",
              readyUrl: '$iReadyUrl',
              videoLink: "$videoLink",
              url360: "$vUrl360",
              url480: "$vUrl480",
              url720: "$vUrl720",
              url1080: "$vUrl1080",
              screenshots: List.generate(3, (int xyz) {
                return type == "T"
                    ? "${APIData.tvImageUriPosterTv}" +
                        "${searchIds2[index]['poster']}"
                    : "${APIData.movieImageUriPosterMovie}" +
                        "${searchIds2[index]['poster']}";
              }),
              url: '${searchIds2[index]['trailer_url']}',
              menuId: 1,
              genre: List.generate(singleId == null ? 0 : singleId.length,
                  (int xyz) {
                return "${singleId[xyz]}";
              }),
              genres: List.generate(genreData2 == null ? 0 : genreData2.length,
                  (int xyz) {
                var genreId2 = genreData2[xyz]['id'].toString();
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
                  if (genreData2[xyz]['name'] == null) {
                    return null;
                  } else {
                    return "${genreData2[xyz]['name']}";
                  }
                }
                return null;
              }),
              seasons:
                  List<Seasons>.generate(se2 == null ? 0 : se2.length, (int s) {
                if (type == "T") {
                  return Seasons(
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
              comments: List<CommentsModel>.generate(
                  idTM == null ? 0 : idTM.length, (int comIndex) {
                return CommentsModel(
                  id: idTM[comIndex]['id'],
                  cComment: idTM[comIndex]['comment'],
                  cMovieId: idTM[comIndex]['movie_id'],
                  cEmail: idTM[comIndex]['email'],
                  cName: idTM[comIndex]['name'],
                  cTvSeriesId: idTM[comIndex]['tv_series_id'],
                  cCreatedAt: idTM[comIndex]['created_at'],
                  cUpdatedAt: idTM[comIndex]['updated_at'],
                );
              }),
              aLang: '${searchIds2[index]['a_language']}',
              maturityRating: '${searchIds2[index]['maturity_rating']}',
              duration: type == "T"
                  ? 'Not Available'
                  : '${searchIds2[index]['duration']}',
              released: type == "T"
                  ? 'Not Available'
                  : '${searchIds2[index]['released']}',
              vStatus: "${searchIds2[index]['status']}",
            );
          });

          userWatchListOld.removeWhere((item) => item.vStatus == 0);

          userWatchList = List<WatchlistModel>.generate(
              showWatchlist == null ? 0 : showWatchlist.length, (int index) {
            return showWatchlist[index]['season_id'] != null
                ? new WatchlistModel(
                    id: showWatchlist[index]['id'],
                    wUserId: showWatchlist[index]['user_id'],
                    season_id: showWatchlist[index]['season_id'],
                    added: showWatchlist[index]['added'],
                    wCreatedAt: '${showWatchlist[index]['created_at']}',
                    wUpdatedAt: '${showWatchlist[index]['updated_at']}',
                  )
                : new WatchlistModel(
                    id: showWatchlist[index]['id'],
                    wUserId: showWatchlist[index]['user_id'],
                    wMovieId: showWatchlist[index]['movie_id'],
                    added: showWatchlist[index]['added'],
                    wCreatedAt: '${showWatchlist[index]['created_at']}',
                    wUpdatedAt: '${showWatchlist[index]['updated_at']}',
                  );
          });
          setState(() {
            loginConfigData = homeApiResponseData['config'];
            topMenuData = topMData['menu'];
            menuList = topMenuData.length;
            fullData = "Bearer ${user['access_token']}!";
            mDataCount = allMovieDataResponse['movie'];
            movieDataLength = mDataCount.length;
          });

          setState(() {
            dataUser = response.data;
            userDetail = dataUser['user'];
            userPaypalPayId = dataUser['payid'];
            isAdmin = userDetail['is_admin'];
            userId = userDetail['id'];
            userName = userDetail['name'];
            userEmail = userDetail['email'];
            userMobile = userDetail['mobile'];
            userDOB = userDetail['dob'];
            userCreatedAt = userDetail['created_at'];
            stripeCustomerId = userDetail['stripe_id'];
            userActivePlan = dataUser['current_subscription'];
            userPaymentType = dataUser['payment'];
            userPaypalHistory = dataUser['paypal'];
            userStripeHistory = userDetail['subscriptions'];
            donationStatus = showPaymentGateway['donation'];
            blogStatus = showPaymentGateway['blog'];
            fbLoginStatus = showPaymentGateway['fb_login'];
            mScreenCount = dataUser['screen'];
            videoCommentsStatus = showPaymentGateway['comments'];
            donationUrl = showPaymentGateway['donation_link'];
            userExpiryDate = dataUser['end'];
            userImage = userDetail['image'];
            status = dataUser['active'];
            userPlanStart = dataUser['start'] != null
                ? DateTime.parse(dataUser['start'])
                : 'N/A';
            userPlanEnd = dataUser['end'] != null
                ? DateTime.parse(dataUser['end'])
                : 'N/A';
            currentDate = dataUser['current_date'] != null
                ? DateTime.parse(dataUser['current_date'])
                : 'N/A';
            faqHelp = faqApiData['faqs'];

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
//            downloadLimit=dataUser['limit'];
//            mScreenCount=dataUser['screen'];
          });

          setState(() {
            showWatchlist = showWatchlistData['wishlist'];
            blogResponse = homeApiResponseData['blogs'];
            userId = userDetail['id'];
            code = dataUser['code'];
            name = userName;
            nameInitial = userName[0];
            email = userEmail;
            expiryDate = userExpiryDate;
            activeStatus = userActiveStatus;
            userPaypalHistory = dataUser['paypal'];
            userStripeHistory = userDetail['subscriptions'];
            if (isAdmin == 1) {
              role = "Admin";
            } else {
              role = "User";
            }
            if (userMobile == null) {
              mobile = "N/A";
            } else {
              mobile = userMobile;
            }
            if (userDOB == null) {
              dob = 'N/A';
            } else {
              dob = userDOB;
            }
            if (userCreatedAt == null) {
              created_at = "";
            } else {
              created_at = userCreatedAt;
            }
            if (userActivePlan == null) {
              activePlan = "";
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
                status == "0") {
              difference = null;
            }
          });
          var homeScreenRouter = new MaterialPageRoute(
              builder: (BuildContext context) =>
                  new BottomNavigationBarController());

          if (status == "1") {
            var multiScreenRouter = new MaterialPageRoute(
                builder: (BuildContext context) => new MultiScreenPage());

            if (userPaymentType == "Free") {
              Navigator.of(context).push(homeScreenRouter);
            } else if (fileContent['screenName'] != null) {
              if (screen1 == fileContent['screenName']) {
                setState(() {
                  myActiveScreen = screen1;
                });

                Navigator.of(context).push(homeScreenRouter);
//                }
              } else if (screen2 == fileContent['screenName']) {
                setState(() {
                  myActiveScreen = screen2;
                });

                // push route to home
                Navigator.of(context).push(homeScreenRouter);
//                }
              } else if (screen3 == fileContent['screenName']) {
                setState(() {
                  myActiveScreen = screen3;
                });
                Navigator.of(context).push(homeScreenRouter);
//                }
              } else if (screen4 == fileContent['screenName']) {
                setState(() {
                  myActiveScreen = screen4;
                });
                // push route to home
                Navigator.of(context).push(homeScreenRouter);
//                }
              } else {
                var multiScreenRouter = new MaterialPageRoute(
                    builder: (BuildContext context) => new MultiScreenPage());
                Navigator.of(context).push(multiScreenRouter);
              }
            } else {
              Navigator.of(context).push(multiScreenRouter);
            }
          } else {
            Navigator.of(context).push(homeScreenRouter);
          }
        } else {
          if (homeDataBlocks != null) {
            var router = new MaterialPageRoute(
                builder: (BuildContext context) => new IntroScreen());
            Navigator.of(context).push(router);
          }
        }
      }
    } catch (e) {
      print("Excepion $e");
    }

    return (null);
  }

// One Signal In-app notification example
  oneSignalInAppMessagingTriggerExamples() async {
    OneSignal.shared.addTrigger("trigger_1", "one");

    Map<String, Object> triggers = new Map<String, Object>();
    triggers["trigger_2"] = "two";
    triggers["trigger_3"] = "three";
    OneSignal.shared.addTriggers(triggers);

    OneSignal.shared.removeTriggerForKey("trigger_2");

    // ignore: unused_local_variable
    Object triggerValue =
        await OneSignal.shared.getTriggerValueForKey("trigger_3");
    List<String> keys = new List<String>();
    keys.add("trigger_1");
    keys.add("trigger_3");
    OneSignal.shared.removeTriggersForKeys(keys);

    OneSignal.shared.pauseInAppMessages(false);
  }

// For One Signal permission
  void _handleConsent() {
    OneSignal.shared.consentGranted(true);
    this.setState(() {
      _enableConsentButton = false;
    });
  }

// For One Signal notification
  Future<void> initPlatformState() async {
    if (!mounted) return;

    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

    OneSignal.shared.setRequiresUserPrivacyConsent(_requireConsent);

    var settings = {
      OSiOSSettings.autoPrompt: false,
      OSiOSSettings.promptBeforeOpeningPushUrl: true
    };

    OneSignal.shared
        .setNotificationReceivedHandler((OSNotification notification) {
      this.setState(() {
        _debugLabelString =
            "Received notification: \n${notification.jsonRepresentation().replaceAll("\\n", "\n")}";
      });
    });

    OneSignal.shared
        .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      this.setState(() {
        _debugLabelString =
            "Opened notification: \n${result.notification.jsonRepresentation().replaceAll("\\n", "\n")}";
      });
    });

    OneSignal.shared
        .setInAppMessageClickedHandler((OSInAppMessageAction action) {
      this.setState(() {
        _debugLabelString =
            "In App Message Clicked: \n${action.jsonRepresentation().replaceAll("\\n", "\n")}";
      });
    });

    OneSignal.shared
        .setSubscriptionObserver((OSSubscriptionStateChanges changes) {});

    OneSignal.shared
        .setPermissionObserver((OSPermissionStateChanges changes) {});

    OneSignal.shared.setEmailSubscriptionObserver(
        (OSEmailSubscriptionStateChanges changes) {});

    await OneSignal.shared.init(APIData.onSignalAppId, iOSSettings: settings);

    OneSignal.shared
        .setInFocusDisplayType(OSNotificationDisplayType.notification);

    bool requiresConsent = await OneSignal.shared.requiresUserPrivacyConsent();

    this.setState(() {
      _enableConsentButton = requiresConsent;
    });
    oneSignalInAppMessagingTriggerExamples();
  }

  Widget loading() {
    return Expanded(
        child: Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          animatedOpacityLogo(),
          Padding(padding: EdgeInsets.only(top: 20.0)),
          animatedOpacityCircular(),
        ],
      ),
    ));
  }

  Widget animatedOpacityLogo() {
    return AnimatedOpacity(
      opacity: _visible == true ? 1.0 : 0.0,
      duration: Duration(milliseconds: 500),
      child: loginConfigData == null
          ? SizedBox(
              height: 25.0,
            )
          : AnimatedOpacity(
              opacity: _visible2 == true ? 1.0 : 0.0,
              duration: Duration(milliseconds: 1000),
              child: new CachedNetworkImage(
                imageUrl: '${APIData.logoImageUri}${loginConfigData['logo']}',
              ),
            ),
    );
  }

  Widget animatedOpacityCircular() {
    return AnimatedOpacity(
        opacity: _visible == true ? 1.0 : 0.0,
        duration: Duration(milliseconds: 500),
        child: _visible3 == true
            ? CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),
              )
            : CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.green),
              ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
              decoration: BoxDecoration(
            color: primaryDarkColor,
          )),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              loading(),
            ],
          )
        ],
      ),
    );
  }
}
