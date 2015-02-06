// Copyright (c) 2015, DartLab.org. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

part of dartlab;

class GistClient {
  static final String apiUrl = "https://api.github.com/gists";

  Future<Workbench> load(String id) {
    return HttpRequest.getString("$apiUrl/$id") //
    .then(JSON.decode) //
    .then((data) {
      Workbench workbench = new Workbench();
      workbench.id = data['id'];
      workbench.description = data['description'];

      Map<String, Map> files = data['files'];
      workbench.body = getFile(files, "body.html");
      workbench.css = getFile(files, "style.css");
      workbench.dart = getFile(files, "main.dart");

      Map metadataJson = {};
      try {
        metadataJson = JSON.decode(getFile(files, ".metadata.json", defaultValue: '{}')) as Map;
      } catch (ignore) {}
      workbench.metadata = new Metadata.fromJson(metadataJson);

      return workbench;
    }).catchError((_) => id = '');
  }

  Future<Workbench> save(Workbench workbench) {
    if (workbench.id.isNotEmpty) workbench.metadata.history.add(workbench.id);
    workbench.description = workbench.description.isEmpty ? "A DartLab experience!" : workbench.description;

    var data = {
      "description": workbench.description,
      "public": true,
      "files": {}
          ..addAll(createFile(".metadata.json", new JsonEncoder.withIndent("  ").convert(workbench.metadata)))
          ..addAll(createFile("body.html", workbench.body))
          ..addAll(createFile("style.css", workbench.css))
          ..addAll(createFile("main.dart", workbench.dart))
    };

    //var url = "https://api.github.com/gists/$id".replaceAll(new RegExp(r'/$'), '');

    //HttpRequest.request(url, method: id.isEmpty ? "POST" : "PATCH", sendData: JSON.encode(data)) //
    return HttpRequest.request(apiUrl, method: "POST", sendData: JSON.encode(data)) //
    .then((HttpRequest req) => req.responseText).then(JSON.decode) //
    .then((data) => workbench..id = data['id']);
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
