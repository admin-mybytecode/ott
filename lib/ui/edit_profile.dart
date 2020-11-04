import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:nexthour/apidata/apidata.dart';
import 'package:nexthour/global.dart';
import 'package:dio/dio.dart';
import 'package:nexthour/loading/loading_screen.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  Dio dio = new Dio();
  FormData formdata = FormData();
  TextEditingController _editNameController = new TextEditingController();
  TextEditingController _editDOBController = new TextEditingController();
  TextEditingController _editMobileController = new TextEditingController();
  DateTime _dateTime = new DateTime.now();
  String pickedDate = '';
  var sEmail;
  var sPass;
  var files;
  String status = '';
  String base64Image;
  File tmpFile;
  String errMessage = 'Error Uploading Image';
  var currentPassword, newPassword, newDob, newMobile, newName;
  bool isShowIndicator = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final formKey = new GlobalKey<FormState>();

//  Show a dialog after updating password
  Future<void> _profileUpdated(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          child: Center(
            child: Container(
              decoration: BoxDecoration(),
              child: AlertDialog(
                backgroundColor: Colors.white,
                contentPadding: const EdgeInsets.all(5.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0))),
                title: Text(
                  'Profile Saved!',
                  style: TextStyle(color: Color.fromRGBO(34, 34, 34, 1.0)),
                ),
                content: Container(
                  height: 70.0,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 2.0,
                      ),
                      Icon(FontAwesomeIcons.checkCircle,
                          size: 40.0, color: redPrime),
                      SizedBox(
                        height: 8.0,
                      ),
                      Text(
                        'Your profile updated.',
                        style:
                            TextStyle(color: Color.fromRGBO(34, 34, 34, 1.0)),
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text(
                      'Ok',
                      style: TextStyle(fontSize: 16.0, color: redPrime),
                    ),
                    onPressed: () {
                      var router = new MaterialPageRoute(
                          builder: (BuildContext context) =>
                              new LoadingScreen());
                      Navigator.of(context).push(router);
                    },
                  ),
                ],
              ),
            ),
          ),
          onWillPop: () async => false,
        );
      },
    );
  }

//  This future process the profile update and save details to the server.
  Future<String> updateProfile() async {
    newDob = DateFormat("y-MM-dd").format(_dateTime);
    newMobile = _editMobileController.text;
    print("dek: $newMobile");
    newName = _editNameController.text;
    String imagefileName = tmpFile != null ? tmpFile.path.split('/').last : '';
    try {
      if (imagefileName != '') {
        formdata = FormData.fromMap({
          "email": sEmail,
          "current_password": sPass,
          "new_password": sPass,
          "dob": newDob,
          "mobile": newMobile,
          "name": newName,
          "image": await MultipartFile.fromFile(tmpFile.path,
              filename: imagefileName),
        });
      } else {
        formdata = FormData.fromMap({
          "email": sEmail,
          "current_password": sPass,
          "new_password": sPass,
          "dob": newDob,
          "mobile": newMobile,
          "name": newName,
        });
      }

      await dio
          .post(APIData.userProfileUpdate,
              data: formdata,
              options: Options(method: 'POST', headers: {
                // ignore: deprecated_member_use
                HttpHeaders.AUTHORIZATION: nToken == null ? fullData : nToken,
              }))
          .then((response) {
        setState(() {
          isShowIndicator = false;
        });
        _profileUpdated(context);
      }).catchError((error) {
        setState(() {
          isShowIndicator = false;
        });
        Fluttertoast.showToast(msg: error.toString());
        print(error.toString());
      });
    } catch (e) {
      setState(() {
        isShowIndicator = false;
      });
      print(e);
    }
    return null;
  }

//  For selecting image from camera
  chooseImageFromCamera() {
    setState(() {
      files = ImagePicker.pickImage(source: ImageSource.camera);
    });
  }

