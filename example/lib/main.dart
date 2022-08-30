import 'dart:math';

import 'package:flutter/material.dart';
import 'package:async_searchable_dropdown/async_searchable_dropdown.dart';

final data = [
  "hello",
  "xyzw",
  "bilal",
  "Romio",
  "Cats in the rain",
  "Ali",
];

Future<List<String>> getData(String? search) async {
  await Future.delayed(const Duration(seconds: 2));
  if (Random().nextBool()) throw 'sdd';
  return data.where((e) => e.contains(search ?? '')).toList();
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final ValueNotifier<String?> selectedValue = ValueNotifier<String?>(null);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Async Searchable Dropdown Example'),
        ),
        body: Column(
          children: [
            const SizedBox(height: 20),
            ValueListenableBuilder<String?>(
              valueListenable: selectedValue,
              builder: (context, value, child) {
                return SearchableDropdown<String>(
                  backgroundDecoration: (child) => Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0)),
                    child: child,
                  ),
                  value: value,
                  itemLabelFormatter: (value) {
                    return value;
                  },
                  labelText: 'List of items',
                  margin: const EdgeInsets.all(15),
                  remoteItems: getData,
                  onChanged: (value) {
                    selectedValue.value = value;
                    debugPrint('$value');
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
