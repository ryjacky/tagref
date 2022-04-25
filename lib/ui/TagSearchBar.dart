import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tagref/assets/constant.dart';
import 'package:tagref/ui/TagLabel.dart';

class TagSearchBar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TagSearchBarState();

}

class _TagSearchBarState extends State<TagSearchBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: accentColor,
        border: Border.all(color: accentColor),
        borderRadius: const BorderRadius.all(Radius.circular(cornerRadius))
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              TagLabel(onPressed: () => {}, tagWd: "asdfghjklqwertyuiopz"),
              const Flexible(
                child: TextField(
                  style: TextStyle(color: primaryColorDark),
                  cursorColor: primaryColorDark,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                    border: InputBorder.none,
                    hintText: "Type to search...",
                    hintStyle: TextStyle(color: primaryColor),
                  ),
                ),
              )
            ],
          ),
        )
      ),
    );
  }

}