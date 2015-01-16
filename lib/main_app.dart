// Copyright (c) 2014, DartLab. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:polymer/polymer.dart';
import 'dart:html';
import 'dart:convert';
import 'package:route_hierarchical/client.dart';
import 'package:usage/usage_html.dart';

final Analytics _analytics = new AnalyticsHtml('UA-58153248-1', 'DartLab', '')..optIn = true;
sendCurrentScreenView([_]) => _analytics.sendScreenView(window.location.pathname + window.location.search + window.location.hash);

@CustomTag('main-app')
class MainApp extends PolymerElement {
  @observable String id;

  @observable String description;

  @observable Metadata metadata;

  @observable String body;

  @observable String dart;

  @observable String css;

  @observable bool isFullscreen = false;

  Router router = new Router(useFragment: true);

  MainApp.created() : super.created() {
    //sendCurrentScreenView();
    window.onHashChange.listen(sendCurrentScreenView);

    router.root
        ..addRoute(name: 'default', defaultRoute: true, enter: (_) => init())
        ..addRoute(name: 'id', path: ':id', enter: (RouteEvent e) => load(id = e.parameters['id']));
    router.listen();
  }

  init() => this
      ..id = ''
      ..description = ''
      ..metadata = new Metadata()
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
      Map metadataJson = {};
      try {
        metadataJson = JSON.decode(getFile(files, ".metadata.json", defaultValue: '{}')) as Map;
      } catch (ignore) {}
      metadata = new Metadata.fromJson(metadataJson);
    }).catchError((_) => id = '');
  }

  save() {
    if (id.isNotEmpty) metadata.history.add(id);

    var data = {
      "description": description.isEmpty ? "A DartLab experience!" : description,
      "public": true,
      "files": {}
          ..addAll(createFile(".metadata.json", new JsonEncoder.withIndent("  ").convert(metadata)))
          ..addAll(createFile("body.html", body))
          ..addAll(createFile("style.css", css))
          ..addAll(createFile("main.dart", dart))
    };

    var url = "https://api.github.com/gists";
    //var url = "https://api.github.com/gists/$id".replaceAll(new RegExp(r'/$'), '');

    //HttpRequest.request(url, method: id.isEmpty ? "POST" : "PATCH", sendData: JSON.encode(data)) //
    HttpRequest.request(url, method: "POST", sendData: JSON.encode(data)) //
    .then((HttpRequest req) => req.responseText).then(JSON.decode) //
    .then((data) => id = data['id']) //
    .then((_) => _analytics.sendEvent('main', 'save', label: id));
  }

  fullscreen() => isFullscreen = !isFullscreen;
  about() => toggle('about');
  faq() => toggle('faq');
  toggle(String id) {
    (shadowRoot.querySelector("#$id") as dynamic).open();
    _analytics.sendEvent('main', 'dialog', label: id);
  }
}

const emptyChar = '\u200B';

createFile(String filename, String content) => {
  filename: {
    "content": content.isEmpty ? emptyChar : content
  }
};

getFile(Map<String, Map> files, String filename, {String defaultValue: ''}) =>
    files[filename] == null ? defaultValue : files[filename]['content'].replaceAll(new RegExp('^$emptyChar\$'), defaultValue);

class Metadata {
  final String origin = 'dartlab.org';
  final String url = 'http://dartlab.org/#:gistId';
  List<String> history = [];

  Metadata();
  Metadata.fromJson(Map m) : history = m['history'] is List ? m['history'] : [];
  Map toJson() => {
    'origin': origin,
    'url': url,
    'history': history
  };
}
