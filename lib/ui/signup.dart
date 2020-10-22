import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:nexthour/apidata/apidata.dart';
import 'package:nexthour/global.dart';
import 'package:nexthour/loading/loading_register.dart';
import 'package:nexthour/widget/confirm_password_field.dart';
import 'package:nexthour/widget/email_field.dart';
import 'package:nexthour/widget/name_field.dart';
import 'package:nexthour/widget/password_field.dart';
import 'package:path_provider/path_provider.dart';
import 'package:nexthour/utils/wavy_header_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

File jsonFile;
Directory dir;
String fileName = "userJSON.json";
bool fileExists = false;

Map<dynamic, dynamic> fileContent;
var acct;

class SignUpForm extends StatefulWidget {
  final String name;

  SignUpForm({Key key, this.name}) : super(key: key);

  @override
  SignUpFormState createState() => SignUpFormState();
}

class SignUpFormState extends State<SignUpForm> with TickerProviderStateMixin {
  String pass;
  final TextEditingController _nameController = new TextEditingController();
  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();
  final TextEditingController _repeatPasswordController =
      new TextEditingController();
  String msg = '';
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final formKey = new GlobalKey<FormState>();

// Sign up button

  void _signUp() {
    final form = formKey.currentState;
    form.save();
    if (form.validate() == true) {
      var router = new MaterialPageRoute(
          builder: (BuildContext context) => LoadingRegister(
                scaffoldKey: scaffoldKey,
                nameController: _nameController,
                emailController: _emailController,
                passwordController: _passwordController,
                isSelected: true,
              ));
      Navigator.of(context).push(router);
    }
  }

  saveNewToken() async {
    // obtain shared preferences
    prefs = await SharedPreferences.getInstance();
// set value
    prefs.setString('token', null);
  }

  void registrationError() {
    final snackBar = new SnackBar(
      content: new Text("Already Exists"),
    );
    scaffoldKey.currentState.showSnackBar(snackBar);
  }

// Registration error
  void wentWrong() {
    final snackBar = new SnackBar(
      content: new Text("Error in Registration"),
    );
    scaffoldKey.currentState.showSnackBar(snackBar);
  }

// Loading profile
  void profileLoad() {
    final snackBar = new SnackBar(
      content: new Text("Please Wait..."),
    );
    scaffoldKey.currentState.showSnackBar(snackBar);
  }

// Network error
  void noNetwork() {
    final snackBar = new SnackBar(
      content: new Text("Please Check Network Connection!"),
    );
    scaffoldKey.currentState.showSnackBar(snackBar);
  }

  @override
  void initState() {
    _passwordController.addListener(() {
      setState(() {
        pass = _passwordController.text;
      });
    });
    super.initState();
    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      jsonFile = new File(dir.path + "/" + fileName);
      fileExists = jsonFile.existsSync();
      if (fileExists) {
        this.setState(
            () => fileContent = json.decode(jsonFile.readAsStringSync()));
      }
    });
  }

// SignUp heading text
  Widget signUpHeading() {
    return Padding(
      padding: EdgeInsets.only(left: 10.0, right: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            "Sign Up!",
            style: TextStyle(
                color: Color.fromRGBO(34, 34, 34, 1.0),
                fontSize: 22,
                fontWeight: FontWeight.w800),
            textAlign: TextAlign.start,
          )
        ],
      ),
    );
  }

// Username label text
  Widget userNameLabelText() {
    return Padding(
      padding: EdgeInsets.only(left: 25.0, right: 10.0, bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            "User Name",
            style: TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }

// Email label text
  Widget emailLabelText() {
    return Padding(
      padding:
          EdgeInsets.only(left: 25.0, right: 10.0, bottom: 10.0, top: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            "Email",
            style: TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
            textAlign: TextAlign.start,
          )
        ],
      ),
    );
  }

// password label text
  Widget passwordLabelText() {
    return Padding(
      padding:
          EdgeInsets.only(left: 25.0, right: 10.0, bottom: 10.0, top: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            "Password",
            style: TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }

// confirm password label text
  Widget confirmPasswordLabelText() {
    return Padding(
      padding:
          EdgeInsets.only(left: 25.0, right: 10.0, bottom: 10.0, top: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            "Confirm Password",
            style: TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }

// SignUp page header of StickyHeader widget
  Widget signUpPageStickyHeader() {
    return Stack(
      children: <Widget>[
        Container(
          margin: new EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
          child: WavyHeaderImage2(),
        ),
        Container(
          margin: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
          child: WavyHeaderImage(),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 15.0, left: 20.0),
              child: Container(
                  child: Image.network(
                '${APIData.logoImageUri}${loginConfigData['logo']}',
                scale: 0.9,
              )),
            ),
          ],
        ),
        IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              size: 24,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
      ],
    );
  }

//Register button tile
  Widget registerButtonTile() {
    return ListTile(
        title: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        goToSignUpButton(),
      ],
    ));
  }

// SignUp form
  Widget signUpForm() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/bg.jpg'), fit: BoxFit.cover),
      ),
      child: Form(
        onWillPop: () async {
          return true;
        },
        key: formKey,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 5.0,
            sigmaY: 5.0,
          ),
          child: ListView(
            padding: EdgeInsets.only(top: 80),
            children: [
              //stickyHeaderContent(),
              Container(
                child: Image.network(
                    APIData.logoImageUri + loginConfigData['logo']),
              ),
              SizedBox(
                height: 30.0,
              ),
              userNameLabelText(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                child: NameField(_nameController),
              ),
              emailLabelText(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                child: EmailField(_emailController),
              ),
              passwordLabelText(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                child: HiddenPasswordField(
                    _passwordController, 'Enter your password'),
              ),
              confirmPasswordLabelText(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                child: ConfirmPasswordField(_passwordController,
                    _repeatPasswordController, "Confirm password"),
              ),
              Padding(padding: EdgeInsets.only(top: 30.0)),
              registerButtonTile(),
              Padding(padding: EdgeInsets.only(bottom: 20.0))
            ],
          ),
        ),
      ),
    );
  }

// Go to sign up button
  Widget goToSignUpButton() {
    return Expanded(
      flex: 1,
      child: InkWell(
        child: Material(
          borderRadius: BorderRadius.circular(40.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: new BorderRadius.circular(40.0),
              // Box decoration takes a gradient
              gradient: LinearGradient(
                // Where the linear gradient begins and ends
                begin: Alignment.topCenter,
                end: Alignment.bottomRight,
                // Add one stop for each color. Stops should increase from 0 to 1
                stops: [0.3, 0.5, 0.7, 0.9],
                colors: [
                  // Colors are easy thanks to Flutter's Colors class.
                  redPrime.withOpacity(0.7),
                  redPrime.withOpacity(0.6),
                  redPrime.withOpacity(0.5),
                  redPrime.withOpacity(0.4),
                ],
              ),
              boxShadow: <BoxShadow>[
                new BoxShadow(
                  color: Colors.black.withOpacity(0.20),
                  blurRadius: 10.0,
                  offset: new Offset(1.0, 10.0),
                ),
              ],
            ),
            child: new MaterialButton(
                height: 50.0,
                splashColor: Colors.red,
                child: Text(
                  "Sign Up",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  SystemChannels.textInput.invokeMethod('TextInput.hide');
                  // ignore: unnecessary_statements
                  _signUp();
                }),
          ),
        ),
      ),
    );
  }

// Build method
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        body: signUpForm(),
      ),
    );
  }
}
