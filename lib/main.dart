// @dart=3.4

import 'package:flutter/material.dart';
import 'package:preferences/preference_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app_info/flutter_app_info.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:shared_preferences/shared_preferences.dart';

import '/constant/app.dart' as ca;
import '/generated/l10n.dart';
import '/page/note_list.dart';
import '/provider/theme.dart';
// import '/utils/logger.dart';

bool isPreviewFeatureEnabled = true;

late AppInfoData appInfo;

late ThemeData themeData;

///
main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PrefService.init(prefix: ca.prefix);

  String lang =
      (await PrefService.getString(ca.lang)) ?? Intl.getCurrentLocale();
  Intl.defaultLocale =
      ca.supportedLang.contains(lang) ? lang : ca.supportedLang.first;
  // Intl.defaultLocale = 'en_US';

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
      title: ca.appName,
      theme: themeData,
      home: NoteListPage(
        isFirstPage: true,
        filterTag: '',
        searchText: '',
      ),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        //  FlutterI18nDelegate(path: 'assets/i18n', fallbackFile: 'en'),
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      supportedLocales: S.delegate.supportedLocales,
    );
  }
}
