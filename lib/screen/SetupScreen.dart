import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tagref/assets/constant.dart';
import 'package:tagref/screen/HomeScreen.dart';

import '../assets/FontSize.dart';
import '../ui/ToggleSwitch.dart';

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
    double width = MediaQuery.of(context).size.width;

    for (int i = 0; i < context.supportedLocales.length; i++) {
      isSelected[i] = context.locale.toString() == locale[i];
    }

    return Scaffold(
        body: Padding(
      padding: EdgeInsets.all(20),
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
                      fontSize: FontSize.l1)),
              Text(tr("tag-ref-description"),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: primaryColorDark,
                      fontWeight: FontWeight.w300,
                      fontSize: FontSize.l3)),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 100, 0, 20),
                child: Text(tr("choose-lang"),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: primaryColorDark,
                        fontWeight: FontWeight.w300,
                        fontSize: FontSize.l3)),
              ),
              ToggleButtons(
                borderRadius: BorderRadius.circular(cornerRadius),
                isSelected: isSelected,
                onPressed: (index) {
                  setState(() {
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
                                  fontSize: FontSize.body1)),
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
                                  fontSize: FontSize.body1)),
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
                          fontSize: FontSize.l3)),
                ),
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tr("customize-exp"),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: primaryColorDark,
                        fontWeight: FontWeight.w300,
                        fontSize: FontSize.l2)),
                Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: width / 1.3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tr("auto-tag"),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: FontSize.l3,
                                      color: fontColorDark)),
                              Text(tr("auto-tag-desc"),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: FontSize.body1,
                                      color: fontColorDark)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Container(),
                        ),
                        const Center(
                          child: ToggleSwitch(),
                        )
                      ],
                    )),
                Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tr("cache"),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: FontSize.l3,
                                    color: fontColorDark)),
                            SizedBox(
                              width: width / 1.3,
                              child: Text(tr("cache-desc"),
                                  softWrap: true,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: FontSize.body1,
                                      color: fontColorDark)),
                            )
                          ],
                        ),
                        Expanded(
                          child: Container(),
                        ),
                        const Center(
                          child: ToggleSwitch(),
                        )
                      ],
                    )),
                Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: width / 1.3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tr("twitter-link"),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: FontSize.l3,
                                      color: fontColorDark)),
                              Text(tr("twitter-link-desc"),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: FontSize.body1,
                                      color: fontColorDark)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Container(),
                        ),
                        const Center(
                          child: ToggleSwitch(),
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
                            fontSize: FontSize.l3)),
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
