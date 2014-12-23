// Copyright (c) 2014, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:isolate';
import 'package:polymer/polymer.dart';
import "package:crypto/crypto.dart";

@CustomTag('x-preview')
class Preview extends PolymerElement {
  @published String body = '';

  @published String css = '';

  @published String dart = '';

  @published String dartDataUri = '';

  @observable String dataUri = '';

  final bool nativeDart;

  Preview.created()
      : super.created(),
        nativeDart = window.navigator.userAgent.contains("Dart") {
    if (!nativeDart) {
      ReceivePort port = new ReceivePort();
      // https://try.dartlang.org/compiler_isolate.dart.js
      Isolate.spawnUri(Uri.base.resolve('compiler_isolate.js'), const <String>[], port.sendPort).then((Isolate isolate) {
        String sdk = '/sdk.json';
        print('Using Dart SDK: $sdk');
        int messageCount = 0;
        SendPort sendPort;
        port.listen((message) {
          messageCount++;
          switch (messageCount) {
            case 1:
              sendPort = message as SendPort;
              sendPort.send([sdk, port.sendPort]);
              break;
            case 2:
              // Acknowledged Receiving the SDK URI.
              compilerPort = sendPort;
              //interaction.onMutation([], observer);
              dartChanged(null, dart);
              break;
            default:
              // TODO(ahe): Close [port]?
              print('Unexpected message received: $message');
              break;
          }
        });
      });
    }
  }

  bodyChanged(_, body) => dataUri = toDataUri(body, css, dartDataUri);
  cssChanged(_, css) => dataUri = toDataUri(body, css, dartDataUri);
  dartChanged(_, dart) {
    if (nativeDart) {
      dartDataUri = toBase64('application/dart', validDart(dart));
    } else {
      new CompilationProcess().start(dart).then((value) => dartDataUri = toBase64('application/javascript', value));
    }
  }
  dartDataUriChanged(_, dartDataUri) => dataUri = toDataUri(body, css, dartDataUri);

  String toDataUri(String body, String css, String dartDataUri) => toBase64('text/html', toHtmlFile(body, css, dartDataUri));

  String toHtmlFile(String body, String css, String dartDataUri) => '''<!doctype html>
<html>
  <head>
    <style>$css</style>
  </head>
  <body>
    $body
    
    <script type="${nativeDart ? 'application/dart' : 'application/javascript'}" src="$dartDataUri"></script>
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

SendPort compilerPort;


class CompilationProcess {
  final ReceivePort receivePort = new ReceivePort();
  final Set<String> seenMessages = new Set<String>();
  bool isDone = false;
  bool usesDartHtml = false;
//  Worker worker;
//  List<String> objectUrls = <String>[];
  String firstError;

  //static CompilationProcess current;

  static bool shouldStartCompilation() {
    if (compilerPort == null) return false;
    //if (isMalformedInput) return false;
    //if (current != null) return current.isDone;
    return true;
  }

  Future start(String source) {
    if (!shouldStartCompilation()) {
      receivePort.close();
      return new Future.value("");
    }
//    if (current != null) current.dispose();
//    current = this;
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
    var completer = new Completer();
    receivePort.listen(onMessage(completer));
    return completer.future;
  }

  void dispose() {
//    if (worker != null) worker.terminate();
//    objectUrls.forEach(Url.revokeObjectUrl);
  }

  onMessage(Completer completer) => (message) {
    String kind = message is String ? message : message[0];
    var data = (message is List && message.length == 2) ? message[1] : null;
    switch (kind) {
      case 'done':
        return onDone(data);
      case 'url':
        HttpRequest.getString(data).then(completer.complete);
        return onUrl(data);
      case 'code':
        return onCode(data);
      case 'diagnostic':
        return onDiagnostic(data);
      case 'crash':
        return onCrash(data);
      case 'failed':
        return onFail(data);
      case 'dart:html':
        return onDartHtml(data);
      default:
        throw ['Unknown message kind', message];
    }
  };

  onDartHtml(_) {
    usesDartHtml = true;
  }

  onFail(_) {
    print(firstError);
  }

  onDone(_) {
    isDone = true;
    receivePort.close();
  }

  // This is called in browsers that support creating Object URLs in a
  // web worker.  For example, Chrome and Firefox 21.
  onUrl(String url) {
    print('onUrl: $url');

    //new FileReader().readAsDataUrl(url);

//    objectUrls.add(url);
//    String wrapper = '''
//// Fool isolate_helper.dart so it does not think this is an isolate.
//var window = self;
//function dartPrint(msg) {
//  self.postMessage(msg);
//};
//self.importScripts("$url");
//''';
//    var wrapperUrl = Url.createObjectUrl(new Blob([wrapper], 'application/javascript'));
//    objectUrls.add(wrapperUrl);
//
//    run(wrapperUrl, () => makeOutputFrame(url));
  }

  // This is called in browsers that do not support creating Object
  // URLs in a web worker.  For example, Safari and Firefox < 21.
  onCode(String code) {
    print('onCode: $code');

//    IFrameElement makeIframe() {
//      // The obvious thing would be to call [makeOutputFrame], but
//      // Safari doesn't support access to Object URLs in an iframe.
//
//      IFrameElement frame = new IFrameElement()
//          ..src = 'iframe.html'
//          ..style.width = '100%'
//          ..style.height = '0px';
//      frame.onLoad.listen((_) {
//        frame.contentWindow.postMessage(['source', code], '*');
//      });
//      return frame;
//    }
//
//    String codeWithPrint = '$code\n' 'function dartPrint(msg) { postMessage(msg); }\n';
//    var url = Url.createObjectUrl(new Blob([codeWithPrint], 'application/javascript'));
//    objectUrls.add(url);
//
//    run(url, makeIframe);
  }

