import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:async_searchable_dropdown/src/utils/search_time_denouncer.dart';
import 'searchable_dropdown_controller.dart';

// ignore: must_be_immutable
class SearchableDropdown<T extends Object> extends StatefulWidget {
  final double? dropDownListHeight;

  final double? dropDownListWidth;

  final double? cursorHeight;

  final InputDecoration inputDecoration;

  ///Dropdowns Border Radius
  final BorderRadius? borderRadius;

  ///Returns selected Item
  final void Function(T? value)? onChanged;

  final double loadingIconSize;

  //Initial value of dropdown
  T? value;

  //Is dropdown enabled
  bool isEnabled;

  /// This is responsible for formatting your objects of type T
  /// to a string representation of itself
  /// It is also required for performance reasons
  String Function(T value) itemLabelFormatter;

  final TextInputType? keyboardType;

  ///Future service which is returns DropdownMenuItem list
  Future<List<T>?> Function(String? search) remoteItems;

  SearchableDropdown({
    super.key,
    required this.remoteItems,
    required this.value,
    required this.itemLabelFormatter,
    this.onChanged,
    this.dropDownListHeight,
    this.dropDownListWidth,
    this.isEnabled = true,
    this.borderRadius,
    this.loadingIconSize = 20.0,
    this.keyboardType,
    this.cursorHeight,
    this.inputDecoration = const InputDecoration(),
  });

  @override
  State<SearchableDropdown<T>> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T extends Object>
    extends State<SearchableDropdown<T>> {
  late SearchableDropdownController<T> controller;
  final _searchTimeDeBouncer = TimeDeBouncer(milliseconds: 750);

  @override
  void initState() {
    controller = SearchableDropdownController<T>();
    controller.selectedItem.value = widget.value;
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: controller.key,
      width: MediaQuery.of(context).size.width,
      child: buildDropDownText(),
    );
  }

  Widget buildDropDownText() {
    return Autocomplete<T>(
      fieldViewBuilder: (
        context,
        textEditingController,
        focusNode,
        onFieldSubmitted,
      ) {
        return TextField(
          controller: textEditingController,
          focusNode: focusNode,
          enabled: widget.isEnabled,
          keyboardType: widget.keyboardType,
          onEditingComplete: onFieldSubmitted,
          cursorHeight: widget.cursorHeight,
          onTap: () {
            if (textEditingController.text.trim().isEmpty) return;
            // To fix Cursor position goes to one before the last
            // when editing a RTL Text
            if (textEditingController.selection ==
                TextSelection.fromPosition(TextPosition(
                    offset: textEditingController.text.length - 1))) {
              textEditingController.selection = TextSelection.fromPosition(
                  TextPosition(offset: textEditingController.text.length));
            }
            textEditingController.text =
                "${textEditingController.text.trim()} ";
          },
          onSubmitted: (value) => focusNode.unfocus(),
          decoration: widget.inputDecoration.copyWith(
            suffixIcon: buildDropDownIcon(textEditingController),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) => Align(
        alignment: Directionality.of(context) == TextDirection.ltr
            ? AlignmentDirectional.topStart
            : AlignmentDirectional.topEnd,
        child: Material(
          color: Colors.white,
          shadowColor: Colors.grey,
          elevation: 8,
          borderRadius: widget.borderRadius,
          child: SizedBox(
            width: widget.dropDownListWidth ?? 300,
            height: widget.dropDownListHeight ?? 200,
            child: ListView(
              shrinkWrap: true,
              children: options
                  .map((e) => ListTile(
                        onTap: () => onSelected(e),
                        title: Text(widget.itemLabelFormatter(e)),
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
      optionsBuilder: optionsBuilder,
      displayStringForOption: widget.itemLabelFormatter,
      onSelected: (value) {
        if (controller.selectedItem.value == value) return;

        controller.selectedItem.value = value;
        widget.onChanged?.call(value);
      },
    );
  }

  Widget buildDropDownIcon(TextEditingController textEditingController) {
    return ValueListenableBuilder<bool>(
      valueListenable: controller.isLoading,
      child: widget.inputDecoration.suffixIcon ??
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: widget.inputDecoration.suffixIconColor,
          ),
      builder: (context, isLoading, child) {
        return ValueListenableBuilder<bool>(
          valueListenable: controller.isError,
          builder: (context, isError, _) {
            if (isLoading) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox.square(
                    dimension: widget.loadingIconSize,
                    child: CircularProgressIndicator.adaptive(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.inputDecoration.suffixIconColor ??
                            Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              );
            } else if (isError) {
              return InkWell(
                onTap: () {
                  // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                  textEditingController.notifyListeners();
                },
                child: Icon(
                  Icons.refresh,
                  color: widget.inputDecoration.suffixIconColor,
                ),
              );
            } else {
              return child!;
            }
          },
        );
      },
    );
  }

  Future<List<T>> optionsBuilder(TextEditingValue search) async {
    if (controller.searchText.value.trim() == search.text.trim()) {
      return controller.oldResults;
    }

    /// This is used to check if the search text is not an actual
    /// value that's been selected
    if (controller.oldResults.isNotEmpty &&
        controller.oldResults.take(4).firstWhereOrNull(
                (e) => widget.itemLabelFormatter(e) == search.text) !=
            null) return [];

    controller.searchText.value = search.text;
    await _searchTimeDeBouncer.run();
    controller.isLoading.value = true;
    controller.isError.value = false;
    try {
      final options = await widget.remoteItems.call(search.text.trim());
      controller.isLoading.value = false;
      controller.oldResults = options ?? [];
      return options ?? [];
    } catch (e) {
      controller.isLoading.value = false;
      controller.isError.value = true;
      rethrow;
    }
  }
}
