import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tagref/assets/constant.dart';
import 'package:tagref/ui/TagLabel.dart';

typedef VoidCallback = Function(String val);

class TagSearchBar extends StatefulWidget {

  final VoidCallback onSubmitted;
  const TagSearchBar({Key? key, required this.onSubmitted}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TagSearchBarState();
}

class _TagSearchBarState extends State<TagSearchBar> {
  final controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width/2,
      decoration: BoxDecoration(
          color: accentColor,
          border: Border.all(color: accentColor),
          borderRadius: const BorderRadius.all(Radius.circular(cornerRadius))),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
        child: TextField(
          controller: controller,
          onSubmitted: (val){
            widget.onSubmitted(val);
            setState(() {
              controller.clear();
            });
          },
          textInputAction: TextInputAction.none,
          style: const TextStyle(color: primaryColorDark),
          cursorColor: primaryColorDark,
          decoration: const InputDecoration(
            isDense: true,
            icon: FaIcon(FontAwesomeIcons.magnifyingGlass),
            border: InputBorder.none,
            hintText: "Type to search...",
            hintStyle: TextStyle(color: primaryColor),
          ),
        ),
      )
    );
  }
}

class TagSearchBarKeywordsView extends StatefulWidget {
  final List<String> keywordList;

  const TagSearchBarKeywordsView({Key? key, required this.keywordList}) : super(key: key);

  @override
  State<TagSearchBarKeywordsView> createState() => _TagSearchBarKeywordsViewState();
}

class _TagSearchBarKeywordsViewState extends State<TagSearchBarKeywordsView> {

  @override
  Widget build(BuildContext context) {
    return Container(
      color: accentColor,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all((widget.keywordList.isEmpty) ? 0 : 10),
      child: Wrap(
          children: widget.keywordList.map((e) => TagLabel(onPressed: (){}, tagWd: e)).toList()
      ),
    );
  }
}

