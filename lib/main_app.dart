// Copyright (c) 2014, DartLab. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:polymer/polymer.dart';
import 'dart:html';
import 'dart:convert';
import 'package:route_hierarchical/client.dart';

@CustomTag('main-app')
class MainApp extends PolymerElement {
  @observable String id = '';

  @observable String description = '';

  @observable String body = '';

  @observable String dart = '';

  @observable String css = '';

  Router router = new Router(useFragment: true);

  MainApp.created() : super.created() {
    router.root
        ..addRoute(name: 'default', defaultRoute: true, enter: (_) => init())
        ..addRoute(name: 'id', path: ':id', enter: (RouteEvent e) => load(e.parameters['id']));
    router.listen();
  }

  init() => this
      ..description = ''
      ..body = ''
      ..dart = 'main() {\n}'
      ..css = '';

  idChanged(_, String id) => router.go('id', {
    'id': id
  });

  load(String id) {
    HttpRequest.getString("https://api.github.com/gists/$id") //
    .then(JSON.decode) //
    .then((data) {
      description = data['description'];
      Map<String, Map> files = data['files'];

      body = getFile(files, "body.html");
      css = getFile(files, "style.css");
      dart = getFile(files, "main.dart");
    }).catchError((_) => id = '');
  }

  save() {
    var data = {
      "description": description.isEmpty ? "A DartLab experience!" : description,
      "public": true,
      "files": {}
          ..addAll(createFile("body.html", body))
          ..addAll(createFile("style.css", css))
          ..addAll(createFile("main.dart", dart))
    };

    var url = "https://api.github.com/gists";
    //var url = "https://api.github.com/gists/$id".replaceAll(new RegExp(r'/$'), '');

    //HttpRequest.request(url, method: id.isEmpty ? "POST" : "PATCH", sendData: JSON.encode(data)) //
    HttpRequest.request(url, method: "POST", sendData: JSON.encode(data)) //
    .then((HttpRequest req) => req.responseText).then(JSON.decode) //
    .then((data) => id = data['id']);
  }

  about() => toggle('about');
  faq() => toggle('faq');
  toggle(String id) => (shadowRoot.querySelector("#$id") as dynamic).toggle();
}

const emptyChar = '\u200B';

createFile(String filename, String content) => {
  filename: {
    "content": content.isEmpty ? emptyChar : content
  }
};

getFile(Map<String, Map> files, String filename) => files[filename] == null ? '' : files[filename]['content'].replaceAll(new RegExp('^$emptyChar\$'), '');
