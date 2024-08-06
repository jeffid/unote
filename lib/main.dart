// @dart=3.4

import 'package:flutter/material.dart';
import 'package:preferences/preference_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app_info/flutter_app_info.dart';

import '/constants/app_constants.dart';
import '/page/note_list.dart';
import '/provider/theme.dart';
// import '/utils/logger.dart';

bool isPreviewFeatureEnabled = true;

late AppInfoData appInfo;

late ThemeData themeData;


///
main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PrefService.init(prefix: 'pref_');
  /* 
  await initializeDateFormatting("en_US", null); */
  Intl.defaultLocale = 'en_US';

  runApp(
    AppInfo(
      data: await AppInfoData.get(),
      child: ChangeNotifierProvider<ThemeNotifier>(
        create: (_) => ThemeNotifier(),
        child: App(),
      ),
    ),
  );
}

class App extends StatelessWidget {
  ///
  @override
  Widget build(BuildContext context) {
    appInfo = AppInfo.of(context);
    themeData = Provider.of<ThemeNotifier>(context).themeData;

    return MaterialApp(
      title: appName,
      theme: themeData,
      home: NoteListPage(
        isFirstPage: true,
        filterTag: '',
        searchText: '',
      ),
/*       localizationsDelegates: [
        FlutterI18nDelegate(path: 'assets/i18n', fallbackFile: 'en'),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ], */
      /* debugShowCheckedModeBanner: false, */
    );
  }
}
