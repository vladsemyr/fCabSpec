import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:provider/provider.dart';

class PortModel with ChangeNotifier {
  SerialPort? port;

  bool setPort(String portName) {
    if (portName == port?.name) {
      return true;
    }
    
    final newPort = SerialPort(portName);
    newPort.openReadWrite();
    if (newPort.isOpen) {
      if (port != null) {
        port!.close();
        port!.dispose();
      }
      port = newPort;
    }
    else {
      return false;
    }
    
    print("port name $portName (${port?.isOpen})");
    return true;
  }
  
  void setParams({
    int? baudRate,
    int? dataBits,
    int? parity, // SerialPortParity
    int? stopBit, //
  }) {
    final cfg = SerialPortConfig();
    
    if (baudRate != null) {
      cfg.baudRate = baudRate;
    }
    
    if (dataBits != null) {
      cfg.bits = dataBits;
    }
    
    if (parity != null) {
      cfg.parity = parity;
    }
    
    if (stopBit != null) {
      cfg.stopBits = stopBit;
    }
    
    port?.config = cfg;
  }
  
  SerialPortConfig getParams() {
    return port!.config;
  }
}

class PortSelector extends StatefulWidget {
  const PortSelector({super.key});

  @override
  State<PortSelector> createState() => _PortSelectorState();
}

class _PortSelectorState extends State<PortSelector> {
  var _ports = SerialPort.availablePorts;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(5.0),
            alignment: Alignment.center,
            child: Consumer<PortModel>(
                builder: (context, portModel, child) => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Выберите порт:"),
                          SizedBox(
                            height: 10.0,
                          ),
                          Visibility(
                              visible: _ports.isEmpty,
                              child: Column(children: [
                                OutlinedButton(
                                    onPressed: () {
                                      setState(() {
                                        _ports = SerialPort.availablePorts;
                                      });
                                    },
                                    child:
                                        Text("нет доступных портов, повторить"))
                              ])),
                          Column(
                              children: _ports.map((e) {
                            final port = SerialPort(e);
                            String name = port.name == null ? "" : port.name!;
                            name += port.description == null
                                ? ""
                                : "\n(${port.description!})";
                            if (port.isOpen) {
                              port.close();
                            }

                            port.dispose();

                            return InkWell(
                              // When the user taps the button, show a snackbar.
                              onTap: () {
                                /*
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text('Настройка порта'),
                              ));
                              */
                                final isOpened = portModel.setPort(e);
                                if (!isOpened) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Не удается открыть порт $e'),
                                      action: SnackBarAction(
                                        label: 'Скрыть',
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                          // Code to execute.
                                        },
                                      ),
                                    ),
                                  );
                                  
                                  return;
                                }

                                Navigator.pushNamed(context, "/");
                              },
                              child: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Text(name),
                              ),
                            );
                          }).toList()),
                        ]))));
  }
}
