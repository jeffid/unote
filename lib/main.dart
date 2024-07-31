// @dart=3.4

// import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:preferences/preference_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app_info/flutter_app_info.dart';

import '/provider/theme.dart';
import '/constants/app_constants.dart';
import '/page/note_list.dart';

bool isPreviewFeatureEnabled = true;

late AppInfoData appInfo;

late ThemeData themeData;

final logger = Logger();

///
main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PrefService.init(prefix: 'pref_');
  /* 
  await initializeDateFormatting("en_US", null); */
  Intl.defaultLocale = 'en_US';

  runApp(
    // ChangeNotifierProvider<ThemeNotifier>(
    //   create: (_) => ThemeNotifier(),
    //   child: App(),
    // ),
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
    themeData = Provider.of<ThemeNotifier>(context).currentThemeData;

    return MaterialApp(
      title: appName,
      theme: Provider.of<ThemeNotifier>(context).currentThemeData,
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
