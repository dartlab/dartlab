// Copyright (c) 2014, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:polymer/polymer.dart';
import 'dart:async';

@CustomTag('x-editor')
class Editor extends PolymerElement {
  @published String label = '';

  @published String value = '';

  Editor.created() : super.created();

  valueChanged(oldValue, newValue) => Timer.run(shadowRoot.querySelector("#autogrow").update);
}
