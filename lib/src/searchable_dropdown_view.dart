import 'package:flutter/material.dart';
import 'package:async_searchable_dropdown/src/utils/search_time_denouncer.dart';
import 'searchable_dropdown_controller.dart';

// ignore: must_be_immutable
class SearchableDropdown<T extends Object> extends StatefulWidget {
  ///label text shown when no value is selected
  final String? labelText;

  ///label text Style
  final TextStyle? labelTextStyle;

  ///Hint text shown when the dropdown is empty
  final String? hintText;

  ///Background decoration of dropdown, i.e. with this you can wrap dropdown with Card
  final Widget Function(Widget child)? backgroundDecoration;

  ///Dropdown trailing icon
  final Widget? dropDownIcon;

  ///Dropdown trailing icon size, default is 20
  final double dropDownIconSize;

  final double? dropDownListHeight;

  final double? dropDownListWidth;

  ///Dropdown trailing icon Color
  final Color? dropDownIconColor;

  ///Dropdown trailing icon
  final Widget? leadingIcon;

  ///Dropdowns margin padding with other widgets
  final EdgeInsetsGeometry? margin;

  ///Dropdowns Border
  final Border? border;

  ///Dropdowns Border Radius
  final BorderRadius? borderRadius;

  ///Returns selected Item
  final void Function(T? value)? onChanged;

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
    this.labelText,
    this.hintText,
    this.backgroundDecoration,
    this.margin,
    this.dropDownIcon,
    this.dropDownIconSize = 20,
    this.dropDownListHeight,
    this.dropDownListWidth,
    this.dropDownIconColor,
    this.leadingIcon,
    this.isEnabled = true,
    this.border,
    this.borderRadius,
    this.labelTextStyle,
    this.keyboardType,
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
  Widget build(BuildContext context) {
    return SizedBox(
      key: controller.key,
      width: MediaQuery.of(context).size.width,
      child: widget.backgroundDecoration != null
          ? widget.backgroundDecoration!(
              buildDropDown(context, controller),
            )
          : buildDropDown(context, controller),
    );
  }

  Widget buildDropDown(
    BuildContext context,
    SearchableDropdownController<T> controller,
  ) {
    return Row(
      children: [
        Expanded(
            child: Row(
          children: [
            if (widget.leadingIcon != null)
              Padding(
                padding: const EdgeInsets.only(right: 3.0),
                child: widget.leadingIcon!,
              ),
            Flexible(child: buildDropDownText()),
          ],
        )),
      ],
    );
  }

  Widget buildDropDownText() {
    return Container(
      margin: widget.margin,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: widget.border,
        borderRadius: widget.borderRadius,
      ),
      child: Autocomplete<T>(
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
            onTap: () {
              // To fix Cursor position goes to one before the last
              // when editing a RTL Text
              if (textEditingController.selection ==
                  TextSelection.fromPosition(TextPosition(
                      offset: textEditingController.text.length - 1))) {
                textEditingController.selection = TextSelection.fromPosition(
                    TextPosition(offset: textEditingController.text.length));
              }
            },
            onSubmitted: (value) => focusNode.unfocus(),
            decoration: InputDecoration(
              hintText: widget.hintText,
              labelText: widget.labelText,
              labelStyle: widget.labelTextStyle,
              border: InputBorder.none,
              suffixIconConstraints: BoxConstraints(
                maxWidth: widget.dropDownIconSize,
                maxHeight: widget.dropDownIconSize,
              ),
              suffixIcon: buildDropDownIcon(textEditingController),
            ),
          );
        },
        optionsViewBuilder: (context, onSelected, options) => Align(
          alignment: Alignment.topLeft,
          child: Material(
            color: Colors.white,
            shadowColor: Colors.grey,
            elevation: 8,
            borderRadius: widget.borderRadius,
            child: SizedBox(
              width: widget.dropDownListWidth ?? 300,
              height: widget.dropDownListHeight ?? 200,
              child: ListView(
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
      ),
    );
  }

  Widget buildDropDownIcon(TextEditingController textEditingController) {
    return ValueListenableBuilder<bool>(
      valueListenable: controller.isLoading,
      child: widget.dropDownIcon ??
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: widget.dropDownIconColor,
          ),
      builder: (context, isLoading, child) {
        return ValueListenableBuilder<bool>(
          valueListenable: controller.isError,
          builder: (context, isError, _) {
            if (isLoading) {
              return CircularProgressIndicator.adaptive(
                valueColor: AlwaysStoppedAnimation<Color>(
                    widget.dropDownIconColor ?? Theme.of(context).primaryColor),
              );
            } else if (isError) {
              return InkWell(
                onTap: () {
                  // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                  textEditingController.notifyListeners();
                },
                child: Icon(
                  Icons.refresh,
                  color: widget.dropDownIconColor,
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
    if (controller.searchText.value == search.text) return [];
    if (widget.value != null &&
        widget.itemLabelFormatter(widget.value!) == search.text) return [];

    controller.searchText.value = search.text;
    await _searchTimeDeBouncer.run();
    controller.isLoading.value = true;
    controller.isError.value = false;
    try {
      final options = await widget.remoteItems.call(search.text);
      controller.isLoading.value = false;
      return options ?? [];
    } catch (e) {
      controller.isLoading.value = false;
      controller.isError.value = true;
      rethrow;
    }
  }
}
