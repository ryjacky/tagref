import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../assets/constant.dart';
class TagLabel extends StatefulWidget {
  final String tagWd;

  const TagLabel({Key? key, required this.onPressed, required this.tagWd})
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
          onTap: (){},
          onHover: (val){
            setState((){
              onHover = val;
            });
          },
          child: RawMaterialButton(
            onPressed: widget.onPressed,
            fillColor: primaryColorDark,
            constraints: const BoxConstraints.tightFor(height: 33),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(cornerRadius)),
            elevation: 0.1,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(
                  width: 8,
                ),
                Text(
                  widget.tagWd,
                  style: TextStyle(
                      decoration: onHover ? TextDecoration.lineThrough : TextDecoration.none,
                      color: Colors.white, fontWeight: FontWeight.w500),
                ),
                const SizedBox(
                  width: 8,
                ),
              ],
            ),
          ),
        )
    );
  }
}