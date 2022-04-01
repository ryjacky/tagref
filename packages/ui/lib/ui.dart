library ui;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Add-Button.
class AddBtn extends StatelessWidget {
  const AddBtn({required this.onPressed});
  final GestureTapCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: onPressed,
      fillColor: Colors.grey.shade200.withOpacity(0.5),
      splashColor: Colors.grey.shade500.withOpacity(0.5),
      elevation: 0.1,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      child: const Padding(
          padding: EdgeInsets.all(30.0),
          child: FaIcon(
            FontAwesomeIcons.plus,
            color: Colors.white,
          )),
    );
  }
}

///Pin-Button pinned.
class PinBtnPinned extends StatelessWidget {
  const PinBtnPinned({required this.onPressed});
  final GestureTapCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: onPressed,
      constraints: BoxConstraints.tight(const Size(42, 42)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 0.1,
      fillColor: Colors.grey.shade200.withOpacity(0.5),
      splashColor: Colors.grey.shade500.withOpacity(0.5),
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 11.0, horizontal: 13),
        child: FaIcon(
          FontAwesomeIcons.thumbtack,
          color: Colors.white,
          size: 21,
        ),
      ),
    );
  }
}

///Pin-Button unpinned.
class PinBtnUnpinned extends StatelessWidget {
  const PinBtnUnpinned({required this.onPressed});
  final GestureTapCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: onPressed,
      constraints: BoxConstraints.tight(const Size(42, 42)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 0.1,
      fillColor: Colors.grey.shade200.withOpacity(0.5),
      splashColor: Colors.grey.shade500.withOpacity(0.5),
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 13.5),
        child: RotationTransition(
          turns: AlwaysStoppedAnimation(30 / 360),
          child: FaIcon(
            FontAwesomeIcons.thumbtack,
            color: Colors.white,
            size: 21,
          ),
        ),
      ),
    );
  }
}

///Remove-Bin-Button.
class RemoveBin extends StatelessWidget {
  const RemoveBin({required this.onPressed});
  final GestureTapCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: onPressed,
      constraints: BoxConstraints.tight(const Size(42, 42)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 0.1,
      fillColor: Colors.grey.shade200.withOpacity(0.5),
      splashColor: Colors.grey.shade500.withOpacity(0.5),
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 11.0, horizontal: 12),
        child: FaIcon(
          FontAwesomeIcons.solidTrashCan,
          color: Colors.white,
          size: 21,
        ),
      ),
    );
  }
}

///Sort-Button.
class SortBtn extends StatelessWidget {
  const SortBtn({required this.onPressed});
  final GestureTapCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: onPressed,
      constraints: BoxConstraints.tight(const Size(36, 36)),
      elevation: 0.1,
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: FaIcon(
          FontAwesomeIcons.arrowDownShortWide,
          color: Colors.purple,
          size: 18,
        ),
      ),
    );
  }
}

///Source-Button Small.
class SourceBtnSmall extends StatelessWidget {
  const SourceBtnSmall({required this.onPressed});
  final GestureTapCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: onPressed,
      constraints: BoxConstraints.tight(const Size(42, 42)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 0.1,
      fillColor: Colors.grey.shade200.withOpacity(0.5),
      splashColor: Colors.grey.shade500.withOpacity(0.5),
      child: const Padding(
        padding: EdgeInsets.all(8),
        child: FaIcon(
          FontAwesomeIcons.link,
          color: Colors.white,
          size: 21,
        ),
      ),
    );
  }
}

///Source-Button.
class SourceBtn extends StatelessWidget {
  const SourceBtn({required this.onPressed});
  final GestureTapCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: onPressed,
      constraints: BoxConstraints.tight(const Size(100, 33)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 0.1,
      fillColor: Colors.grey.shade200.withOpacity(0.5),
      splashColor: Colors.grey.shade500.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const <Widget>[
            SizedBox(
              width: 6,
            ),
            FaIcon(
              FontAwesomeIcons.link,
              color: Colors.white,
              size: 18,
            ),
            Spacer(),
            Text(
              "Source",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}

///Edit-Tag-Button.
class EditTagBtn extends StatelessWidget {
  const EditTagBtn({required this.onPressed});
  final GestureTapCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: onPressed,
      constraints: BoxConstraints.tight(const Size(100, 33)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 0.1,
      fillColor: Colors.grey.shade200.withOpacity(0.5),
      splashColor: Colors.grey.shade500.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const <Widget>[
            SizedBox(width: 6),
            FaIcon(
              FontAwesomeIcons.pencil,
              color: Colors.white,
              size: 18,
            ),
            Spacer(),
            Text(
              "Edit tags",
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}

///Tag Chip.
class Tag extends StatelessWidget {
  String tagWd = "";
  Tag({Key? key, required this.onPressed, required this.tagWd})
      : super(key: key);
  final GestureTapCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: onPressed,
      fillColor: Colors.purple,
      constraints: BoxConstraints.tight(Size(84, 33)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 0.1,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      child: Row(
        children: <Widget>[
          const Spacer(),
          Text(
            tagWd,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          const FaIcon(
            FontAwesomeIcons.xmark,
            color: Colors.white,
            size: 15,
          ),
          const SizedBox(
            width: 8,
          )
        ],
      ),
    );
  }
}

///Add-Tag-Field.
class AddTagField extends StatelessWidget {
  const AddTagField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
          fillColor: Colors.grey.shade400.withOpacity(0.5),
          filled: true,
          hintText: "Type to add a new tag",
          hintStyle: const TextStyle(color: Colors.white),
          contentPadding: const EdgeInsets.all(12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          constraints: const BoxConstraints(maxHeight: 42)),
      style: const TextStyle(color: Colors.white),
    );
  }
}
