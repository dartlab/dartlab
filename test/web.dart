// Copyright (c) 2015, DartLab.org. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library dartlab.web_test;

import 'package:unittest/html_config.dart' show useHtmlConfiguration;

import 'src/gist_client_test.dart' as gist_client_test;

void main() {
  useHtmlConfiguration();

  gist_client_test.main();
}
