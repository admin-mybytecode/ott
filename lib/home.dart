import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:nexthour/loading/loading_page.dart';
import 'package:html/dom.dart' as dom;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:nexthour/global.dart';
import 'package:nexthour/apidata/apidata.dart';
import 'package:nexthour/ui/login_page.dart';
import 'package:nexthour/ui/signup.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

DateTime currentBackPressTime;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _visible = false;
  bool isLoggedIn = false;
  var profileData;
  var facebookLogin = FacebookLogin();

  Future<String> loginFacebook(email, password, code, name) async {
    final accessTokenResponse = await http.post(APIData.fbLoginApi, body: {
      "email": email,
      "password": password,
      "code": code,
      "name": name,
    });

    if (accessTokenResponse.statusCode == 200) {
      var route = MaterialPageRoute(
          builder: (BuildContext context) => LoadingPage(
              isSelected: true, useremail: email, userpass: password));
      Navigator.of(context).push(route);
    } else {
      Fluttertoast.showToast(msg: "Error in login");
    }
    return null;
  }

// Basic details of app
  Future<String> basicDetails() async {
    final homeDataApiResponse = await http.get(
      Uri.encodeFull(APIData.homeDataApi),
    );

    homeApiResponseData = json.decode(homeDataApiResponse.body);

    setState(() {
      loginImageData = homeApiResponseData['login_img'];
      loginConfigData = homeApiResponseData['config'];
      homeDataBlocks = homeApiResponseData['blocks'];
      fbLoginStatus = loginConfigData['fb_login'];
      if (fbLoginStatus == "1") {
        fbLoginStatus = 1;
      }
    });
    return null;
  }

// Used to show toast on back press to confirm exit
  Future<bool> onWillPopS() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: "Press again to exit.");
      return Future.value(false);
    }
    return SystemNavigator.pop();
  }

// Permission for onesignal notification
  void _handleConsent() {
    OneSignal.shared.consentGranted(true);
  }

  void onLoginStatusChanged(bool isLoggedIn, {profileData}) {
    setState(() {
      this.isLoggedIn = isLoggedIn;
      this.profileData = profileData;
    });
  }

//   Check if user is already login with facebook
  void initiateFacebookLogin2() async {
    var facebookLoginResult3 = await facebookLogin.isLoggedIn;
    if (facebookLoginResult3 == true) {
      initiateFacebookLogin();
    }
  }

// Initialize login with facebook
  void initiateFacebookLogin() async {
    var facebookLoginResult;
    var facebookLoginResult2 = await facebookLogin.isLoggedIn;
    print(facebookLoginResult2);
    if (facebookLoginResult2 == true) {
      facebookLoginResult = await facebookLogin.currentAccessToken;

      var graphResponse = await http.get(
          'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,picture.height(200)&access_token=${facebookLoginResult.token}');

      var profile = json.decode(graphResponse.body);

      print("Token: ${facebookLoginResult.token}");

      print(profile.toString());
      var name = profile['name'];
      var email = profile['email'];
      var code = profile['id'];
      var password = "123456";
//      print("Name: $name");
//      print("Email: $email");

      loginFacebook(email, password, code, name);

      onLoginStatusChanged(true, profileData: profile);
    } else {
      facebookLoginResult = await facebookLogin.logIn(['email']);

      switch (facebookLoginResult.status) {
        case FacebookLoginStatus.error:
          onLoginStatusChanged(false);
          break;
        case FacebookLoginStatus.cancelledByUser:
          onLoginStatusChanged(false);
          break;
        case FacebookLoginStatus.loggedIn:
          var graphResponse = await http.get(
              'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,picture.height(200)&access_token=${facebookLoginResult.accessToken.token}');

          var profile = json.decode(graphResponse.body);
          var name = profile['name'];
          var email = profile['email'];
          var code = profile['id'];
          var password = "123456";
          print("Name: $name");
          print("Email: $email");
          print("Token: ${facebookLoginResult.accessToken.token}");
          loginFacebook(email, password, code, name);
          print(profile.toString());
          onLoginStatusChanged(true, profileData: profile);
          break;
      }
    }
  }

  Widget welcomeTitle() {
    return Text(
      "Welcome to " + "${loginConfigData['title']}",
      textAlign: TextAlign.center,
      style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          fontFamily: "AvenirNext",
          color: whiteColor),
    );
  }

//  Register button
  Widget registerButton() {
    return ListTile(
        title: MaterialButton(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
            height: 50.0,
            color: whiteColor,
            textColor: textColor,
            child: new Text("Register"),
            onPressed: () {
              var router = new MaterialPageRoute(
                  builder: (BuildContext context) => SignUpForm());
              Navigator.of(context).push(router);
            }));
  }

