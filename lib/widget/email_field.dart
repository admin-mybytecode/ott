import 'package:flutter/material.dart';

class EmailField extends StatelessWidget {
  EmailField(this._emailController);
  final _emailController;

// Email textFormField
  Widget emailTextField() {
    return TextFormField(
      maxLines: 1,
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: "Enter your email",
        hintStyle: TextStyle(color: Colors.grey, fontSize: 18),
      ),
      style: TextStyle(color: Colors.black, fontSize: 20),
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
    );
  }

  Widget emailTextFieldContainer() {
    return Container(
        child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.0),
      child: emailTextField(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0.0,
      color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(40.0))),
      child: emailTextFieldContainer(),
    );
  }
}
