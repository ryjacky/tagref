// import 'dart:io';
//
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:tagref/helpers/google_api_helper.dart';
// import 'package:tagref/helpers/twitter_api_helper.dart';
// import 'package:tagref/main.dart';
//
// import '../../assets/db_helper.dart';
// import '../../assets/constant.dart';
// import '../../ui/tag_search_bar.dart';
// import '../../screen/setting_screen.dart';
// import '../../screen/masonry_fragments.dart';
// import '../../screen/twitter_masonry_fragment.dart';
//
// class HomeScreen extends StatefulWidget {
//   final GoogleApiHelper gApiHelper;
//   const HomeScreen({Key? key, required this.gApiHelper}) : super(key: key);
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   final List<String> tagFilterList = [];
//
//   /// Upload FAB is dynamically updated with this variable
//   bool syncing = false;
//   bool syncingFailed = false;
//
//   bool twitterModeOn = false;
//
//   late final TwitterMasonryFragment tmf;
//   late final TwitterApiHelper _twitterApiHelper;
//
//   GlobalKey<TagRefMasonryFragmentState> trmfKey = GlobalKey();
//   late final TagRefMasonryFragment trmf;
//
//   final secureStorage = const FlutterSecureStorage();
//
//   @override
//   void initState() {
//     // secureStorage.deleteAll();
//     _twitterApiHelper =
//         TwitterApiHelper(context: context, secureStorage: secureStorage);
//     trmf = TagRefMasonryFragment(
//       key: trmfKey,
//     );
//     tmf = TwitterMasonryFragment(
//       twitterHelper: _twitterApiHelper,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // Calculates the padding from the application window width
//     // double paddingH = MediaQuery.of(context).size.width / 10;
//
//     return Scaffold(
//         floatingActionButton: Visibility(
//           visible: !twitterModeOn,
//           child: FloatingActionButton.extended(
//             backgroundColor: syncingFailed
//                 ? Colors.red
//                 : syncing
//                     ? Colors.orangeAccent
//                     : primaryColorDark,
//             onPressed: () async {
//               widget.gApiHelper.pushDB()
//                   .then((success) => {
//                         if (success)
//                           {
//                             setState(() {
//                               syncing = false;
//                             })
//                           }
//                         else
//                           {
//                             setState(() {
//                               syncing = false;
//                               syncingFailed = true;
//                               Future.delayed(const Duration(seconds: 3))
//                                   .then((value) => syncingFailed = false);
//                             })
//                           }
//                       });
//               setState(() {
//                 syncing = true;
//               });
//             },
//             label: Text(tr("sync")),
//             icon: const FaIcon(FontAwesomeIcons.arrowsRotate),
//           ),
//         ),
//         appBar: AppBar(
//           elevation: 0,
//           backgroundColor: primaryColor,
//           title: Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Image.asset(
//                 "assets/images/logo.png",
//                 width: 30,
//                 height: 30,
//                 alignment: Alignment.centerLeft,
//               ),
//               Expanded(child: Container()),
//               TagSearchBar(
//                   hintText: tr("search-hint"),
//                   onSubmitted: (val) {
//                     setState(() {
//                       if (val.isNotEmpty && !tagFilterList.contains(val)) {
//                         tagFilterList.add(val);
//                       }
//
//                       trmfKey.currentState?.setFilterTags(tagFilterList);
//                     });
//                   }),
//               IconButton(
//                 icon: const FaIcon(
//                   FontAwesomeIcons.twitter,
//                   color: Colors.white,
//                 ),
//                 iconSize: 28,
//                 padding: const EdgeInsets.all(20),
//                 splashRadius: 1,
//                 onPressed: () async {
//                   if (twitterModeOn == false) {
//                     if (!_twitterApiHelper.authorized) {
//                       await _twitterApiHelper.authTwitter();
//                     }
//                   }
//
//                   setState(() {
//                     twitterModeOn = !twitterModeOn;
//                   });
//                 },
//               ),
//               Expanded(child: Container()),
//               IconButton(
//                 icon: const FaIcon(FontAwesomeIcons.bars),
//                 alignment: Alignment.centerRight,
//                 iconSize: 28,
//                 onPressed: () {
//                   Navigator.push(
//                       context,
//                       PageRouteBuilder(
//                           transitionsBuilder:
//                               (context, animation, secondaryAnimation, child) {
//                             const begin = Offset(0, -1.0);
//                             const end = Offset.zero;
//                             const curve = Curves.ease;
//
//                             final tween = Tween(begin: begin, end: end);
//                             final curvedAnimation = CurvedAnimation(
//                               parent: animation,
//                               curve: curve,
//                             );
//
//                             return SlideTransition(
//                               position: tween.animate(curvedAnimation),
//                               child: child,
//                             );
//                           },
//                           pageBuilder: (context, a1, a2) =>
//                               SettingScreen(gApiHelper: widget.gApiHelper,))).then((remoteChanged) =>
//                       trmfKey.currentState?.refreshImageList());
//                 },
//               ),
//             ],
//           ),
//         ),
//         body: Column(
//           children: [
//             TagSearchBarKeywordsView(
//                 keywordList: tagFilterList,
//                 onKeywordRemoved: (keywordRemoved) {
//                   tagFilterList.remove(keywordRemoved);
//                   trmfKey.currentState?.setFilterTags(tagFilterList);
//                 }),
//             twitterModeOn ? tmf : trmf,
//           ],
//         ));
//   }
// }
