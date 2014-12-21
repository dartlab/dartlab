// Copyright (c) 2014, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'package:polymer/polymer.dart';
import "package:crypto/crypto.dart";

@CustomTag('x-preview')
class Preview extends PolymerElement {
  @published String body = '';

  @published String dart = '';

  @published String css = '';

  Preview.created() : super.created();

  String toDataUri(String body, String css, String dart) => toBase64('text/html', toHtmlFile(body, css, dart));

  String toHtmlFile(String body, String css, String dart) => '''<!doctype html>
<html>
  <head>
    <style>$css</style>
  </head>
  <body>
    $body
    
    <script type="application/dart" src="${toBase64('application/dart', validDart(dart))}"></script>
    <script data-pub-inline src="packages/browser/dart.js"></script>
  </body>
</html>''';

  String toBase64(String contentType, String content) => "data:$contentType;base64," + CryptoUtils.bytesToBase64(UTF8.encode(content));

  validDart(String s) {
    try {
      //parseCompilationUnit(s);
      return s;
    } catch (e) {
      print(e);
      return "";
    }
  }
}
