// Copyright (c) 2015, DartLab.org. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library dartlab;

import 'package:unittest/unittest.dart';

import 'dart:async';
import 'dart:convert';
import 'package:observe/observe.dart';

part '../../lib/src/gist_client.dart';
part '../../lib/src/model.dart';

main() {
  group('Gist client', () {
    GistClient client = new GistClient();
    var apiUrl = "https://api.github.com/gists";

    test('should load Gist and deserialize Workbench', () {
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
        expect(w.metadata, isNotNull);
        expect(w.metadata.history, equals(["1", "2", "3"]));
      });
    });

    test('should save Workbench on Gist', () {
      // GIVEN
      Workbench w = new Workbench()
          ..id = "666"
          ..description = "The description"
          ..body = "HTML content"
          ..css = "CSS content"
          ..dart = "Dart content"
          ..metadata = (new Metadata()..history.addAll(["1", "2", "3"]));

      var expectedData = JSON.encode({
        "description": "The description",
        "public": true,
        "files": {
          ".metadata.json": {
            "content": new JsonEncoder.withIndent("  ").convert((new Metadata()..history.addAll(["1", "2", "3", "666"])).toJson())
          },
          "body.html": {
            "content": "HTML content"
          },
          "style.css": {
            "content": "CSS content"
          },
          "main.dart": {
            "content": "Dart content"
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
        expect(w.metadata, isNotNull);
        expect(w.metadata.history, equals(["1", "2", "3", "666"]));
      });
    });
    
    test('should save empty Workbench on Gist', () {
      // GIVEN
      Workbench w = new Workbench();

      var expectedData = JSON.encode({
        "description": "A DartLab experience!",
        "public": true,
        "files": {
          ".metadata.json": {
            "content": new JsonEncoder.withIndent("  ").convert(new Metadata().toJson())
          },
          "body.html": {
            "content": "\u200B"
          },
          "style.css": {
            "content": "\u200B"
          },
          "main.dart": {
            "content": "\u200B"
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
        expect(w.metadata, isNotNull);
        expect(w.metadata.history, equals([]));
      });
    });
  });
}

/// HttpRequest mock.
class HttpRequest {
  static HttpRequestGetString getString;
  static HttpRequestRequest request;
  String responseText;
}

typedef Future<String> HttpRequestGetString(String url);
typedef Future<HttpRequest> HttpRequestRequest(String url, {String method, sendData});
