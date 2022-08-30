# About

This Flutter package helps create a dropdown which it's items are fetched upon search.

## Features

- Has a good degree of customization .
- Fetch items on the start, and when changing search text.
- Search debounce is built in.

## Getting started

To use this package, add async_searchable_dropdown as a dependency in your [pubspec.yaml] file. And add this import to your file.

```dart
import 'package:async_searchable_dropdown/async_searchable_dropdown.dart';
```

## Usage

```dart
SearchableDropdown<String>(
    hintText: 'List of items',
    margin: const EdgeInsets.all(15),
    remoteItems: (search){
        /// Your async function call must return list of string [List<String>]
    },
    itemLabelFormatter: (value) =>
        "my custom value formatter for: $value",
    onChanged: (int? value) {
        debugPrint('$value');
    },
)
```

- backgroundDecoration: Background decoration of dropdown, i.e. with this you can wrap dropdown with Card
- backgroundDecoration: Background decoration of dropdown, i.e. with this you can wrap dropdown with Card

## License

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](/LICENSE)
