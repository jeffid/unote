import 'dart:io';

///
class Note {
  String title = '';
  late File file;
  late DateTime created;
  late DateTime modified;
  List<String> tags = [];
  List<String> attachments = [];
  bool pinned = false;
  bool favorite = false;
  bool deleted = false;

  bool isMillisecond = false;
  bool idUpdatedInsteadOfModified = false;
  Map<String, dynamic> additionalFrontMatterKeys = {};

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
}
