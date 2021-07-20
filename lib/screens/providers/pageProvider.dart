import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final pageProvider = ChangeNotifierProvider<PageNotifier>(
  (ref) => PageNotifier(),
  name: 'pageProvider',
);

class PageNotifier extends ChangeNotifier {
  List<MaterialPage> _pages = [];

  List<MaterialPage> get pages => List.unmodifiable(_pages);

  replaceAll(MaterialPage page) {
    _pages = [page];
    notifyListeners();
  }

  addNext(MaterialPage page) {
    _pages.add(page);
    notifyListeners();
  }

  replace(MaterialPage page) {
    _pages.last = page;
    notifyListeners();
  }

  bool handlePopPage(Route<dynamic> route, dynamic result) {
    final bool success = route.didPop(result);
    _pages.removeLast();
    notifyListeners();
    return success;
  }

  remove() {
    _pages.removeLast();
    notifyListeners();
  }
}
