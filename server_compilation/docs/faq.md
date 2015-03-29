Frequently Asked Questions (FAQ)
--------------------------------

### Q. Why DartLab?
DartLab lets you to test your Dart code directly in your browser.
Save the code for future usage or to share it to other people.

### Q. Why is it taking so long to execute my Dart code?
Dart works by first being compiled down to JavaScript before being executed in the browser. You can get your code to execute extra fast by trying DartLab in [Dartium](https://www.dartlang.org/tools/dartium/) to run your Dart code natively. Dartium is a technical preview of the Chromium browser with the Dart VM used to speed up Dart development.

### Q. Will the Dart VM make it into my browser?
The Dart team have choosen to focus their efforts on improving the compilation time and multibrowser support rather than adding a new VM to Chrome [[1]](http://news.dartlang.org/2015/03/dart-for-entire-web.html). The Dart team has no current plans of integrating the Dart VM into Chrome.

### Q. Where are my DartLab experiments saved?
All DartLab experiments are persisted on [Gist](https://gist.github.com).
You can find it on Gist reusing the same `id`:

    http://dartlab.org/#:id
    https://gist.github.com/anonymous/:id
