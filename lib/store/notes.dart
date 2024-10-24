import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
// import 'package:path_provider/path_provider.dart';
import 'package:preferences/preference_service.dart';
import 'package:uuid/uuid.dart';

import '/constant/app.dart' as ca;
import '/data/tutorial.dart';
import '/generated/l10n.dart';
import '/model/note.dart';
import '/store/persistent.dart';
import '/utils/logger.dart';

class NotesStore {
  //
  late Directory notesDir, assetsDir, imagesDir;

  String syncMethod = '';

  String searchText = '';

  List<Note> allNotes = [];

  List<Note> shownNotes = [];

  String _currentTag = '';

  Set<String> allTags = {};

  List<String> rootTags = [];

  String get currentTag => _currentTag;

  set currentTag(String newTag) {
    _currentTag = newTag;
    PrefService.setString(ca.currentTag, newTag);
  }

  String get syncMethodName {
    switch (syncMethod) {
      case 'webdav':
        return 'WebDav';
      default:
        return 'No';
    }
  }

  bool get isDendronMode => PrefService.getBool(ca.isDendronMode) ?? false;

  String get subNoteDir => isDendronMode ? '/notes' : '';

  String get subAssetsDir => '$subNoteDir/assets'; // attachments

  ///
  // void init() {
  //   syncMethod = PrefService.getString(ca.sync) ?? '';
  // }

  ///
  Future<Note> createNote([String content = '', String title = '']) async {
    Note newNote = Note();

    // new title
    int i = 0;
    List<String> filenames = [];
    for (Note note in allNotes) {
      filenames.add(p.basenameWithoutExtension(note.file.path));
    }
    if (title.isEmpty) title = S.current.Untitled; // default
    while (true) {
      i++;
      if (i > 1) title += ' ($i)';

      if (!filenames.contains(title)) break;
    }
    newNote.title = title;

    if (isDendronMode) {
      newNote.header = {
        'id': Uuid().v4(),
        'desc': '',
      };
    }

    newNote.file = File('${notesDir.path}/${newNote.title}.md');
    allNotes.add(newNote);

    await PersistentStore.saveNote(newNote, '# ${newNote.title}\n\n$content');

    return newNote;
  }

  ///
  Future createTutorialNotes() async {
    String lang = Intl.getCurrentLocale();

    for (String fileName in Tutorial.notesNames) {
      File('${notesDir.path}/$fileName').writeAsStringSync(
          await rootBundle.loadString('assets/tutorial/notes/$lang/$fileName'));
    }
  }

  ///
  Future createTutorialAssets() async {
    for (String fileName in Tutorial.assetsNames) {
      File('${assetsDir.path}/$fileName').writeAsBytesSync(
          (await rootBundle.load('assets/tutorial/assets/$fileName'))
              .buffer
              .asUint8List());
    }
  }

  ///
  Future<void> listNotes() async {
    // reset list
    allNotes = [];

    String dataPath = (await dataDirectory()).path;

    notesDir = Directory('$dataPath$subNoteDir');
    PrefService.setString(ca.notesPath, notesDir.path);
    if (!notesDir.existsSync()) {
      notesDir.createSync(recursive: true);
      if (!isDendronMode) await createTutorialNotes();
    }

    assetsDir = Directory('$dataPath$subAssetsDir');
    imagesDir = Directory('${assetsDir.path}/images');
    PrefService.setString(ca.assetsPath, assetsDir.path);
    if (!assetsDir.existsSync()) {
      imagesDir.createSync(recursive: true);
      if (!isDendronMode) await createTutorialAssets();
    } else if (!imagesDir.existsSync()) {
      imagesDir.createSync();
    }

    DateTime start = DateTime.now();
    await _listNotesInFolder('');
    logger.d((DateTime.now().difference(start)));

    // _updateTagList();
  }

