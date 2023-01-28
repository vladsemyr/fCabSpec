import 'package:cable_spector/app_state.dart';
import 'package:cable_spector/port_configuration.dart';
import 'package:cable_spector/port_selector.dart';
import 'package:cable_spector/port_selfdiag.dart';
import 'package:flutter/material.dart';
/*
import 'package:flutter_libserialport/flutter_libserialport.dart';
*/
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<LogModel>(create: (_) => LogModel()),
      ChangeNotifierProvider<PortModel>(create: (_) => PortModel()),
      ChangeNotifierProvider<AppModel>(create: (_) => AppModel()),
    ],
    child: const MyApp(),
  ));
}

class LogModel with ChangeNotifier {
  String text = "";
  bool visible = true;

  void addMessage(String message) {
    DateTime now = DateTime.now();
    text +=
        "\n${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}: $message";
    notifyListeners();
  }

  void show() {
    visible = true;
    notifyListeners();
  }

  void hide() {
    visible = false;
    notifyListeners();
  }

  void clear() {
    text = "";
    notifyListeners();
  }
}

class LogWidget extends StatelessWidget {
  const LogWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LogModel>(
      builder: (context, log, child) {
        return Text(log.text);
      },
    );
  }
}

class ThemeClass {
  static ThemeData lightTheme = ThemeData(colorScheme: ColorScheme.light());

  static ThemeData darkTheme = ThemeData(colorScheme: ColorScheme.dark());
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme:
          ThemeData(brightness: Brightness.dark, primaryColor: Colors.blueGrey),
      title: 'Startup Name Generator',
      //home: MyHomePage(),
      routes: {
        '/': (context) => MyHomePage(),
        '/details': (context) => MyHomePage(),
        '/portSelect': (context) => PortSelector(),
        '/portConfig': (context) => PortConfiguration(),
        '/portSelfdiag': (context) => PortSelfDiagnostic(),
      },
      initialRoute: '/portSelect',
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final boxDecoration = BoxDecoration(
      color: Theme.of(context).dialogBackgroundColor,
      borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10)),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 5,
          blurRadius: 7,
          offset: const Offset(0, 3), // changes position of shadow
        ),
      ],
    );

    final scroll = SingleChildScrollView(
      reverse: true,
      controller: _scrollController,
      child: LogWidget(),
    );

    return Scaffold(
        body: Container(
            padding: const EdgeInsets.all(5.0),
            width: double.infinity,
            child: Column(children: [
              Expanded(
                  child: Row(
                children: [
                  Container(
                      width: 200.0,
                      padding: const EdgeInsets.all(5.0),
                      margin: const EdgeInsets.all(5.0),
                      decoration: boxDecoration,
                      child: Column(children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(35), // NEW
                          ),
                          child:
                              Text("Выбор порта", textAlign: TextAlign.center),
                          onPressed: () {
                            final model =
                                Provider.of<LogModel>(context, listen: false);
                            model.clear();
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(35), // NEW
                          ),
                          child: Text("Настройка порта",
                              textAlign: TextAlign.center),
                          onPressed: () {
                            final model =
                                Provider.of<LogModel>(context, listen: false);
                            model.clear();
                            Navigator.pushNamed(context, "/portConfig");
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50), // NEW
                          ),
                          child: Text("Открыть/скрыть журнал",
                              textAlign: TextAlign.center),
                          onPressed: () {
                            final model =
                                Provider.of<LogModel>(context, listen: false);
                            model.addMessage("message");
                            if (!model.visible) {
                              model.show();
                            } else {
                              model.hide();
                            }
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(35), // NEW
                          ),
                          child: Text("Selfdiag",
                              textAlign: TextAlign.center),
                          onPressed: () {
                            Navigator.pushNamed(context, "/portSelfdiag");
                          },
                        ),
                      ])),
                  Expanded(
                      child: Container(
                    margin: const EdgeInsets.all(5.0),
                    padding: const EdgeInsets.all(5.0),
                    width: 200.0,
                    decoration: boxDecoration,
                    child: ListView(
                      children: [],
                    ),
                  ))
                ],
              )),
              Consumer<LogModel>(builder: (context, log, child) {
                return Visibility(
                  visible: log.visible,
                  child: Container(
                      height: 100.0,
                      width: double.infinity,
                      margin: const EdgeInsets.all(5.0),
                      padding: const EdgeInsets.all(10.0),
                      decoration: boxDecoration,
                      child: scroll),
                );
              }),
            ])));
  }
}
