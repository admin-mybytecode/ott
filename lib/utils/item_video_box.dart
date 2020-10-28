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
    return Material(
      color: primaryColor,
      borderRadius: new BorderRadius.circular(8.0),
      child: new ClipRRect(
        borderRadius: new BorderRadius.circular(8.0),
        child: new CachedNetworkImage(
          imageUrl: game.box,
          height: 160.0,
          width: 110.0,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
