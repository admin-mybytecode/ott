import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:nexthour/apidata/apidata.dart';
import 'package:nexthour/global.dart';
import 'package:nexthour/loading/loading_page.dart';
import 'package:nexthour/ui/signup.dart';
import 'package:nexthour/ui/webview.dart';
import 'package:nexthour/widget/email_field.dart';
import 'package:nexthour/widget/password_field.dart';
import 'package:path_provider/path_provider.dart';
import 'package:nexthour/widget/reset_alert_container.dart';

File jsonFile;
Directory dir;
String fileName = "userJSON.json";
bool fileExists = false;
Map<dynamic, dynamic> fileContent;
var acct;

class LoginForm extends StatefulWidget {
  @override
  LoginFormState createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  String pass;
  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();

  String msg = '';
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final formKey = new GlobalKey<FormState>();

  @override
  void initState() {
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

//    Validate the form and and start loading home page
  void _submit() {
    final form = formKey.currentState;
    form.save();
    if (form.validate() == true) {
      startLoading();
    }
  }

//    Start loading page
  void startLoading() {
    var router = new MaterialPageRoute(
        builder: (BuildContext context) => new LoadingPage(
              isSelected: true,
              useremail: _emailController.text,
              userpass: _passwordController.text,
            ));
    Navigator.of(context).push(router);
  }

//    When user is enter wrong credentials it calls and generate login error
  void loginError() {
    Scaffold.of(context).showSnackBar(
      new SnackBar(
        backgroundColor: Colors.red,
        content: new Container(
          height: 50.0,
          child: new Column(
            children: <Widget>[
              new Text(
                "The user credentias were incorrect..!",
                style:
                    new TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }

//    When network is disconnected when logging
  void noNetwork() {
    Scaffold.of(context).showSnackBar(
      new SnackBar(
        content: new Text('Please Check Network Connection!'),
      ),
    );
  }

//    Create file to save the login email and password
  void createFile(Map<String, String> content, Directory dir, String fileName) {
    print("Creating file!");
    File file = new File(dir.path + "/" + fileName);
    file.createSync();
    setState(() {
      fileExists = true;
    });
    file.writeAsStringSync(json.encode(content));
    this.setState(() => fileContent = json.decode(jsonFile.readAsStringSync()));
  }

//    write email and password in the file
  void writeToFile(String key, String value) {
    print("Writing to file!");
    Map<String, String> content = {key: value};
    if (fileExists) {
      print("File exists");
      Map<dynamic, dynamic> jsonFileContent =
          json.decode(jsonFile.readAsStringSync());
      jsonFileContent.addAll(content);
      jsonFile.writeAsStringSync(json.encode(jsonFileContent));
    } else {
      print("File does not exist!");
      createFile(content, dir, fileName);
    }

    this.setState(() => fileContent = json.decode(jsonFile.readAsStringSync()));
//    print(fileContent);
  }

////    Tap on the radio button to remember password for future login
//    void _radio() {
//    setState(() {
//      _isSelected = !_isSelected;
//    });
//  }

//    Sign text heading
  Widget signInHeadingText() {
    return Padding(
      padding: EdgeInsets.only(left: 10.0, right: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            "Sign In..!",
            style: TextStyle(
                color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.start,
          )
        ],
      ),
    );
  }

//    Logo image on login page
  Widget logoImage() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 15.0, left: 20.0),
          child: Container(
            child: homeApiResponseData == null
                ? new Image.asset(
                    'assets/logo.png',
                    scale: 0.9,
                  )
                : CachedNetworkImage(
                    imageUrl:
                        '${APIData.logoImageUri}${loginConfigData['logo']}',
                  ),
          ),
        ),
      ],
    );
  }

//    SignIn material button
  Widget signInMaterialButton() {
    return MaterialButton(
        height: 50.0,
        splashColor: Color.fromRGBO(125, 183, 91, 1.0),
        child: Text(
          "Login",
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          SystemChannels.textInput.invokeMethod('TextInput.hide');
          // ignore: unnecessary_statements
          _submit();
        });
  }

//    Register here text line
  Widget registerHereText() {
    return InkWell(
      child: new RichText(
        textAlign: TextAlign.center,
        text: new TextSpan(
          text: 'Register',
          style: new TextStyle(
              color: redPrime, fontSize: 17.5, fontWeight: FontWeight.bold),
        ),
      ),
      onTap: () {
        var router = new MaterialPageRoute(
            builder: (BuildContext context) => new SignUpForm());
        Navigator.of(context).push(router);
      },
    );
  }

//    Email text
  Widget emailText() {
    return Padding(
      padding:
          EdgeInsets.only(left: 25.0, right: 10.0, bottom: 10.0, top: 50.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            "Email",
            style: TextStyle(
                color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.start,
          )
        ],
      ),
    );
  }

//    Password text
  Widget passwordText() {
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
                color: textColor, fontSize: 18, fontWeight: FontWeight.w600),
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }

//    SignIn button container
  Widget signInButtonContainer() {
    return InkWell(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 50.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
            // Add one stop for each color. Stops should increase from 0 to 1
            stops: [0.1, 0.5, 0.7, 0.9],
            colors: [
              // Colors are easy thanks to Flutter's Colors class.
              Colors.red.withOpacity(1.0),
              Colors.red.withOpacity(0.9),
              Colors.red.withOpacity(0.8),
              Colors.red.withOpacity(0.7),
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
        child: signInMaterialButton(),
      ),
    );
  }

//    Row is sub widget of ListTile that contains remember me radio button and sign in button.
  Widget signInButtonListRow() {
    return ListTile(
        title: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        signInButtonContainer(),
      ],
    ));
  }

//    Forgot password field
  Widget forgotPasswordField() {
    return FlatButton(
      child: Text(
        'Forgot Password? ',
        style: new TextStyle(
          color: textColor,
          fontSize: 14.0,
        ),
      ),
      onPressed: resetPasswordAlertBox,
    );
  }

  Widget termsandcoditions() {
    return FlatButton(
      child: Text(
        'By tapping Login you agreed to our Terms and Conditions.',
        textAlign: TextAlign.center,
        style: new TextStyle(
          color: Colors.blue,
          fontSize: 14.0,
        ),
      ),
      onPressed:(){
        var router = new MaterialPageRoute(
            builder: (BuildContext context) => new CustomWebView(url: APIData.termsandcondition,appbarTitle: "Terms and Conditions",));
        Navigator.of(context).push(router);
      },
    );
  }

  resetPasswordAlertBox() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            contentPadding: EdgeInsets.only(top: 10.0),
            content: ResetAlertBoxContainer(),
          );
        });
  }

//    Login form
  Widget form() {
    return Form(
      onWillPop: () async {
        return true;
      },
      key: formKey,
      child: Container(
        alignment: Alignment.center,
        child: Container(
          child: ListView(
            padding: EdgeInsets.only(top: 30.0),
            children: [
              Container(
                child: Padding(
                  padding: const EdgeInsets.only(left:30.0,right: 30),
                  child: Image.asset(
                    'assets/logo.png',
                  ),
                ),
              ),
              emailText(),
              Padding(
                padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                child: EmailField(_emailController),
              ),
              passwordText(),
              Padding(
                padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 30.0),
                child: HiddenPasswordField(
                    _passwordController, "Enter your password"),
              ),
              signInButtonListRow(),
              forgotPasswordField(),
              termsandcoditions()
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0.0,
        actions: [
          Center(
            widthFactor: 1.5,
            child: registerHereText(),
          ),
        ],
      ),
      body: Container(child: form()),
      backgroundColor: primaryColor,
    );
  }
}
