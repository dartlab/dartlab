import 'package:http/http.dart' as http;
import 'dart:convert';

main() {
  var data = {
    "description": "the description for this gist",
    "public": true,
    "files": {
      "file1.txt": {
        "content": "String file contents"
      },
      "file2.txt": {
        "content": "\u200B"
      }
      //"file2.txt": null
    }
  };

  http.post("https://api.github.com/gists", body: JSON.encode(data)) //
  .then((res) => res.body) // .then(JSON.decode) //
  .then(print);

  var res = {
    "url": "https://api.github.com/gists/533505e07f04a59b907d",
    "forks_url": "https://api.github.com/gists/533505e07f04a59b907d/forks",
    "commits_url": "https://api.github.com/gists/533505e07f04a59b907d/commits",
    "id": "533505e07f04a59b907d",
    "git_pull_url": "https://gist.github.com/533505e07f04a59b907d.git",
    "git_push_url": "https://gist.github.com/533505e07f04a59b907d.git",
    "html_url": "https://gist.github.com/533505e07f04a59b907d",
    "files": {
      "file1.txt": {
        "filename": "file1.txt",
        "type": "text/plain",
        "language": "Text",
        "raw_url": "https://gist.githubusercontent.com/anonymous/533505e07f04a59b907d/raw/b087a4c57f47ffad4025004869d7366ddc82d0d1/file1.txt",
        "size": 20,
        "truncated": false,
        "content": "String file contents"
      }
    },
    "public": true,
    "created_at": "2014-12-20T21:36:47Z",
    "updated_at": "2014-12-20T21:36:47Z",
    "description": "the description for this gist",
    "comments": 0,
    "user": null,
    "comments_url": "https://api.github.com/gists/533505e07f04a59b907d/comments",
    "forks": [],
    "history": [{
        "user": {
          "login": "invalid-email-address",
          "id": 148100,
          "avatar_url": "https://avatars.githubusercontent.com/u/148100?v=3",
          "gravatar_id": "",
          "url": "https://api.github.com/users/invalid-email-address",
          "html_url": "https://github.com/invalid-email-address",
          "followers_url": "https://api.github.com/users/invalid-email-address/followers",
          "following_url": "https://api.github.com/users/invalid-email-address/following{/other_user}",
          "gists_url": "https://api.github.com/users/invalid-email-address/gists{/gist_id}",
          "starred_url": "https://api.github.com/users/invalid-email-address/starred{/owner}{/repo}",
          "subscriptions_url": "https://api.github.com/users/invalid-email-address/subscriptions",
          "organizations_url": "https://api.github.com/users/invalid-email-address/orgs",
          "repos_url": "https://api.github.com/users/invalid-email-address/repos",
          "events_url": "https://api.github.com/users/invalid-email-address/events{/privacy}",
          "received_events_url": "https://api.github.com/users/invalid-email-address/received_events",
          "type": "User",
          "site_admin": false
        },
        "version": "2cfaa6fe9bd36fce026a97d7a62ef095740848cd",
        "committed_at": "2014-12-20T21:36:47Z",
        "change_status": {
          "total": 1,
          "additions": 1,
          "deletions": 0
        },
        "url": "https://api.github.com/gists/533505e07f04a59b907d/2cfaa6fe9bd36fce026a97d7a62ef095740848cd"
      }]
  };
}
