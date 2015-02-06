// Copyright (c) 2015, DartLab.org. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

part of dartlab;

class Workbench extends Observable {
  @observable String id = '';
  @observable String description = '';
  @observable String body = '';
  @observable String css = '';
  @observable String dart = '';
  @observable Metadata metadata = new Metadata();
}

class Metadata extends Observable {
  final String origin = 'dartlab.org';
  final String url = 'http://dartlab.org/#:gistId';
  final List<String> history;

  Metadata() : history = toObservable([]);
  Metadata.fromJson(Map m) : history = toObservable(m['history'] is List ? m['history'] : []);
  Map toJson() => {
    'origin': origin,
    'url': url,
    'history': history
  };
}
