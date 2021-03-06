import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageWidthItem extends StatelessWidget {
  ImageWidthItem(this.buildContext, this.image, this.width,
      {this.imageRatio = 1.50});
  final BuildContext buildContext;
  final String image;
  final double width;
  final double imageRatio;

  @override
  Widget build(BuildContext context) {
    double height = imageRatio * width;

    return new Material(
      borderRadius: new BorderRadius.circular(4.0),
      elevation: 8.0,
      shadowColor: new Color(0xCC000000),
      child: new CachedNetworkImage(
        imageUrl: image,
        width: width,
        height: height,
        fit: BoxFit.cover,
      ),
    );
  }
}
