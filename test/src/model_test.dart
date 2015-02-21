// Copyright (c) 2015, DartLab.org. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library dartlab;

import 'package:unittest/unittest.dart';

import 'package:observe/observe.dart';

part 'package:dartlab/src/model.dart';

main() {
  group('Workbench', () {
    test('should build fully-formed index.html file', () {
      Workbench w = new Workbench()..body = '<h1>Hello World!</h1>';

      var expected = r'''<!DOCTYPE html>

<html>
<head>
  <script src="packages/browser/dart.js"></script>
  <script type="application/dart" src="main.dart" async></script>
  <link href="styles.css" rel="stylesheet" media="screen">
</head>
<body>
<h1>Hello World!</h1>
</body>
</html>''';

      expect(w.html, equals(expected));
    });

    Map<String, String> pubspecCases = {
      'hello': 'hello',
      'Hello': 'hello',
      'Hello World': 'hello_world',
      'Hello_World': 'hello_world',
      'Hello___World': 'hello_world',
      'HelloWorld': 'helloworld',
      'Hello-World': 'hello_world',
      '  Hello  World   ': 'hello_world',
      'Hello World!': 'hello_world',
      'Hello World! 42.': 'hello_world_42',
      '12 Monkeys': '_12_monkeys',
      '  12   Monkeys  ': '_12_monkeys',
    };
    pubspecCases.forEach((description, expectedName) {
      test('should build fully-formed pubspec.yaml file: $description => $expectedName', () {
        Workbench w = new Workbench()..description = description;

        var expected = '''name: $expectedName
dependencies:
  browser: any''';

        expect(w.pubspec, equals(expected));
      });
    });
  });
}
