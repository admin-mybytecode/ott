import 'package:flutter/material.dart';
import 'package:nexthour/global.dart';

import 'package:nexthour/model/video_data.dart';

class RatingInformation extends StatelessWidget {
  RatingInformation(this.mVideo);

  final VideoDataModel mVideo;

  _buildRatingBar() {
    var stars = <Widget>[];

    for (var i = 1; i <= 5; i++) {
      var star;
      if (i + 1 <= mVideo.rating + 1) {
        star = new Icon(
          Icons.star,
          color: redPrime,
        );
      } else {
        if (i + 0.5 <= mVideo.rating + 1) {
          star = new Icon(
            Icons.star_half,
            color: redPrime,
          );
        } else {
          star = new Icon(
            Icons.star_border,
            color: redPrime,
          );
        }
      }

      stars.add(star);
    }

    return new Flex(direction: Axis.horizontal, children: stars);
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var textTheme = theme.textTheme;
    var ratingCaptionStyle = textTheme.caption.copyWith(color: textColor);

    var numericRating = new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        new Text(
          mVideo.rating.toString(),
          style: textTheme.headline6.copyWith(
            fontWeight: FontWeight.w400,
            color: redPrime,
          ),
        ),
        new Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: new Text(
            'Rating',
            style: ratingCaptionStyle,
          ),
        ),
      ],
    );

    var starRating = new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildRatingBar(),
      ],
    );

    return new Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        numericRating,
        new Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 14.0),
          child: starRating,
        ),
      ],
    );
  }
}