//  For selecting image from gallery
  chooseImageFromGallery() {
    setState(() {
      files = ImagePicker.pickImage(source: ImageSource.gallery);
    });
  }

//  This Future picks date using material date picker
  Future<Null> _selectDate() async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: new DateTime(1970),
      lastDate: new DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _editDOBController.text = pickedDate;
        _dateTime = picked;
      });
      // ignore: unrelated_type_equality_checks
      String formattedDate =
          "_dateTime" != '' ? DateFormat.yMMMd().format(_dateTime) : '';
      pickedDate = formattedDate;
    }
  }

//  Appbar

  Widget appbar() {
    return AppBar(
      elevation: 0.0,
      title: Text(
        "Edit Profile",
        style: TextStyle(fontSize: 16.0, color: textColor),
      ),
      centerTitle: true,
      leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: primaryDarkColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          }),
      backgroundColor: primaryColor,
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      jsonFile = new File(dir.path + "/" + fileName);
      fileExists = jsonFile.existsSync();
      if (fileExists)
        this.setState(
            () => fileContent = json.decode(jsonFile.readAsStringSync()));
      sEmail = fileContent['user'];
      sPass = fileContent['pass'];
    });
  }

  @override
  Widget build(BuildContext context) {
    newName = _editNameController.text;
    newDob = _editDOBController.text;
    newMobile = _editMobileController.text;
    _editNameController.text = newName != ''
        ? newName
        : name == 'N/A'
            ? ''
            : name;
    _editDOBController.text = pickedDate != ''
        ? pickedDate
        : dob == 'N/A'
            ? ''
            : dob;
    _editMobileController.text = newMobile != ''
        ? newMobile
        : mobile == 'N/A'
            ? ''
            : mobile;

    return SafeArea(
      child: Theme(
        data: ThemeData(
          primaryColor: redPrime,
          primaryColorDark: primaryDarkColor,
          scaffoldBackgroundColor: primaryColor,
          brightness: Brightness.light,
          accentColor: redPrime,
          canvasColor: redPrime,
        ),
        child: Scaffold(
          key: _scaffoldKey,
          appBar: appbar(),
          body: scaffoldBody(),
        ),
      ),
    );
  }

//  Scaffold body
  Widget scaffoldBody() {
    return SingleChildScrollView(
        child: Column(
      children: <Widget>[
        Stack(
          children: <Widget>[
            showImage(),
            browseImageButton(),
          ],
        ),
        form(),
      ],
    ));
  }

//  Browse button container
  Widget browseImageButton() {
    return Container(
      height: 45.0,
      width: 45.0,
      margin: EdgeInsets.fromLTRB(125.0, 170.0, 0.0, 0.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: redPrime,
      ),
      child: IconButton(
        icon: Icon(Icons.add_a_photo),
        color: primaryDarkColor,
        onPressed: _onButtonPressed,
      ),
    );
  }

//  Form that containing text fields to update profile
  Widget form() {
    return Container(
      padding:
          EdgeInsets.only(top: 10.0, right: 20.0, left: 20.0, bottom: 20.0),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 30.0,
            ),
            buildNameTextField("Name"),
            SizedBox(
              height: 20.0,
            ),
            buildDOBTextField("Date of Birth"),
            SizedBox(
              height: 20.0,
            ),
            buildMobileTextField("Mobile Number"),
            SizedBox(
              height: 20.0,
            ),
            SizedBox(height: 20.0),
            updateButtonContainer(),
            SizedBox(
              height: 10.0,
            ),
          ],
        ),
      ),
    );
  }

//  Name TextField to update name
  Widget buildNameTextField(String hintText) {
    return TextFormField(
      controller: _editNameController,
      keyboardType: TextInputType.text,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(5.0),
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey,
          fontSize: 16.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        prefixIcon: Icon(
          Icons.account_box,
          color: primaryDarkColor,
        ),
      ),
      validator: (val) {
        if (val.length == 0) {
          return 'Name can not be empty';
        } else {
          if (val.length < 4) {
            return 'Name required at least 5 characters.';
          } else {
            return null;
          }
        }
      },
      onSaved: (val) => _editNameController.text = val,
    );
  }

