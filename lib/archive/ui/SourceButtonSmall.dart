// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//
// import '../../assets/constant.dart';
// @Deprecated("This class is replaced by a more generalized class, FaIconButton,"
//     "for improved UI consistency.")
// class SourceButtonSmall extends StatelessWidget {
//   const SourceButtonSmall({required this.onPressed});
//   final GestureTapCallback onPressed;
//
//   @override
//   Widget build(BuildContext context) {
//     return RawMaterialButton(
//       onPressed: onPressed,
//       materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//       constraints: BoxConstraints.tight(const Size(buttonWidth, buttonHeight)),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cornerRadius)),
//       elevation: 0,
//       fillColor: Colors.grey.shade200.withOpacity(0.5),
//       splashColor: Colors.grey.shade500.withOpacity(0.5),
//       child: const Padding(
//         padding: EdgeInsets.all(8),
//         child: FaIcon(
//           FontAwesomeIcons.link,
//           color: Colors.white,
//           size: 21,
//         ),
//       ),
//     );
//   }
// }
