import 'package:flutter/material.dart';

class SearchableDropdownController<T> {
  GlobalKey key = GlobalKey();

  final ValueNotifier<T?> selectedItem = ValueNotifier<T?>(null);
  final ValueNotifier<String> searchText = ValueNotifier<String>("");

  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isError = ValueNotifier<bool>(false);

  List<T> oldResults = [];

  void dispose() {
    selectedItem.dispose();
    searchText.dispose();
    isLoading.dispose();
    isError.dispose();
    oldResults.clear();
  }
}
