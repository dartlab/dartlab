// Copyright (c) 2015, DartLab.org. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

part of dartlab;

class GistClient {
  static final String apiUrl = "https://api.github.com/gists";

  Future<Workbench> load(String id) {
    return HttpRequest.getString("$apiUrl/$id") //
    .then(JSON.decode) //
    .then(_gistDecode).catchError((_) => id = '');
  }

  Future<Workbench> save(Workbench workbench) {
    workbench.description = workbench.description.isEmpty ? "A DartLab experience!" : workbench.description;

    //var url = "https://api.github.com/gists/$id".replaceAll(new RegExp(r'/$'), '');

    //HttpRequest.request(url, method: id.isEmpty ? "POST" : "PATCH", sendData: JSON.encode(data)) //
    return HttpRequest.request(apiUrl, method: "POST", sendData: JSON.encode(_gistEncode(workbench))) //
    .then((HttpRequest req) => req.responseText).then(JSON.decode) //
    .then((data) => workbench..id = data['id']);
  }

  Map _gistFileEncode(String filename, String content) => content.isEmpty ? {} : {
    filename: {
      "content": content
    }
  };

  Map _gistEncode(Workbench workbench) {
    return {
      "description": workbench.description,
      "public": true,
      "files": {}
          ..addAll(_gistFileEncode("index.html", workbench.html))
          ..addAll(_gistFileEncode("style.css", workbench.css))
          ..addAll(_gistFileEncode("main.dart", workbench.dart))
          ..addAll(_gistFileEncode("pubspec.yaml", workbench.pubspec))
          ..addAll(_gistFileEncode("README.md", workbench.readme))
          ..addAll(_gistFileEncode(".gitignore", workbench.gitignore))
    };
  }

  Workbench _gistDecode(Map data) {
    Map<String, Map> files = data['files'];
    Workbench workbench = new Workbench()
        ..id = data['id']
        ..description = data['description']
        ..body = files["index.html"] != null ? _htmlDecode(_gistFileDecode(files, "index.html")) :  _gistFileDecode(files, "body.html")
        ..css = _gistFileDecode(files, "style.css")
        ..dart = _gistFileDecode(files, "main.dart");
    return workbench;
  }

  String _htmlDecode(String html) {
    return html5lib.parse(html).querySelector("body").innerHtml.trim();
  }

  String _gistFileDecode(Map<String, Map> files, String filename, {String defaultValue: ''}) => files[filename] == null ? defaultValue : files[filename]['content'];
}
