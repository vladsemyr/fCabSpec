import 'package:cable_spector/port_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PortSelfDiagnostic extends StatefulWidget {
  const PortSelfDiagnostic({super.key});

  @override
  State<PortSelfDiagnostic> createState() => _PortSelfDiagnosticState();
}

class _PortSelfDiagnosticState extends State<PortSelfDiagnostic> {
  bool _inProgress = false;

  void _startSelfdiag(PortModel portModel) {
    setState(() {
      _inProgress = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      title: Text("Самодиагностика"),
      //automaticallyImplyLeading: !_inProgress,
    );
    return Consumer<PortModel>(
        builder: (context, portModel, child) => Scaffold(
              appBar: !_inProgress ? appBar : null,
              body: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: !_inProgress
                      ? [
                          SizedBox(
                            height:
                                _inProgress ? appBar.preferredSize.height : 0,
                          ),
                          OutlinedButton(
                              onPressed: () {
                                _startSelfdiag(portModel);
                              },
                              child: Text("Начать самодиагностиику")),
                          const SizedBox(
                            height: 10,
                          ),
                          OutlinedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, "/portConfig");
                              },
                              child: Text(
                                  "Конфигурация порта ${portModel.port!.name}"))
                        ]
                      : [
                        SizedBox(
                            height: appBar.preferredSize.height,
                          ),
                          Container(
                              width: 400,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                      width: 1.0,
                                      color: Color.fromARGB(255, 95, 95, 95)),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  SizedBox(
                                      width: 300,
                                      child: Text(
                                        "Отправка команды самодиагностики",
                                        textAlign: TextAlign.center,
                                      )),
                                  SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator())
                                ],
                              )),
                          const SizedBox(
                            height: 10,
                          ),
                          OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _inProgress = false;
                                });
                              },
                              child: Text("отмена"))
                        ],
                ),
              ),
            ));
  }
}
