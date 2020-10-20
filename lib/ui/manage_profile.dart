import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nexthour/apidata/apidata.dart';
import 'package:nexthour/global.dart';
import 'package:nexthour/seekbar/src/seekbars.dart';
import 'package:nexthour/ui/edit_profile.dart';
import 'change_password.dart';

var sw = '';
var acct;

class ManageProfileForm extends StatefulWidget {
  final String name;

  ManageProfileForm({Key key, this.name}) : super(key: key);

  @override
  ManageProfileFormState createState() => ManageProfileFormState();
}

class ManageProfileFormState extends State<ManageProfileForm> {
  DateTime _date;
  var planDays;
  var progressWidth;
  var diff;

  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final formKey = new GlobalKey<FormState>();

//  Pop menu button to edit profile
  Widget _selectPopup() {
    return isAdmin == "1"
        ? PopupMenuButton<int>(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 1,
                child: Text("Change Password"),
              ),
            ],
            onCanceled: () {
              print("You have canceled the menu.");
            },
            onSelected: (value) {
              if (value == 1) {
//          print("value:$value");
                var route =
                    MaterialPageRoute(builder: (context) => ChangePassword());
                Navigator.push(context, route);
              }
            },
            icon: Icon(Icons.more_vert),
          )
        : PopupMenuButton<int>(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 1,
                child: Text("Edit Profile"),
              ),
              PopupMenuItem(
                value: 2,
                child: Text("Change Password"),
              ),
            ],
            onCanceled: () {
              print("You have canceled the menu.");
            },
            onSelected: (value) {
              if (value == 1) {
                print("value:$value");
                var route =
                    MaterialPageRoute(builder: (context) => EditProfilePage());
                Navigator.push(context, route);
              } else if (value == 2) {
                var route =
                    MaterialPageRoute(builder: (context) => ChangePassword());
                Navigator.push(context, route);
              }
            },
            icon: Icon(Icons.more_vert),
          );
  }

//  User profile image
  Widget userProfileImage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 10.0),
      child: Container(
        height: 130.0,
        width: 130.0,
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.all(
            Radius.circular(100.0),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.all(
            Radius.circular(100.0),
          ),
          child: userImage != null
              ? Image.network(
                  "${APIData.profileImageUri}" + "$userImage",
                  scale: 1.0,
                  fit: BoxFit.cover,
                )
              : Image.asset(
                  "assets/avatar.png",
                  scale: 1.0,
                  fit: BoxFit.cover,
                ),
        ),
      ),
    );
  }

//  App bar
  Widget appBar() {
    return AppBar(
      elevation: 0.0,
      title: Text(
        "Manage Profile",
        style: TextStyle(fontSize: 16.0),
      ),
      centerTitle: true,
      backgroundColor: primaryColor,
      actions: [
        _selectPopup(),
      ],
    );
  }

//  Rounded SeekBar
  Widget roundedSeekBar() {
    diff = difference == null ? sw : '$difference' + ' Days Remaining';
    return RadialSeekBar(
      trackColor: Color.fromRGBO(20, 20, 20, 1.0),
      trackWidth: 8.0,
      progressColor: difference == null ? Colors.red : redPrime,
      progressWidth: 8.0,
      progress: difference == null ? 1.0 : progressWidth,
      centerContent: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(15.0),
            child: Text(
              diff,
              style: TextStyle(color: textColor),
            ),
          )
        ],
      ),
    );
  }

//  Rounded SeekBar Container
  Widget roundedSeekBarContainer() {
    return Container(
      height: 200.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 0,
              child: SizedBox(
                width: 200.0,
                height: 200.0,
                child: roundedSeekBar(),
              ),
            ),
          ],
        ),
      ),
    );
  }

//  Account status text
  Widget accountStatusText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Text(
        'Account status:',
        textAlign: TextAlign.left,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14.0,
          color: textColor,
        ),
      ),
    );
  }

//  When user is active
  Widget activeStatus() {
    return Row(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Color.fromRGBO(125, 183, 91, 1.0),
              width: 1.0,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 12.0,
                height: 12.0,
                decoration: BoxDecoration(
                    //                    color: Colors.orange,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Color.fromRGBO(125, 183, 91, 1.0), width: 2.5)),
              )
            ],
          ),
        ),
        Container(
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text(
              'Active',
              style: TextStyle(
                color: textColor,
                fontSize: 12.0,
              ),
            ),
          ),
        ),
      ],
    );
  }

//  When user is inactive
  Widget inactiveStatus() {
    return Padding(
        padding: EdgeInsets.only(right: 70.0),
        child: Row(
          children: <Widget>[
            new Container(
              margin: EdgeInsets.only(top: 10.0),
              width: 20.0,
              height: 20.0,
              decoration: new BoxDecoration(
                  //                    color: Colors.orange,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.red, width: 1.0)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  new Container(
                    width: 12.0,
                    height: 12.0,
                    decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.red, width: 2.5)),
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 10.0, left: 5.0),
              child: Text(
                'Inactive',
                style: TextStyle(
                  color: textColor,
                  fontSize: 12.0,
                ),
              ),
            ),
          ],
        ));
  }

