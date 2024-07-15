import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Option extends StatefulWidget {
  const Option({super.key});

  @override
  _Option createState() => _Option();
}

class _Option extends State<Option> {

  Widget _createOption({required String statement, required String initialValue, required ValueSetter<String> onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        decoration: InputDecoration(
          prefix: Text(
            statement,
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        initialValue: initialValue,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _createOption(
                statement: "WiFi 刷新週期(秒): ",
                initialValue: optionData.getWifiUpdateCycle().toString(),
                onChanged: (data) => optionData.setWifiUpdateCycle(int.tryParse(data))
            ),
            _createOption(
                statement: "Bluetooth 刷新週期(秒): ",
                initialValue: optionData.getBluetoothUpdateCycle().toString(),
                onChanged: (data) => optionData.setBluetoothUpdateCycle(int.tryParse(data))
            ),
          ],
        ),
      ),
    );
  }
}

// Store data.
// -----------------------------------------------------------------

OptionData optionData = OptionData();

class OptionData {

  late int _wifiUpdateCycle;
  late int _bluetoothUpdateCycle;

  OptionData() {
    _wifiUpdateCycle = 5;
    _bluetoothUpdateCycle = 5;
  }

  int getWifiUpdateCycle() { return _wifiUpdateCycle; }
  int getBluetoothUpdateCycle() { return _bluetoothUpdateCycle; }

  void setWifiUpdateCycle(int? data) { if(data != null) _wifiUpdateCycle = data; }
  void setBluetoothUpdateCycle(int? data) { if(data != null) _bluetoothUpdateCycle = data; }
}

// -----------------------------------------------------------------