import 'package:flutter/material.dart';
import 'package:preferences/preference_service.dart';

///
class ThemeNotifier with ChangeNotifier {
  ///
  ThemeNotifier() {
    _accentColor =
        Color(PrefService.getInt('theme_color') ?? _defaultThemeColor.value);
    _setOnAccentColor(_accentColor);

    updateTheme(PrefService.getString('theme') ?? 'light');
  }

  ThemeType currentTheme = ThemeType.light;

  late ThemeData _currentThemeData;

  ThemeData get currentThemeData => _currentThemeData;

  late Color _accentColor, _onAccentColor;

  Color get accentColor => _accentColor;

  Color _defaultThemeColor = Color(0xff21d885);

  Color get defaultThemeColor => _defaultThemeColor;

  set accentColor(Color color) {
    _accentColor = color;
    _setOnAccentColor(_accentColor);
    updateTheme();
  }

  ///
  void _setOnAccentColor(Color color) {
    _onAccentColor =
        ThemeData.estimateBrightnessForColor(color) == Brightness.light
            ? Colors.grey.shade900
            : Colors.white;
  }

  ///
/*  void switchTheme() => currentTheme == ThemeType.light
      ? currentTheme = ThemeType.dark
      : currentTheme = ThemeType.light; */

  ///
  updateTheme([String? theme]) {
    Brightness brightness;
    Color bgColor, onBgColor, dividerColor;

    switch (theme) {
      case 'light':
        currentTheme = ThemeType.light;
        break;
      case 'dark':
        currentTheme = ThemeType.dark;
        break;
      case 'black':
        currentTheme = ThemeType.black;
        break;
    }

    if (currentTheme == ThemeType.light) {
      brightness = Brightness.light;
      bgColor = Colors.white;
      onBgColor = Colors.black;
      dividerColor = Colors.grey.shade300;
    } else if (currentTheme == ThemeType.dark) {
      brightness = Brightness.dark;
      bgColor = Colors.grey.shade900;
      onBgColor = Colors.white;
      dividerColor = Colors.grey.shade800;
    } else {
      brightness = Brightness.dark;
      bgColor = Colors.black;
      onBgColor = Colors.grey.shade100;
      dividerColor = Colors.grey.shade800;
    }

    ColorScheme colorScheme = ColorScheme(
      brightness: brightness,
      primary: Colors.blue,
      onPrimary: Colors.black,
      // secondary: Colors.blue.shade100,
      secondary: _accentColor,
      onSecondary: _onAccentColor,
      error: Colors.red.shade100,
      onError: Colors.red,
      surface: _accentColor, // title bar bg color
      onSurface: onBgColor, // ListTile
    );

    _currentThemeData = ThemeData(
        brightness: brightness,
        // scaffoldBackgroundColor: theme == 'black' ? Colors.black : null,
        // // backgroundColor: theme == 'black' ? Colors.black : null,
        // dialogBackgroundColor: theme == 'black' ? Colors.black : null,
        // canvasColor: theme == 'black' ? Colors.black : null,
        // cardColor: theme == 'black' ? Colors.black : null,

        scaffoldBackgroundColor: bgColor,
        dialogBackgroundColor: bgColor,
        canvasColor: bgColor,
        cardColor: bgColor,
        dividerColor: dividerColor,

        // accentColor: _accentColor,
        colorScheme: colorScheme,
        hoverColor: _accentColor.withOpacity(0.5),

        // primaryColor: _accentColor,
        // primaryColor: Colors.cyan, // unused
        // highlightColor: _accentColor,
        // highlightColor: Colors.green.shade400, // unused

        // focusColor: Colors.blue,
        // hintColor: Colors.blue.shade900,
        // indicatorColor: Colors.green.shade900,

        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: _accentColor,
        ),
        buttonTheme: ButtonThemeData(
          textTheme: ButtonTextTheme.primary,
          buttonColor: _accentColor,
        ),
        textTheme: TextTheme(
          // labelLarge: TextStyle(color: _accentColor),
          labelLarge: TextStyle(color: Colors.purple), // unused
          // bodySmall: TextStyle(color: Colors.amber.shade900),
        ),
        appBarTheme: AppBarTheme(
          foregroundColor: colorScheme.onSecondary,
          // titleTextStyle: TextStyle(color: Colors.green),
        ));

    notifyListeners();
  }

  // ColorFilter _contrastColorFilter({double contrast = 1.0}) {
  // return ColorFilter.matrix([
  //   contrast, 0, 0, 0, 0,
  //   0, contrast, 0, 0, 0,
  //   0, 0, contrast, 0, 0,
  //   0, 0, 0, 1, 0,
  // ]);
}

///
enum ThemeType { light, dark, black }
