import 'package:flutter/material.dart';

//  For confirm password this widget  will called.
class ConfirmPasswordField extends StatefulWidget {
  final _passwordController;
  final _repeatPasswordController;
  final hintText;
  ConfirmPasswordField(
      this._passwordController, this._repeatPasswordController, this.hintText);
  @override
  _ConfirmPasswordFieldState createState() => _ConfirmPasswordFieldState();
}

class _ConfirmPasswordFieldState extends State<ConfirmPasswordField> {
  bool _isHidden = true;

// Toggle for visibility
  void _toggleVisibility() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }

//  TextFormField
  Widget textField() {
    return TextFormField(
      decoration: new InputDecoration(
        border: InputBorder.none,
        hintText: "Confirm password",
        suffixIcon: widget.hintText == "Confirm password"
            ? IconButton(
                onPressed: _toggleVisibility,
                icon: _isHidden
                    ? Text(
                        "Show",
                        style: TextStyle(fontSize: 10.0, color: Colors.black),
                      )
                    : Text(
                        "Hide",
                        style: TextStyle(fontSize: 10.0, color: Colors.black),
                      ),
              )
            : null,
        hintStyle: TextStyle(color: Colors.grey, fontSize: 18),
      ),
      style: TextStyle(color: Colors.black, fontSize: 18),
      validator: (val) {
        if (val.length < 6) {
          if (val.length == 0) {
            return 'Confirm Password can not be empty';
          } else {
            return 'Password too short';
          }
        } else {
          if (widget._passwordController.text == val) {
            return null;
          } else {
            return 'Password & Confirm Password does not match';
          }
        }
      },
      onSaved: (val) => widget._repeatPasswordController.text = val,
      obscureText: _isHidden == true ? true : false,
    );
  }

//  TextField Container
  Widget fieldContainer() {
    return Container(
      child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: <Widget>[
              textField(),
            ],
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0.0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(40.0))),
      child: fieldContainer(),
    );
  }
}
