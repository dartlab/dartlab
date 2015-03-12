// Copyright (c) 2015, DartLab.org. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library dartlab;

import 'package:unittest/unittest.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:html' show DomParser;
import 'package:observe/observe.dart';

part 'package:dartlab/src/gist_client.dart';
part 'package:dartlab/src/model.dart';

main() {
  group('Gist client', () {
    GistClient client = new GistClient();
    var apiUrl = "https://api.github.com/gists";

    test('should load old Gist format and deserialize Workbench', () {
      // GIVEN
      var response = JSON.encode({
        "id": "42",
        "files": {
          "body.html": {
            "content": "HTML content"
          },
          "style.css": {
            "content": "CSS content"
          },
          "main.dart": {
            "content": "Dart content"
          },
          ".metadata.json": {
            "content": '{"history": ["1", "2", "3"]}'
          }
        },
        "description": "The description"
      });

      HttpRequest.getString = (url) {
        expect(url, equals("$apiUrl/gistId"));
        return new Future.value(response);
      };

      // WHEN
      return client.load("gistId").then((Workbench w) {
        // THEN
        expect(w.id, equals("42"));
        expect(w.description, equals("The description"));
        expect(w.body, equals("HTML content"));
        expect(w.css, equals("CSS content"));
        expect(w.dart, equals("Dart content"));
      });
    });

    test('should load new Gist format and deserialize Workbench', () {
      // GIVEN
      var response = JSON.encode({
        "id": "42",
        "files": {
          "index.html": {
            "content": fullHtml('HTML content')
          },
          "style.css": {
            "content": "CSS content"
          },
          "main.dart": {
            "content": "Dart content"
          }
        },
        "description": "The description"
      });

      HttpRequest.getString = (url) {
        expect(url, equals("$apiUrl/gistId"));
        return new Future.value(response);
      };

      // WHEN
      return client.load("gistId").then((Workbench w) {
        // THEN
        expect(w.id, equals("42"));
        expect(w.description, equals("The description"));
        expect(w.body, equals("HTML content"));
        expect(w.css, equals("CSS content"));
        expect(w.dart, equals("Dart content"));
      });
    });

    test('should load new Gist format and deserialize Workbench without body tag', () {
      // GIVEN
      var response = JSON.encode({
        "files": {
          "index.html": {
            "content": '<h1>HTML content</h1>'
          },
        }
      });

      HttpRequest.getString = (url) => new Future.value(response);

      // WHEN
      return client.load(null).then((Workbench w) {
        // THEN
        expect(w.body, equals("<h1>HTML content</h1>"));
      });
    });

    test('should save Workbench on Gist', () {
      // GIVEN
      Workbench w = new Workbench()
          ..id = "666"
          ..description = "The description"
          ..body = "HTML content"
          ..css = "CSS content"
          ..dart = "Dart content";

      var expectedData = JSON.encode({
        "description": "The description",
        "public": true,
        "files": {
          "index.html": {
            "content": fullHtml('HTML content')
          },
          "style.css": {
            "content": "CSS content"
          },
          "main.dart": {
            "content": "Dart content"
          },
          "pubspec.yaml": {
            "content": fullPubspec('the_description')
          },
          "README.md": {
            "content": fullReadme('The description')
          },
          ".gitignore": {
            "content": gitignore
          }
        }
      });

      var response = '{"id": "42"}';

      HttpRequest.request = (url, {String method, sendData}) {
        expect(url, equals(apiUrl));
        expect(method, equals("POST"));
        expect(sendData, equals(expectedData));
        return new Future.value(new HttpRequest()..responseText = response);
      };

      // WHEN
      return client.save(w).then((Workbench w) {
        // THEN
        expect(w.id, equals("42"));
        expect(w.description, equals("The description"));
        expect(w.body, equals("HTML content"));
        expect(w.css, equals("CSS content"));
        expect(w.dart, equals("Dart content"));
      });
    });

    test('should save empty Workbench on Gist', () {
      // GIVEN
      Workbench w = new Workbench();

      var expectedData = JSON.encode({
        "description": "A DartLab experience!",
        "public": true,
        "files": {
          "index.html": {
            "content": fullHtml('')
          },
          "pubspec.yaml": {
            "content": fullPubspec('a_dartlab_experience')
          },
          "README.md": {
            "content": fullReadme('A DartLab experience!')
          },
          ".gitignore": {
            "content": gitignore
          }
        }
      });

      var response = '{"id": "42"}';

      HttpRequest.request = (url, {String method, sendData}) {
        expect(url, equals(apiUrl));
        expect(method, equals("POST"));
        expect(sendData, equals(expectedData));
        return new Future.value(new HttpRequest()..responseText = response);
      };

      // WHEN
      return client.save(w).then((Workbench w) {
        // THEN
        expect(w.id, equals("42"));
        expect(w.description, equals("A DartLab experience!"));
        expect(w.body, isEmpty);
        expect(w.css, isEmpty);
        expect(w.dart, isEmpty);
      });
    });

    group('_htmlDecode', () {
      test('should return empty string if html is empty', () {
        expect(client._htmlDecode(''), isEmpty);
      });

      test('should return body content if html is well-formed', () {
        expect(client._htmlDecode('<html><body><h1>Hello World!</h1></body></html>'), equals('<h1>Hello World!</h1>'));
      });

      test('should return empty string if html is well-formed but without body', () {
        expect(client._htmlDecode('<html><head><title>Hello World!</title></head></html>'), isEmpty);
      });

      test('should return body content even if html is malformed', () {
        expect(client._htmlDecode('Hello World!'), equals('Hello World!'));
        expect(client._htmlDecode('<h1>Hello World!</h1>'), equals('<h1>Hello World!</h1>'));
        expect(client._htmlDecode('<body><h1>Hello World!</h1>'), '<h1>Hello World!</h1>');
        expect(client._htmlDecode('<body><h1>Hello World!</h1></XXX>'), '<h1>Hello World!</h1>');
      });

      test('should return body content with external scripts or resources', () {
        var js = 'https://cdn.com/bootstrap.js';
        var css = 'https://cdn.com/bootstrap.css';
        expect(client._htmlDecode('<link rel="stylesheet" href="$css">'), equals('<link rel="stylesheet" href="$css">'));
        expect(client._htmlDecode('<script src="$js"></script>'), equals('<script src="$js"></script>'));
        expect(client._htmlDecode('<html><body><script src="$js"></script></body></html>'), equals('<script src="$js"></script>'));
        expect(client._htmlDecode('<script src="$js"></script><h1>Mixed script and content</h1>'), equals('<script src="$js"></script><h1>Mixed script and content</h1>'));
      });

      test('should return body content with custom elements or attributes', () {
        expect(client._htmlDecode('<custom-element>Hello World!</custom-element>'), equals('<custom-element>Hello World!</custom-element>'));
        expect(client._htmlDecode('<h1 custom-attribute="Bob">Hello World!</h1>'), equals('<h1 custom-attribute="Bob">Hello World!</h1>'));
      });

      test('should preserve formatting', () {
        expect(client._htmlDecode(r'''<html>
<body>
<h1  class="awesome" >
  Hello World!

  <!-- Some comments
       <custom-comments> -->

  <input type='text'
    required >
</h1 >
</body>
</html>'''), equals(r'''<h1 class="awesome">
  Hello World!

  <!-- Some comments
       <custom-comments> -->

  <input type="text" required="">
</h1>'''));
      });
    });
  });
}

fullHtml(String body) => '''<!DOCTYPE html>

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

fullPubspec(String name) => '''name: $name
dependencies:
  browser: any''';

fullReadme(String description) => '''# $description

Created using [DartLab.org](http://dartlab.org).''';

const gitignore = '''*.dart.js
*.js.deps
*.js.map
.buildlog
pubspec.lock

.pub/
.settings/
build/
packages''';

/// HttpRequest mock.
class HttpRequest {
  static HttpRequestGetString getString;
  static HttpRequestRequest request;
  String responseText;
}

typedef Future<String> HttpRequestGetString(String url);
typedef Future<HttpRequest> HttpRequestRequest(String url, {String method, sendData});
