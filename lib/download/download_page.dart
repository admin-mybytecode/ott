import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nexthour/apidata/apidata.dart';
import 'package:nexthour/download/down_video_player.dart';
import 'package:nexthour/global.dart';
import 'package:http/http.dart' as http;
import 'package:nexthour/model/progress_data.dart';
import 'package:nexthour/model/task_info.dart';
import 'package:nexthour/model/todo.dart';
import 'package:nexthour/model/video_data.dart';
import 'package:nexthour/repository/database_creator.dart';
import 'package:nexthour/repository/repository_service_todo.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:nexthour/ui/subscription.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wakelock/wakelock.dart';

import '../global.dart';

class DownloadPage extends StatefulWidget {
  DownloadPage(this.game);

  final VideoDataModel game;

  @override
  _DownloadPageState createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage>
    with TickerProviderStateMixin {
  var readyCompleter = Completer();

  Future get ready => readyCompleter.future;

  ReceivePort _port = ReceivePort();
  static const _channel = const MethodChannel('vn.hunghd/downloader');
  var dFileName;
  List x = new List();
  int id;
  var mtName,
      mReadyUrl,
      mIFrameUrl,
      mUrl360,
      mUrl480,
      mUrl720,
      mUrl1080,
      youtubeUrl,
      vimeoUrl;
  TargetPlatform platform;
  var dMsg = '';
  var download1, download2, download3, download4, downCount;

  Future<Null> _prepare() async {
    final tasks = await FlutterDownloader.loadTasks();
    int count = 0;
    dTasks = [];
    dItems = [];

    dTasks.add(
      TaskInfo(
        name: "${widget.game.name}",
        ifLink: "${widget.game.iFrameLink}",
        hdLink: "${widget.game.readyUrl}",
        link360: "${widget.game.url360}",
        link480: "${widget.game.url480}",
        link720: "${widget.game.url720}",
        link1080: "${widget.game.url1080}",
      ),
    );

    for (int i = count; i < dTasks.length; i++) {
      dItems.add(ItemHolder(name: dTasks[i].name, task: dTasks[i]));
      count++;
    }

    tasks?.forEach((task) {
      for (TaskInfo info in dTasks) {
        if (info.hdLink == task.url ||
            info.ifLink == task.url ||
            info.link360 == task.url ||
            info.link480 == task.url ||
            info.link720 == task.url ||
            info.link1080 == task.url) {
          setState(() {
            mReadyUrl = info.hdLink;
            mIFrameUrl = info.ifLink;
            mUrl360 = info.link360;
            mUrl480 = info.link480;
            mUrl720 = info.link720;
            mUrl1080 = info.link1080;
          });
          info.taskId = task.taskId;
          info.status = task.status;
          info.progress = task.progress;
        }
      }
    });

    permissionReady = await _checkPermission();
    dLocalPath = (await _findLocalPath()) + Platform.pathSeparator + 'Download';
    final savedDir = Directory(dLocalPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<String> _findLocalPath() async {
    final directory = platform == TargetPlatform.android
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<bool> _checkPermission() async {
    if (platform == TargetPlatform.android) {
      PermissionStatus permission = await PermissionHandler()
          .checkPermissionStatus(PermissionGroup.storage);
      if (permission != PermissionStatus.granted) {
        Map<PermissionGroup, PermissionStatus> permissions =
            await PermissionHandler()
                .requestPermissions([PermissionGroup.storage]);
        if (permissions[PermissionGroup.storage] == PermissionStatus.granted) {
          return true;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_senddPort');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }

    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];

      final task =
          dTasks?.firstWhere((task) => task.taskId == id, orElse: () => null);

      if (task != null) {
        setState(() {
          task.status = status;
          task.progress = progress;
        });
      }
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_senddPort');
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    print(
        'Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_senddPort');
    send.send([id, status, progress]);
  }

  void _showDialog(task) {
    getAllScreens();
    var downCount;
    if (downloadLimit == null) {
      Fluttertoast.showToast(msg: "You can't download with this plan.");
      return;
    }
    var dCount = downloadLimit / mScreenCount;

    if (fileContent['screenCount'] == "1") {
      setState(() {
        downCount = download1;
      });
    } else if (fileContent['screenCount'] == "2") {
      setState(() {
        downCount = download2;
      });
    } else if (fileContent['screenCount'] == "3") {
      setState(() {
        downCount = download3;
      });
    } else if (fileContent['screenCount'] == "4") {
      setState(() {
        downCount = download4;
      });
    }

    if (dCount.toInt() > downCount) {
      _requestDownload(task);
    } else {
      Fluttertoast.showToast(msg: "Your download limit exceed.");
    }
  }

  Future<String> getAllScreens() async {
    final getAllScreensResponse =
        await http.get(Uri.encodeFull(APIData.showScreensApi), headers: {
      // ignore: deprecated_member_use
      HttpHeaders.AUTHORIZATION: nToken == null ? fullData : nToken
    });
    print(getAllScreensResponse.statusCode);
    print(getAllScreensResponse.body);
    var screensRes = json.decode(getAllScreensResponse.body);
    if (getAllScreensResponse.statusCode == 200) {
      setState(() {
        download1 = screensRes['screen']['download_1'] == null
            ? 0
            : screensRes['screen']['download_1'];
        download2 = screensRes['screen']['download_2'] == null
            ? 0
            : screensRes['screen']['download_2'];
        download3 = screensRes['screen']['download_3'] == null
            ? 0
            : screensRes['screen']['download_3'];
        download4 = screensRes['screen']['download_4'] == null
            ? 0
            : screensRes['screen']['download_4'];
      });
    }
    return null;
  }

  void _showMultiDialog(task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            backgroundColor: Color.fromRGBO(250, 250, 250, 1.0),
            title: Text(
              "Video Quality",
              style: TextStyle(
                  color: Color.fromRGBO(72, 163, 198, 1.0),
                  fontWeight: FontWeight.w600,
                  fontSize: 20.0),
              textAlign: TextAlign.center,
            ),
            content: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    "Available Video Format in which you want to download video.",
                    style: TextStyle(
                        color: Colors.black.withOpacity(0.7), fontSize: 12.0),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  widget.game.url360 == "null"
                      ? SizedBox.shrink()
                      : Padding(
                          padding: EdgeInsets.only(left: 50.0, right: 50.0),
                          child: RaisedButton(
                            hoverColor: Colors.red,
                            splashColor: Color.fromRGBO(49, 131, 41, 1.0),
                            highlightColor: Color.fromRGBO(72, 163, 198, 1.0),
                            color: redPrime,
                            child: Container(
                              alignment: Alignment.center,
                              width: 100.0,
                              height: 30.0,
                              child: Text("360"),
                            ),
                            onPressed: () {
                              setState(() {
                                downCount = download1;
                              });
                              if (dCount.toInt() > downCount) {
                                _requestDownload360(task);
                              } else {
                                Fluttertoast.showToast(
                                    msg: "Download limit exceed.");
                              }
                              Navigator.pop(context);
                            },
                          ),
                        ),
                  widget.game.url480 == "null"
                      ? SizedBox.shrink()
                      : Padding(
                          padding: EdgeInsets.only(left: 50.0, right: 50.0),
                          child: RaisedButton(
                            color: redPrime,
                            hoverColor: Colors.red,
                            splashColor: Color.fromRGBO(49, 131, 41, 1.0),
                            highlightColor: Color.fromRGBO(72, 163, 198, 1.0),
                            child: Container(
                              alignment: Alignment.center,
                              width: 100.0,
                              height: 30.0,
                              child: Text("480"),
                            ),
                            onPressed: () {
                              setState(() {
                                downCount = download2;
                              });
                              _requestDownload480(task);
                              Navigator.pop(context);
                            },
                          ),
                        ),
                  widget.game.url720 == "null"
                      ? SizedBox.shrink()
                      : Padding(
                          padding: EdgeInsets.only(left: 50.0, right: 50.0),
                          child: RaisedButton(
                            hoverColor: Colors.red,
                            splashColor: Color.fromRGBO(49, 131, 41, 1.0),
                            highlightColor: Color.fromRGBO(72, 163, 198, 1.0),
                            color: redPrime,
                            child: Container(
                              alignment: Alignment.center,
                              width: 100.0,
                              height: 30.0,
                              child: Text("720"),
                            ),
                            onPressed: () {
                              setState(() {
                                downCount = download3;
                              });
                              _requestDownload720(task);
                              Navigator.pop(context);
                            },
                          ),
                        ),
                  widget.game.url1080 == "null"
                      ? SizedBox.shrink()
                      : Padding(
                          padding: EdgeInsets.only(left: 50.0, right: 50.0),
                          child: RaisedButton(
                            hoverColor: Colors.red,
                            splashColor: Color.fromRGBO(49, 131, 41, 1.0),
                            highlightColor: Color.fromRGBO(72, 163, 198, 1.0),
                            color: redPrime,
                            child: Container(
                              alignment: Alignment.center,
                              width: 100.0,
                              height: 30.0,
                              child: Text("1080"),
                            ),
                            onPressed: () {
                              setState(() {
                                downCount = download4;
                              });
                              _requestDownload1080(task);
                              Navigator.pop(context);
                            },
                          ),
                        ),
                ],
              ),
            ));
      },
    );
  }

