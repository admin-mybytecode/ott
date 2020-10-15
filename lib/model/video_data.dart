import 'package:meta/meta.dart';
import 'package:nexthour/model/seasons.dart';
import 'package:nexthour/model/comments_model.dart';

class VideoDataModel {
  VideoDataModel({
    @required this.name,
    @required this.box,
    this.duration,
    this.cover,
    this.description,
    this.platforms,
    this.rating,
    this.screenshots,
    this.url,
    this.menuId,
    this.genre,
    this.maturityRating,
    this.genres,
    this.id,
    this.datatype,
    this.seasons,
    this.comments,
    this.released,
    this.videoLink,
    this.iFrameLink,
    this.iFrameLSD,
    this.readyUrl,
    this.url360,
    this.url480,
    this.url720,
    this.url1080,
    this.aLang,
    this.vStatus,
  });
  final int id;
  final List<String> genres;
  final String name;
  final String duration;
  final String box;
  final String cover;
  final String description;
  final List<String> platforms;
  final double rating;
  final String url;
  final List<String> screenshots;
  final int menuId;
  final List<String> genre;
  final String maturityRating;
  final String datatype;
  final List<Seasons> seasons;
  final List<CommentsModel> comments;
  final String released;
  final String videoLink;
  final String iFrameLink;
  final String iFrameLSD;
  final String readyUrl;
  final String url360;
  final String url480;
  final String url720;
  final String url1080;
  final String aLang;
  final vStatus;
}