//  TextField Date of birth field
  Widget buildDOBTextField(String hintText) {
    return TextField(
      controller: _editDOBController,
      focusNode: AlwaysDisabledFocusNode(),
      onTap: _selectDate,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(5.0),
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey,
          fontSize: 16.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        prefixIcon: Icon(
          Icons.calendar_today,
          color: primaryDarkColor,
        ),
      ),
    );
  }

//  TextField to update mobile number
  Widget buildMobileTextField(String hintText) {
    return TextField(
      controller: _editMobileController,
      keyboardType: TextInputType.phone,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(5.0),
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey,
          fontSize: 16.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        prefixIcon: Icon(
          Icons.phone,
          color: primaryDarkColor,
        ),
      ),
    );
  }

//  Update button container
  Widget updateButtonContainer() {
    return InkWell(
      child: Container(
        height: 56.0,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: new BorderRadius.circular(5.0),
          // Box decoration takes a gradient
          gradient: LinearGradient(
            // Where the linear gradient begins and ends
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
            // Add one stop for each color. Stops should increase from 0 to 1
            stops: [0.1, 0.5, 0.7, 0.9],
            colors: [
              // Colors are easy thanks to Flutter's Colors class.
              redPrime.withOpacity(0.9),
              redPrime.withOpacity(0.8),
              redPrime.withOpacity(0.7),
              redPrime.withOpacity(0.6),
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
        child: Center(
          child: isShowIndicator == true
              ? CircularProgressIndicator(
                  backgroundColor: Colors.white,
                )
              : Text(
                  "Update Profile",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18.0,
                  ),
                ),
        ),
      ),
      onTap: () {
//     To remove keypad on tapping button
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        setState(() {
          isShowIndicator = true;
        });
        final form = formKey.currentState;
        form.save();
        if (form.validate() == true) {
          updateProfile();
        } else {
          setState(() {
            isShowIndicator = false;
          });
        }
      },
    );
  }

//  Preview of selected image
  Widget showImage() {
    return FutureBuilder<File>(
      future: files,
      builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            null != snapshot.data) {
          tmpFile = snapshot.data;
          base64Image = base64Encode(snapshot.data.readAsBytesSync());
          return Container(
              alignment: Alignment.center,
              height: 210.0,
              width: 170.0,
              child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.only(
                        bottomLeft: Radius.circular(25.0),
                        bottomRight: Radius.circular(25.0)),
                  ),
                  child: Container(
                      margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                      height: 190.0,
                      width: 150.0,
                      decoration: new BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          border: new Border.all(
                              color: Colors.white.withOpacity(0.0),
                              width: 10.0),
                          borderRadius: new BorderRadius.only(
                              bottomLeft: Radius.circular(25.0),
                              bottomRight: Radius.circular(25.0))),
                      child: Card(
                        margin: EdgeInsets.all(0.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.only(
                              bottomLeft: Radius.circular(25.0),
                              bottomRight: Radius.circular(25.0)),
                        ),
                        child: ClipRRect(
                          borderRadius: new BorderRadius.only(
                              bottomLeft: Radius.circular(25.0),
                              bottomRight: Radius.circular(25.0)),
                          child: tmpFile == null
                              ? userImage == null
                                  ? Image.asset(
                                      "assets/avatar.png",
                                      fit: BoxFit.cover,
                                      scale: 1.7,
                                    )
                                  : CachedNetworkImage(
                                      imageUrl: "${APIData.profileImageUri}" +
                                          "$userImage",
                                      fit: BoxFit.cover,
                                    )
                              : Image.file(
                                  tmpFile,
                                  fit: BoxFit.cover,
                                  scale: 1.7,
                                ),
                        ),
                      ))));
        } else if (null != snapshot.error) {
          return const Text(
            'Error Picking Image',
            textAlign: TextAlign.center,
          );
        } else {
          return Container(
              height: 210.0,
              width: 170.0,
              child: Card(
                  color: primaryDarkColor.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.only(
                        bottomLeft: Radius.circular(25.0),
                        bottomRight: Radius.circular(25.0)),
                  ),
                  child: Container(
                      margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                      height: 190.0,
                      width: 150.0,
                      decoration: new BoxDecoration(
                          color: primaryDarkColor.withOpacity(0.4),
                          border: new Border.all(
                              color: primaryDarkColor.withOpacity(0.0),
                              width: 10.0),
                          borderRadius: new BorderRadius.only(
                              bottomLeft: Radius.circular(25.0),
                              bottomRight: Radius.circular(25.0))),
                      child: Card(
                        margin: EdgeInsets.all(0.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.only(
                              bottomLeft: Radius.circular(25.0),
                              bottomRight: Radius.circular(25.0)),
                        ),
                        child: ClipRRect(
                          borderRadius: new BorderRadius.only(
                              bottomLeft: Radius.circular(25.0),
                              bottomRight: Radius.circular(25.0)),
                          child: tmpFile == null
                              ? userImage == null
                                  ? Image.asset(
                                      "assets/avatar.png",
                                      fit: BoxFit.cover,
                                      scale: 1.7,
                                    )
                                  : CachedNetworkImage(
                                      imageUrl: "${APIData.profileImageUri}" +
                                          "$userImage",
                                      fit: BoxFit.cover,
                                    )
                              : Image.file(
                                  tmpFile,
                                  fit: BoxFit.cover,
                                  scale: 1.7,
                                ),
                        ),
                      ))));
        }
      },
    );
  }

