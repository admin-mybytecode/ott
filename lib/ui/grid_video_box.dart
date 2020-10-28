import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nexthour/model/video_data.dart';

class GridVideoBox extends StatelessWidget {
  GridVideoBox(this.buildContext, this.game);
  final BuildContext buildContext;
  final VideoDataModel game;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ClipRRect(
        borderRadius: new BorderRadius.circular(8.0),
        child: new CachedNetworkImage(
          imageUrl: game.box,
          height: 200,
          width: 60.0,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
