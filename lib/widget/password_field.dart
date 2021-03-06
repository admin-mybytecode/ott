import 'package:flutter/material.dart';
import 'package:nexthour/global.dart';

class HiddenPasswordField extends StatefulWidget {
  final _passwordController;
  final hintText;
  HiddenPasswordField(this._passwordController, this.hintText);
  @override
  _HiddenPasswordFieldState createState() => _HiddenPasswordFieldState();
}

class _HiddenPasswordFieldState extends State<HiddenPasswordField> {
  bool _isHidden = true;

// Toggle for visibility
  void _toggleVisibility() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }

//  Password TextFormField
  Widget textField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: TextFormField(
        controller: widget._passwordController,
        decoration: new InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: primaryDarkColor),
          ),
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Colors.grey, fontSize: 18),
          suffixIcon: widget.hintText == "Enter your password"
              ? IconButton(
                  splashColor: Colors.transparent,
                  onPressed: _toggleVisibility,
                  icon: _isHidden
                      ? Text("Show",
                          style: TextStyle(fontSize: 10.0, color: textColor))
                      : Text(
                          "Hide",
                          style: TextStyle(fontSize: 10.0, color: textColor),
                        ),
                )
              : null,
        ),
        style: TextStyle(color: textColor, fontSize: 18),
        validator: (val) {
          if (val.length < 6) {
            if (val.length == 0) {
              return 'Password can not be empty';
            } else {
              return 'Password too short';
            }
          } else {
            return null;
          }
        },
        onSaved: (val) => widget._passwordController.text = val,
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
