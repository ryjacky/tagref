import 'package:flutter/material.dart';
import '../assets/constant.dart';

typedef GestureTapCallback = Function(String tagWd);

class TagLabel extends StatefulWidget {
  final String tagWd;

  const TagLabel(
      {Key? key,
      required this.onPressed,
      required this.tagWd})
      : super(key: key);
  final GestureTapCallback onPressed;

  @override
  State<TagLabel> createState() => _TagLabelState();
}

class _TagLabelState extends State<TagLabel> {
  bool onHover = false;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: InkWell(
          onTap: () {},
          onHover: (val) {
            setState(() {
              onHover = val;
            });
          },
          child: RawMaterialButton(
              onPressed: () => widget.onPressed(widget.tagWd),
              fillColor: desktopColorLight,
              constraints: const BoxConstraints.tightFor(height: 28),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(cornerRadius)),
              elevation: 0.1,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                child: Text(
                  widget.tagWd,
                  style: TextStyle(
                    fontSize: 16,
                      decoration: onHover
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: Colors.white,
                      fontWeight: FontWeight.w500),
                ),
              )),
        ));
  }
}

