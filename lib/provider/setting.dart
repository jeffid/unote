import 'package:flutter/material.dart';
// import 'package:preferences/preference_service.dart';

// import '/constant/app.dart' as ca;

class SettingNotifier extends ChangeNotifier {
  bool? _isShowSubtitle;
  bool? get isShowSubtitle => _isShowSubtitle;
  void set isShowSubtitle(bool? v) {
    _isShowSubtitle = v;
    notifyListeners();
  }
}
