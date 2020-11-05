import 'package:flutter/material.dart';
import 'package:nexthour/global.dart';

class DescriptionText extends StatefulWidget {
  DescriptionText(this.text);

  final String text;

  @override
  _DescriptionTextState createState() => new _DescriptionTextState();
}

class _DescriptionTextState extends State<DescriptionText> {
  bool descTextShowFlag = false;

  Widget descriptionHeader(theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                descTextShowFlag = !descTextShowFlag;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                descTextShowFlag
                    ? Text(
                        '',
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 15.0,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.9,
                          color: theme.accentColor,
                        ),
                      )
                    : Text(
                        '',
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 15.0,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.9,
                          color: theme.accentColor,
                        ),
                      ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18.0, vertical: 3.0),
                  child: descTextShowFlag
                      ? Icon(
                          Icons.keyboard_arrow_up,
                          size: 20.0,
                          color: primaryDarkColor,
                        )
                      : Icon(
                          Icons.keyboard_arrow_down,
                          size: 20.0,
                          color: primaryDarkColor,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            InkWell(
              onTap: () {
                setState(() {
                  descTextShowFlag = !descTextShowFlag;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 18.0, vertical: 10.0),
                child: Text(widget.text,
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.9,
                      color: textColor,
                    ),
                    maxLines: descTextShowFlag ? 100 : 2,
                    textAlign: TextAlign.start),
              ),
            ),
          ],
        ),
        // No expand-collapse in this tutorial, we just slap the "more"
        descriptionHeader(theme),
      ],
    );
  }
}
