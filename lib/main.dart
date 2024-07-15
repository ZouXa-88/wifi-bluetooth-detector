import 'package:flutter/material.dart';

import 'pages/home.dart';
import 'pages/wifi.dart';
import 'pages/bluetooth.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const Detector(),
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Detector extends StatefulWidget{
  const Detector({super.key});

  @override
  _Detector createState() => _Detector();
}

class _Detector extends State<Detector>{

  final pages = const [Home(), WifiDetector(), BluetoothDetector()];
  late int _selectedIndex;


  @override
  void initState() {
    _selectedIndex = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        body: pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "首頁",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.wifi),
              label: "WiFi",
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.bluetooth),
                label: "Bluetooth"
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState((){
              _selectedIndex = index;
            });
          },
        ),

      ),
      onWillPop: () async {
        if(_selectedIndex == 0){
          return true;
        }
        setState(() {
          _selectedIndex = 0;
        });
        return false;
      }
    );
  }
}