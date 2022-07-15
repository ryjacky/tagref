import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../assets/constant.dart';

const double _cornerRadius = 4;

typedef OnTagDeleted = Function(String tagWd);
typedef OnKeywordRemovedCallBack = Function(String keywordRemoved);
typedef OnSubmitted = Function(String val);
typedef GestureTapCallback = Function(String tagWd);
typedef VoidCallback = Function(String val);
typedef TagListBuilder = List<String> Function();

/// A height limited box widget that displays tags listed in [tagList].
class TagListBox extends StatefulWidget {
  final double height;
  final List<String> tagList;

  final OnTagDeleted onTagDeleted;
  final Color color;

  /// Creates a height limited box widget that displays tags listed in [tagList].
  const TagListBox(
      {Key? key,
      required this.height,
      required this.tagList,
      required this.onTagDeleted,
      this.color = const Color.fromARGB(87, 255, 255, 255)})
      : super(key: key);

  @override
  State<TagListBox> createState() => _TagListBoxState();
}

class _TagListBoxState extends State<TagListBox> {
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
            decoration: BoxDecoration(
                color: widget.color,
                borderRadius:
                    const BorderRadius.all(Radius.circular(_cornerRadius))),
            child: SingleChildScrollView(
              controller: ScrollController(),
              padding: const EdgeInsets.all(4),
              child: Wrap(
                children: tagLabelList,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A stylized [TextField] for tag input in [ReferenceImage], with preset
/// RegEx expression to filter out special characters
class TagInputField extends StatefulWidget {
  final String hintText;
  final OnSubmitted onSubmitted;

  /// Creates a stylized [TextField] for tag input in [ReferenceImage],
  /// with preset RegEx expression to filter out special characters
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
        FilteringTextInputFormatter(
            RegExp("[\"'~!@#\$%^&*()_+{}\\[\\]:;,.<>/?-]"),
            allow: false)
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

/// A label widget displaying [tagWd]
class TagLabel extends StatefulWidget {
  final String tagWd;

  /// Creates a label widget displaying [tagWd]
  const TagLabel({Key? key, required this.onPressed, required this.tagWd})
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
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
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
          ),
        ),
      ),
    );
  }
}

/// A stylized search bar
class SearchBarDesktop extends StatefulWidget {
  final VoidCallback onSubmitted;

  final String hintText;
  final List<String> autoFillHints;

  /// Creates a stylized search bar
  const SearchBarDesktop(
      {Key? key,
      required this.onSubmitted,
      required this.hintText,
      this.autoFillHints = const []})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _SearchBarDesktopState();
}

class _SearchBarDesktopState extends State<SearchBarDesktop> {
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
            autofillHints: widget.autoFillHints,
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

// TODO: Deprecate this widget
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

// class AllTagsView extends StatefulWidget {
//   final OnKeywordRemovedCallBack onTagRemoved;
//
//   const AllTagsView({Key? key, required this.onTagRemoved}) : super(key: key);
//
//   @override
//   State<AllTagsView> createState() => _AllTagsViewState();
// }
//
// class _AllTagsViewState extends State<AllTagsView> {
//   List<TagLabel> currentTagLabels = [];
//
//   @override
//   void initState() {
//     refreshTagList();
//
//     super.initState();
//   }
//
//   Future<void> refreshTagList() async {
//     // Query for database and all tags if not already
//     String queryTag = "SELECT name FROM tags";
//     List<Map<String, Object?>> results = await DBHelper.db.rawQuery(queryTag);
//
//     if (results.length != currentTagLabels.length) {
//       setState(() {
//         currentTagLabels = [];
//         for (Map record in results) {
//           currentTagLabels.add(
//               TagLabel(onPressed: widget.onTagRemoved, tagWd: record["name"]));
//         }
//       });
//     } else {
//       for (int i = 0; i < results.length; i++) {
//         if (currentTagLabels[i].tagWd != results[i]["name"]) {
//           setState(() {
//             currentTagLabels = [];
//             for (Map record in results) {
//               currentTagLabels.add(TagLabel(
//                   onPressed: widget.onTagRemoved, tagWd: record["name"]));
//             }
//           });
//         }
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         height: 230,
//         decoration: const BoxDecoration(
//             color: desktopColorDarker,
//             borderRadius: BorderRadius.all(Radius.circular(4))),
//         width: MediaQuery.of(context).size.width,
//         padding: const EdgeInsets.all(10),
//         child: SingleChildScrollView(
//           controller: ScrollController(),
//           child: Wrap(
//             // Creates List<TagLabel> from List<String> which stores the searched
//             // keywords
//             children: currentTagLabels,
//           ),
//         ));
//   }
// }