  Widget _buildActionForTask(TaskInfo task) {
    if (task.status == DownloadTaskStatus.undefined) {
      return RawMaterialButton(
        onPressed: () {
          mIFrameUrl = widget.game.iFrameLink;
          print("Iframe: $mIFrameUrl");
          mReadyUrl = widget.game.readyUrl;
          print("Ready Url: $mReadyUrl");
          mUrl360 = widget.game.url360;
          print("Url 360: $mUrl360");
          mUrl480 = widget.game.url480;
          print("Url 480: $mUrl480");
          mUrl720 = widget.game.url720;
          print("Url 720: $mUrl720");
          mUrl1080 = widget.game.url1080;
          print("Url 1080: $mUrl1080");

          if (mIFrameUrl != "null" ||
              mReadyUrl != "null" ||
              mUrl360 != "null" ||
              mUrl480 != "null" ||
              mUrl720 != "null" ||
              mUrl1080 != "null") {
            if (mIFrameUrl != "null") {
              Fluttertoast.showToast(msg: "Can't download this video.");
              return;
            } else if (mReadyUrl != "null") {
              print("Ready URL Condition");
              var matchUrl = mReadyUrl.substring(0, 29);

              var checkMp4 = mReadyUrl.substring(mReadyUrl.length - 4);
              var checkMpd = mReadyUrl.substring(mReadyUrl.length - 4);
              var checkWebm = mReadyUrl.substring(mReadyUrl.length - 5);
              var checkMkv = mReadyUrl.substring(mReadyUrl.length - 4);
              var checkM3u8 = mReadyUrl.substring(mReadyUrl.length - 5);

              if (matchUrl.substring(0, 18) == "https://vimeo.com/") {
                Fluttertoast.showToast(msg: "Can't download this video.");
                return;
              } else if (matchUrl == 'https://www.youtube.com/embed') {
                Fluttertoast.showToast(msg: "Can't download this video.");
                return;
              } else if (matchUrl.substring(0, 23) ==
                  'https://www.youtube.com') {
                Fluttertoast.showToast(msg: "Can't download this video.");
                return;
              } else if (matchUrl.substring(0, 29) ==
                  'https://drive.google.com/file/') {
                Fluttertoast.showToast(msg: "Can't download this video.");
                return;
              } else if (matchUrl.substring(0, 29) ==
                  'https://drive.google.com/file/') {
                Fluttertoast.showToast(msg: "Can't download this video.");
                return;
              } else if (checkMp4 == ".mp4" ||
                  checkMpd == ".mpd" ||
                  checkWebm == ".webm" ||
                  checkMkv == ".mkv" ||
                  checkM3u8 == ".m3u8") {
                _showDialog(task);
              } else {
                Fluttertoast.showToast(msg: "Can't download this video.");
                return;
              }
            } else if (mUrl360 != "null" ||
                mUrl480 != "null" ||
                mUrl720 != "null" ||
                mUrl1080 != "null") {
              getAllScreens();
              print("MSCREEN: $mScreenCount");
              print("MSCREEN: $downloadLimit");
              if (downloadLimit == null) {
                Fluttertoast.showToast(msg: "Can't download with this plan.");
                return;
              }
              setState(() {
                dCount = downloadLimit / mScreenCount;
              });
              _showMultiDialog(task);
            } else {
              Fluttertoast.showToast(msg: "Can't download this video.");
              return;
            }
          } else {
            Fluttertoast.showToast(msg: "Video URL doesn't exist");
          }
        },
        child: Icon(
          Icons.file_download,
          size: 30.0,
        ),
        shape: new CircleBorder(),
        constraints: new BoxConstraints(minHeight: 30.0, minWidth: 30.0),
      );
    } else if (task.status == DownloadTaskStatus.running) {
      return new RawMaterialButton(
        onPressed: () {
          _pauseDownload(task);
        },
        onLongPress: () {
          _showDialog3(task);
        },
        child: Icon(
          Icons.pause,
          color: Colors.red,
          size: 30.0,
        ),
        shape: new CircleBorder(),
        constraints: BoxConstraints(minHeight: 32.0, minWidth: 32.0),
      );
    } else if (task.status == DownloadTaskStatus.paused) {
      return new RawMaterialButton(
        onPressed: () {
          _resumeDownload(task);
        },
        onLongPress: () {
          _showDialog3(task);
        },
        child: Icon(
          Icons.play_arrow,
          color: Colors.green,
          size: 30.0,
        ),
        shape: CircleBorder(),
        constraints: BoxConstraints(minHeight: 32.0, minWidth: 32.0),
      );
    } else if (task.status == DownloadTaskStatus.complete) {
      int progress = 100;
      createTodo(task, task.name, dFileName, widget.game.datatype,
          widget.game.id, task.taskId, progress, task.hdLink);
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          RawMaterialButton(
            onPressed: () {
              Wakelock.disable();
              _openDownloadedFile(task);
            },
            onLongPress: () {
              _showDeleteDialog(task);
            },
            child: Icon(
              Icons.file_download,
              color: redPrime,
              size: 30.0,
            ),
            shape: CircleBorder(),
            constraints: BoxConstraints(minHeight: 32.0, minWidth: 32.0),
          )
        ],
      );
    } else if (task.status == DownloadTaskStatus.canceled) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('Failed', style: TextStyle(color: Colors.red)),
          RawMaterialButton(
            onPressed: () {
              _showDialog(task);
            },
            onLongPress: () {
              _showDialog3(task);
            },
            child: Icon(
              Icons.refresh,
              color: Colors.green,
            ),
            shape: CircleBorder(),
            constraints: BoxConstraints(minHeight: 32.0, minWidth: 32.0),
          )
        ],
      );
    } else if (task.status == DownloadTaskStatus.failed) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('Failed', style: TextStyle(color: Colors.red)),
          RawMaterialButton(
            onPressed: () {
              _showDialog(task);
            },
            onLongPress: () {
              _showDialog3(task);
            },
            child: Icon(
              Icons.refresh,
              color: Colors.green,
            ),
            shape: CircleBorder(),
            constraints: BoxConstraints(minHeight: 32.0, minWidth: 32.0),
          )
        ],
      );
    } else {
      return SizedBox.shrink();
    }
  }

  increaseCounter() async {
    final increaseCounter = await http.post(APIData.downloadCounter, body: {
      "count": '${fileContent['screenCount']}',
    }, headers: {
      // ignore: deprecated_member_use
      HttpHeaders.AUTHORIZATION: nToken == null ? fullData : nToken
    });
  }

  void _showDialog3(task) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: new Text(
            "Stop Download",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          ),
          content: new Text(
            "Do you want to cancel?",
            style: TextStyle(
                color: Colors.black.withOpacity(0.7),
                fontWeight: FontWeight.w600,
                fontSize: 16.0),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text(
                "Yes",
                style: TextStyle(color: redPrime, fontSize: 16.0),
              ),
              onPressed: () {
                _delete(task);
                Navigator.pop(context);
              },
            ),
            new FlatButton(
              child: new Text(
                "No",
                style: TextStyle(color: redPrime, fontSize: 16.0),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(task) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: new Text(
            "Delete Downloaded",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          ),
          content: new Text(
            "Do you want to delete?",
            style: TextStyle(
                color: Colors.black.withOpacity(0.7),
                fontWeight: FontWeight.w600,
                fontSize: 16.0),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text(
                "Yes",
                style: TextStyle(color: redPrime, fontSize: 16.0),
              ),
              onPressed: () {
                _delete(task);
                Navigator.pop(context);
              },
            ),
            new FlatButton(
              child: new Text(
                "No",
                style: TextStyle(color: redPrime, fontSize: 16.0),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future checkConn(task) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
      }
    } on SocketException catch (_) {
      print('not connected');
      _pauseDownload(task);
    }
  }

  void _delete(TaskInfo task) async {
    await FlutterDownloader.remove(
        taskId: task.taskId, shouldDeleteContent: true);
    await _prepare();
    var raw = await cdb.delete(
      DatabaseCreator.todoTable,
      where: "movie_id = ? AND vtype = ?",
      whereArgs: ['${widget.game.id}', '${widget.game.datatype}'],
    );
    setState(() {});
  }

  void createTodo(task, taskName, mVideoFileName, videoType, vMovieId, taskId,
      progress, url) async {
    name = taskName;
    checkName(task, taskName, mVideoFileName, videoType, vMovieId, taskId,
        progress, url);
  }

  addPersonToDatabase(Todo todo) async {
    var raw = await cdb.insert(
      DatabaseCreator.todoTable,
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return raw;
  }

  updatePersoneDatabase(ProgressData pdata, vMovieId, videoType) async {
    var raw = await cdb.update(
      DatabaseCreator.todoTable,
      pdata.toMap(),
      where: "movie_id = ? AND vtype = ? AND progress = ?",
      whereArgs: [vMovieId, videoType, 0],
    );
    return raw;
  }

  Future<Todo> getPersonWithId(task, taskName, mVideoFileName, videoType,
      vMovieId, taskId, progress, url) async {
    int count = await RepositoryServiceTodo.todosCount();
    if (count > 0) {
      var response = await cdb.query(
        DatabaseCreator.todoTable,
        where: "movie_id = ? AND vtype = ?",
        whereArgs: [vMovieId, videoType],
      );
      if (response.isEmpty == true) {
        addPersonToDatabase(Todo(
            id: count,
            name: taskName,
            path: url,
            type: videoType,
            movieId: vMovieId.toString(),
            tvSeriesId: null,
            seasonId: null,
            episodeId: null,
            dTaskId: taskId,
            dUserId: fileContent['user'],
            progress: progress));
        increaseCounter();
      } else {
        updatePersoneDatabase(ProgressData(dTaskId: taskId, progress: progress),
            vMovieId, videoType);
      }
    } else {
      addPersonToDatabase(Todo(
          id: count,
          name: taskName,
          path: url,
          type: videoType,
          movieId: vMovieId.toString(),
          tvSeriesId: null,
          seasonId: null,
          episodeId: null,
          dTaskId: taskId,
          dUserId: fileContent['user'],
          progress: progress));
      increaseCounter();
    }
  }

  void checkName(task, taskName, mVideoFileName, videoType, vMovieId, taskId,
      progress, url) async {
    getPersonWithId(task, taskName, mVideoFileName, videoType, vMovieId, taskId,
        progress, url);
  }

  saveNewFileName(dFileName) async {
    prefs = await SharedPreferences.getInstance();
    prefs.setString('dFileName', "$dFileName");
    print("Saved File Name");
  }

  void _requestDownload(TaskInfo task) async {
    Wakelock.enable();
    setState(() {
      dFileName = task.hdLink.split('/').last;
    });
    print("100: $dFileName");
    saveNewFileName(dFileName);
    task.taskId = await FlutterDownloader.enqueue(
        url: task.hdLink,
        headers: {"auth": "test_for_sql_encoding"},
        savedDir: dLocalPath,
        showNotification: true,
        openFileFromNotification: true);

    int progress = 0;
    createTodo(task, task.name, dFileName, widget.game.datatype, widget.game.id,
        task.taskId, progress, task.hdLink);
  }

  void _requestDownload360(TaskInfo task) async {
    Wakelock.enable();
    setState(() {
      dFileName = task.link360.split('/').last;
    });
    saveNewFileName(dFileName);
    task.taskId = await FlutterDownloader.enqueue(
        url: task.link360,
        headers: {"auth": "test_for_sql_encoding"},
        savedDir: dLocalPath,
        showNotification: true,
        openFileFromNotification: true);

    int progress = 0;
    createTodo(task, task.name, dFileName, widget.game.datatype, widget.game.id,
        task.taskId, progress, task.link360);
  }

  void _requestDownload480(TaskInfo task) async {
    Wakelock.enable();
    setState(() {
      dFileName = task.link480.split('/').last;
    });
    saveNewFileName(dFileName);
    task.taskId = await FlutterDownloader.enqueue(
        url: task.link480,
        headers: {"auth": "test_for_sql_encoding"},
        savedDir: dLocalPath,
        showNotification: true,
        openFileFromNotification: true);

    int progress = 0;
    createTodo(task, task.name, dFileName, widget.game.datatype, widget.game.id,
        task.taskId, progress, task.link480);
  }

  void _requestDownload720(TaskInfo task) async {
    Wakelock.enable();
    setState(() {
      dFileName = task.link720.split('/').last;
    });
    saveNewFileName(dFileName);
    task.taskId = await FlutterDownloader.enqueue(
        url: task.link720,
        headers: {"auth": "test_for_sql_encoding"},
        savedDir: dLocalPath,
        showNotification: true,
        openFileFromNotification: true);

    int progress = 0;
    createTodo(task, task.name, dFileName, widget.game.datatype, widget.game.id,
        task.taskId, progress, task.link720);
  }

  void _requestDownload1080(TaskInfo task) async {
    Wakelock.enable();
    setState(() {
      dFileName = task.link1080.split('/').last;
    });
    saveNewFileName(dFileName);
    task.taskId = await FlutterDownloader.enqueue(
        url: task.link1080,
        headers: {"auth": "test_for_sql_encoding"},
        savedDir: dLocalPath,
        showNotification: true,
        openFileFromNotification: true);

    int progress = 0;
    createTodo(task, task.name, dFileName, widget.game.datatype, widget.game.id,
        task.taskId, progress, task.link1080);
  }

  void _cancelDownload(TaskInfo task) async {
    await FlutterDownloader.cancel(taskId: task.taskId);
  }

  void _pauseDownload(TaskInfo task) async {
    await FlutterDownloader.pause(taskId: task.taskId);
  }

  void _resumeDownload(TaskInfo task) async {
    String newTaskId = await FlutterDownloader.resume(taskId: task.taskId);
    task.taskId = newTaskId;
  }

  void _retryDownload(TaskInfo task) async {
    String newTaskId = await FlutterDownloader.retry(taskId: task.taskId);
    task.taskId = newTaskId;
  }

  Future<bool> _openDownloadedFile(TaskInfo task) async {
    var response = await cdb.query(
      DatabaseCreator.todoTable,
      where: "movie_id = ? AND vtype = ?",
      whereArgs: [widget.game.id, widget.game.datatype],
    );

    var cFileName = response[0]['info'];

    var fileNamenew = cFileName.split('/').last;

    var router = new MaterialPageRoute(
        builder: (BuildContext context) => DownloadedVideoPlayer(
              taskId: task.taskId,
              name: task.name,
              fileName: fileNamenew,
              downloadStatus: 0,
            ));
    Navigator.of(context).push(router);

    return null;
  }

//  Download text
  Widget downloadText(TaskInfo task) {
    return task.status == DownloadTaskStatus.complete
        ? Text(
            "Downloaded",
            style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.0,
                color: redPrime
                // color: Colors.white
                ),
          )
        : Text(
            "Download",
            style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.0,
                color: Colors.white
                // color: Colors.white
                ),
          );
  }

  void _showMsg() {
    if (userPaypalHistory.length == 0 || userStripeHistory == null) {
      dMsg = "Watch unlimited movies, TV shows and videos in HD or SD quality."
          " You don't have subscribe.";
    } else {
      dMsg = "Watch unlimited movies, TV shows and videos in HD or SD quality."
          " You don't have any active subscription plan.";
    }
    // set up the button
    Widget cancelButton = FlatButton(
      child: Text(
        "Cancel",
        style: TextStyle(color: redPrime, fontSize: 16.0),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    Widget subscribeButton = FlatButton(
      child: Text(
        "Subscribe",
        style: TextStyle(color: redPrime, fontSize: 16.0),
      ),
      onPressed: () {
        Navigator.pop(context);
        var router = new MaterialPageRoute(
            builder: (BuildContext context) => new SubscriptionPlan());
        Navigator.of(context).push(router);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      contentPadding:
          EdgeInsets.only(top: 10.0, left: 16.0, right: 16.0, bottom: 0.0),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Subscribe Plans",
            style: TextStyle(color: Colors.black),
          ),
        ],
      ),
      content: Row(
        children: <Widget>[
          Flexible(
            flex: 1,
            fit: FlexFit.loose,
            child: Text(
              "$dMsg",
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          )
        ],
      ),
      actions: [
        subscribeButton,
        cancelButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Widget column() {
    if (download == 0) {
      return Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Ink(
              decoration: ShapeDecoration(
                color: redPrime,
                shape: CircleBorder(),
              ),
              child: IconButton(
                  icon: Icon(
                    Icons.file_download,
                    size: 30,
                    color: primaryColor,
                  ),
                  onPressed: () {
                    Fluttertoast.showToast(msg: "Downloading is OFF.");
                  }),
            ),
          ),
          Text(
            "Download",
            style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.0,
                color: textColor),
          ),
        ],
      );
    } else {
      return status == "1"
          ? userPaymentType == "Free"
              ? Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Ink(
                        decoration: ShapeDecoration(
                          color: redPrime,
                          shape: CircleBorder(),
                        ),
                        child: IconButton(
                            icon: Icon(
                              Icons.download_outlined,
                              size: 30,
                              color: primaryColor,
                            ),
                            onPressed: () {
                              Fluttertoast.showToast(
                                  msg:
                                      "You can not download video using free trial.");
                            }),
                      ),
                    ),
                    Text(
                      "Download",
                      style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.0,
                          color: textColor),
                    ),
                  ],
                )
              : Builder(
                  builder: (context) => isLoading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : permissionReady
                          ? Container(
                              child: Column(
                                children: dItems.map((item) {
                                  checkConn(item.task);
                                  return item.task == null
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0, vertical: 8.0),
                                          child: Text(
                                            item.name,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: textColor,
                                                fontSize: 18.0),
                                          ),
                                        )
                                      : Container(
                                          child: InkWell(
                                            onTap: item.task.status ==
                                                    DownloadTaskStatus.complete
                                                ? () {
                                                    _openDownloadedFile(
                                                            item.task)
                                                        .then((success) {
                                                      if (!success) {
                                                        Scaffold.of(context)
                                                            .showSnackBar(SnackBar(
                                                                content: Text(
                                                                    'Cannot open this file')));
                                                      }
                                                    });
                                                  }
                                                : null,
                                            child: Stack(
                                              children: <Widget>[
                                                new Container(
                                                  width: double.infinity,
                                                  margin: EdgeInsets.only(
                                                      bottom: 10.0),
                                                  height: 62.0,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: <Widget>[
                                                      _buildActionForTask(
                                                          item.task),
                                                      downloadText(item.task),
                                                    ],
                                                  ),
                                                ),
                                                item.task.status ==
                                                            DownloadTaskStatus
                                                                .running ||
                                                        item.task.status ==
                                                            DownloadTaskStatus
                                                                .paused
                                                    ? new Positioned(
                                                        left: 15.0,
                                                        right: 15.0,
                                                        bottom: 0.0,
                                                        child:
                                                            LinearProgressIndicator(
                                                          value: item.task
                                                                  .progress /
                                                              100,
                                                        ),
                                                      )
                                                    : Container()
                                              ]
                                                  .where(
                                                      (child) => child != null)
                                                  .toList(),
                                            ),
                                          ),
                                        );
                                }).toList(),
                              ),
                            )
                          : Container(
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24.0),
                                      child: Text(
                                        'Please grant accessing storage permission to continue -_-',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.blueGrey,
                                            fontSize: 18.0),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 32.0,
                                    ),
                                    FlatButton(
                                        onPressed: () {
                                          _checkPermission().then((hasGranted) {
                                            setState(() {
                                              permissionReady = hasGranted;
                                            });
                                          });
                                        },
                                        child: Text(
                                          'Retry',
                                          style: TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20.0),
                                        ))
                                  ],
                                ),
                              ),
                            ),
                )
          : Column(
              children: <Widget>[
                IconButton(
                    icon: Icon(Icons.file_download),
                    onPressed: () {
                      _showMsg();
                    }),
                Text(
                  "Download",
                  style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.0,
                      color: Colors.white
                      // color: Colors.white
                      ),
                ),
              ],
            );
    }
  }

  getNewFileName() async {
    prefs = await SharedPreferences.getInstance();
    prefs.getString('dFileName');
    setState(() {
      downFileName = prefs.getString('dFileName');
    });
    print("getFileName: $downFileName");
  }

  @override
  void initState() {
    // TODO: implement initState
    _bindBackgroundIsolate();
    FlutterDownloader.registerCallback(downloadCallback);
    isLoading = true;
    permissionReady = false;
    _prepare();
    getNewFileName();
    if (status == "1") {
      if (userPaymentType != "Free") {
        getAllScreens();
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        child: column(),
        color: primaryColor,
      ),
    );
  }
}
