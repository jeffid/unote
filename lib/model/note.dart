import 'dart:io';

import '/store/encryption.dart';

/// [Note] data model for notes.
///
/// markdown file content example：
/// ```md
/// ---
/// title: 01 - The Data Directory
/// tags: [Basics, Notebooks/Tutorial]
/// created: 1723268317678
/// updated: 1723268317678
/// ---
///
/// # H1 - The Data Directory
/// content text...
/// ## H2
/// ```
///
class Note {
  ///
  Note({File? f}) {
    if (f != null) file = f;
  }

  String title = '';

  late File file;

  DateTime created = DateTime.now();

  DateTime updated = DateTime.now();

  List<String> tags = [];

  List<String> attachments = [];

  bool pinned = false;

  bool favorite = false;

  bool deleted = false;

  bool encrypted = false;

  /// Whether decryption was successful with the incoming key
  bool isDecryptSuccess = false;

  /// Document content header data(e.g., title, created)
  Map<String, dynamic> header = {};

  /// Encryption tool
  Encryption? encryption;

  /// Retry decryption time list.
  List<DateTime> _retryAt = [];

  /// Cooling time deadline after the maximum number of decryption retries has been reached.
  DateTime? _cdEndAt;

  /// The maximum number of decryption attempts within a period.
  static const int maxRetryNum = 3;

  /// The time period between decryption attempts. unit: seconds.
  static const int retryPeriod = 60;

  /// The cooling down time after the maximum number of decryption retries has been reached. unit: seconds.
  static const int retryCd = 180;

  ///
  static const List<String> validHeaderKeys = [
    'title',
    'updated',
    'created',
    'tags',
    'attachments',
    'pinned',
    'favorite',
    'deleted',
    'encrypted',
  ];

  ///
  bool hasTag(String cTag) {
    if (cTag != '') {
      if (cTag == 'Trash') {
        return deleted;
      } else if (cTag == 'Favorites') {
        return favorite;
      } else if (cTag == 'Untagged') {
        return tags.isEmpty;
      } else {
        bool hasTag = false;
        for (String tag in tags) {
          if (tag.startsWith(cTag)) {
            hasTag = true;
            break;
          }
        }
        if (!hasTag) return false;
      }
    } else {}
    if (deleted) return false;
    //if (note.deleted) return false;
    return true;
  }

  ///
  (int, bool) canRetry([bool addNow = true]) {
    DateTime now = DateTime.now();
    bool can = false;
    int total = _retryAt.length;
    int cd = 0;

    if (_cdEndAt != null) cd = _cdEndAt!.difference(now).inSeconds;

    if (_cdEndAt == null &&
        total >= maxRetryNum &&
        now.difference(_retryAt[total - maxRetryNum]).inSeconds <=
            retryPeriod) {
      // `retryCd` greater than `retryPeriod` , `cd` greater than 0
      cd = retryCd - now.difference(_retryAt.last).inSeconds;
      _cdEndAt = _retryAt.last.add(Duration(seconds: cd));
    }

    if (_retryAt.isEmpty ||
        total < maxRetryNum ||
        cd <= 0 ||
        (_cdEndAt != null && now.isAfter(_cdEndAt!))) {
      // reset the cooling time.
      _cdEndAt = null;

      // add the current time to the retry list.
      if (addNow) _retryAt.add(now);

      // trim the list to keep the size within the limit.
      if (_retryAt.length >= maxRetryNum * 2) {
        _retryAt = _retryAt.sublist(_retryAt.length - maxRetryNum);
      }

      can = true;
    }

    return (cd, can);
  }
}
