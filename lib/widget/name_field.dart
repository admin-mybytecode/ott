import 'package:flutter/material.dart';
import 'package:nexthour/global.dart';

class NameField extends StatelessWidget {
  NameField(this._nameController);
  final _nameController;

//  Name TextFormField
  Widget nameTextField() {
    return TextFormField(
      maxLines: 1,
      keyboardType: TextInputType.text,
      controller: _nameController,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: "User Name",
        hintStyle: TextStyle(color: Colors.grey, fontSize: 18),
      ),
      style: TextStyle(color: textColor, fontSize: 18),
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
    );
  }

//  Name field container
  Widget nameFieldContainer() {
    return Container(
        child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.0),
      child: nameTextField(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0.0,
      color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(40.0))),
      child: nameFieldContainer(),
    );
  }
}
