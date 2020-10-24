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
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: TextFormField(
        decoration: new InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(color: whiteColor, width: 2.0),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(color: redPrime, width: 2.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(color: whiteColor, width: 2.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(color: redPrime, width: 2.0),
          ),
          hintText: "Confirm password",
          suffixIcon: widget.hintText == "Confirm password"
              ? IconButton(
                  splashColor: Colors.transparent,
                  onPressed: _toggleVisibility,
                  icon: _isHidden
                      ? Text(
                          "Show",
                          style: TextStyle(fontSize: 10.0, color: whiteColor),
                        )
                      : Text(
                          "Hide",
                          style: TextStyle(fontSize: 10.0, color: whiteColor),
                        ),
                )
              : null,
          hintStyle: TextStyle(color: Colors.grey, fontSize: 18),
        ),
        style: TextStyle(color: whiteColor, fontSize: 18),
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
