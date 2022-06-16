import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../assets/constant.dart';

class DriveStatusDisplay extends StatefulWidget {
  final String driveLogoSrc;
  final String driveName;

  final VoidCallback onTap;

  const DriveStatusDisplay(
      {Key? key,
      required this.driveLogoSrc,
      required this.driveName,
      required this.onTap})
      : super(key: key);

  @override
  State<DriveStatusDisplay> createState() => _DriveStatusDisplayState();
}

class _DriveStatusDisplayState extends State<DriveStatusDisplay> {
  bool statusOn = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: ClipRRect(
          borderRadius: BorderRadius.circular(cornerRadius),
          child: Container(
            width: 150,
            color: accentColor,
            child: Column(
              children: [
                Container(
                  width: 150,
                  color: primaryColor,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    child: Text("Status: " + (statusOn ? "ON" : "OFF"),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            backgroundColor: primaryColor,
                            fontWeight: FontWeight.w300,
                            fontSize: 18,
                            color: fontColorDark)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: SvgPicture.asset(
                    widget.driveLogoSrc,
                    width: 70,
                    height: 70,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 15, 10, 20),
                  child: Text(widget.driveName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: fontColorDark)),
                )
              ],
            ),
          )),
    );
  }
}
