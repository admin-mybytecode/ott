import 'package:flutter/material.dart';
import 'package:nexthour/global.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: TextFormField(
        decoration: new InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: primaryDarkColor,
            ),
          ),
          hintText: "Confirm password",
          suffixIcon: widget.hintText == "Confirm password"
              ? IconButton(
                  splashColor: Colors.transparent,
                  onPressed: _toggleVisibility,
                  icon: _isHidden
                      ? Text(
                          "Show",
                          style: TextStyle(fontSize: 10.0, color: textColor),
                        )
                      : Text(
                          "Hide",
                          style: TextStyle(fontSize: 10.0, color: textColor),
                        ),
                )
              : null,
          hintStyle: TextStyle(color: Colors.grey, fontSize: 18),
        ),
        style: TextStyle(color: textColor, fontSize: 18),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0.0,
      color: Colors.transparent,
      child: textField(),
    );
  }
}
