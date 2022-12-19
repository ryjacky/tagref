import 'package:flutter/cupertino.dart';

typedef OnUpdateListener = Function(String callerId, UpdateType type, dynamic data);
typedef SearchTags = List<String>;

enum UpdateType { searchChanged, refresh }

class UpdateNotifier {
  List<OnUpdateListener> onUpdateListeners = <OnUpdateListener>[];

  void addOnUpdateListener(OnUpdateListener listener) {
    onUpdateListeners.add(listener);
  }

  void update(String callerId,
      {UpdateType type = UpdateType.refresh, dynamic data}) {
    // data type check
    switch (type) {
      case UpdateType.searchChanged:
        if (data is! SearchTags) {
          throw Exception("${data.runtimeType} received, SearchTags expected");
        }
        break;
      case UpdateType.refresh:

        break;
    }

    for (var listener in onUpdateListeners) {
      listener(callerId, type, data);
    }
  }
}
