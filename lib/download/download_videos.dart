import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:nexthour/controller/navigation_bar_controller.dart';
import 'package:nexthour/repository/database_creator.dart';

import '../global.dart';
import 'down_video_player.dart';

const debug = true;

class OfflineDownloadPage extends StatefulWidget {
  const OfflineDownloadPage({Key key}) : super(key: key);

  @override
  _OfflineDownloadPageState createState() => _OfflineDownloadPageState();
}

class _OfflineDownloadPageState extends State<OfflineDownloadPage> with SingleTickerProviderStateMixin {
  static const _channel = const MethodChannel('vn.hunghd/downloader');

  var videos = [];

  getUrlVideo() async {
    videos = await cdb.query(DatabaseCreator.todoTable);
    final tasks = await FlutterDownloader.loadTasks();

    int count = 0;
    _tasks = [];
    _items = [];
    _tasks.addAll(videos.map((video) => _TaskInfo(
        id: video['vtype'] == 'M' ? video['movie_id'] : video['tvseries_id'],
        name: video['name'],
        link: video['info'],
        type: video['vtype'],
        seasonId: video['vtype'] == 'M' ? null : video['season_id'],
        episodeId: video['vtype'] == 'M' ? null : video['episode_id'])
    )
    );

    for (int i = count; i < _tasks.length; i++) {
      _items.add(_ItemHolder(name: _tasks[i].name, task: _tasks[i]));
      count++;
    }

    tasks?.forEach((task) {
      for (_TaskInfo info in _tasks) {
        if (info.link == task.url) {
          info.taskId = task.taskId;
          info.status = task.status;
          info.progress = task.progress;
        }
      }
    });
    if(mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<_TaskInfo> _tasks;
  List<_ItemHolder> _items;
  bool _isLoading;
  String _localPath;
  ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();

    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      jsonFile = new File(dir.path + "/" + fileName);
      fileExists = jsonFile.existsSync();
      if (fileExists)
        this.setState(
            () => fileContent = json.decode(jsonFile.readAsStringSync()));
    });

