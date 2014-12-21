// Copyright (c) 2014, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:polymer/polymer.dart';
import 'dart:html';
import 'dart:convert';
import 'package:route_hierarchical/client.dart';

const emptyChar = '\u200B';

/// A Polymer `<main-app>` element.
@CustomTag('main-app')
class MainApp extends PolymerElement {
  @observable String id = '';

  @observable String body = '';

  @observable String dart = 'main() {\n}';

  @observable String css = '';

  var router = new Router();

  /// Constructor used to create instance of MainApp.
  MainApp.created() : super.created() {
    router.root..addRoute(name: 'id', path: '/:page#:id', enter: load);
    router.listen();
  }

  void idChanged(String oldValue, String newValue) => router.go('id', {
    'page': 'index.html',
    'id': newValue
  });
  
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
          ..addAll(createFile("body.html", body))
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

      body = getContent(files, "body.html");
      css = getContent(files, "style.css");
      dart = getContent(files, "main.dart");
    });
  }
}
