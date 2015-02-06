// Copyright (c) 2015, DartLab.org. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:polymer/polymer.dart';
import 'dart:html' hide Metadata;
import 'package:route_hierarchical/client.dart';
import 'package:usage/usage_html.dart';

import 'dartlab.dart';

final Analytics _analytics = new AnalyticsHtml('UA-58153248-1', 'DartLab', '')..optIn = true;
sendCurrentScreenView([_]) => _analytics.sendScreenView(window.location.pathname + window.location.search + window.location.hash);
sendButtonClick(String label) => _analytics.sendEvent('button', 'click', label: label);

@CustomTag('main-app')
class MainApp extends PolymerElement {
  final GistClient gistClient = new GistClient();

  @observable String id;

  @observable Workbench workbench = new Workbench();

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

  ready() => async((_) => resize());

  init() => workbench = new Workbench()
      ..dart = 'main() {\n}';

  idChanged(_, String id) => router.go('id', {
    'id': id
  });

  load(String id) {
    gistClient.load(id) //
    .then((Workbench w) => workbench = w) //
    .catchError((_) => id = '');
  }

  save() {
    gistClient.save(workbench) //
    .then((Workbench w) => workbench = w) //
    .then((w) => id = w.id) //
    .then((_) => _analytics.sendEvent('main', 'save', label: id));
  }

  twitter() {
    var text = Uri.encodeComponent('Awesome! ' + (workbench.description.isEmpty ? 'DartLab' : workbench.description));
    openShareLink('twitter', 'https://twitter.com/intent/tweet?hashtags=dartlab&via=TheDartLab&text=$text&url=');
  }
  gplus() => openShareLink('gplus', 'https://plus.google.com/share?url=');
  openShareLink(String button, String url) {
    var currentLocation = Uri.encodeComponent(window.location.toString());
    window.open(url + currentLocation, '_blank', 'menubar=no,toolbar=no,resizable=yes,scrollbars=yes,height=600,width=600');
    sendButtonClick(button);
  }
  fullscreen() {
    isFullscreen = !isFullscreen;
    sendButtonClick('fullscreen');
  }
  about() => openDialog('about');
  faq() => openDialog('faq');
  openDialog(String id) {
    (shadowRoot.querySelector("#$id") as dynamic).open();
    sendButtonClick(id);
  }

  resize() => document.querySelectorAll('html /deep/ code-mirror').forEach((node) => node.refresh());
}
