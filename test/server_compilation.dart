// Copyright (c) 2014, DartLab. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:http/http.dart' as http;
import 'dart:convert';

main() {
  analyzeTest();
  compileTest();
}

void analyzeTest() {
  var data = r'''
void main() {
  for (int i = 0; i < 4; i++) {
    print('hello ${i}')
  }
}
''';
  http.post("https://liftoff-dev.appspot.com/api/analyze", body: data) //
  .then((res) => res.body) //
  .then(JSON.decode) //
  .then(print);

  var result = [{
      "kind": "error",
      "line": 3,
      "message": "Expected to find ';'",
      "charStart": 68,
      "charLength": 1
    }];
}

void compileTest() {
  var data = r'''
void main() {
  for (int i = 0; i < 4; i++) {
    print('hello ${i}');
  }
}
''';
  http.post("https://liftoff-dev.appspot.com/api/compile", body: data) //
  .then((res) => res.body).then(print);
}
