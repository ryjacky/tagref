import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../assets/constant.dart';

double _cornerRadius = 4;

typedef PinButtonOnClicked = Function(bool unPinned);

class AddButton extends StatelessWidget {
  final String imgUrl;

  const AddButton({Key? key, required this.onPressed, required this.imgUrl})
      : super(key: key);
  final GestureTapCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(_cornerRadius),
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 350,
              child: ImageFiltered(
                // Stronger blur (than ReferenceImageDisplay) for differentiation
                // (visually)
                imageFilter: ImageFilter.blur(
                    sigmaX: 10, sigmaY: 10, tileMode: TileMode.decal),
                child: Image.network(
                  imgUrl,
                  fit: BoxFit.cover,
                  color: Colors.grey.shade800,
                  colorBlendMode: BlendMode.screen,
                ),
              ),
            ),
            FaIconButton(onPressed: () {
              onPressed();
            }, faIcon: FontAwesomeIcons.plus, size: const Size(65, 65),)
          ],
        ));
  }
}

class EditTagButton extends StatelessWidget {
  final String btnText;

  final double buttonWidth = 42;
  final double buttonHeight = 42;

  const EditTagButton(
      {Key? key, required this.onPressed, this.btnText = "Edit Tag"})
      : super(key: key);
  final GestureTapCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: onPressed,
      constraints:
      BoxConstraints.tight(Size(buttonWidth * 3, buttonHeight)),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cornerRadius)),
      elevation: 0.1,
      fillColor: Colors.grey.shade200.withOpacity(0.5),
      splashColor: Colors.grey.shade500.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(width: 6),
            const FaIcon(
              FontAwesomeIcons.pencil,
              color: Colors.white,
              size: 18,
            ),
            const Spacer(),
            Text(
              btnText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class FaIconButton extends StatelessWidget {
  final IconData faIcon;
  final Size size;

  const FaIconButton(
      {Key? key,
        required this.onPressed,
        required this.faIcon,
        this.size = const Size(42, 42)})
      : super(key: key);
  final GestureTapCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
        onPressed: onPressed,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        constraints: BoxConstraints.tight(size),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_cornerRadius)),
        elevation: 0,
        fillColor: Colors.grey.shade200.withOpacity(0.5),
        splashColor: Colors.grey.shade500.withOpacity(0.5),
        child: Padding(
          padding: const EdgeInsets.only(left: 1,),
          child: Center(
            child: FaIcon(
              faIcon,
              color: Colors.white,
              size: min(size.width/2, size.height/2),
            ),
          ),
        )
    );
  }
}

class PinButton extends StatefulWidget {
  const PinButton({Key? key, required this.onPressed}) : super(key: key);
  final PinButtonOnClicked onPressed;

  @override
  _PinButtonState createState() => _PinButtonState();
}

class _PinButtonState extends State<PinButton> {
  bool _unPinned = true;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cornerRadius)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      elevation: 0,
      constraints: BoxConstraints.tight(const Size(42, 42)),
      fillColor: Colors.grey.shade300.withOpacity(0.5),
      splashColor: Colors.grey.shade500.withOpacity(0.5),
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11.0, horizontal: 12),
          child: _unPinned
              ? const RotationTransition(
            turns: AlwaysStoppedAnimation(30 / 360),
            child: FaIcon(
              FontAwesomeIcons.thumbtack,
              color: Colors.white,
              size: 21,
            ),
          )
              : const FaIcon(
            FontAwesomeIcons.thumbtack,
            color: Colors.white,
            size: 21,
          )),
      onPressed: () {
        setState(() {
          // Flips the pin state when clicked
          _unPinned = !_unPinned;

          // Triggers callback and pass the pin state
          widget.onPressed(_unPinned);
        });
      },
    );
  }
}

class IntegrationStatusButton extends StatefulWidget {
  final String driveLogoSrc;
  final String driveName;
  final VoidCallback onTap;
  final bool statusOn;

  const IntegrationStatusButton(
      {Key? key,
        required this.driveLogoSrc,
        required this.driveName,
        this.statusOn = false,
        required this.onTap})
      : super(key: key);

  @override
  State<IntegrationStatusButton> createState() => _IntegrationStatusButtonState();
}

class _IntegrationStatusButtonState extends State<IntegrationStatusButton> {

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: ClipRRect(
          borderRadius: BorderRadius.circular(_cornerRadius),
          child: Container(
            width: 150,
            color: desktopColorDark,
            child: Column(
              children: [
                Container(
                  width: 150,
                  color: desktopColorLight,
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
