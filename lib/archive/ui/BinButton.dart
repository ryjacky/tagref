// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//
// import '../../assets/constant.dart';
// @Deprecated("This class is replaced by a more generalized class, FaIconButton,"
//     "for improved UI consistency.")
// class BinButton extends StatelessWidget {
//   const BinButton({required this.onPressed});
//   final GestureTapCallback onPressed;
//
//   @override
//   Widget build(BuildContext context) {
//     return RawMaterialButton(
//       onPressed: onPressed,
//       materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//       constraints: BoxConstraints.tight(const Size(42, 42)),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cornerRadius)),
//       elevation: 0,
//       fillColor: Colors.grey.shade200.withOpacity(0.5),
//       splashColor: Colors.grey.shade500.withOpacity(0.5),
//       child: const Padding(
//         padding: EdgeInsets.symmetric(vertical: 11.0, horizontal: 12),
//         child: FaIcon(
//           FontAwesomeIcons.solidTrashCan,
//           color: Colors.white,
//           size: 21,
//         ),
//       ),
//     );
//   }
// }