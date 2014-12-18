// Copyright (c) 2014, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:polymer/polymer.dart';
import 'dart:html';
import 'dart:convert';
import "package:crypto/crypto.dart";
//import 'package:analyzer/analyzer.dart';

/// A Polymer `<main-app>` element.
@CustomTag('main-app')
class MainApp extends PolymerElement {
  @observable String html = '';

  @observable String dart = 'main() {\n}';

  @observable String css = '';

  @observable String content = '';

  ScriptElement contentScript;

  /// Constructor used to create instance of MainApp.
  MainApp.created() : super.created() {
    contentScript = this.shadowRoot.querySelector("script#content");
  }

//  void inputChanged(String oldValue, String newValue) {
//    //print(newValue);
//    var content = CryptoUtils.bytesToBase64(UTF8.encode(newValue));
//    IFrameElement iframe = this.shadowRoot.querySelector("iframe");
//    ScriptElement contentScript = this.shadowRoot.querySelector("script#content");
//    print(contentScript.text);
//    iframe.src = "data:text/html;base64,$content";
////    var window = iframe.contentWindow;
////    window.document.documentElement.setInnerHtml(newValue);
//  }
  
//  <script id="content" type="text/template">
//    <html>
//      <head></head>
//      <body>
//        {{ html }}
//      </body>
//    </html>
//  </script>

  String toTemplate(String html, String css, String dart) => '''<!doctype html>
<html>
  <head>
    <style>$css</style>
  </head>
  <body>
    $html
    
    <script type="application/dart" src="${base64('application/dart')(validDart(dart))}"></script>
    <script data-pub-inline src="packages/browser/dart.js"></script>
  </body>
</html>''';

  base64(contentType) => (String s) => "data:$contentType;base64," + CryptoUtils.bytesToBase64(UTF8.encode(s));
  validDart(String s) {
    try{
      //parseCompilationUnit(s);
      return s;
    } catch(e) {
      print(e);
      return "";      
    }
  }

}

//import 'dart:html';
//
//void main() {
//  print("Hello world!");
//
//  document.body.append(new Text("Hello world!"));
//}
