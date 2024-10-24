import 'package:flutter/material.dart';
import 'package:flutter_app_info/flutter_app_info.dart';
import 'package:url_launcher/url_launcher.dart';

import '/constant/app.dart' as ca;
import '/main.dart';
import '/generated/l10n.dart';
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
      appBar: AppBar(title: Text(S.current.About)),
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
              child: Text(S.current.GitHub_Repo),
              onPressed: () {
                launchUrl(Uri.parse(ca.gitHubRepo));
              },
            ),
          ],
        ),
      ),
    );
  }
}
