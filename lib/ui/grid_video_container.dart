import 'package:flutter/material.dart';

import 'package:nexthour/model/video_data.dart';
import 'package:nexthour/ui/deatiledViewPage.dart';
import 'package:nexthour/ui/grid_video_box.dart';

class GridVideoContainer extends StatelessWidget {
  GridVideoContainer(this.buildContext, this.game);
  final BuildContext buildContext;
  final VideoDataModel game;

  @override
  Widget build(BuildContext context) {

    return InkWell(
      onTap: () => _goGameDetailsPage(context, game),
      child: videoColumn(context),
    );
  }

  void _goGameDetailsPage(BuildContext context, VideoDataModel game) {
    Navigator.of(context).push(
      new MaterialPageRoute(
        builder: (c) {
          return new DetailedViewPage(game);
        },
      ),
    );
  }

  Widget videoColumn(context){
    return Hero(
      tag: Text("hero2"),
      child: new GridVideoBox(context, game),
    );
  }
}