    _isLoading = true;
  }

  @override
  void dispose() {
    super.dispose();
  }


  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    if (debug) {
      print(
          'Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');
    }
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }

  Widget appBar() {
    return AppBar(
      title: Text(
        "Download Videos",
        style: TextStyle(fontSize: 16.0),
      ),
      centerTitle: true,
      automaticallyImplyLeading: false,
      backgroundColor: primaryDarkColor.withOpacity(0.98),
    );
  }

  Future<String> getUpdates() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var router = new MaterialPageRoute(
            builder: (BuildContext context) => BottomNavigationBarController());
        Navigator.of(context).push(router);
      } else {
        return null;
      }
    } on SocketException catch (e3) {
      Fluttertoast.showToast(msg: "Connect to internet");
      return null;
    } on Exception catch (e4) {
      print("Exception $e4");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    getUrlVideo();
    return Scaffold(
      appBar: appBar(),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.black,
          child: Icon(
            Icons.refresh,
            color: Colors.white,
            size: 25.0,
          ),
          onPressed: () {
            getUpdates();
          }),
      body: Builder(builder: (context) {
        return _isLoading
            ? new Center(
                child: new CircularProgressIndicator(),
              )
            : new Container(
                child: new ListView(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  children: _items.map((item) {
//                    print("MyId1: ${_items}");
//                    print("MyId2: ${item.name}");
                    return item.task == null
                        ? new Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: Text(
                              item.name,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                  fontSize: 18.0),
                            ),
                          )
                        : new Container(
                            padding: const EdgeInsets.only(left: 16.0, right: 8.0),
                            child: InkWell(
                              onTap: item.task.status ==
                                      DownloadTaskStatus.complete
                                  ? () {
                                      _openDownloadedFile(item.task);
                                    }
                                  : null,
                              child: new Stack(
                                children: <Widget>[
                                  new Container(
                                    width: double.infinity,
                                    height: 64.0,
                                    child: new Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        new Expanded(
                                          child: new Text(
                                            item.name,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18.0),
                                            maxLines: 1,
                                            softWrap: true,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        new Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: _buildActionForTask(item.task),
                                        ),
                                      ],
                                    ),
                                  ),
                                  item.task.status ==
                                              DownloadTaskStatus.running ||
                                          item.task.status ==
                                              DownloadTaskStatus.paused
                                      ? new Positioned(
                                          left: 0.0,
                                          right: 0.0,
                                          bottom: 0.0,
                                          child: new LinearProgressIndicator(
                                            value: item.task.progress / 100,
                                          ),
                                        )
                                      : new Container()
                                ].where((child) => child != null).toList(),
                              ),
                            ),
                          );
                  }).toList(),
                ),
              );
      }),
    );
  }

  Widget _buildActionForTask(_TaskInfo task) {
    if (task.status == DownloadTaskStatus.undefined) {
      return new RawMaterialButton(
        onPressed: () {
          _requestDownload(task);
        },
        child: new Icon(Icons.file_download),
        shape: new CircleBorder(),
        constraints: new BoxConstraints(minHeight: 32.0, minWidth: 32.0),
      );
    } else if (task.status == DownloadTaskStatus.running) {
      return new RawMaterialButton(
        onPressed: () {
          _pauseDownload(task);
        },
        child: new Icon(
          Icons.pause,
          color: Colors.red,
        ),
        shape: new CircleBorder(),
        constraints: new BoxConstraints(minHeight: 32.0, minWidth: 32.0),
      );
    } else if (task.status == DownloadTaskStatus.paused) {
      return new RawMaterialButton(
        onPressed: () {
          _resumeDownload(task);
        },
        child: new Icon(
          Icons.play_arrow,
          color: Colors.green,
        ),
        shape: new CircleBorder(),
        constraints: new BoxConstraints(minHeight: 32.0, minWidth: 32.0),
      );
    } else if (task.status == DownloadTaskStatus.complete) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(
            Icons.play_arrow,
            color: Colors.green,
            size: 35.0,
          ),
          RawMaterialButton(
            onPressed: () {
              _delete(task);
            },
            child: Icon(
              Icons.delete_forever,
              color: Colors.red,
              size: 28.0,
            ),
            shape: new CircleBorder(),
            constraints: new BoxConstraints(minHeight: 32.0, minWidth: 32.0),
          )
        ],
      );
    } else if (task.status == DownloadTaskStatus.canceled) {
      return new Text('Canceled', style: new TextStyle(color: Colors.red));
    } else if (task.status == DownloadTaskStatus.failed) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          new Text('Failed', style: new TextStyle(color: Colors.red)),
          RawMaterialButton(
            onPressed: () {
              _retryDownload(task);
            },
            child: Icon(
              Icons.refresh,
              color: Colors.green,
            ),
            shape: new CircleBorder(),
            constraints: new BoxConstraints(minHeight: 32.0, minWidth: 32.0),
          )
        ],
      );
    } else {
      return null;
    }
  }

  void _requestDownload(_TaskInfo task) async {
    task.taskId = await FlutterDownloader.enqueue(
        url: task.link,
        headers: {"auth": "test_for_sql_encoding"},
        savedDir: _localPath,
        showNotification: true,
        openFileFromNotification: true);
  }

  void _cancelDownload(_TaskInfo task) async {
    await FlutterDownloader.cancel(taskId: task.taskId);
  }

  void _pauseDownload(_TaskInfo task) async {
    await FlutterDownloader.pause(taskId: task.taskId);
  }

  void _resumeDownload(_TaskInfo task) async {
    String newTaskId = await FlutterDownloader.resume(taskId: task.taskId);
    task.taskId = newTaskId;
  }

  void _retryDownload(_TaskInfo task) async {
    String newTaskId = await FlutterDownloader.retry(taskId: task.taskId);
    task.taskId = newTaskId;
  }

  Future<bool> _openDownloadedFile(_TaskInfo task) {
    var fileNamenew = task.link.split('/').last;

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

  void _delete(_TaskInfo task) async {
    await FlutterDownloader.remove(
        taskId: task.taskId, shouldDeleteContent: true);
    await _prepare();

    var raw = await task.type == 'M'
        ? cdb.delete(
            DatabaseCreator.todoTable,
            where: "movie_id = ? AND vtype = ?",
            whereArgs: [task.id, task.type],
          )
        : cdb.delete(DatabaseCreator.todoTable,
            where:
                "tvseries_id = ? AND vtype = ? AND season_id = ? AND episode_id = ?",
            whereArgs: [task.id, task.type, task.seasonId, task.episodeId]);
    setState(() {});
  }

  Future<Null> _prepare() async {
    final tasks = await FlutterDownloader.loadTasks();

    int count = 0;
    _tasks = [];
    _items = [];

    _tasks.addAll(videos
        .map((video) => _TaskInfo(name: video['name'], link: video['info'])));

    for (int i = count; i < _tasks.length; i++) {
      _items.add(_ItemHolder(name: _tasks[i].name, task: _tasks[i]));
      count++;
    }

    tasks?.forEach((task) {
      for (_TaskInfo info in _tasks) {
        if (info.link == task.url) {
          info.taskId = task.taskId;
          info.status = task.status;
          info.progress = task.progress;
        }
      }
    });

    _localPath = (await _findLocalPath()) + Platform.pathSeparator + 'Download';

    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<String> _findLocalPath() async {
    final platform = Theme.of(context).platform;
    final directory = platform == TargetPlatform.android
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory.path;
  }
}

class _TaskInfo {
  final String id;
  final String name;
  final String link;
  final String type;
  final String seasonId;
  final String episodeId;

  String taskId;
  int progress = 0;
  DownloadTaskStatus status = DownloadTaskStatus.undefined;

  _TaskInfo(
      {this.id,
      this.name,
      this.link,
      this.type,
      this.seasonId,
      this.episodeId});
}

class _ItemHolder {
  final String name;
  final _TaskInfo task;

  _ItemHolder({this.name, this.task});
}
