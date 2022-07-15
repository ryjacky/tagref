import 'package:flutter/material.dart';
import 'package:tagref/ui/tag_label.dart';

typedef OnTagDeleted = Function(String tagWd);

class TagDisplay extends StatefulWidget {
  final double height;
  final List<String> tagList;

  final OnTagDeleted onTagDeleted;

  const TagDisplay(
      {Key? key,
      required this.height,
      required this.tagList,
      required this.onTagDeleted})
      : super(key: key);

  @override
  State<TagDisplay> createState() => _TagDisplayState();
}

class _TagDisplayState extends State<TagDisplay> {
  @override
  Widget build(BuildContext context) {
    List<TagLabel> tagLabelList = widget.tagList
        .map((tagWd) => TagLabel(onPressed: widget.onTagDeleted, tagWd: tagWd))
        .toList();

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
                    children: tagLabelList,
                  ),
                )))
      ],
    );
  }
}
