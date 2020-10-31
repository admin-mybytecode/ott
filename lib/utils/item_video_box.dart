import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nexthour/global.dart';
import 'package:nexthour/model/video_data.dart';

class VideoBoxItem extends StatelessWidget {
  static const IMAGE_RATIO = 1.50;

  VideoBoxItem(this.buildContext, this.game, {this.height = 120.0});
  final BuildContext buildContext;
  final VideoDataModel game;
  //final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
//    print('image url test ${game.box}');
    return Card(
      elevation: 4.0,
      shadowColor: redPrime.withOpacity(0.6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: new CachedNetworkImage(
          imageUrl: game.box,
          height: 150.0,
          width: 110.0,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
