import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:tagref/ui/tag_label.dart';

class TagDisplay extends StatefulWidget {
  final double height;

  const TagDisplay({Key? key, required this.height}) : super(key: key);

  @override
  State<TagDisplay> createState() => _TagDisplayState();
}

class _TagDisplayState extends State<TagDisplay> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Container(
                height: widget.height,
                decoration: const BoxDecoration(
                    color: Color.fromARGB(87, 255, 255, 255),
                    borderRadius: BorderRadius.all(Radius.circular(4))),
                child: SingleChildScrollView(
                  child: Wrap(
                    children: [
                      TagLabel(onPressed: () {}, tagWd: "lskdjf"),
                      TagLabel(onPressed: () {}, tagWd: "qweyui"),
                      TagLabel(onPressed: () {}, tagWd: "ayuisd"),
                      TagLabel(onPressed: () {}, tagWd: "zyuixc"),
                      TagLabel(onPressed: () {}, tagWd: "iiivbn"),
                      TagLabel(onPressed: () {}, tagWd: "lskdjf"),
                      TagLabel(onPressed: () {}, tagWd: "qweyui"),
                      TagLabel(onPressed: () {}, tagWd: "ayuisd"),
                      TagLabel(onPressed: () {}, tagWd: "zyuixc"),
                      TagLabel(onPressed: () {}, tagWd: "iiivbn"),
                      TagLabel(onPressed: () {}, tagWd: "lskdjf"),
                      TagLabel(onPressed: () {}, tagWd: "qweyui"),
                      TagLabel(onPressed: () {}, tagWd: "ayuisd"),
                      TagLabel(onPressed: () {}, tagWd: "zyuixc"),
                      TagLabel(onPressed: () {}, tagWd: "iiivbn"),
                      TagLabel(onPressed: () {}, tagWd: "lskdjf"),
                      TagLabel(onPressed: () {}, tagWd: "qweyui"),
                      TagLabel(onPressed: () {}, tagWd: "ayuisd"),
                      TagLabel(onPressed: () {}, tagWd: "zyuixc"),
                      TagLabel(onPressed: () {}, tagWd: "iiivbn"),
                      TagLabel(onPressed: () {}, tagWd: "lskdjf"),
                      TagLabel(onPressed: () {}, tagWd: "qweyui"),
                      TagLabel(onPressed: () {}, tagWd: "ayuisd"),
                      TagLabel(onPressed: () {}, tagWd: "zyuixc"),
                      TagLabel(onPressed: () {}, tagWd: "iiivbn"),
                      TagLabel(onPressed: () {}, tagWd: "lskdjf"),
                      TagLabel(onPressed: () {}, tagWd: "qweyui"),
                      TagLabel(onPressed: () {}, tagWd: "ayuisd"),
                      TagLabel(onPressed: () {}, tagWd: "zyuixc"),
                      TagLabel(onPressed: () {}, tagWd: "iiivbn"),
                    ],
                  ),
                )))
      ],
    );
  }
}
