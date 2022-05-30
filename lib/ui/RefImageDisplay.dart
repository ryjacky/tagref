import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../assets/constant.dart';

class RefImageDisplay extends StatefulWidget {
  const RefImageDisplay({Key? key}) : super(key: key);

  @override
  State<RefImageDisplay> createState() => _RefImageDisplayState();
}

class _RefImageDisplayState extends State<RefImageDisplay> {
  bool blurVisible = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(cornerRadius),
        child: Stack(
          children: [
            ImageFiltered(
              imageFilter: ImageFilter.blur(
                  sigmaX: blurVisible ? 5 : 0,
                  sigmaY: blurVisible ? 5 : 0),
              child: Image.network(
                  "https://cdn.pixabay.com/photo/2021/10/24/18/16/stream-6738889_960_720.jpg")
            )
          ],
        ),
      ),
      onTap: () {},
      onHover: (val) {
        setState(() {
          blurVisible = val;
        });
      },
    );
  }
}
