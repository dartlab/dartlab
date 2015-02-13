// Copyright (c) 2015, DartLab.org. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:isolate';
import 'package:polymer/polymer.dart';
import "package:crypto/crypto.dart";

@CustomTag('dart-preview')
class DartPreview extends PolymerElement {
  final Duration jobDelay = const Duration(milliseconds: 300);

  @published String body = '';

  @published String css = '';

  @published String dart = '';

  @published String dartUri = '';

  @observable String htmlUri = '';

  @observable int loading = 0;

  final PreviewTemplate previewTemplate;

  DartPreview.created()
      : super.created(),
        previewTemplate = window.navigator.userAgent.contains("Dart") ? new DartVMPreviewTemplate() : new JavaScriptPreviewTemplate();

  PolymerJob dartJob, htmlJob;

  dartChanged(_, dart) => dartJob = scheduleJob(dartJob, generateDart, jobDelay);

  bodyChanged(_, body) => htmlJob = scheduleJob(htmlJob, generateHtml, jobDelay);
  cssChanged(_, css) => htmlJob = scheduleJob(htmlJob, generateHtml, jobDelay);
  dartUriChanged(_, dartUri) => htmlJob = scheduleJob(htmlJob, generateHtml, jobDelay);

  generateDart() {
    loading++;
    previewTemplate.toDartUrl(dart).then((uri) => dartUri = uri).catchError(print).whenComplete(() => loading--);
  }
  generateHtml() => previewTemplate.toHtmlUri(body, css, dartUri).then((uri) => htmlUri = uri);
}

abstract class PreviewTemplate {
  Future<String> toHtmlUri(String body, String css, String dartUri) => new Future.value(_toBase64('text/html', _toHtmlFile(body, css, dartUri)));

  String _toHtmlFile(String body, String css, String dartUri) => '''<!doctype html>
<html>
  <head>
    <style>$css</style>
  </head>
  <body>
    $body
    
    ${_toScriptTag(dartUri)}
  </body>
</html>''';

  String _toBase64(String contentType, String content) => "data:$contentType;base64," + CryptoUtils.bytesToBase64(UTF8.encode(content));

  Future<String> toDartUrl(String dart);

  String _toScriptTag(String dartUri);
}

class DartVMPreviewTemplate extends PreviewTemplate {
  Future<String> toDartUrl(String dart) => new Future.value(_toBase64('application/dart', dart));

  String _toScriptTag(String dartUri) => '''<script type="application/dart" src="$dartUri"></script><script data-pub-inline src="packages/browser/dart.js"></script>''';
}

class JavaScriptPreviewTemplate extends PreviewTemplate {
  final Completer _ready = new Completer();

  CompilationProcess compilationProcess;

  JavaScriptPreviewTemplate() {
    ReceivePort port = new ReceivePort();
    // https://try.dartlang.org/compiler_isolate.dart.js
    Isolate.spawnUri(Uri.base.resolve('compiler_isolate.js'), const <String>[], port.sendPort).then((Isolate isolate) {
      String sdk = './sdk.json';
      print('Using Dart SDK: $sdk');
      port.take(2).listen((message) {
        if (compilationProcess == null) {
          SendPort compilerPort = message as SendPort;
          compilerPort.send([sdk, port.sendPort]);
          compilationProcess = new CompilationProcess(compilerPort);
        }
      }, onDone: _ready.complete);
    });
  }

  Future<String> toDartUrl(String dart) => _ready.future.then((_) => compilationProcess.start(dart).then((javascript) => _toBase64('application/javascript', javascript)));

  String _toScriptTag(String dartUri) => '''<script type="application/javascript" src="$dartUri"></script>''';
}

class CompilationProcess {
  final SendPort compilerPort;

  CompilationProcess(this.compilerPort);

  Future start(String source) {
    var completer = new Completer();
    ReceivePort receivePort = new ReceivePort();
    var options = ['--analyze-main', '--no-source-maps',];
//    if (verboseCompiler) options.add('--verbose');
//    if (minified) options.add('--minify');
//    if (onlyAnalyze) options.add('--analyze-only');
//    if (incrementalCompilation.value) {
//      options.addAll(['--incremental-support', '--disable-type-inference']);
//    }
    compilerPort.send([['options', options], receivePort.sendPort]);
    compilerPort.send([['communicateViaBlobs', false], receivePort.sendPort]);
    compilerPort.send([source, receivePort.sendPort]);
    receivePort.listen(onMessage(receivePort, completer));
    return completer.future;
  }

  onMessage(ReceivePort receivePort, Completer completer) => (message) {
    String kind = message is String ? message : message[0];
    var data = (message is List && message.length == 2) ? message[1] : null;
    switch (kind) {
      case 'done':
        receivePort.close();
        break;
      // This is called in browsers that support creating Object URLs in a
      // web worker.  For example, Chrome and Firefox 21.
      case 'url':
        completer.complete(HttpRequest.getString(data));
        break;
      // This is called in browsers that do not support creating Object
      // URLs in a web worker.  For example, Safari and Firefox < 21.
      case 'code':
        completer.complete(data);
        break;
      case 'diagnostic':
      case 'dart:html':
        print("$kind: $data");
        break;
      case 'crash':
      case 'failed':
        print("$kind: $data");
        completer.completeError("$kind: $data");
        receivePort.close();
        break;
      default:
        throw ['Unknown message kind', message];
    }
  };
}
