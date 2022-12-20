import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tagref/assets/constant.dart';

class IntegrationDisplayButton extends StatefulWidget {
  final String driveLogoSrc;
  final String driveName;
  final VoidCallback onTap;
  final bool statusOn;

  const IntegrationDisplayButton(
      {Key? key,
      required this.driveLogoSrc,
      required this.driveName,
      this.statusOn = false,
      required this.onTap})
      : super(key: key);

  @override
  State<IntegrationDisplayButton> createState() =>
      _IntegrationDisplayButtonState();
}

class _IntegrationDisplayButtonState extends State<IntegrationDisplayButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: 150,
            color: desktopColorDark,
            child: Column(
              children: [
                Container(
                  width: 150,
                  color: widget.statusOn ? Colors.green : desktopColorLight,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    child: Text("Status: " + (widget.statusOn ? "ON" : "OFF"),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelMedium),
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
                      style: Theme.of(context).textTheme.labelSmall),
                )
              ],
            ),
          )),
    );
  }
}

class IntegrationDisplayButtonMobile extends StatefulWidget {
  final String driveLogoSrc;
  final String driveName;
  final VoidCallback onTap;
  final bool statusOn;

  const IntegrationDisplayButtonMobile(
      {Key? key,
      required this.driveLogoSrc,
      required this.driveName,
      this.statusOn = false,
      required this.onTap})
      : super(key: key);

  @override
  State<IntegrationDisplayButtonMobile> createState() =>
      _IntegrationDisplayButtonMobileState();
}

class _IntegrationDisplayButtonMobileState
    extends State<IntegrationDisplayButtonMobile> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 120,
            color: desktopColorDark,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(child: Container()),
                      Container(
                        decoration: BoxDecoration(
                            color: widget.statusOn ? Colors.green : desktopColorLight,
                            borderRadius: BorderRadius.circular(100)),
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
                          child: Text((widget.statusOn ? "ON" : "OFF"),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.displaySmall),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: SvgPicture.asset(
                    widget.driveLogoSrc,
                    width: 60,
                    height: 60,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 15, 10, 20),
                  child: Text(widget.driveName,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall),
                )
              ],
            ),
          )),
    );
  }
}
