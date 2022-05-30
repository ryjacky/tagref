import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:tagref/assets/constant.dart';
import 'package:tagref/ui/ReferenceImageDisplay.dart';
import 'package:tagref/ui/TagSearchBar.dart';

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
      home: const TagRefHome(title: 'TagRef Home'),
    );
  }
}

class TagRefHome extends StatefulWidget {
  const TagRefHome({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<TagRefHome> createState() => _TagRefHomePageState();
}

class _TagRefHomePageState extends State<TagRefHome> {
  @override
  Widget build(BuildContext context) {
    double paddingH = MediaQuery.of(context).size.width / 5;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: Padding(
          padding: EdgeInsets.symmetric(horizontal: paddingH),
          child: TagSearchBar(),
        )
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(paddingH, 20, paddingH, 0),
        child: MasonryGridView.count(
          crossAxisCount: 3,
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          itemCount: 100,
          itemBuilder: (context, index) {
            return const RefImageDisplay(srcUrl: "https://cdn.pixabay.com/photo/2022/03/30/14/55/holiday-home-7101309_960_720.jpg");
          },
        ),
      )
    );
  }
}
