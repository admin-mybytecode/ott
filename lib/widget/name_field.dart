import 'package:flutter/material.dart';
import 'package:nexthour/global.dart';

class NameField extends StatelessWidget {
  NameField(this._nameController);
  final _nameController;

//  Name TextFormField
  Widget nameTextField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.text,
        controller: _nameController,
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
          hintText: "User Name",
          hintStyle: TextStyle(color: Colors.grey, fontSize: 18),
        ),
        style: TextStyle(color: whiteColor, fontSize: 18),
        validator: (val) {
          if (val.length == 0) {
            return 'Name can not be empty';
          } else {
            if (val.length < 5) {
              return 'Required at least 5 characters.';
            } else {
              return null;
            }
          }
        },
        onSaved: (val) => _nameController.text = val,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0.0,
      color: Colors.transparent,
      child: nameTextField(),
    );
  }
}
