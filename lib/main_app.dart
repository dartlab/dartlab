// Copyright (c) 2014, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:polymer/polymer.dart';
import 'dart:html';
import 'dart:convert';
import "package:crypto/crypto.dart";
import 'package:route_hierarchical/client.dart';
//import 'package:github/browser.dart';
//import 'package:github/common.dart';
//import 'package:analyzer/analyzer.dart';

const emptyChar = '\u200B';

/// A Polymer `<main-app>` element.
@CustomTag('main-app')
class MainApp extends PolymerElement {
  @observable String id = '';

  @observable String html = '';

  @observable String dart = 'main() {\n}';

  @observable String css = '';

  //GitHub github = createGitHubClient();

  var router = new Router();

  /// Constructor used to create instance of MainApp.
  MainApp.created() : super.created() {
    router.root..addRoute(name: 'id', path: '/:page#:id', enter: load);
    router.listen();
  }

  void inputChanged(String oldValue, String newValue) {
    var content = CryptoUtils.bytesToBase64(UTF8.encode(newValue));
    IFrameElement iframe = this.shadowRoot.querySelector("iframe");
    ScriptElement contentScript = this.shadowRoot.querySelector("script#content");
    print(contentScript.text);
    iframe.src = "data:text/html;base64,$content";
  }

  save() {
    createFile(String filename, String content) => {
      filename: {
        "content": content.isEmpty ? emptyChar : content
      }
    };

    var data = {
      "description": "the description for this gist",
      "public": true,
      "files": {}
          ..addAll(createFile("index.html", html))
          ..addAll(createFile("style.css", css))
          ..addAll(createFile("main.dart", dart))
    };

    print(data);

    var url = "https://api.github.com/gists";
    //var url = "https://api.github.com/gists/$id".replaceAll(new RegExp(r'/$'), '');

    //HttpRequest.request(url, method: id.isEmpty ? "POST" : "PATCH", sendData: JSON.encode(data)) //
    HttpRequest.request(url, method: "POST", sendData: JSON.encode(data)) //
    .then((HttpRequest req) => req.responseText).then(JSON.decode) //
    .then((data) => print(id = data['id']));
  }

  load(RouteEvent e) {
    id = e.parameters['id'];
    print(id);

    getContent(Map<String, Map> files, String filename) => files[filename] == null ? '' : files[filename]['content'].replaceAll(new RegExp('^$emptyChar\$'), '');

    HttpRequest.getString("https://api.github.com/gists/$id") //
    .then(JSON.decode) //
    .then((data) {
      Map<String, Map> files = data['files'];
      print(files);

      html = getContent(files, "index.html");
      css = getContent(files, "style.css");
      dart = getContent(files, "main.dart");
    });
  }

  void idChanged(String oldValue, String newValue) => router.go('id', {
    'page': 'index.html',
    'id': newValue
  });

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
    try {
      //parseCompilationUnit(s);
      return s;
    } catch (e) {
      print(e);
      return "";
    }
  }
}
