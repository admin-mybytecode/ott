import 'package:flutter/material.dart';
import 'package:nexthour/global.dart';

class EmailField extends StatelessWidget {
  EmailField(this._emailController);
  final _emailController;

// Email textFormField
  Widget emailTextField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: TextFormField(
        maxLines: 1,
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
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
          hintText: "Enter your email",
          hintStyle: TextStyle(color: Colors.grey, fontSize: 18),
        ),
        style: TextStyle(color: whiteColor, fontSize: 20),
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
