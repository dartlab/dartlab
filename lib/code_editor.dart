// Copyright (c) 2014, DartLab. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:polymer/polymer.dart';

@CustomTag('code-editor')
class CodeEditor extends PolymerElement {
  @published String value = '';
  @published String label;
  @published String mode;
  @published bool autoCloseTags = false;

  CodeEditor.created() : super.created();
}
