// Copyright (c) 2015, DartLab.org. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

part of dartlab;

class Workbench extends Observable {
  @observable String id = '';
  @observable String description = '';
  @observable String body = '';
  @observable String css = '';
  @observable String dart = '';

  String get html => '''<!DOCTYPE html>

<html>
<head>
  <script src="packages/browser/dart.js"></script>
  <script type="application/dart" src="main.dart" async></script>
  <link href="styles.css" rel="stylesheet" media="screen">
</head>
<body>
$body
</body>
</html>''';

  String get pubspec => '''name: ${_snakeCase(description)}
dependencies:
  browser: any''';

  String get readme => '''# $description

Created using [DartLab.org](http://dartlab.org).''';

  String get gitignore => '''*.dart.js
*.js.deps
*.js.map
.buildlog
pubspec.lock

.pub/
.settings/
build/
packages''';

  // The name should be all lowercase, with underscores to separate words, just_like_this.
  // Use only basic Latin letters and Arabic digits: [a-z0-9_].
  // Also, make sure the name is a valid Dart identifier—that it doesn’t start with digits and isn’t a reserved word.
  String _snakeCase(String s) => s.toLowerCase()
      .replaceAll(new RegExp('[^a-z0-9]+'), ' ').trim()
      .replaceAll(new RegExp('^([0-9])'), '_\1')
      .replaceAll(' ', '_');
}

class Metadata extends Observable {
  final String origin = 'dartlab.org';
  final String url = 'http://dartlab.org/#:gistId';
  final List<String> history;

  Metadata() : history = toObservable([]);
  Metadata.fromJson(Map m) : history = toObservable(m['history'] is List ? m['history'] : []);
  Map toJson() => {
    'origin': origin,
    'url': url,
    'history': history
  };
}
