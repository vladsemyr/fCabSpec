import 'package:cable_spector/port_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:provider/provider.dart';

class PortConfiguration extends StatefulWidget {
  const PortConfiguration({Key? key}) : super(key: key);

  @override
  State<PortConfiguration> createState() => _PortConfigurationState();
}

const Map<int, int> baudRateMap = {
  75: 75,
  110: 110,
  150: 150,
  300: 300,
  600: 600,
  1200: 1200,
  1800: 1800,
  2400: 2400,
  4800: 4800,
  7200: 7200,
  9600: 9600,
  14400: 14400,
  19200: 19200,
  38400: 38400,
  56000: 56000,
  57600: 57600,
  115200: 115200,
  128000: 128000,
  25600: 256000
};

const Map<int, int> dataBitsMap = {7: 7, 8: 8};

const Map<int, String> parityMap = {
  SerialPortParity.none: "Нет",
  SerialPortParity.odd: "Odd (Четность)",
  SerialPortParity.even: "Even (Нечетность)",
  SerialPortParity.mark: "Mark (Единица)",
  SerialPortParity.space: "Space (Ноль)",
};

const Map<int, String> stopBitsMap = {1: "1", 3: "1.5", 2: "2"};

const List<String> flowControlList = [
  "None",
];

class PortConfigDropdown<T> extends StatefulWidget {
  final String label;
  final T selectedItem;
  final List<DropdownMenuItem<T>> items;

  const PortConfigDropdown(
      {super.key,
      required this.label,
      required this.selectedItem,
      required this.items});
  
  @override
  State<PortConfigDropdown<T>> createState() => _PortConfigDropdownState<T>();
}

class _PortConfigDropdownState<T> extends State<PortConfigDropdown<T>> {
  T? selectedItem;
  
  @override
  Widget build(BuildContext context) {
    selectedItem ??= widget.selectedItem;
    
    return DropdownButtonFormField(
      decoration: InputDecoration(label: Text(widget.label)),
      value: selectedItem,
      items: widget.items,
      onChanged: (T? value) {
        if (value != null) {
          setState(() {
            selectedItem = value;
          });
        }
      },
    );
  }
}

class _PortConfigurationState extends State<PortConfiguration> {
  List<DropdownMenuItem<int>> get baudRateItems {
    List<DropdownMenuItem<int>> menuItems = baudRateMap.entries
        .map((entry) => DropdownMenuItem(
            value: entry.key, child: Text(entry.value.toString())))
        .toList();
    return menuItems;
  }

  List<DropdownMenuItem<int>> get dataBitsItems {
    List<DropdownMenuItem<int>> menuItems = dataBitsMap.entries
        .map((entry) => DropdownMenuItem(
            value: entry.key, child: Text(entry.value.toString())))
        .toList();
    return menuItems;
  }

  List<DropdownMenuItem<int>> get parityItems {
    List<DropdownMenuItem<int>> menuItems = parityMap.entries
        .map((entry) => DropdownMenuItem(
            value: entry.key, child: Text(entry.value.toString())))
        .toList();
    return menuItems;
  }

  List<DropdownMenuItem<int>> get stopBitsItems {
    List<DropdownMenuItem<int>> menuItems = stopBitsMap.entries
        .map((entry) => DropdownMenuItem(
            value: entry.key, child: Text(entry.value.toString())))
        .toList();
    return menuItems;
  }

  @override
  Widget build(BuildContext context) {
    int selectedBaudRate = 19200;
    int selectedDataBits = 8;
    int selectedParity = parityMap.entries.first.key;
    int selectedStopBits = stopBitsMap.entries.first.key;

    return Scaffold(
        appBar: AppBar(
          title: const Text("Настройка порта"),
        ),
        body: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(5.0),
          alignment: Alignment.center,
          child: Consumer<PortModel>(builder: (context, portModel, child) {
            final defconf = portModel.getParams();
            if (baudRateMap.containsKey(defconf.baudRate)) {
              selectedBaudRate = defconf.baudRate;
            }

            if (dataBitsMap.containsKey(defconf.bits)) {
              selectedDataBits = defconf.bits;
            }

            if (parityMap.containsKey(defconf.parity)) {
              selectedParity = defconf.parity;
            }

            if (stopBitsMap.containsKey(defconf.stopBits)) {
              selectedStopBits = defconf.stopBits;
            }
            
            final speedKey = GlobalKey<_PortConfigDropdownState<int>>();
            final speedWidget = PortConfigDropdown(
                key: speedKey,
                label: "Скорость",
                items: baudRateItems,
                selectedItem: selectedBaudRate);
            final dataBitsKey = GlobalKey<_PortConfigDropdownState<int>>();
            final dataBitsWidget = PortConfigDropdown(
                key: dataBitsKey,
                label: "Биты данных",
                items: dataBitsItems,
                selectedItem: selectedDataBits);
            final parityKey = GlobalKey<_PortConfigDropdownState<int>>();
            final parityWidget = PortConfigDropdown(
                key: parityKey,
                label: "Четность",
                items: parityItems,
                selectedItem: selectedParity);
            final stopBitsyKey = GlobalKey<_PortConfigDropdownState<int>>();
            final stopBitsWidget = PortConfigDropdown(
                key: stopBitsyKey,
                label: "Стоповые биты",
                items: stopBitsItems,
                selectedItem: selectedStopBits);

            return SingleChildScrollView(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Настройка порта ${portModel.port?.name}"),
                Container(
                  width: 400,
                  padding: EdgeInsets.all(5),
                  child: Column(children: [
                    speedWidget,
                    dataBitsWidget,
                    parityWidget,
                    stopBitsWidget,
                  ]),
                ),
                Row(
                  children: [
                    Expanded(
                        child: Container(
                      margin: const EdgeInsets.all(5.0),
                      padding: const EdgeInsets.all(5.0),
                      height: 20.0,
                      child: ListView(
                        children: [],
                      ),
                    ))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        margin: EdgeInsets.all(5.0),
                        child: OutlinedButton(
                            onPressed: () {
                              portModel.setParams(
                                  baudRate: speedKey.currentState?.selectedItem,
                                  dataBits: dataBitsKey.currentState?.selectedItem,
                                  parity: parityKey.currentState?.selectedItem,
                                  stopBit: stopBitsyKey.currentState?.selectedItem);
                              Navigator.pop(context);
                            },
                            child: Text("Ок"))),
                    Container(
                        margin: EdgeInsets.all(5.0),
                        child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("Отмена"))),
                  ],
                )
              ],
            ));
          }),
        ));
  }
}
