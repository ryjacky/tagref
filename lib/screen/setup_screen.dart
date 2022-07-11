import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tagref/assets/constant.dart';
import 'package:tagref/screen/home_screen.dart';

import '../assets/font_size.dart';
import '../ui/toggle_switch.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({Key? key}) : super(key: key);

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final List<bool> isSelected = [false, false];

  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    // Query for window width
    double width = MediaQuery.of(context).size.width;

    // Set current language to active in the language options toggle button
    for (int i = 0; i < context.supportedLocales.length; i++) {
      isSelected[i] = context.locale.toString() == locale[i];
    }

    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(20),
      child: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(tr("welcome-text"),
                  style: TextStyle(
                      color: primaryColorDark,
                      fontWeight: FontWeight.w500,
                      fontSize: FontSize.l1.sp)),
              Text(tr("tag-ref-description"),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: primaryColorDark,
                      fontWeight: FontWeight.w300,
                      fontSize: FontSize.l3.sp)),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 100, 0, 20),
                child: Text(tr("choose-lang"),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: primaryColorDark,
                        fontWeight: FontWeight.w300,
                        fontSize: FontSize.l3.sp)),
              ),
              ToggleButtons(
                borderRadius: BorderRadius.circular(cornerRadius),
                isSelected: isSelected,
                onPressed: (index) {
                  setState(() {
                    // Implements the exclusive selection feature for
                    // the language options toggle button
                    for (int buttonIndex = 0;
                        buttonIndex < isSelected.length;
                        buttonIndex++) {
                      if (buttonIndex == index) {
                        isSelected[buttonIndex] = true;
                      } else {
                        isSelected[buttonIndex] = false;
                      }
                    }

                    context.setLocale(Locale(locale[index]));
                  });
                },
                children: [
                  Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(cornerRadius),
                            child: SvgPicture.asset(
                              "assets/images/us.svg",
                              height: 60,
                              width: 50,
                            ),
                          ),
                          Text("English",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  height: 2,
                                  color: primaryColorDark,
                                  fontWeight: FontWeight.w300,
                                  fontSize: FontSize.body1.sp)),
                        ],
                      )),
                  Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(cornerRadius),
                            child: SvgPicture.asset(
                              "assets/images/jp.svg",
                              height: 60,
                              width: 50,
                            ),
                          ),
                          Text("日本語",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  height: 2,
                                  color: primaryColorDark,
                                  fontWeight: FontWeight.w300,
                                  fontSize: FontSize.body1.sp)),
                        ],
                      )),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(30),
                child: TextButton(
                  onPressed: () {
                    _pageController.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut);
                  },
                  style: ButtonStyle(
                      padding: MaterialStateProperty.all(
                          const EdgeInsets.fromLTRB(18, 8, 18, 14)),
                      backgroundColor: MaterialStateProperty.all(accentColor)),
                  child: Text(tr("next"),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: primaryColorDark,
                          fontWeight: FontWeight.w300,
                          fontSize: FontSize.l3.sp)),
                ),
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 60.w, 20.w, 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tr("customize-exp"),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: primaryColorDark,
                        fontWeight: FontWeight.w300,
                        fontSize: FontSize.l2.sp)),
                Padding(
                    padding: EdgeInsets.fromLTRB(0, 20.w, 0, 0),
                    child: Row(
                      children: [

                        Expanded(
                          child: SizedBox(
                            width: (width / 1.3).w,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(tr("auto-tag"),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: FontSize.l3.sp,
                                        color: fontColorDark)),
                                Text(tr("auto-tag-desc"),
                                    style: TextStyle(
                                        fontWeight: FontWeight.w300,
                                        fontSize: FontSize.body1.sp,
                                        color: fontColorDark)),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40.w,0,0,0),
                          child: const ToggleSwitch(),
                        )
                      ],
                    )),
                Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: Row(
                      children: [

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tr("cache"),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: FontSize.l3.sp,
                                      color: fontColorDark)),
                              SizedBox(
                                width: width / 1.3,
                                child: Text(tr("cache-desc"),
                                    softWrap: true,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w300,
                                        fontSize: FontSize.body1.sp,
                                        color: fontColorDark)),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40.w,0,0,0),
                          child: const ToggleSwitch(),
                        )
                      ],
                    )),
                Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: Row(
                      children: [

                        Expanded(
                          child: SizedBox(
                            width: width / 1.3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(tr("twitter-link"),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: FontSize.l3.sp,
                                        color: fontColorDark)),
                                Text(tr("twitter-link-desc"),
                                    style: TextStyle(
                                        fontWeight: FontWeight.w300,
                                        fontSize: FontSize.body1.sp,
                                        color: fontColorDark)),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40.w,0,0,0),
                          child: const ToggleSwitch(),
                        )
                      ],
                    )),
                Expanded(
                  child: Container(),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(30),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomeScreen()));
                    },
                    style: ButtonStyle(
                        padding: MaterialStateProperty.all(
                            const EdgeInsets.fromLTRB(18, 8, 18, 14)),
                        backgroundColor:
                            MaterialStateProperty.all(accentColor)),
                    child: Text(tr("done"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: primaryColorDark,
                            fontWeight: FontWeight.w300,
                            fontSize: FontSize.l3.sp)),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    ));
  }
}
