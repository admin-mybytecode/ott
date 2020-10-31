import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:nexthour/apidata/apidata.dart';
import 'package:nexthour/global.dart';
import 'package:nexthour/model/video_data.dart';
import 'package:nexthour/ui/deatiledViewPage.dart';

//  Image slider showed on home page used this widget
class ImageSlider extends StatelessWidget {
  List showsMoviesList;
//  Image swiper
  Widget imageSwiper() {
    return Swiper(
      scrollDirection: Axis.horizontal,
      loop: true,
      autoplay: true,
      duration: 500,
      autoplayDelay: 10000,
      autoplayDisableOnInteraction: true,
      itemCount: sliderData == null ? 0 : sliderData.length,
      // index: 0,
      itemBuilder: (BuildContext context, int index) {
        if (sliderData.isEmpty ?? true) {
          return null;
        } else {
//          List showsMoviesList = List<VideoDataModel>.generate(userWatchListOld == null ? 0 : userWatchListOld.length, (int mIndex){
//            if(userWatchListOld[mIndex].datatype == "T"){
//              var s = userWatchListOld[mIndex].seasons;
//              String genres =  userWatchListOld[mIndex].genres.toString();
//              genres = genres.replaceAll("[", "").replaceAll("]", "");
//              userWatchListOld[mIndex].genres.removeWhere((value) => value == null);
//              for(var k=0; k<s.length; k++){
//                for(var i = 0; i<sliderData.length; i++){
//                  if(userWatchListOld[mIndex].id == sliderData[i]['tv_series_id']){
//                    return VideoDataModel(
//                      id: userWatchListOld[mIndex].id,
//                      name: userWatchListOld[mIndex].name,
//                      box: userWatchListOld[mIndex].box,
//                      cover: userWatchListOld[mIndex].cover,
//                      description: userWatchListOld[mIndex].description,
//                      datatype: userWatchListOld[mIndex].datatype,
//                      rating: userWatchListOld[mIndex].rating,
//                      screenshots: userWatchListOld[mIndex].screenshots,
//                      url: userWatchListOld[mIndex].url,
//                      iFrameLink: userWatchListOld[mIndex].iFrameLink,
//                      readyUrl: userWatchListOld[mIndex].readyUrl,
//                      url360: userWatchListOld[mIndex].url360,
//                      url480: userWatchListOld[mIndex].url480,
//                      url720: userWatchListOld[mIndex].url720,
//                      url1080: userWatchListOld[mIndex].url1080,
//                      menuId: userWatchListOld[mIndex].menuId,
//                      genre: userWatchListOld[mIndex].genre,
//                      genres: userWatchListOld[mIndex].genres,
//                      seasons: userWatchListOld[mIndex].seasons,
//                      maturityRating: userWatchListOld[mIndex].maturityRating,
//                      duration: userWatchListOld[mIndex].duration,
//                      released: userWatchListOld[mIndex].released,
//                    );
//                  }
//                }
//              }
//            }
//            else{
//              String genres =  userWatchListOld[mIndex].genres.toString();
//              genres = genres.replaceAll("[", "").replaceAll("]", "");
//              userWatchListOld[mIndex].genres.removeWhere((value) => value == null);
//              for(var i = 0; i<sliderData.length; i++){
//                if(userWatchListOld[mIndex].id == sliderData[i]['movie_id']){
//                  return new VideoDataModel(
//                    id: userWatchListOld[mIndex].id,
//                    name: userWatchListOld[mIndex].name,
//                    box: userWatchListOld[mIndex].box,
//                    cover: userWatchListOld[mIndex].cover,
//                    description: userWatchListOld[mIndex].description,
//                    datatype: userWatchListOld[mIndex].datatype,
//                    rating: userWatchListOld[mIndex].rating,
//                    screenshots: userWatchListOld[mIndex].screenshots,
//                    url: userWatchListOld[mIndex].url,
//                    iFrameLink: userWatchListOld[mIndex].iFrameLink,
//                    readyUrl: userWatchListOld[mIndex].readyUrl,
//                    url360: userWatchListOld[mIndex].url360,
//                    url480: userWatchListOld[mIndex].url480,
//                    url720: userWatchListOld[mIndex].url720,
//                    url1080: userWatchListOld[mIndex].url1080,
//                    menuId: userWatchListOld[mIndex].menuId,
//                    genre: userWatchListOld[mIndex].genre,
//                    genres: userWatchListOld[mIndex].genres,
//                    seasons: userWatchListOld[mIndex].seasons,
//                    maturityRating: userWatchListOld[mIndex].maturityRating,
//                    duration: userWatchListOld[mIndex].duration,
//                    released: userWatchListOld[mIndex].released,
//                  );
//                }
//              }
//            }
//            return null;
//          });
//          showsMoviesList.removeWhere((value) => value == null);
          if (sliderData[index]['movie_id'] == null) {
            if ("${APIData.silderImageUri}" +
                    "shows/" +
                    "${sliderData[index]['slide_image']}" ==
                "${APIData.silderImageUri}" + "shows/" + "null") {
              return null;
            } else {
              showsMoviesList = List<VideoDataModel>.generate(
                  userWatchListOld == null ? 0 : userWatchListOld.length,
                  (int mIndex) {
                var s = userWatchListOld[mIndex].seasons;
                String genres = userWatchListOld[mIndex].genres.toString();
                genres = genres.replaceAll("[", "").replaceAll("]", "");
                userWatchListOld[mIndex]
                    .genres
                    .removeWhere((value) => value == null);
                for (var k = 0; k < s.length; k++) {
                  for (var i = 0; i < sliderData.length; i++) {
                    if (userWatchListOld[mIndex].id ==
                        sliderData[i]['tv_series_id']) {
                      return VideoDataModel(
                        id: userWatchListOld[mIndex].id,
                        name: userWatchListOld[mIndex].name,
                        box: userWatchListOld[mIndex].box,
                        cover: userWatchListOld[mIndex].cover,
                        description: userWatchListOld[mIndex].description,
                        datatype: userWatchListOld[mIndex].datatype,
                        rating: userWatchListOld[mIndex].rating,
                        screenshots: userWatchListOld[mIndex].screenshots,
                        url: userWatchListOld[mIndex].url,
                        iFrameLink: userWatchListOld[mIndex].iFrameLink,
                        readyUrl: userWatchListOld[mIndex].readyUrl,
                        url360: userWatchListOld[mIndex].url360,
                        url480: userWatchListOld[mIndex].url480,
                        url720: userWatchListOld[mIndex].url720,
                        url1080: userWatchListOld[mIndex].url1080,
                        menuId: userWatchListOld[mIndex].menuId,
                        genre: userWatchListOld[mIndex].genre,
                        genres: userWatchListOld[mIndex].genres,
                        seasons: userWatchListOld[mIndex].seasons,
                        maturityRating: userWatchListOld[mIndex].maturityRating,
                        duration: userWatchListOld[mIndex].duration,
                        released: userWatchListOld[mIndex].released,
                      );
                    }
                  }
                }
                return null;
              });
              showsMoviesList.removeWhere((value) => value == null);
              return GestureDetector(
                onTap: () {
                  var router = new MaterialPageRoute(
                      builder: (BuildContext context) =>
                          DetailedViewPage(showsMoviesList[index]));
                  Navigator.of(context).push(router);
                },
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 0.0, bottom: 0.0, left: 5.0, right: 5.0),
                  child: new CachedNetworkImage(
                    imageUrl: "${APIData.silderImageUri}" +
                        "shows/" +
                        "${sliderData[index]['slide_image']}",
                    fit: BoxFit.cover,
                  ),
                ),
              );
            }
          } else {
            if ("${APIData.silderImageUri}" +
                    "movies/" +
                    "${sliderData[index]['slide_image']}" ==
                "${APIData.silderImageUri}" + "movies/" + "null") {
              return null;
            } else {
              showsMoviesList = List<VideoDataModel>.generate(
                  userWatchListOld == null ? 0 : userWatchListOld.length,
                  (int mIndex) {
                String genres = userWatchListOld[mIndex].genres.toString();
                genres = genres.replaceAll("[", "").replaceAll("]", "");
                userWatchListOld[mIndex]
                    .genres
                    .removeWhere((value) => value == null);
                for (var i = 0; i < sliderData.length; i++) {
                  if (userWatchListOld[mIndex].id ==
                      sliderData[i]['movie_id']) {
                    return new VideoDataModel(
                      id: userWatchListOld[mIndex].id,
                      name: userWatchListOld[mIndex].name,
                      box: userWatchListOld[mIndex].box,
                      cover: userWatchListOld[mIndex].cover,
                      description: userWatchListOld[mIndex].description,
                      datatype: userWatchListOld[mIndex].datatype,
                      rating: userWatchListOld[mIndex].rating,
                      screenshots: userWatchListOld[mIndex].screenshots,
                      url: userWatchListOld[mIndex].url,
                      iFrameLink: userWatchListOld[mIndex].iFrameLink,
                      readyUrl: userWatchListOld[mIndex].readyUrl,
                      url360: userWatchListOld[mIndex].url360,
                      url480: userWatchListOld[mIndex].url480,
                      url720: userWatchListOld[mIndex].url720,
                      url1080: userWatchListOld[mIndex].url1080,
                      menuId: userWatchListOld[mIndex].menuId,
                      genre: userWatchListOld[mIndex].genre,
                      genres: userWatchListOld[mIndex].genres,
                      seasons: userWatchListOld[mIndex].seasons,
                      maturityRating: userWatchListOld[mIndex].maturityRating,
                      duration: userWatchListOld[mIndex].duration,
                      released: userWatchListOld[mIndex].released,
                    );
                  }
                }
                return null;
              });
              showsMoviesList.removeWhere((value) => value == null);
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 3.0, vertical: 10.0),
                child: Card(
                  elevation: 6.0,
                  shadowColor: redPrime.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: InkWell(
                        onTap: () {
                          print(showsMoviesList[index].id);
                          var router = new MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  DetailedViewPage(showsMoviesList[index]));
                          Navigator.of(context).push(router);
                        },
                        child: new CachedNetworkImage(
                          imageUrl: "${APIData.silderImageUri}" +
                              "movies/" +
                              "${sliderData[index]['slide_image']}",
                          fit: BoxFit.cover,
                        )),
                  ),
                ),
              );
            }
          }
        }
      },
      viewportFraction: 0.93,
      pagination: new SwiperPagination(
        margin: EdgeInsets.only(
          bottom: 30.0,
        ),
        builder: new DotSwiperPaginationBuilder(
          color: Colors.white,
          activeColor: redPrime, //Color.fromRGBO(125, 183, 91, 1.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      child: imageSwiper(),
    );
  }
}
