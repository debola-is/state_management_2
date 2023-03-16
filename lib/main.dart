import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inherited Widget',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ApiProvider(
        api: Api(),
        child: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ValueKey _textKey = ValueKey<String?>(null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ApiProvider.of(context).api.dateAndTime ?? ''),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () async {
          final api = ApiProvider.of(context).api;
          final timeAndDate = await api.getDateAndTime();
          setState(() {
            _textKey = ValueKey(timeAndDate);
          });
        },
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(25),
            color: Colors.red,
            child: DateTimeWidget(key: _textKey),
          ),
        ),
      ),
    );
  }
}

class DateTimeWidget extends StatelessWidget {
  // This class will just be used to demonstrate theat so long as a widget is a dependant below the tree of an inherited widget, it can have access to the same data in the tree.
  const DateTimeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final api = ApiProvider.of(context).api;
    return Text(api.dateAndTime ?? 'Tap on Screen to fetch date and time');
  }
}

class Api {
  String? dateAndTime;

  Future<String> getDateAndTime() {
    return Future.delayed(
            const Duration(seconds: 2), () => DateTime.now().toIso8601String())
        .then((value) {
      dateAndTime = value;
      return value;
    });
  }
}

class ApiProvider extends InheritedWidget {
  final Api api;
  final String uuid;

  ApiProvider({
    Key? key,
    required this.api,
    required Widget child,
  })  : uuid = const Uuid().v4(),
        super(
          key: key,
          child: child,
        );

/*  
This function just evalutes if the uuid of the current class is not the same as the uuid of the oldWidget, then the children should be redrawn.
Note that replacing your inherited widget redraws all children. So, if your inherited widget is sitting high up in the widget tree, this will trigger a rebuild of the entire widgets under it.
*/

  @override
  bool updateShouldNotify(covariant ApiProvider oldWidget) =>
      uuid != oldWidget.uuid;

/* 
We need a way for the child of our inherited widget to have access to the instance of our Api Provider. 
The "of" function is an inbuilt flutter function that gives similar functionality to classes such as MediaQuery, Theme managers etc. 
*/
  static ApiProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ApiProvider>()!;
  }
}