//  When user account status
  Widget userAccountStatus() {
    print(status);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          accountStatusText(),
          //    Radial progress bar is used to show the remaining days of user subscription
          status == "0" ? inactiveStatus() : activeStatus(),
        ],
      ),
    );
  }

//  User subscription end date
  Widget subExpiryDate() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          //    This shows subscription end date on manage profile page and also show status of user subscription.
          Text(
            expiryDate == '' ? '' : 'Subscription will end on',
            style: TextStyle(
              color: textColor,
              fontSize: 12.0,
            ),
            textAlign: TextAlign.right,
          ),
          status == "1"
              ? Text(
                  expiryDate == '' ? sw : '${DateFormat.yMMMd().format(_date)}',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12.0,
                  ),
                  textAlign: TextAlign.right,
                )
              : Text(
                  sw,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12.0,
                  ),
                  textAlign: TextAlign.right,
                )
        ],
      ),
    );
  }

//  Divider Container
  Widget dividerContainer() {
    return Expanded(
      flex: 0,
      child: new Container(
        height: 80.0,
        width: 1.0,
        decoration: new BoxDecoration(
          border: Border(
            right: BorderSide(
              //                    <--- top side
              color: primaryColor.withOpacity(0.1),
              width: 2.0,
            ),
          ),
        ),
      ),
    );
  }

//  Show mobile number
  Widget mobileNumberText() {
    return Expanded(
      flex: 1,
      child: Card(
        color: redPrime,
        borderOnForeground: true,
        child: Container(
          margin: EdgeInsets.only(top: 0.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Mobile Number',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12.0,
                  ),
                  textAlign: TextAlign.right,
                ),
                SizedBox(
                  height: 5.0,
                ),
                Text(
                  mobile,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14.0,
                  ),
                  textAlign: TextAlign.right,
                )
              ]),
        ),
      ),
    );
  }

//  Show date of birth
  Widget dobText() {
    return Expanded(
      flex: 1,
      child: Card(
        borderOnForeground: true,
        color: redPrime,
        child: Container(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Date of Birth',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12.0,
                  ),
                  textAlign: TextAlign.right,
                ),
                SizedBox(
                  height: 5.0,
                ),
                Text(
                  dob,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14.0,
                  ),
                  textAlign: TextAlign.right,
                )
              ]),
        ),
      ),
    );
  }

//  Date of birth and mobile text container
  Widget dobAndMobile() {
    return Container(
      height: 80.0,
      child: Row(
        children: <Widget>[
          dobText(),
          mobileNumberText(),
        ],
      ),
    );
  }

//  Show joined date text
  Widget joinedDateText() {
    var split = created_at.split(' ').map((i) {
      if (i == "") {
        return Divider();
      } else {
        return Text(
          i,
          style: TextStyle(
            color: textColor,
            fontSize: 14.0,
          ),
          textAlign: TextAlign.left,
        );
      }
    }).toList();

    return Expanded(
      flex: 1,
      child: Card(
        color: primaryColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: <Widget>[
            Text(
              "Joined on",
              style: TextStyle(color: textColor, fontSize: 24.0),
              textAlign: TextAlign.left,
            ),
            SizedBox(
              height: 3.0,
            ),
            split[0],
            SizedBox(
              height: 3.0,
            ),
            split[1]
          ]),
        ),
      ),
    );
  }

//  Show name and joined date container
  Widget nameAndJoinedDateContainer() {
    return Container(
      height: 100,
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Card(
              color: primaryColor,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        name,
                        style: TextStyle(color: textColor, fontSize: 24.0),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Flexible(
                        child: Text(
                          email,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14.0,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ]),
              ),
            ),
          ),
          joinedDateText(),
        ],
      ),
    );
  }

//  Overall UI of this page is in stack
  Widget stack() {
    return ListView(
      children: <Widget>[
        userProfileImage(),
        userAccountStatus(),
        subExpiryDate(),
        dobAndMobile(),
        nameAndJoinedDateContainer(),
        roundedSeekBarContainer(),
      ],
    );
  }

//  Scaffold body
  Widget scaffoldBody() {
    return SingleChildScrollView(
      child: Container(
        color: primaryColor,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: ListView(
          children: <Widget>[
            Row(
              children: [
                userProfileImage(),
                Column(
                  children: [
                    userAccountStatus(),
                    subExpiryDate(),
                  ],
                ),
              ],
            ),
            Divider(
              height: 30,
              color: redPrime,
              thickness: 2,
              indent: 20,
              endIndent: 20,
            ),
            dobAndMobile(),
            nameAndJoinedDateContainer(),
            Divider(
              height: 30,
              color: redPrime,
              thickness: 2,
              indent: 20,
              endIndent: 20,
            ),
            roundedSeekBarContainer(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (expiryDate == '' ||
        expiryDate == 'N/A' ||
        userExpiryDate == null ||
        status == "0") {
      sw = 'You are not Subscribed';
      setState(() {
        difference = null;
      });
    } else {
      setState(() {
        _date = userPlanEnd;
      });
      difference = status == "1" ? _date.difference(currentDate).inDays : 0.0;
      planDays = userPlanEnd.difference(userPlanStart).inDays;
      print(difference / planDays);
      progressWidth = difference / planDays;
    }
    return SafeArea(
      child: Scaffold(
        appBar: appBar(),
        body: scaffoldBody(),
      ),
    );
  }
}