//  Setting background design of login button
  Widget loginButton() {
    return MaterialButton(
        height: 50.0,
        textColor: whiteColor,
        child: new Text("Login"),
        onPressed: () {
          var router = new MaterialPageRoute(
              builder: (BuildContext context) => new LoginPage());
          Navigator.of(context).push(router);
        });
  }

  Widget loginListTile() {
    return ListTile(
        title: Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40.0),
          // gradient: LinearGradient(
          //   // Where the linear gradient begins and ends
          //   begin: Alignment.topCenter,
          //   end: Alignment.bottomRight,
          //   // Add one stop for each color. Stops should increase from 0 to 1
          //   stops: [0.1, 0.5, 0.7, 0.9],
          //   colors: [
          //     // Colors are easy thanks to Flutter's Colors class.
          //     Color(0xffeb4334).withOpacity(0.5),
          //     Color(0xffeb4334).withOpacity(0.5),
          //     Color(0xffeb4334).withOpacity(0.6),
          //     Color(0xffeb4334).withOpacity(0.6),
          //   ],
          // ),
          color: redPrime),
      child: loginButton(),
    ));
  }

// Facebook login
  Widget facebookLoginButton() {
    return ListTile(
      title: new MaterialButton(
          height: 50.0,
          color: Color.fromRGBO(60, 90, 153, 1.0),
          textColor: textColor,
          child: new Text("Login with Facebook"),
          onPressed: () {
            initiateFacebookLogin();
          }),
    );
  }

// If you get HTML tag in copy right text
  Widget html() {
    return Html(
      data: loginImageData == null
          ? """</div>"""
          : """${loginConfigData['copyright']}</div>""",
      customTextAlign: (dom.Node node) {
        if (node is dom.Element) {
          switch (node.localName) {
            case "p":
              return TextAlign.center;
          }
        }
        return null;
      },
    );
  }

// Copyright text
  Widget copyRightTextContainer() {
    return Container(
      margin: EdgeInsets.only(bottom: 5.0),
      child: new Align(
          alignment: FractionalOffset.bottomCenter,
          heightFactor: 100,
          child: new Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  //    For setting copyright text on the login page
                  loginImageData == null
                      ? SizedBox.shrink()
                      : Container(
                          width: 300,
                          child: Html(
                            customTextAlign: (ele) {
                              return TextAlign.center;
                            },
                            data: loginConfigData['copyright'],
                          )),
// If you get HTML tag in copy right text
//                  html(),
                ],
              ),
            ],
          )),
    );
  }

// Background image filter
  Widget imageBackDropFilter() {
    return BackdropFilter(
      filter: new ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
      child: new Container(
        decoration: new BoxDecoration(color: Colors.black.withOpacity(0.0)),
      ),
    );
  }

// ListView contains buttons and logo
  Widget listView() {
    if (fbLoginStatus == 1) {
      setState(() {
        fbLoginStatus = "1";
      });
    }
    return ListView(
      children: <Widget>[
        SizedBox(
          height: 100.0,
        ),
        loginConfigData == null
            ? SizedBox(
                height: 0.0,
              )
            : AnimatedOpacity(
/*
  If the widget is visible, animate to 0.0 (invisible).
  If the widget is hidden, animate to 1.0 (fully visible).
*/
                //
                opacity: _visible == true ? 1.0 : 0.0,
                duration: Duration(milliseconds: 500),

/*
For setting logo image that is accessed from the server using API.
You can change logo by server
*/

                child: CachedNetworkImage(
                  imageUrl: '${APIData.logoImageUri}${loginConfigData['logo']}',
                  //imageScale: 1.5,
                  width: 150.0,
                  height: 150.0,
                ),
              ),
        SizedBox(
          height: 20.0,
        ),
/*
  For setting title on the Login or registration page that is accessed from the server using API.
  You can change this title by server
*/
        welcomeTitle(),
        SizedBox(
          height: 5.0,
        ),
        Text(
          "Sign in to continue",
          textAlign: TextAlign.center,
          style: TextStyle(color: whiteColor),
        ),
        SizedBox(
          height: 50.0,
        ),
        loginListTile(),
        registerButton(),
        fbLoginStatus == "1" ? facebookLoginButton() : SizedBox.shrink(),
        SizedBox(
          height: 5.0,
        ),
      ],
    );
  }

//Overall this page in Stack
  Widget stack() {
    return Stack(
      children: <Widget>[
        loginImageData == null
            ? Column(
                children: <Widget>[
                  Container(
                    color: primaryDarkColor.withOpacity(0.48),
                  )
                ],
              )
            : Container(
                decoration: new BoxDecoration(
/*
   For setting background color of loading screen.
*/
                  color: primaryDarkColor.withOpacity(0.48),
                  image: new DecorationImage(
                      fit: BoxFit.cover,
                      colorFilter: new ColorFilter.mode(
                          Colors.black.withOpacity(0.4), BlendMode.dstATop),
/*
  For setting logo image that is accessed from the server using API.
  You can change logo by server
*/
                      // image: NetworkImage(
                      //   '${APIData.loginImageUri}${loginImageData['image']}',
                      // ),
                      image: AssetImage('assets/bg1.jpeg')),
                ),
                child: imageBackDropFilter(),
              ),
        listView(),
        copyRightTextContainer(),
      ],
    );
  }

// WillPopScope to handle app exit
  Widget willPopScope() {
    return WillPopScope(
        child: Container(
            child: Center(
          child: stack(),
        )),
        onWillPop: onWillPopS);
  }

  void initState() {
    super.initState();
    this.basicDetails();
    this._handleConsent();
    Timer(Duration(seconds: 2), () {
      setState(() {
        _visible = true;
      });
    });
  }

// build method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: willPopScope(),
    );
  }
}
