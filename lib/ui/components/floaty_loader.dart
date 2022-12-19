import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/cloudbuild/v1.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
class FloatyLoader extends StatefulWidget {
  final Function() onCancel;
  final BuildContext context;

  const FloatyLoader({Key? key, required this.onCancel, required this.context}) : super(key: key);

  @override
  State<FloatyLoader> createState() => _FloatyLoaderState();

  void startsLoadingForResult() {
    Navigator.push(
        context,
        PageRouteBuilder(
            opaque: false,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = 0.0;
              const end = 1.0;
              const curve = Curves.ease;

              final tween = Tween(begin: begin, end: end);
              final curvedAnimation = CurvedAnimation(
                parent: animation,
                curve: curve,
              );

              return FadeTransition(
                opacity: tween.animate(curvedAnimation),
                child: child,
              );
            },
            pageBuilder: (context, a1, a2) => this));
  }

  void closeLoader(){
    Navigator.pop(context);
    onCancel();
  }

}

class _FloatyLoaderState extends State<FloatyLoader> {
  @override
  Widget build(BuildContext context) {

    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
          child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).primaryColorLight),
              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 50),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tr("waiting-oauth"),
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: LoadingAnimationWidget.staggeredDotsWave(
                      color: Colors.white,
                      size: 150,
                    ),
                  ),
                  TextButton(
                    onPressed: widget.closeLoader,
                    child: Text(tr("cancel"), style: Theme.of(context).textTheme.labelSmall,),
                    style: TextButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                  )
                ],
              ))),
    );
  }
}

