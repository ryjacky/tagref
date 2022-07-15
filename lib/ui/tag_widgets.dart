import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../assets/constant.dart';
import '../assets/db_helper.dart';

double _cornerRadius = 4;

typedef OnTagDeleted = Function(String tagWd);

class TagDisplay extends StatefulWidget {
  final double height;
  final List<String> tagList;

  final OnTagDeleted onTagDeleted;

  const TagDisplay(
      {Key? key,
      required this.height,
      required this.tagList,
      required this.onTagDeleted})
      : super(key: key);

  @override
  State<TagDisplay> createState() => _TagDisplayState();
}

class _TagDisplayState extends State<TagDisplay> {
  @override
  Widget build(BuildContext context) {
    List<TagLabel> tagLabelList = widget.tagList
        .map((tagWd) => TagLabel(onPressed: widget.onTagDeleted, tagWd: tagWd))
        .toList();

    return Row(
      children: [
        Expanded(
            child: Container(
                height: widget.height,
                decoration: const BoxDecoration(
                    color: Color.fromARGB(87, 255, 255, 255),
                    borderRadius: BorderRadius.all(Radius.circular(4))),
                child: SingleChildScrollView(
                  child: Wrap(
                    children: tagLabelList,
                  ),
                )))
      ],
    );
  }
}

typedef OnSubmitted = Function(String val);

class TagInputField extends StatefulWidget {
  final String hintText;
  final OnSubmitted onSubmitted;
  const TagInputField(
      {Key? key, required this.hintText, required this.onSubmitted})
      : super(key: key);

  @override
  State<TagInputField> createState() => _TagInputFieldState();
}

class _TagInputFieldState extends State<TagInputField> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TextField(
      onSubmitted: (val) {
        widget.onSubmitted(val);
        _controller.clear();
      },
      controller: _controller,
      inputFormatters: [
        FilteringTextInputFormatter(RegExp("[\"'~!@#\$%^&*()_+{}\\[\\]:;,.<>/?-]"), allow: false)
      ],
      decoration: InputDecoration(
          fillColor: Colors.grey.shade400.withOpacity(0.5),
          filled: true,
          hintText: widget.hintText,
          hintStyle: Theme.of(context).textTheme.bodySmall,
          contentPadding: const EdgeInsets.all(12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_cornerRadius),
            borderSide: BorderSide.none,
          ),
          constraints: const BoxConstraints(maxHeight: 42)),
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}

typedef GestureTapCallback = Function(String tagWd);

class TagLabel extends StatefulWidget {
  final String tagWd;

  const TagLabel(
      {Key? key,
        required this.onPressed,
        required this.tagWd})
      : super(key: key);
  final GestureTapCallback onPressed;

  @override
  State<TagLabel> createState() => _TagLabelState();
}

class _TagLabelState extends State<TagLabel> {
  bool onHover = false;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: InkWell(
          onTap: () {},
          onHover: (val) {
            setState(() {
              onHover = val;
            });
          },
          child: RawMaterialButton(
              onPressed: () => widget.onPressed(widget.tagWd),
              //TODO : CHANGE TO USE THE CONTEXT ONE
              fillColor: desktopColorLight,
              constraints: const BoxConstraints.tightFor(height: 28),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_cornerRadius)),
              elevation: 0.1,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                child: Text(
                  widget.tagWd,
                  style: TextStyle(
                      fontSize: 16,
                      decoration: onHover
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: Colors.white,
                      fontWeight: FontWeight.w500),
                ),
              )),
        ));
  }
}

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
            textAlignVertical: TextAlignVertical.top,
            controller: controller,
            onSubmitted: (val) {
              widget.onSubmitted(val);
              setState(() {
                controller.clear();
              });
            },
            textInputAction: TextInputAction.unspecified,
            style: Theme.of(context).textTheme.bodySmall,
            cursorColor: primaryColorDark,
            decoration: InputDecoration(
              isDense: true,
              icon: const FaIcon(
                FontAwesomeIcons.magnifyingGlass,
                color: Colors.white,
              ),
              border: InputBorder.none,
              hintText: widget.hintText,
              hintStyle: Theme.of(context).textTheme.bodySmall,
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
  final List<String> tagList;

  final OnKeywordRemovedCallBack onKeywordRemoved;

  const TagSearchBarKeywordsViewDesktop(
      {Key? key, required this.tagList, required this.onKeywordRemoved})
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

    for (int i = 0; i < widget.tagList.length; i++) {
      late TagLabel iLabel;
      iLabel = TagLabel(
          onPressed: (tagId) => setState(() {
            widget.onKeywordRemoved(widget.tagList[i]);
          }),
          tagWd: widget.tagList[i]);
      tagLabels.add(iLabel);
    }

    return Container(
        height: 130,
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

class AllTagsView extends StatefulWidget {

  final OnKeywordRemovedCallBack onTagRemoved;

  const AllTagsView(
      {Key? key, required this.onTagRemoved})
      : super(key: key);



  @override
  State<AllTagsView> createState() => _AllTagsViewState();
}

class _AllTagsViewState extends State<AllTagsView> {
  List<TagLabel> currentTagLabels = [];

  @override
  void initState() {
    refreshTagList();

    super.initState();
  }

  Future<void> refreshTagList() async {
    // Query for database and all tags if not already
    String queryTag = "SELECT name FROM tags";
    List<Map<String, Object?>> results = await DBHelper.db.rawQuery(queryTag);

    if (results.length != currentTagLabels.length){
      setState((){
        currentTagLabels = [];
        for (Map record in results){
          currentTagLabels.add(TagLabel(onPressed: widget.onTagRemoved, tagWd: record["name"]));
        }
      });

    } else {
      for (int i = 0; i < results.length; i++){
        if (currentTagLabels[i].tagWd != results[i]["name"]){
          setState((){
            currentTagLabels = [];
            for (Map record in results){
              currentTagLabels.add(TagLabel(onPressed: widget.onTagRemoved, tagWd: record["name"]));
            }
          });

        }
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 230,
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
            children: currentTagLabels,
          ),
        ));
  }
}

