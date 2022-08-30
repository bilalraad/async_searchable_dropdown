import 'package:flutter/material.dart';

class SearchableDropdownController<T> {
  GlobalKey key = GlobalKey();

  final ValueNotifier<T?> selectedItem = ValueNotifier<T?>(null);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isError = ValueNotifier<bool>(false);
}
