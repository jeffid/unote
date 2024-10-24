// @dart=3.4

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:preferences/preference_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app_info/flutter_app_info.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '/constant/app.dart' as ca;
import '/generated/l10n.dart';
import '/page/note_list.dart';
import '/provider/setting.dart';
import '/provider/theme.dart';
import '/utils/logger.dart';
import './page/screen_lock.dart';

bool isPreviewFeatureEnabled = true;

late AppInfoData appInfo;

late ThemeData themeData;

late ColorScheme cs;

final GlobalKey<NavigatorState> navKey = new GlobalKey<NavigatorState>();

///
main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PrefService.init(prefix: ca.prefix);

  String lang = PrefService.getString(ca.lang) ?? Intl.getCurrentLocale();
  Intl.defaultLocale =
      ca.supportedLang.contains(lang) ? lang : ca.supportedLang.first;
  // Intl.defaultLocale = 'en_US';

  logger.d((
    // await getExternalStorageDirectory(),
    await getApplicationDocumentsDirectory(),
  ));

  runApp(
    AppInfo(
        data: await AppInfoData.get(),
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider<ThemeNotifier>(
                create: (_) => ThemeNotifier()),
            ChangeNotifierProvider<SettingNotifier>(
                create: (_) => SettingNotifier()),
          ],
          child: App(),
        )
        // ChangeNotifierProvider<ThemeNotifier>(
        //   create: (_) => ThemeNotifier(),
        //   child: App(),
        // ),
        ),
  );
}

class App extends StatelessWidget {
  ///
  @override
  Widget build(BuildContext context) {
    appInfo = AppInfo.of(context);
    themeData = Provider.of<ThemeNotifier>(context).themeData;
    cs = themeData.colorScheme;

    final bool hasLock = PrefService.stringDefault(ca.screenLockPwd).isNotEmpty;

    return MaterialApp(
      title: ca.appName,
      theme: themeData,
      home:
          hasLock ? ScreenLockPage(isFirst: true) : NoteListPage(isFirst: true),
      debugShowCheckedModeBanner: false,
      navigatorKey: navKey,
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
