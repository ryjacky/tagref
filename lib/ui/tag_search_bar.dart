import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tagref/assets/constant.dart';
import 'package:tagref/ui/tag_label.dart';

typedef VoidCallback = Function(String val);

class TagSearchBarDesktop extends StatefulWidget {
  final VoidCallback onSubmitted;

  final String hintText;

  const TagSearchBarDesktop(
      {Key? key, required this.onSubmitted, required this.hintText})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _TagSearchBarDesktopState();
}

class _TagSearchBarDesktopState extends State<TagSearchBarDesktop> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width / 2,
        decoration: BoxDecoration(
            color: desktopColorLight,
            border: Border.all(color: desktopColorLight),
            borderRadius:
                const BorderRadius.all(Radius.circular(cornerRadius))),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
          child: TextField(
            controller: controller,
            onSubmitted: (val) {
              widget.onSubmitted(val);
              setState(() {
                controller.clear();
              });
            },
            textInputAction: TextInputAction.unspecified,
            style: const TextStyle(color: Colors.white),
            cursorColor: primaryColorDark,
            decoration: InputDecoration(
              isDense: true,
              icon: const FaIcon(FontAwesomeIcons.magnifyingGlass, color: Colors.white,),
              border: InputBorder.none,
              hintText: widget.hintText,
              hintStyle: const TextStyle(color: Colors.white),
            ),
          ),
        ));
  }
}

class TagSearchBar extends StatefulWidget {
  final VoidCallback onSubmitted;

  final String hintText;

  const TagSearchBar(
      {Key? key, required this.onSubmitted, required this.hintText})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _TagSearchBarState();
}

class _TagSearchBarState extends State<TagSearchBar> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width / 2,
        decoration: BoxDecoration(
            color: accentColor,
            border: Border.all(color: accentColor),
            borderRadius:
                const BorderRadius.all(Radius.circular(cornerRadius))),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
          child: TextField(
            controller: controller,
            onSubmitted: (val) {
              widget.onSubmitted(val);
              setState(() {
                controller.clear();
              });
            },
            textInputAction: TextInputAction.unspecified,
            style: const TextStyle(color: primaryColorDark),
            cursorColor: primaryColorDark,
            decoration: InputDecoration(
              isDense: true,
              icon: const FaIcon(FontAwesomeIcons.magnifyingGlass),
              border: InputBorder.none,
              hintText: widget.hintText,
              hintStyle: const TextStyle(color: primaryColor),
            ),
          ),
        ));
  }
}

typedef OnKeywordRemovedCallBack = Function(String keywordRemoved);

class TagSearchBarKeywordsView extends StatefulWidget {
  final List<String> keywordList;

  final OnKeywordRemovedCallBack onKeywordRemoved;

  const TagSearchBarKeywordsView(
      {Key? key, required this.keywordList, required this.onKeywordRemoved})
      : super(key: key);

  @override
  State<TagSearchBarKeywordsView> createState() =>
      _TagSearchBarKeywordsViewState();
}

class _TagSearchBarKeywordsViewState extends State<TagSearchBarKeywordsView> {
  @override
  Widget build(BuildContext context) {
    List<TagLabel> tagLabels = [];

    for (int i = 0; i < widget.keywordList.length; i++) {
      late TagLabel iLabel;
      iLabel = TagLabel(
          onPressed: (tagId) => setState(() {
                widget.onKeywordRemoved(widget.keywordList[i]);
              }),
          tagWd: widget.keywordList[i]);
      tagLabels.add(iLabel);
    }

    return Container(
        color: accentColor,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all((widget.keywordList.isEmpty) ? 0 : 10),
        child: Wrap(
          // Creates List<TagLabel> from List<String> which stores the searched
          // keywords
          children: tagLabels,
        ));
  }
}

class TagSearchBarKeywordsViewDesktop extends StatefulWidget {
  final List<String> keywordList;

  final OnKeywordRemovedCallBack onKeywordRemoved;

  const TagSearchBarKeywordsViewDesktop(
      {Key? key, required this.keywordList, required this.onKeywordRemoved})
      : super(key: key);

  @override
  State<TagSearchBarKeywordsViewDesktop> createState() =>
      _TagSearchBarKeywordsViewDesktopState();
}

class _TagSearchBarKeywordsViewDesktopState
    extends State<TagSearchBarKeywordsViewDesktop> {
  @override
  Widget build(BuildContext context) {
    List<TagLabel> tagLabels = [];

    for (int i = 0; i < widget.keywordList.length; i++) {
      late TagLabel iLabel;
      iLabel = TagLabel(
          onPressed: (tagId) => setState(() {
                widget.onKeywordRemoved(widget.keywordList[i]);
              }),
          tagWd: widget.keywordList[i]);
      tagLabels.add(iLabel);
    }

    return Container(
      height: 200,
        decoration: const BoxDecoration(
            color: desktopColorDarker,
            borderRadius: BorderRadius.all(Radius.circular(4))),
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          controller: ScrollController(),
          child: Wrap(
            // Creates List<TagLabel> from List<String> which stores the searched
            // keywords
            children: tagLabels,
          ),
        ));
  }
}
