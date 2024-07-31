import 'package:flutter/material.dart';
import 'package:flutter_app_info/flutter_app_info.dart';
import 'package:url_launcher/url_launcher.dart';

import '/main.dart';
import '/store/notes.dart';

class AboutPage extends StatefulWidget {
  final NotesStore store;
  AboutPage(this.store);
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final AppPackageInfo info = appInfo.package;

  ///
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('About')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Column(
              children: <Widget>[
                Text('${info.appName}'),
                Text('${info.packageName}'),
                SizedBox(
                  height: 8,
                ),
                Text('Version ${info.versionWithoutBuild}'),
                Text('Build ${info.version}'),
              ],
            ),
            SizedBox(
              height: 16,
            ),
            ElevatedButton(
              child: Text('GitHub Repo'),
              onPressed: () {
                launchUrl(Uri.parse('https://github.com/inote-flutter/inote'));
              },
            ),
          ],
        ),
      ),
    );
  }
}
