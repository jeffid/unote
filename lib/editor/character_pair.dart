import 'package:flutter/services.dart';

import '/utils/logger.dart';

///
class CharacterPair implements TextInputFormatter {
  /// Creates a CharacterPair with the ability to toggle it on/off with
  /// [enablePairing] which should be derived from the settings. This is final
  /// as a new instance is created when the note is navigated to again.
  CharacterPair({this.enablePairing = true});

  /// All the characters that can be paired, and their pairing character.
  static const pairedChar = {
    // English punctuation
    '"': '"',
    "'": "'",
    '(': ')',
    '`': '`',
    '[': ']',
    '{': '}',
    '<': '>',
    // Chinese punctuation; There is an issue with probability not recognizing symbols.
    '“': '”',
    '‘': '’',
    '（': '）',
    '《': '》',
    '〈': '〉',
    '「': '」',
    '『': '』',
    '【': '】',
    '〖': '〗',
    // '': '',
  };

  ///
  final bool enablePairing;

  /// Gets the changed char from the new and old values.
  static (String, bool) changedChar(
      TextEditingValue oldVal, TextEditingValue newVal) {
    var oldSel = oldVal.selection;
    var newSel = newVal.selection;
    String char = '';
    bool isDel = (oldSel.start > newSel.start &&
        oldVal.text.length > newVal.text.length);
    if (oldVal.text == newVal.text) return (char, isDel);

    if (isDel && oldSel.start > 0) {
      char = oldVal.text.substring(oldSel.start - 1, oldSel.start);
    }

    if (!isDel && newSel.start > 0) {
      char = newVal.text.substring(newSel.start - 1, newSel.start);
    }

    return (char, isDel);
  }

  ///
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldVal, TextEditingValue newVal) {
    if (enablePairing) {
      final (char, isDel) = changedChar(oldVal, newVal);

      if (pairedChar.containsKey(char)) {
        return isDel
            ? _delPairChar(char, oldVal, newVal)
            : _addPairChar(char, oldVal, newVal);
      }
    }

    return newVal;
  }

  ///
  TextEditingValue _delPairChar(
      String char, TextEditingValue oldVal, TextEditingValue newVal) {
    final newSel = newVal.selection;
    final before = newVal.text.substring(0, newSel.start);
    String after = newVal.text.substring(newSel.end);
    int offset = after.startsWith(pairedChar[char]!) ? 1 : 0;
    if (offset > 0) after = after.substring(offset);

    return newVal.copyWith(
      text: '$before$after',
      selection: newVal.selection.copyWith(
        baseOffset: newSel.baseOffset,
        extentOffset: newSel.extentOffset,
      ),
    );
  }

  /// Pairs a character with the first character being [char] and the second
  /// corresponding to its value in [pairedChar].
  TextEditingValue _addPairChar(
      String char, TextEditingValue oldVal, TextEditingValue newVal) {
    final oldSel = oldVal.selection;
    final content = oldVal.text.substring(oldSel.start, oldSel.end);

    final newSel = newVal.selection;
    final before = newVal.text.substring(0, newSel.start);
    final after = newVal.text.substring(newSel.end);

    return newVal.copyWith(
      text: '$before$content${pairedChar[char]}$after',
      selection: newVal.selection.copyWith(
        baseOffset: newSel.baseOffset,
        extentOffset: newSel.extentOffset + content.length,
      ),
    );

    // return TextEditingValue(
    //   text: '$before$content${pairedChar[char]}$after',
    //   composing: oldVal.composing,
    //   selection: TextSelection(
    //     baseOffset: newSel.baseOffset,
    //     extentOffset: newSel.extentOffset + content.length,
    //     affinity: newSel.affinity,
    //     isDirectional: newSel.isDirectional,
    //   ),
    // );
  }
}
