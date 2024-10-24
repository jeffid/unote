import 'package:flutter/material.dart';
import 'package:preferences/preference_service.dart';

import '/constant/app.dart' as ca;
///
class ThemeNotifier with ChangeNotifier {
  ///
  ThemeNotifier() {
    _accentColor =
        Color(PrefService.getInt(ca.themeColor) ?? _defaultThemeColor.value);
    _setOnAccentColor(_accentColor);

    updateTheme(PrefService.getString(ca.theme) ?? ThemeType.light.name);
  }

  static const Color _defaultThemeColor = Color(0xFF2196F3); // blue

  static Color get defaultThemeColor => _defaultThemeColor;

  ThemeType currentTheme = ThemeType.light;

  late ThemeData _themeData;

  ThemeData get themeData => _themeData;

  late Color _accentColor, _onAccentColor;

  Color get accentColor => _accentColor;

  set accentColor(Color color) {
    _accentColor = color;
    _setOnAccentColor(_accentColor);
    updateTheme();
  }
  
  Color get onAccentColor => _onAccentColor;

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
      onBgColor = Colors.grey.shade200;
      dividerColor = Colors.grey.shade800;
    }

    ColorScheme colorScheme = ColorScheme(
      brightness: brightness,
      primary: Colors.blue,
      onPrimary: Colors.black,
      // secondary: Colors.blue.shade100,
      secondary: _accentColor,
      // onSecondary: _onAccentColor,
      onSecondary: onBgColor, //
      error: Colors.red,
      onError: Colors.redAccent,
      surface: _accentColor, // title bar bg color
      onSurface: onBgColor, // ListTile
      surfaceContainer: bgColor, // PopupMenuButton bg,
    );

    _themeData = ThemeData(
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bgColor,
      dialogBackgroundColor: bgColor,
      canvasColor: bgColor,
      cardColor: bgColor,
      dividerColor: dividerColor,
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
      // textTheme: TextTheme(
      //   // labelLarge: TextStyle(color: _accentColor),
      //   labelLarge: TextStyle(color: Colors.purple), // unused
      //   // bodySmall: TextStyle(color: Colors.amber.shade900),
      // ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
        // titleTextStyle: TextStyle(color: Colors.green),
      ),
      // switchTheme: SwitchThemeData( // no effect
      //   thumbColor:
      //       WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
      //     if (states.contains(WidgetState.selected)) {
      //       return colorScheme.secondary;
      //     }
      //     return colorScheme.secondary;
      //   }),
      //   trackColor:
      //       WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
      //     if (states.contains(WidgetState.selected)) {
      //       return colorScheme.secondary.withOpacity(0.5);
      //     }
      //     return dividerColor.withOpacity(0.5);
      //   }),
      //   overlayColor:
      //       WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
      //     if (states.contains(WidgetState.selected)) {
      //       return colorScheme.secondary.withOpacity(0.1);
      //     }
      //     return dividerColor.withOpacity(0.1);
      //   }),
      //   trackOutlineColor: WidgetStateProperty.resolveWith<Color>(
      //       (Set<WidgetState> states) => dividerColor),
      //   trackOutlineWidth: WidgetStateProperty.resolveWith<double>(
      //       (Set<WidgetState> states) => 1),
      // ),
    );

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
