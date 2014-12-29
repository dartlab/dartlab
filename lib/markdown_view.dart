// Copyright (c) 2014, DartLab. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:html';
import 'package:polymer/polymer.dart';

import 'package:markdown/markdown.dart';

@CustomTag('markdown-view')
class MarkdownView extends PolymerElement {
  @published String src = '';

  @published String content = '';

  MarkdownView.created() : super.created();

  srcChanged(_, src) => HttpRequest.getString(src).then((content) => this.content = content);
  contentChanged(_, content) => shadowRoot.innerHtml = markdownToHtml(content);
}