//  void run(String url, IFrameElement makeIframe()) {
//    void retryInIframe() {
//      interaction.aboutToRun();
//      var frame = makeIframe();
//      frame.style
//          ..visibility = 'hidden'
//          ..position = 'absolute';
//      outputFrame.parent.insertBefore(frame, outputFrame);
//      outputFrame = frame;
//      errorStream(frame).listen(interaction.onIframeError);
//    }
//    void onError(String errorMessage) {
//      interaction.consolePrintLine(errorMessage);
//      console
//          ..append(buildButton('Try in iframe', (_) => retryInIframe()))
//          ..appendText('\n');
//    }
//    interaction.aboutToRun();
//    if (alwaysRunInIframe.value || usesDartHtml && !alwaysRunInWorker) {
//      retryInIframe();
//    } else {
//      runInWorker(url, onError);
//    }
//  }
//
//  void runInWorker(String url, void onError(String errorMessage)) {
//    worker = new Worker(url)
//        ..onMessage.listen((MessageEvent event) {
//          interaction.consolePrintLine(event.data);
//        })
//        ..onError.listen((ErrorEvent event) {
//          worker.terminate();
//          worker = null;
//          onError(event.message);
//        });
//  }

  onDiagnostic(Map<String, dynamic> diagnostic) {
    print('onDiagnostic: $diagnostic');
//    if (currentSource != source) return;
//    String kind = diagnostic['kind'];
//    String message = diagnostic['message'];
//    if (kind == 'verbose info') {
//      interaction.verboseCompilerMessage(message);
//      return;
//    }
//    if (kind == 'error' && firstError == null) {
//      firstError = message;
//    }
//    String uri = diagnostic['uri'];
//    if (uri != '${PRIVATE_SCHEME}:/main.dart') {
//      interaction.consolePrintLine('$uri: [$kind] $message');
//      return;
//    }
//    int begin = diagnostic['begin'];
//    int end = diagnostic['end'];
//    if (begin == null) return;
//    if (seenMessages.add('$begin:$end: [$kind] $message')) {
//      // Guard against duplicated messages.
//      addDiagnostic(kind, message, begin, end);
//    }
  }

  onCrash(data) {
    print('onCrash: $data');
  }
}