//  Creating bottom sheet for selecting profile picture
  Widget bottomSheet() {
    return Container(
      child: Column(
        children: <Widget>[
          InkWell(
              onTap: () {
                chooseImageFromCamera();
              },
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 0.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Icon(
                      Icons.camera,
                      color: Color.fromRGBO(34, 34, 34, 1.0),
                      size: 35,
                    ),
                    Container(
                      width: 250.0,
//                  height: 15.0,
                      child: ListTile(
                        title: Text(
                          'Camera',
                          style:
                              TextStyle(color: Color.fromRGBO(20, 20, 20, 1.0)),
                        ),
                        subtitle: Text(
                          "Click profile picture from camera.",
                          style:
                              TextStyle(color: Color.fromRGBO(20, 20, 20, 1.0)),
                        ),
                      ),
                    )
                  ],
                ),
              )),
          InkWell(
              onTap: () {
                chooseImageFromGallery();
                Navigator.pop(context);
              },
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 0.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Icon(
                      Icons.photo,
                      color: Color.fromRGBO(34, 34, 34, 1.0),
                      size: 35,
                    ),
                    Container(
                      width: 260.0,
                      child: ListTile(
                        title: Text(
                          'Gallery',
                          style:
                              TextStyle(color: Color.fromRGBO(20, 20, 20, 1.0)),
                        ),
                        subtitle: Text(
                          "Choose profile picture from gallery.",
                          style:
                              TextStyle(color: Color.fromRGBO(20, 20, 20, 1.0)),
                        ),
                      ),
                    )
                  ],
                ),
              )),
        ],
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(10.0),
          topRight: const Radius.circular(10.0),
        ),
      ),
    );
  }

//  Show bottom sheet
  void _onButtonPressed() {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return new Container(
            height: 190.0,
            color: Colors.transparent, //could change this to Color(0xFF737373),
            child: new Container(
                decoration: new BoxDecoration(
                    color: Color.fromRGBO(34, 34, 34, 1.0),
                    borderRadius: new BorderRadius.only(
                        topLeft: const Radius.circular(10.0),
                        topRight: const Radius.circular(10.0))),
                child: bottomSheet()),
          );
        });
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
