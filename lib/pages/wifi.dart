import 'dart:async';

import 'package:flutter/material.dart';

import 'package:wifi_scan/wifi_scan.dart';

class WifiDetector extends StatefulWidget{
  const WifiDetector({super.key});

  @override
  _WifiDetector createState() => _WifiDetector();
}

class _WifiDetector extends State<WifiDetector>{

  late Timer _timer;
  int timeCount = 10;

  List<WiFiAccessPoint> _accessPoints = List.empty();
  List<WiFiAccessPoint> _lastAccessPoints = List.empty();

  List<WiFiAccessPoint> _presentAll = List.empty();
  List<WiFiAccessPoint> _present24G = List.empty(growable: true);
  List<WiFiAccessPoint> _present5G = List.empty(growable: true);

  int _frequencyType = 0;


  @override
  void initState() {
    _detect();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _timeUpdate());
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _timeUpdate() {
    if(timeCount == 0){
      _detect();
      setState(() {
        timeCount = 10;
      });
    }
    else{
      setState(() {
        timeCount -= 1;
      });
    }
  }

  void _detect() async {
    final can = await WiFiScan.instance.canStartScan(askPermissions: true);
    switch(can) {
      case CanStartScan.yes:
        await WiFiScan.instance.startScan();
        _update();
        break;
      default:
        break;
    }
  }

  void _update() async {
    final can = await WiFiScan.instance.canGetScannedResults(askPermissions: true);
    switch(can) {
      case CanGetScannedResults.yes:
        List<WiFiAccessPoint> accessPoints = await WiFiScan.instance.getScannedResults();
        accessPoints = _filter(accessPoints);
        setState(() {
          _lastAccessPoints = _accessPoints.toList();
          _accessPoints = List.from(accessPoints);
        });
        _updatePresentation();
        break;
      default:
        break;
    }
  }

  List<WiFiAccessPoint> _filter(final List<WiFiAccessPoint> accessPoint) {
    List<WiFiAccessPoint> filtered = List.from(accessPoint, growable: true);
    filtered.removeWhere((element) => element.ssid.isEmpty);
    filtered.sort((WiFiAccessPoint a, WiFiAccessPoint b) => -a.level.compareTo(b.level));
    return filtered;
  }

  Icon _getWifiIcon(final int rssi) {
    if(rssi >= -60) {
      return const Icon(Icons.wifi_outlined);
    }
    if(rssi >= -80) {
      return const Icon(Icons.wifi_2_bar_outlined);
    }
    return const Icon(Icons.wifi_1_bar_outlined);
  }

  void _updatePresentation() {
    setState(() {
      _presentAll = _accessPoints;
    });

    _present24G.clear();
      for(WiFiAccessPoint accessPoint in _accessPoints){
        if(accessPoint.frequency >= 2401 && accessPoint.frequency <= 2484){
          _present24G.add(accessPoint);
        }
      }

    _present5G.clear();
      for(WiFiAccessPoint accessPoint in _accessPoints){
        if(accessPoint.frequency >= 5170 && accessPoint.frequency <= 5825){
          _present5G.add(accessPoint);
        }
      }
  }

  List<WiFiAccessPoint> _getPresentList() {
    switch(_frequencyType){
      case 1:
        return _present24G;
      case 2:
        return _present5G;
      default:
        return _presentAll;
    }
  }

  int? _getRssiDiffer(final WiFiAccessPoint device) {
    WiFiAccessPoint? lastStateDevice;
    for(WiFiAccessPoint point in _lastAccessPoints){
      if(point.ssid == device.ssid){
        lastStateDevice = point;
        break;
      }
    }

    if(lastStateDevice != null){
      return device.level - lastStateDevice.level;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    List<WiFiAccessPoint> presentList = _getPresentList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("WiFi"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(
              child: Text(
                timeCount.toString(),
                style: const TextStyle(fontSize: 20),
              ),
            )
          ),
        ],
      ),
      body: Column(
        children: <Expanded>[
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <TextButton>[
                TextButton(
                  onPressed: _frequencyType == 0 ? null : () {
                    setState(() {
                      _frequencyType = 0;
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateColor.resolveWith(
                            (states) => _frequencyType == 0 ? Theme.of(context).primaryColor : Colors.grey),
                    shape: MaterialStateProperty.all<ContinuousRectangleBorder>(
                        const ContinuousRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                          ),
                        )
                    ),
                    fixedSize: MaterialStateProperty.all(const Size(80, 40)),
                  ),
                  child: Text(
                    "All",
                    style: TextStyle(
                      color: _frequencyType == 0 ? Colors.white : Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _frequencyType == 1 ? null : () {
                    setState(() {
                      _frequencyType = 1;
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateColor.resolveWith(
                            (states) => _frequencyType == 1 ? Theme.of(context).primaryColor : Colors.grey),
                    shape: MaterialStateProperty.all<ContinuousRectangleBorder>(
                        const ContinuousRectangleBorder()
                    ),
                    fixedSize: MaterialStateProperty.all(const Size(80, 40)),
                  ),
                  child: Text(
                    "2.4G",
                    style: TextStyle(
                      color: _frequencyType == 1 ? Colors.white : Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _frequencyType == 2 ? null : () {
                    setState(() {
                      _frequencyType = 2;
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateColor.resolveWith(
                            (states) => _frequencyType == 2 ? Theme.of(context).primaryColor : Colors.grey),
                    shape: MaterialStateProperty.all<ContinuousRectangleBorder>(
                        const ContinuousRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        )
                    ),
                    fixedSize: MaterialStateProperty.all(const Size(80, 40)),
                  ),
                  child: Text(
                    "5G",
                    style: TextStyle(
                      color: _frequencyType == 2 ? Colors.white : Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 9,
            child: Container(
              padding: const EdgeInsets.all(10),
              child: ListView.builder(
                itemCount: presentList.length,
                itemBuilder: (BuildContext buildContext, int index) {
                  int? rssiDiffer = _getRssiDiffer(presentList[index]);
                  return Card(
                    child: ListTile(
                      leading: _getWifiIcon(presentList[index].level),
                      title: Text(presentList[index].ssid),
                      subtitle: rssiDiffer == null ? const Text("") : Text(rssiDiffer.toString()),
                      trailing: Text(presentList[index].level.toString()),
                    ),
                  );
                },
                physics: const BouncingScrollPhysics(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}