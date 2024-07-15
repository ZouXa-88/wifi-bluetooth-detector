import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';


class BluetoothDetector extends StatefulWidget {
  const BluetoothDetector({super.key});

  @override
  _BluetoothDetector createState() => _BluetoothDetector();
}

class _BluetoothDetector extends State<BluetoothDetector> {

  late Timer _timer;
  int timeCount = 10;
  List<ScanResult> _currentResults = List.empty(growable: true);
  List<ScanResult> _lastResults = List.empty(growable: true);
  //StreamSubscription<BluetoothDiscoveryResult>? _streamSubscription;
  //List<BluetoothDiscoveryResult> _results = List<BluetoothDiscoveryResult>.empty(growable: true);


  @override
  void initState() {
    _bluetoothSetup();
    super.initState();
  }

  void _bluetoothSetup() async {
    _detect();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _timeUpdate());
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
    FlutterBluePlus.instance.startScan(timeout: const Duration(seconds: 1)).then((_) {
      setState(() {
        _lastResults = _currentResults.toList();
        _currentResults.clear();
      });
    });
  }

  List<ScanResult> _filter(final List<ScanResult>? results) {
    if(results == null){
      return List<ScanResult>.empty(growable: true);
    }

    List<ScanResult> filtered = List.from(results, growable: true);
    filtered.removeWhere((element) => element.device.name.isEmpty);
    filtered.sort((ScanResult a, ScanResult b) => -a.rssi.compareTo(b.rssi));
    return filtered;
  }

  int? _getRssiDiffer(final ScanResult currentResult) {
    ScanResult? lastStateDevice;
    for(ScanResult result in _lastResults){
      if(result.device.name == currentResult.device.name){
        lastStateDevice = result;
        break;
      }
    }

    if(lastStateDevice != null){
      return currentResult.rssi - lastStateDevice.rssi;
    }
    return null;
  }

  @override
  void dispose() {
    _timer.cancel();
    FlutterBluePlus.instance.stopScan();
    //_streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Bluetooth"),
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
      body: Container(
        padding: const EdgeInsets.all(10),
        child: StreamBuilder<List<ScanResult>>(
          stream: FlutterBluePlus.instance.scanResults,
          initialData: const [],
          builder: (context, snapshot) {
            final List<ScanResult> results = _filter(snapshot.data);
            return ListView.builder(
              itemCount: results.length,
              itemBuilder: (BuildContext buildContext, int index) {
                _currentResults.add(results[index]);
                int? rssiDiffer = _getRssiDiffer(results[index]);
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.devices),
                    title: Text(results[index].device.name),
                    subtitle: rssiDiffer == null ? const Text("") : Text(rssiDiffer.toString()),
                    trailing: Text(results[index].rssi.toString()),
                  ),
                );
              },
              physics: const BouncingScrollPhysics(),
            );
          },
        ),
      )
    );
  }
}