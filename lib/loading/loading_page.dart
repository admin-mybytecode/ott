import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:nexthour/apidata/apidata.dart';
import 'package:nexthour/controller/navigation_bar_controller.dart';
import 'package:nexthour/global.dart';
import 'package:nexthour/model/comments_model.dart';
import 'package:nexthour/ui/login_page.dart';
import 'package:nexthour/ui/multi_screen_page.dart';
import 'package:nexthour/utils/color_loader.dart';
import 'package:nexthour/model/WatchlistModel.dart';
import 'package:nexthour/model/video_data.dart';
import 'package:nexthour/model/seasons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock/wakelock.dart';

File jsonFile;
Directory dir;
String fileName = "userJSON.json";
bool fileExists = false;
Map<dynamic, dynamic> fileContent;

class LoadingPage extends StatefulWidget {
  LoadingPage({Key key, this.isSelected, this.useremail, this.userpass})
      : super(key: key);
  final bool isSelected;
  final String useremail;
  final String userpass;

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
    with TickerProviderStateMixin {
  Animation<double> containerGrowAnimation;
  List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.indigo,
    Colors.pinkAccent,
    Colors.blue
  ];

  bool _visible = false;
  bool _visible3 = false;

  saveNewToken() async {
    // obtain shared preferences
    prefs = await SharedPreferences.getInstance();
// set value
    prefs.setString('token', null);
  }

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      jsonFile = new File(dir.path + "/" + fileName);
      fileExists = jsonFile.existsSync();
      if (fileExists) {
        this.setState(
            () => fileContent = json.decode(jsonFile.readAsStringSync()));
      }
    });

    Timer(Duration(seconds: 1), () {
      setState(() {
        _visible = true;
      });
    });
    Timer(Duration(seconds: 2), () {
      _login();
    });

    Timer(Duration(seconds: 5), () {
      setState(() {
        _visible3 = true;
      });
    });
  }

  void loginError() {
    var router = new MaterialPageRoute(
        builder: (BuildContext context) => new LoginPage());
    Navigator.of(context).push(router);
    Fluttertoast.showToast(msg: "The user credentias were incorrect..!");
  }

  void noNetwork() {
    var router = new MaterialPageRoute(
        builder: (BuildContext context) => new LoginPage());
    Navigator.of(context).push(router);
    Fluttertoast.showToast(msg: "Please Check Network Connection!");
  }

  Future<String> _login() async {
    try {
      var dio = Dio();

      Response accessToken = await dio.post(APIData.tokenApi,
          data: {
            "email": widget.useremail,
            "password": widget.userpass,
          },
          options: Options(
              headers: {HttpHeaders.contentTypeHeader: "application/json"}));

      print(accessToken.statusCode);
      var user = accessToken.data;

      if (accessToken.statusCode == 200) {
        saveNewToken();

        Response response = await dio.get(APIData.userProfileApi,
            options: Options(method: 'GET', headers: {
              // ignore: deprecated_member_use
              HttpHeaders.AUTHORIZATION: "Bearer ${user['access_token']}!",
              HttpHeaders.contentTypeHeader: "application/json"
            }));
        print(response.statusCode);
        setState(() {
          fullData = "Bearer ${user['access_token']}!";
        });

        Response menuResponse = await dio.get(APIData.topMenu,
            options: Options(method: 'GET', headers: {
              // ignore: deprecated_member_use
              HttpHeaders.AUTHORIZATION: fullData,
              HttpHeaders.contentTypeHeader: "application/json"
            }));
        topMData = menuResponse.data;
        Response showWatchlistResponse = await dio.get(APIData.watchListApi,
            options: Options(method: 'GET', headers: {
              // ignore: deprecated_member_use
              HttpHeaders.AUTHORIZATION: fullData,
              HttpHeaders.contentTypeHeader: "application/json"
            }));

        var showWatchlistData = showWatchlistResponse.data;

        showWatchlist = showWatchlistData['wishlist'];

        Response compData = await dio.get(APIData.movieTvApi,
            options: Options(method: 'GET', headers: {
              // ignore: deprecated_member_use
              HttpHeaders.AUTHORIZATION: fullData,
              HttpHeaders.contentTypeHeader: "application/json"
            }));

        Response stripeDetailsResponse = await dio.get(APIData.stripeDetailApi,
            options: Options(method: 'GET', headers: {
              // ignore: deprecated_member_use
              HttpHeaders.AUTHORIZATION: "Bearer ${user['access_token']}!",
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

        var aData = compData.data;

        List aData2 = aData['data'];
        print(accessToken.statusCode);

        Response mainResponse2 = await dio.get(APIData.allDataApi,
            options: Options(method: 'GET', headers: {
              // ignore: deprecated_member_use
              HttpHeaders.AUTHORIZATION: "Bearer ${user['access_token']}!",
              HttpHeaders.contentTypeHeader: "application/json"
            }));

        Response userProfileApiResponse = await dio.get(APIData.userProfileApi,
            options: Options(method: 'GET', headers: {
              // ignore: deprecated_member_use
              HttpHeaders.AUTHORIZATION: fullData,
              HttpHeaders.contentTypeHeader: "application/json"
            }));

        userProfileApiData = userProfileApiResponse.data;

        status = userProfileApiData['active'];
        userPlanStart = userProfileApiData['start'] != null
            ? DateTime.parse(userProfileApiData['start'])
            : 'N/A';
        userPlanEnd = userProfileApiData['end'] != null
            ? DateTime.parse(userProfileApiData['end'])
            : 'N/A';
        currentDate = userProfileApiData['current_date'] != null
            ? DateTime.parse(userProfileApiData['current_date'])
            : 'N/A';

        final faqApiResponse = await dio.get(APIData.faq);

        faqApiData = faqApiResponse.data;
        faqHelp = faqApiData['faqs'];

        var mainData2 = mainResponse2.data;
        var genreData2 = mainData2['genre'];

        int dataLen = aData2.length == null ? 0 : aData2.length;
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
                print("double Rating: ${searchIds2[index]['rating']}");

                double tmdbrating = searchIds2[index]['rating'] == null
                    ? 0
                    : searchIds2[index]['rating'];
                convrInStart = tmdbrating != null ? tmdbrating / 2 : 0;
                print("double Name: ${searchIds2[index]['title']}");
              }
              break;
            case int:
              {
                print("ing Rating: ${searchIds2[index]['rating']}");
                print("int  Name: ${searchIds2[index]['title']}");
                var tmdbrating = searchIds2[index]['rating'] == null
                    ? 0
                    : searchIds2[index]['rating'];
                convrInStart = tmdbrating != null ? tmdbrating / 2 : 0;
              }
              break;
            case String:
              {
                print("double2 Rating: ${searchIds2[index]['rating']}");
                print("double2 Name: ${searchIds2[index]['title']}");
                var tmdbrating = searchIds2[index]['rating'] == null
                    ? 0
                    : double.parse(searchIds2[index]['rating']);
                convrInStart = tmdbrating != null ? tmdbrating / 2 : 0;
              }
              break;
          }

          List<dynamic> se2;
          var idTM;
          if (type == "T") {
            print("103");
            se2 = searchIds2[index]['seasons'] as List<dynamic>;
            idTM = searchIds2[index]['comments'];
          } else {
            se2 = searchIds2[index]['movie_series'] as List<dynamic>;
            idTM = searchIds2[index]['comments'];
            videoLink = searchIds2[index]['video_link'];
            iFrameURL = videoLink['iframeurl'];
            iReadyUrl = videoLink['ready_url'];
            vUrl360 = videoLink['url_360'];
            vUrl480 = videoLink['url_480'];
            vUrl720 = videoLink['url_720'];
            vUrl1080 = videoLink['url_1080'];
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
        userWatchListOld.removeWhere((item) => item.vStatus == "0");

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

        Response sliderResponse = await dio.get(APIData.sliderApi,
            options: Options(method: 'GET', headers: {
              // ignore: deprecated_member_use
              HttpHeaders.AUTHORIZATION: fullData,
              HttpHeaders.contentTypeHeader: "application/json"
            }));

        sliderResponseData = sliderResponse.data;
        print("125");
        sliderData = sliderResponseData['slider'];

        dataUser = response.data;

        setState(() {
          userDetail = dataUser['user'];
          userRole = userDetail['is_admin'];
          userImage = userDetail['image'];
          userName = userDetail['name'];
          userEmail = userDetail['email'];
          userMobile = userDetail['mobile'];
          userDOB = userDetail['dob'];
          userCreatedAt = userDetail['created_at'];
          stripeCustomerId = userDetail['stripe_id'];
          activePlan = dataUser['current_subscription'];
          userPaypalHistory = dataUser['paypal'];
          userStripeHistory = userDetail['subscriptions'];
          userActivePlan = dataUser['current_subscription'];
          userPaymentType = dataUser['payment'];
          userPaypalPayId = dataUser['payid'] != null ? dataUser['payid'] : '';
          userExpiryDate = dataUser['end'];
          status = dataUser['active'];
          userPlanStart = dataUser['start'] != null
              ? DateTime.parse(dataUser['start'])
              : 'N/A';
          userPlanEnd =
              dataUser['end'] != null ? DateTime.parse(dataUser['end']) : 'N/A';
          currentDate = dataUser['current_date'] != null
              ? DateTime.parse(dataUser['current_date'])
              : 'N/A';
          faqHelp = faqApiData['faqs'];
          showPaymentGateway = homeApiResponseData['config'];
          blogResponse = homeApiResponseData['blogs'];
          donationUrl = showPaymentGateway['donation_link'];
          blogStatus = showPaymentGateway['blog'];
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
          topMenuData = topMData['menu'];
          menuList = topMenuData.length;
          name = userName;
          email = userEmail;
          expiryDate = userExpiryDate;
          nameInitial = userName[0];
          if (userRole == 1) {
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
            activePlan = "N/A";
          } else {
            activePlan = userActivePlan;
          }
          if (userExpiryDate == null) {
            expiryDate = '';
          } else {
            expiryDate = userExpiryDate;
          }
        });
        if (status == "1") {
          if (userPaymentType == "Free") {
            var router = new MaterialPageRoute(
                builder: (BuildContext context) =>
                    new BottomNavigationBarController());
            Navigator.of(context).push(router);
          } else {
            var router = new MaterialPageRoute(
                builder: (BuildContext context) => new MultiScreenPage());
            Navigator.of(context).push(router);
          }
        } else {
          var router = new MaterialPageRoute(
              builder: (BuildContext context) =>
                  new BottomNavigationBarController());
          Navigator.of(context).push(router);
        }

        setState(() {
          message = "welcome admin";
        });

        if (widget.isSelected == true) {
          writeToFile("user", widget.useremail);
          writeToFile("pass", widget.userpass);
          writeToFile("screenName", null);
          writeToFile("screenStatus", null);
        }
      } else {
        loginError();
      }

      return null;
    } on DioError catch (e) {
      var router = new MaterialPageRoute(
          builder: (BuildContext context) => new LoginPage());
      Navigator.of(context).push(router);
      Fluttertoast.showToast(msg: "${e.response.data['error_description']}");
    } on HttpException catch (e2) {
      print("http: $e2");
      return null;
    } on SocketException catch (e3) {
      print("Socket: $e3");
      noNetwork();
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  void createFile(Map<String, String> content, Directory dir, String fileName) {
    File file = new File(dir.path + "/" + fileName);
    file.createSync();
    setState(() {
      fileExists = true;
    });
    file.writeAsStringSync(json.encode(content));
    this.setState(() => fileContent = json.decode(jsonFile.readAsStringSync()));
  }

  void writeToFile(String key, String value) {
    Map<String, String> content = {key: value};
    if (fileExists) {
      Map<dynamic, dynamic> jsonFileContent =
          json.decode(jsonFile.readAsStringSync());
      jsonFileContent.addAll(content);
      jsonFile.writeAsStringSync(json.encode(jsonFileContent));
    } else {
      createFile(content, dir, fileName);
    }

    this.setState(() => fileContent = json.decode(jsonFile.readAsStringSync()));
  }

  Widget loadingPageWidget() {
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
      // The green box must be a child of the AnimatedOpacity widget.
      child: homeApiResponseData == null
          ? new Image.asset(
              'assets/logo.png',
              scale: 0.9,
            )
          : new FadeInImage.assetNetwork(
              image: '${APIData.logoImageUri}${loginConfigData['logo']}',
              placeholder: 'assets/placeholder_box_trans.png',
              imageScale: 1.5,
            ),
    );
  }

  Widget animatedOpacityCircular() {
    return AnimatedOpacity(
      // If the widget is visible, animate to 0.0 (invisible).
      // If the widget is hidden, animate to 1.0 (fully visible).
      opacity: _visible == true ? 1.0 : 0.0,
      duration: Duration(milliseconds: 500),
      // The green box must be a child of the AnimatedOpacity widget.
      child: _visible3 == true ? ColorLoader() : ColorLoader(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
              decoration: BoxDecoration(
            color: Color.fromRGBO(34, 34, 34, 1.0),
          )),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              loadingPageWidget(),
            ],
          )
        ],
      ),
    );
  }
}
