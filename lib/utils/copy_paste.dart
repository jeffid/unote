import 'package:flutter/services.dart';

///
class CopyPaste {
  /// set clipboard text
  static void copy(String? text) {
    if (text == null) return;
    Clipboard.setData(ClipboardData(text: text));
  }

  /// get clipboard text
  static Future<String?> paste() async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text;
  }
}
