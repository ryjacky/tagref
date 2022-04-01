import 'package:flutter/material.dart';
import 'package:ui/ui.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TagRef',
      theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue),
      home: const MyHomePage(title: 'TagRef Home'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _TagRefHomePageState();
}

class _TagRefHomePageState extends State<MyHomePage> {
  int count = 0;

  void incrementCounter() {
    setState(() {
      count++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              PinBtnPinned(onPressed: incrementCounter),
              PinBtnUnpinned(onPressed: incrementCounter),
              RemoveBin(onPressed: incrementCounter),
              SourceBtnSmall(onPressed: incrementCounter),
              SortBtn(onPressed: incrementCounter),
            ],
          ),
          SourceBtn(onPressed: incrementCounter),
          EditTagBtn(onPressed: incrementCounter),
          Tag(onPressed: incrementCounter, tagWd: "tagWd"),
          const SizedBox(height: 6),
          Tag(onPressed: incrementCounter, tagWd: "sex"),
          const SizedBox(height: 6),
          AddTagField(),
          ClipRect(
              child: Padding(
            padding: const EdgeInsets.all(100.0),
            child: Stack(children: <Widget>[
              const Image(image: AssetImage('assets/beautiful_view.png')),
              AddBtn(onPressed: incrementCounter),
            ]),
          )),
        ],
      ),
    );
  }
}
