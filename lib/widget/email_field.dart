import 'package:flutter/material.dart';
import 'package:nexthour/global.dart';

class EmailField extends StatelessWidget {
  EmailField(this._emailController);
  final _emailController;

// Email textFormField
  Widget emailTextField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: TextFormField(
        maxLines: 1,
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: primaryDarkColor,
            ),
          ),
          hintText: "Enter your email",
          hintStyle: TextStyle(color: Colors.grey, fontSize: 18),
        ),
        style: TextStyle(color: textColor, fontSize: 20),
        validator: (val) {
          if (val.length == 0) {
            return 'Email can not be empty';
          } else {
            if (!val.contains('@')) {
              return 'Invalid Email';
            } else {
              return null;
            }
          }
        },
        onSaved: (val) => _emailController.text = val,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0.0,
      color: Colors.transparent,
      child: emailTextField(),
    );
  }
}
