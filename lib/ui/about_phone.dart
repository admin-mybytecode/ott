import 'dart:io';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_info/device_info.dart';
import 'package:nexthour/global.dart';

class AboutPhone extends StatefulWidget {
  @override
  _AboutPhoneState createState() => _AboutPhoneState();
}

class _AboutPhoneState extends State<AboutPhone> {

  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};

  Future<void> initPlatformState() async {
    Map<String, dynamic> deviceData;

    try {
      if (Platform.isAndroid) {
        deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
      } else if (Platform.isIOS) {
        deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }

    if (!mounted) return;

    setState(() {
      _deviceData = deviceData;
    });
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'Version.securityPatch': build.version.securityPatch,
      'Version.sdkInt': build.version.sdkInt,
      'Version.release': build.version.release,
      'Version.previewSdkInt': build.version.previewSdkInt,
      'Version.incremental': build.version.incremental,
      'Version.codename': build.version.codename,
      'Version.baseOS': build.version.baseOS,
      'Board': build.board,
      'Bootloader': build.bootloader,
      'Brand': build.brand,
      'Device': build.device,
      'Display': build.display,
      'Fingerprint': build.fingerprint,
      'Hardware': build.hardware,
      'Host': build.host,
      'Id': build.id,
      'Manufacturer': build.manufacturer,
      'Model': build.model,
      'Product': build.product,
      'Supported32BitAbis': build.supported32BitAbis,
      'Ssupported64BitAbis': build.supported64BitAbis,
      'SupportedAbis': build.supportedAbis,
      'Tags': build.tags,
      'Type': build.type,
      'IsPhysicalDevice': build.isPhysicalDevice,
      'AndroidId': build.androidId,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Device Info",style: TextStyle(fontSize: 16.0),),
        centerTitle: true,

        backgroundColor:
        primaryColor.withOpacity(0.98),
      ),
      body: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.only(left: 10.0, right: 10.0),
        children: _deviceData.keys.map((String property) {
          return Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        property,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14.0
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
                        child: Text(
                          '${_deviceData[property]}',
                          style: TextStyle(color: Colors.white.withOpacity(0.5)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                  ),
                ],
              ),
              Container(
                height: 0.3,
                color: Colors.white.withOpacity(0.2),
              )
            ],
          );
        }).toList(),
      ),
    );
  }
}