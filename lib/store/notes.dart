import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:preferences/preference_service.dart';
import 'package:uuid/uuid.dart';

import '/constant/app.dart' as ca;
import '/data/samples.dart';
import '/generated/l10n.dart';
import '/model/note.dart';
import '/store/persistent.dart';
import '/utils/logger.dart';

class NotesStore {
  //
  late Directory appDir, notesDir, attachmentsDir;

  late String syncMethod;

  String? searchText;

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

  /* String subDirectoryNotes = ;
  String subDirectoryAttachments = ; */

  bool get isDendronMode => PrefService.getBool(ca.isDendronMode) ?? false;

  String get subNoteDir => isDendronMode ? '' : '/notes';

  String get subAssetsDir => '/assets';

  ///
  void init() {
    syncMethod = PrefService.getString(ca.sync) ?? '';
  }

  ///
  Future<Note> createNewNote([String content = '']) async {
    Note newNote = Note();
    int i = 1;
    while (true) {
      String title = S.current.Untitled;
      if (i > 1) title += ' ($i)';

      bool exists = false;

      for (Note note in allNotes) {
        if (title == note.title) {
          exists = true;
          break;
        }
      }

      if (!exists) {
        newNote.title = title;
        break;
      }

      i++;
    }

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
    for (String fileName in Samples.tutorialNotes) {
      File('${notesDir.path}/$fileName').writeAsStringSync(
          await rootBundle.loadString('assets/tutorial/notes/$fileName'));
    }
  }

  ///
  Future createTutorialAttachments() async {
    for (String fileName in Samples.tutorialAttachments) {
      File('${attachmentsDir.path}/$fileName').writeAsBytesSync(
          (await rootBundle.load('assets/tutorial/attachments/$fileName'))
              .buffer
              .asUint8List());
    }
  }

  ///
  Future listNotes() async {
    appDir = await getApplicationDocumentsDirectory();
    Directory directory;

    if (PrefService.getBool(ca.isExternalDirectoryEnabled) ?? false) {
      directory = Directory(PrefService.getString(ca.externalDirectory) ?? '');
    } else {
      directory = appDir;
    }
    PrefService.setString(ca.dataDirectory, directory.path);

    // print(isDendronModeEnabled);

    notesDir = Directory('${directory.path}$subNoteDir');

    PrefService.setString(ca.notesDirectory, notesDir.path);

    if (!notesDir.existsSync()) {
      notesDir.createSync();
      if (!isDendronMode) await createTutorialNotes();
    }

    attachmentsDir = Directory('${directory.path}$subAssetsDir');
    PrefService.setString(ca.assetsDirectory, attachmentsDir.path);

    if (!attachmentsDir.existsSync()) {
      attachmentsDir.createSync();
      if (!isDendronMode) await createTutorialAttachments();
    }

    /* for (String fileName in Samples.tutorialNotes) {
      File('${notesDir.path}/$fileName').writeAsStringSync(
          await rootBundle.loadString('assets/tutorial/notes/$fileName'));
    } */

    allNotes = [];

    DateTime start = DateTime.now();

    await _listNotesInFolder('');

    logger.d(DateTime.now().difference(start));

    // _updateTagList();
  }

  ///
  Future<void> _listNotesInFolder(String dir, {bool isSubDir = false}) async {
    logger.d(('_listNotesInFolder', notesDir, notesDir.path, dir));
    //
    await for (var entity in Directory('${notesDir.path}$dir').list()) {
      if (entity is File) {
        // only process markdown files
        if (!entity.path.endsWith('.md')) continue;
        try {
          Note? note = await PersistentStore.readNote(entity);

          if (note != null) {
            if (isSubDir &&
                (PrefService.getBool(ca.canShowVirtualTags) ?? false)) {
              // note.tags.add('#' + dir.replaceAll(r'\', '/'));
              note.tags.add('#$dir');
            }
            if (isDendronMode) {
              var path = entity.path
                  .substring(notesDir.path.length, entity.path.length - 3);
              while (path.startsWith(p.separator)) {
                path = path.substring(1);
              }
              note.tags.add('${path.replaceAll('.', '/')}');
            }

            allNotes.add(note);
          }
        } catch (e) {
          final note = Note();
          note.title = 'ERROR - "$e" on parsing "${entity.path}"';
          note.tags = ['ERROR'];
          note.attachments = [];

          note.pinned = true;
          note.favorite = true;
          note.deleted = false;

          allNotes.add(note);
        }
      } else if (entity is Directory) {
        final basename = p.basename(entity.path);
        if (basename.startsWith('.')) continue;
        if (entity.path.startsWith(attachmentsDir.path)) continue;

        await _listNotesInFolder(dir + '/' + basename, isSubDir: true);
      }
    }
  }

  ///
  updateTagList() {
    for (Note note in allNotes) {
      for (String tag in note.tags) {
        allTags.add(tag);
      }
    }

    final tmpRootTags = <String>{};

    for (String tag in allTags) {
      tmpRootTags.add(tag.split('/').first);
    }

    rootTags = tmpRootTags.toList();
    rootTags.sort();
  }

  ///
  List<String> getSubTags(String forTag) {
    Set<String> subTags =
        allTags.where((tag) => tag.startsWith(forTag) && tag != forTag).toSet();

    subTags = subTags.map((String t) => t.replaceFirst('$forTag/', '')).toSet();

    subTags = subTags.map((String t) => t.split('/').first).toSet();

    final subTagsList = subTags.toList();

    if (PrefService.getBool(ca.isSortTags) ?? true) {
      subTagsList.sort();
    }

    return subTagsList;
  }

  ///
  filterAndSortNotes() {
    //shownNotes = List.from(allNotes);

    shownNotes = _filterByTag(allNotes, currentTag);

    if (searchText != null) {
      List keywords =
          searchText!.split(' ').map((s) => s.toLowerCase()).toList();

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
}