  ///
  /// - [path] empty or start with slash.
  Future<void> _listNotesInFolder(String path, {bool isSubDir = false}) async {
    logger.d(('_listNotesInFolder', notesDir, path, isSubDir));
    //
    await for (var entity in Directory('${notesDir.path}$path').list()) {
      final enPath = formatPath(entity.path);

      if (entity is File) {
        // only process markdown files
        if (!enPath.endsWith('.md')) continue;
        try {
          Note? note = await PersistentStore.readNote(entity);

          if (note != null) {
            if (PrefService.boolDefault(ca.canShowVirtualTags)) {
              note.tags.add(path.isEmpty ? '#/' : '#$path');
            }
            if (isDendronMode) {
              // path without extension
              String _p =
                  enPath.substring(notesDir.path.length, enPath.length - 3);

              // Dendron is separated by dot symbols
              note.tags.add('Dendron$_p'.replaceAll('.', '/'));
            }

            allNotes.add(note);
          }
        } catch (e) {
          final note = Note();
          note.title = 'ERROR - "$e" on parsing "${enPath}"';
          note.tags = ['ERROR'];
          note.attachments = [];

          note.pinned = true;
          note.favorite = true;
          note.deleted = false;

          allNotes.add(note);
        }
      } else if (entity is Directory) {
        final basename = p.basename(enPath);
        if (basename.startsWith('.')) continue;
        if (enPath.startsWith(assetsDir.path)) continue;

        await _listNotesInFolder(path + '/' + basename, isSubDir: true);
      }
    }
  }

  ///
  void updateTagList() {
    // reset tags
    allTags = {};

    for (Note note in allNotes) {
      for (String tag in note.tags) {
        allTags.add(tag);
      }
    }

    final Set<String> tmpRootTags = {};

    for (String tag in allTags) {
      tmpRootTags.add(tag.split('/').first);
    }

    rootTags = tmpRootTags.toList();
    rootTags.sort();
  }

  ///
  List<String> getSubTags(String tagPath) {
    Set<String> subTags =
        allTags.where((t) => t != tagPath && t.startsWith('$tagPath/')).toSet();
    // next level tags
    List<String> subTagsList = subTags
        .map((String t) {
          t = t.replaceFirst('$tagPath/', ''); // Remove the front part
          t = t.split('/').first;
          return t;
        })
        .where((String t) => t.isNotEmpty)
        .toSet() // Remove Duplicates
        .toList();

    if (PrefService.getBool(ca.isSortTags) ?? true) {
      subTagsList.sort();
    }

    return subTagsList;
  }

  ///
  void filterAndSortNotes() {
    //shownNotes = List.from(allNotes);
    shownNotes = _filterByTag(allNotes, currentTag);

    if (searchText.isNotEmpty) {
      List keywords =
          searchText.split(' ').map((s) => s.toLowerCase()).toList();

      if (PrefService.getBool(ca.canSearchContent) ?? true) {
        List<String> toRemove = [];

        for (Note note in shownNotes) {
          String content = note.file.readAsStringSync().toLowerCase();

          bool _contains = true;
          for (String keyword in keywords) {
            if (!content.contains(keyword)) {
              _contains = false;
              break;
            }
          }
          if (!_contains) {
            toRemove.add(note.title);
          }
        }
        shownNotes.removeWhere((n) => toRemove.contains(n.title));
      } else {
        shownNotes.retainWhere((note) {
          String noteTitle = note.title.toLowerCase();
          for (String keyword in keywords) {
            if (!noteTitle.contains(keyword)) return false;
          }
          return true;
        });
      }
    }

    shownNotes.sort((a, b) {
      if (a.pinned ^ b.pinned) {
        return a.pinned ? -1 : 1;
      } else {
        int value = 0;

        switch (PrefService.getString(ca.sortKey) ?? ca.sortByTitle) {
          case ca.sortByTitle:
            value = a.title.compareTo(b.title);
            break;
          case ca.sortByCreated:
            value = a.created.compareTo(b.created);
            break;
          case ca.sortByUpdated:
            value = a.updated.compareTo(b.updated);
            break;
        }
        if (!(PrefService.getBool(ca.isSortAsc) ?? true)) value *= -1;

        return value;
      }
    });
  }

  ///
  List<Note> _filterByTag(List<Note> notes, String cTag) {
    return notes.where((note) => note.hasTag(cTag)).toList();
  }

  ///
  int countNotesWithTag(List<Note> notes, String tag) {
    int count = 0;
    notes.forEach((note) {
      if (note.hasTag(tag)) count++;
    });
    return count;
  }

  ///
  Note getNote(String title) {
    return allNotes.firstWhere((n) => n.title == title);
  }

  ///
  Future<String?> syncNow() async {
/*     switch (syncMethod) {
      case 'webdav':
        return await WebdavSync().syncFiles(this);
    } */
    return null;
  }

  ///
  Future<void> refresh() async {
    await listNotes();
    filterAndSortNotes();
    updateTagList();
  }
}
