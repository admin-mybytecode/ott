import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nexthour/home.dart';
import '../apidata/apidata.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../global.dart';

class CreateMultiProfile extends StatefulWidget {
  @override
  _CreateMultiProfileState createState() => _CreateMultiProfileState();
}

class _CreateMultiProfileState extends State<CreateMultiProfile> {
  TextEditingController _nameController = new TextEditingController();
  final _formKey = new GlobalKey<FormState>();

  String dropdownValue = 'Screen1';
  //  App bar
  Widget appBar(){
    return AppBar(
      title: Text("Create Screen",style: TextStyle(fontSize: 16.0),),
      centerTitle: true,
      backgroundColor: primaryDarkColor,
    );
  }

  Future<String> postScreenProfile(screen) async{
    final postScreenResponse = await http.post( APIData.screensProfilesApi, body: {
      "type": '$screen',
      "value": _nameController.text,
    }, headers: {
      // ignore: deprecated_member_use
      HttpHeaders.AUTHORIZATION: nToken == null ? fullData : nToken
    });

    print(postScreenResponse.statusCode);
    if(postScreenResponse.statusCode == 200){
      _nameController.text = '';
      Fluttertoast.showToast(msg: "Screen Created");
    }
    print(postScreenResponse.body);

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            height: 150.0,
          ),
          Container(
            alignment: Alignment.center,
            child: DropdownButton<String>(
              value: dropdownValue,
              icon: Icon(Icons.keyboard_arrow_down),
              iconSize: 30,
              elevation: 16,
              style: TextStyle(
                  color: Colors.white
              ),
              onChanged: (String newValue) {
                setState(() {
                  dropdownValue = newValue;
                });
                print(dropdownValue);
              },
              items: <String>['Screen1', 'Screen2', 'Screen3', 'Screen4']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: TextStyle(
                      fontSize: 18.0
                  ),
                  ),
                );
              })
                  .toList(),
            ),
          ),

          SizedBox(
            height: 30.0,
          ),
          Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.only(left: 50.0, right: 50.0),
              child: TextFormField(
                controller: _nameController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(left: 10.0, right: 10.0, top: 15.0, bottom: 15.0),
                  hintText: 'Enter screen name',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 16.0,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                validator: (val) {
                  if (val.length == 0) {
                    return 'Name can not be empty';
                  } else {
                    return null;
                  }
                },
                onSaved: (val) => _nameController.text = val,
              ),
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          Padding(padding: EdgeInsets.only(left: 50.0, right: 50.0),
            child: Row(
              children: <Widget>[
                Expanded(
                    flex: 1,
                    child: Material(
                      child: Container(
                        height: 50.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomRight,
                            stops: [0.1, 0.5, 0.7, 0.9],
                            colors: [
                              Color.fromRGBO(72, 163, 198, 0.4).withOpacity(0.4),
                              Color.fromRGBO(72, 163, 198, 0.3).withOpacity(0.5),
                              Color.fromRGBO(72, 163, 198, 0.2).withOpacity(0.6),
                              Color.fromRGBO(72, 163, 198, 0.1).withOpacity(0.7),
                            ],
                          ),
                        ),
                        child: new MaterialButton(
                          splashColor: Color.fromRGBO(72, 163, 198, 0.9),
                          child: Text(
                            "Create Screen",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: (){
                            final form = _formKey.currentState;
                            form.save();
                            if(form.validate() == true){
                              postScreenProfile(dropdownValue);
                            }
                          },
                        ),
                      ),
                    ))
              ],
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 30.0, left: 50.0, right: 50.0),
            child: Row(
              children: <Widget>[
                Expanded(
                    flex: 1,
                    child: Material(
                      child: Container(
                        height: 50.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomRight,
                            stops: [0.1, 0.5, 0.7, 0.9],
                            colors: [
                              Color.fromRGBO(72, 163, 198, 0.4).withOpacity(0.4),
                              Color.fromRGBO(72, 163, 198, 0.3).withOpacity(0.5),
                              Color.fromRGBO(72, 163, 198, 0.2).withOpacity(0.6),
                              Color.fromRGBO(72, 163, 198, 0.1).withOpacity(0.7),
                            ],
                          ),
                        ),
                        child: new MaterialButton(
                          splashColor: Color.fromRGBO(72, 163, 198, 0.9),
                          child: Text(
                            "Logout",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: (){
                            deleteFile();
                            var router = MaterialPageRoute(
                                builder: (BuildContext context) => Home()
                            );
                            Navigator.of(context).push(router);
                          },
                        ),
                      ),
                    ))
              ],
            ),
          )
        ],
      ),
    );
  }
  void deleteFile() {
    File file = new File(dir.path + "/" + fileName);
    file.delete();
    fileExists = false;
  }
}
