import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:preferences/preferences.dart';
// import 'package:quick_actions/quick_actions.dart';
// import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '/constant/app.dart' as ca;
import '/generated/l10n.dart';
import '/main.dart';
import '/model/note.dart';
import '/store/encryption.dart';
import '/store/notes.dart';
import '/store/persistent.dart';
import '/utils/logger.dart';
import './about.dart';
import './edit.dart';
import './settings.dart';

///
class NoteListPage extends StatefulWidget {
  ///
  NoteListPage(
      {required this.filterTag,
      required this.searchText,
      required this.isFirstPage});

  final String filterTag;

  final String searchText;

  final bool isFirstPage;

  ///
  @override
  _NoteListPageState createState() => _NoteListPageState();
}

///
class _NoteListPageState extends State<NoteListPage> {
  NotesStore store = NotesStore();

  TextEditingController _searchFieldCtrl = TextEditingController();

  bool searching = false;

  late Directory notesDir, attachmentsDir;

  bool _syncing = false;

  Set<String> _selectedNotes = {};

  // late StreamSubscription _intentDataStreamSubscription;
  // late StreamSubscription _intentSub;
  // final _sharedFiles = <SharedMediaFile>[];

  @override
  void initState() {
    store.currentTag = widget.filterTag.isNotEmpty
        ? widget.filterTag
        : PrefService.getString(ca.currentTag) ?? '';

    if (widget.searchText.isNotEmpty) {
      _searchFieldCtrl.text = widget.searchText;
      store.searchText = widget.searchText;
      searching = true;
    }

    store.init();
    _load().then((_) {
      if (widget.isFirstPage) {
        // todo MissingPluginException(No implementation found for method getLaunchAction on channel plugins.flutter.io/quick_actions)
        // final quickActions = QuickActions();
        // quickActions.initialize((shortcutType) {
        //   if (shortcutType == 'action_create_note') {
        //     createNewNote();
        //   }
        // });
        // quickActions.setShortcutItems(<ShortcutItem>[
        //   const ShortcutItem(
        //       type: 'action_create_note',
        //       localizedTitle: 'Create note',
        //       icon: 'ic_shortcut_add'),
        // ]);

        //todo [ERROR:flutter/runtime/dart_vm_initializer.cc(41)] Unhandled Exception: MissingPluginException(No implementation found for method getInitialMedia on channel receive_sharing_intent/messages)
        // // For sharing or opening urls/text coming from outside the app while the app is in the memory
        // _intentSub =
        //     ReceiveSharingIntent.instance.getMediaStream().listen((value) {
        //   _sharedFiles.clear();
        //   _sharedFiles.addAll(value);

        //   // handleSharedText(value); todo
        //   ReceiveSharingIntent.instance.reset();
        // }, onError: (err) {
        //   print("getLinkStream error: $err");
        // });

        // // For sharing or opening urls/text coming from outside the app while the app is closed
        // ReceiveSharingIntent.instance.getInitialMedia().then<void>((value) {
        //   // handleSharedText(value ?? ''); todo
        //   ReceiveSharingIntent.instance.reset();
        // });
      }
    });

    super.initState();
  }

  ///
  @override
  void dispose() {
    // _intentSub.cancel();
    super.dispose();
  }

  ///
  @override
  Widget build(BuildContext context) {
    logger.d('note_list build ===================');

    return PopScope(
      canPop: false,
      onPopInvoked: _onPopInvoked,
      child: Scaffold(
        appBar: _appBar(),
        body: store.shownNotes.isEmpty
            ? LinearProgressIndicator()
            : RefreshIndicator(
                onRefresh: () async {
                  await _load();
                },
                child: Scrollbar(
                  child: ListView(
                    primary: true,
                    children: <Widget>[
                      if (_syncing) ...[
                        LinearProgressIndicator(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child:
                              Text('Syncing with ${store.syncMethodName}...'),
                        ),
                        Divider(color: themeData.dividerColor),
                      ],
                      _sortBar(),
                      Container(
                        height: 1,
                        color: Colors.grey.shade300,
                      ),
                      for (Note note in store.shownNotes)
                        !note.file.existsSync()
                            ? ListTile(
                                title: Text(
                                  note.title,
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : _slidableTitle(note),
                    ],
                  ),
                ),
              ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () async => _createNewNote(),
        ),
        bottomNavigationBar: _selectedNotes.isEmpty ? null : _bottomBar(),
        drawer: store.shownNotes.isEmpty ? Container() : _drawer(),
      ),
    );
  }

  ///
  PreferredSizeWidget _appBar() {
    Color fgColor = themeData.colorScheme.onSecondary;

    return AppBar(
      title: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: searching
            ? TextField(
                decoration: InputDecoration(
                  isDense: true,
                  labelText: S.current.Search,
                  labelStyle: TextStyle(color: fgColor),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: fgColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: fgColor),
                  ),
                ),
                style: TextStyle(color: fgColor),
                autofocus: true,
                cursorColor: fgColor,
                controller: _searchFieldCtrl,
                onChanged: (text) {
                  store.searchText = _searchFieldCtrl.text;
                  _filterAndSortNotes();
                },
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(ca.appName),
                  if (store.currentTag.length > 0)
                    Text(
                      store.currentTag,
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    )
                ],
              ),
      ),
      actions: <Widget>[
        if (!searching)
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              store.searchText = _searchFieldCtrl.text;
              setState(() {
                searching = true;
              });
              _filterAndSortNotes();
            },
          ),
        if (searching)
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              store.searchText = '';
              setState(() {
                searching = false;
              });
              _filterAndSortNotes();
            },
          ),

        /* IconButton(
              icon: Icon(Icons.),
            ), */
      ],
    );
  }

  ///
  Widget _sortBar() {
    return Container(
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 16,
          ),
          DropdownButton<dynamic>(
            value: PrefService.getString(ca.sortKey) ?? ca.sortByTitle,
            underline: Container(),
            onChanged: (key) {
              PrefService.setString(ca.sortKey, key);
              _filterAndSortNotes();
            },
            items: <DropdownMenuItem>[
              DropdownMenuItem(
                value: ca.sortByTitle,
                child: Text(S.current.Sort_by_Title),
              ),
              DropdownMenuItem(
                value: ca.sortByCreated,
                child: Text(S.current.Sort_by_Created_Date),
              ),
              DropdownMenuItem(
                value: ca.sortByUpdated,
                child: Text(S.current.Sort_by_Updated_Date),
              ),
            ],
          ),
          Expanded(
            child: Container(),
          ),
          InkWell(
            child: Icon(
              (PrefService.getBool(ca.isSortAsc) ?? true)
                  ? Icons.keyboard_arrow_down
                  : Icons.keyboard_arrow_up,
              size: 32,
            ),
            onTap: () {
              PrefService.setBool(
                  ca.isSortAsc, !(PrefService.getBool(ca.isSortAsc) ?? true));

              _filterAndSortNotes();
            },
          ),
          SizedBox(
            width: 16,
          ),
          /*  Expanded(
                              child: 
                            ) */
        ],
      ),
    );
  }

  ///
  Slidable _slidableTitle(Note note) {
    return Slidable(
      // class upgrade: https://github.com/letsar/flutter_slidable/wiki/Migration-from-version-0.6.0-to-version-1.0.0
      startActionPane:
          ActionPane(motion: const DrawerMotion(), children: <Widget>[
        if (note.deleted) ...[
          SlidableAction(
            label: S.current.Delete,
            backgroundColor: Colors.red,
            icon: Icons.delete_forever,
            onPressed: (context) async {
              if (await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title:
                                Text('Do you really want to delete this note?'),
                            content: Text('This will delete it permanently.'),
                            actions: <Widget>[
                              TextButton(
                                child: Text(S.current.Cancel),
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                              ),
                              TextButton(
                                child: Text(S.current.Delete),
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                              )
                            ],
                          )) ??
                  false) {
                store.allNotes.remove(note);
                PersistentStore.deleteNote(note);

                await _filterAndSortNotes();
              }
            },
          ),
          SlidableAction(
            label: S.current.Restore,
            backgroundColor: Colors.redAccent,
            icon: MdiIcons.deleteRestore,
            onPressed: (context) async {
              note.deleted = false;

              PersistentStore.saveNoteHeader(note);

              await _filterAndSortNotes();
            },
          ),
        ],
        if (!note.deleted)
          SlidableAction(
            label: S.current.Trash,
            backgroundColor: Colors.red,
            icon: Icons.delete,
            onPressed: (context) async {
              note.deleted = true;

              PersistentStore.saveNoteHeader(note);

              await _filterAndSortNotes();
            },
          ),
      ]),
      endActionPane:
          ActionPane(motion: const DrawerMotion(), children: <Widget>[
        SlidableAction(
          label: note.favorite ? S.current.Unfavorite : S.current.Favorite,
          backgroundColor: Colors.yellow,
          icon: note.favorite ? MdiIcons.starOff : MdiIcons.star,
          onPressed: (context) async {
            note.favorite = !note.favorite;

            PersistentStore.saveNoteHeader(note);

            await _filterAndSortNotes();
          },
        ),
        SlidableAction(
          label: note.pinned ? S.current.Unpin : S.current.Pin,
          backgroundColor: Colors.green,
          icon: note.pinned ? MdiIcons.pinOff : MdiIcons.pin,
          onPressed: (context) async {
            note.pinned = !note.pinned;

            PersistentStore.saveNoteHeader(note);

            await _filterAndSortNotes();
          },
        ),
      ]),
      child: ListTile(
        selected: _selectedNotes.contains(note.title),
        selectedColor: Theme.of(context).colorScheme.primary,
        title: Text(note.title),
        // textColor: Theme.of(context).textTheme.bodySmall?.color,
        subtitle: store.isDendronMode
            ? Text(note.file.path.substring(store.notesDir.path.length + 1))
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (note.pinned) Icon(MdiIcons.pin),
            if (note.favorite) Icon(MdiIcons.star),
            if (note.encrypted)
              note.isDecryptSuccess
                  ? Icon(MdiIcons.lockOpen)
                  : Icon(MdiIcons.lock),
            // if (note.encrypted && note.isDecryptSuccess)
            //   Icon(MdiIcons.lockOpen),
            // if (note.encrypted && !note.isDecryptSuccess) Icon(MdiIcons.lock),
            if (note.attachments.isNotEmpty) Icon(MdiIcons.paperclip),
            if (note.tags.contains('color/red'))
              Container(
                color: Colors.red,
                width: 5,
              ),
            if (note.tags.contains('color/yellow'))
              Container(
                color: Colors.yellow,
                width: 5,
              ),
            if (note.tags.contains('color/green'))
              Container(
                color: Colors.green,
                width: 5,
              ),
            if (note.tags.contains('color/blue'))
              Container(
                color: Colors.blue,
                width: 5,
              ),
          ],
        ),
        onTap: () async {
          if (_selectedNotes.isNotEmpty) {
            setState(() {
              if (_selectedNotes.contains(note.title)) {
                _selectedNotes.remove(note.title);
              } else {
                _selectedNotes.add(note.title);
              }
            });
            return;
          }

          //  password is required for encrypted documents
          if (note.encrypted && !note.isDecryptSuccess) {
            TextEditingController ctrl = TextEditingController();
            final (cd, canRetry) = note.canRetry(false);

            String pwd = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(S.current.Enter_password),
                    content: TextField(
                      controller: ctrl,
                      autofocus: true,
                      readOnly: !canRetry,
                      decoration: InputDecoration(
                        hintText: canRetry
                            ? S.current.Enter_password
                            : S.current.Please_try_again_in_cd_second(cd),
                      ),
                      onSubmitted: (str) {
                        Navigator.of(context).pop(str);
                      },
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: Text(S.current.Cancel),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: Text(S.current.Confirm),
                        onPressed: canRetry
                            ? () => Navigator.of(context).pop(ctrl.text)
                            : null,
                      ),
                    ],
                  ),
                ) ??
                '';
            if (pwd.isNotEmpty) {
              note.encryption = Encryption(key: pwd);
            } else {
              return;
            }
          }

          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EditPage(
                note,
                store,
              ),
            ),
          );
          _filterAndSortNotes();
        },
        onLongPress: () {
          setState(() {
            if (_selectedNotes.contains(note.title)) {
              _selectedNotes.remove(note.title);
            } else {
              _selectedNotes.add(note.title);
            }
          });
        },
      ),
    );
  }

  ///
  BottomAppBar _bottomBar() {
    return BottomAppBar(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(S.current.countSelectedNotes(_selectedNotes.length)),
                  Row(
                    children: <Widget>[
                      InkWell(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                          child: Text(S.current.ALL,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        onTap: () {
                          store.shownNotes.forEach((s) {
                            _selectedNotes.add(s.title);
                          });
                          setState(() {});
                        },
                      ),
                      InkWell(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                          child: Text(S.current.NONE,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        onTap: () {
                          store.shownNotes.forEach((s) {
                            _selectedNotes.remove(s.title);
                          });
                          setState(() {});
                        },
                      )
                    ],
                  )
                ],
              ),
            ),
            IconButton(
              icon: Icon(MdiIcons.pin),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(S.current.Pin),
                    content: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            leading: Icon(MdiIcons.pin),
                            title: Text(S.current.Pin_selected),
                            onTap: () => _modifyAll((Note note) async {
                              note.pinned = true;
                              PersistentStore.saveNoteHeader(note);
                            }),
                          ),
                          ListTile(
                            leading: Icon(MdiIcons.pinOff),
                            title: Text(S.current.Unpin_selected),
                            onTap: () => _modifyAll(
                              (Note note) async {
                                note.pinned = false;
                                PersistentStore.saveNoteHeader(note);
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(MdiIcons.star),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(S.current.Favorite),
                    content: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            leading: Icon(MdiIcons.star),
                            title: Text(S.current.Favorite_selected),
                            onTap: () => _modifyAll((Note note) async {
                              note.favorite = true;

                              PersistentStore.saveNoteHeader(note);
                            }),
                          ),
                          ListTile(
                            leading: Icon(MdiIcons.starOff),
                            title: Text(S.current.Unfavorite_selected),
                            onTap: () => _modifyAll(
                              (Note note) async {
                                note.favorite = false;
                                PersistentStore.saveNoteHeader(note);
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(MdiIcons.tag),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(S.current.Tags),
                    content: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            leading: Icon(MdiIcons.tagPlus),
                            title: Text(S.current.Add_Tag_to_selected_notes),
                            onTap: () async {
                              /*
                                                    Navigator.of(context).pop(); */
                              TextEditingController ctrl =
                                  TextEditingController();
                              String newTag = await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text(S.current.Add_Tag),
                                      content: TextField(
                                        controller: ctrl,
                                        autofocus: true,
                                        onSubmitted: (str) {
                                          Navigator.of(context).pop(str);
                                        },
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text(S.current.Cancel),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: Text(S.current.Add),
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(ctrl.text);
                                          },
                                        ),
                                      ],
                                    ),
                                  ) ??
                                  '';

                              if (newTag.isNotEmpty) {
                                print('ADD');
                                await _modifyAll((Note note) async {
                                  note.tags.add(newTag);
                                  PersistentStore.saveNoteHeader(note);
                                });
                                store.updateTagList();
                              } else {
                                /* Navigator.of(context)
                                                          .pop(); */
                              }
                            },
                          ),
                          ListTile(
                            leading: Icon(MdiIcons.tagMinus),
                            title:
                                Text(S.current.Remove_Tag_from_selected_notes),
                            onTap: () async {
                              Set<String> tags = {};

                              for (String title in _selectedNotes) {
                                Note note = store.getNote(title);
                                tags.addAll(note.tags);
                              }

                              String tagToRemove = await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        title: Text(
                                            S.current.Choose_Tag_to_remove),
                                        content: SingleChildScrollView(
                                          child: Column(
                                            children: <Widget>[
                                              for (String tag in tags)
                                                ListTile(
                                                    title: Text(tag),
                                                    onTap: () {
                                                      Navigator.of(context)
                                                          .pop(tag);
                                                    })
                                            ],
                                          ),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            child: Text(S.current.Cancel),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      ));
                              if (tagToRemove.isNotEmpty) {
                                // print('REMOVE');
                                await _modifyAll(
                                  (Note note) async {
                                    note.tags.remove(tagToRemove);
                                    PersistentStore.saveNoteHeader(note);
                                  },
                                );
                                store.updateTagList();
                              }
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(MdiIcons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(S.current.Delete_selected),
                    content: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            leading: Icon(MdiIcons.delete),
                            title: Text(S.current.Move_to_trash),
                            onTap: () => _modifyAll((Note note) {
                              note.deleted = true;

                              PersistentStore.saveNoteHeader(note);
                            }),
                          ),
                          ListTile(
                            leading: Icon(MdiIcons.deleteRestore),
                            title: Text(S.current.Restore_from_trash),
                            onTap: () => _modifyAll((Note note) {
                              note.deleted = false;

                              PersistentStore.saveNoteHeader(note);
                            }),
                          ),
                          ListTile(
                            leading: Icon(MdiIcons.deleteForever),
                            title: Text(S.current.Delete_forever),
                            onTap: () async {
                              bool isDelete = await showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                            title: Text(S.current
                                                .Do_you_really_want_to_delete_the_selected_notes),
                                            content: Text(S.current
                                                .This_will_delete_them_permanently),
                                            actions: <Widget>[
                                              TextButton(
                                                child: Text(S.current.Cancel),
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(false);
                                                },
                                              ),
                                              TextButton(
                                                child: Text(S.current.Delete),
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(true);
                                                },
                                              )
                                            ],
                                          )) ??
                                  false;
                              if (isDelete) {
                                await _modifyAll(
                                  (Note note) {
                                    store.allNotes.remove(note);

                                    PersistentStore.deleteNote(note);
                                    _selectedNotes.remove(note.title);
                                  },
                                );
                              }
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

//
  Drawer _drawer() {
    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: ListView(
        children: <Widget>[
          ListTile(
              // title: FutureBuilder<PackageInfo>(
              //   future: PackageInfo.fromPlatform(),
              //   builder: (context, snap) {
              //     if (!snap.hasData) return SizedBox();
              //     PackageInfo? info = snap.data;
              //     return Text('${info?.appName} ${info?.version}');
              //   },
              // ),
              title: Text('${ca.appName} ${appInfo.package.version}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.info),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => AboutPage(store)));
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.settings),
                    onPressed: () async {
                      await Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => SettingsPage(store)));
                      setState(() {});
                    },
                  ),
                ],
              )),
          Divider(color: themeData.dividerColor),
          // DrawerHeader(child: Text('Hello')),
          TagDropdown(
            '',
            store,
            () {
              Navigator.of(context).pop();
              _filterAndSortNotes();
            },
            icon: MdiIcons.noteText,
            displayTag: S.current.All_Notes,
            hasSubTags: false,
          ),
          TagDropdown(
            'Favorites',
            store,
            () {
              Navigator.of(context).pop();
              _filterAndSortNotes();
            },
            icon: MdiIcons.star,
            displayTag: S.current.Favorite,
            hasSubTags: false,
          ),
          for (String tag in store.rootTags)
            TagDropdown(
              tag,
              store
              //  store.allTags.where((t) => t.startsWith(tag)).toList()
              ,
              () {
                Navigator.of(context).pop();
                _filterAndSortNotes();
              },
              foldedByDefault: !['Notebooks'].contains(tag),
            ),
          TagDropdown(
            'Untagged',
            store,
            () {
              Navigator.of(context).pop();
              _filterAndSortNotes();
            },
            icon: MdiIcons.labelOff,
            displayTag: S.current.Untagged,
            hasSubTags: false,
          ),
          TagDropdown(
            'Trash',
            store,
            () {
              Navigator.of(context).pop();
              _filterAndSortNotes();
            },
            icon: Icons.delete,
            displayTag: S.current.Trash,
          ),
        ],
      ),
    );
  }
  // handleSharedText(String value) {
  //   if (value.isEmpty) return;

  //   showDialog(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //             title: Text('Received text'),
  //             content:
  //                 Scrollbar(child: SingleChildScrollView(child: Text(value))),
  //             actions: [
  //               TextButton(
  //                   onPressed: () {
  //                     Navigator.of(context).pop();
  //                   },
  //                   child: Text('Cancel')),
  //               // TextButton(onPressed: () {}, child: Text('Append to note')),
  //               TextButton(
  //                   onPressed: () {
  //                     Navigator.of(context).pop();
  //                     createNewNote(value);
  //                   },
  //                   child: Text('Create new note')),
  //             ],
  //           ));
  // }

  ///
  void _deselectAllNotes() {
    if (_selectedNotes.isNotEmpty) {
      setState(() {
        _selectedNotes = {};
      });
    }
  }

  ///
  void _onPopInvoked(bool didPop) async {
    if (didPop) {
      _deselectAllNotes();
      return;
    }

    var shouldPop = false;
    if (_selectedNotes.isNotEmpty) {
      _deselectAllNotes();
      shouldPop = false;
    } else if (!widget.isFirstPage) {
      shouldPop = true;
    } else {
      shouldPop = await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: Text(S.current.Do_you_want_to_exit_the_app),
                    actions: <Widget>[
                      TextButton(
                        child: Text(S.current.Cancel),
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                      ),
                      TextButton(
                        child: Text(S.current.Exit),
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                      )
                    ],
                  )) ??
          false;
    }

    if (context.mounted && shouldPop) {
      Navigator.pop(context);
    }
  }

  ///
  Future _filterAndSortNotes() async {
    store.filterAndSortNotes();
    setState(() {});
  }

  ///
  Future _load() async {
    print('LOAD');
    await store.listNotes();

    store.updateTagList();

    store.filterAndSortNotes();

    setState(() {});
  }

  ///
  Future _modifyAll(Function processNote) async {
    Navigator.of(context).pop();
    for (String title in _selectedNotes.toList()) {
      Note note = store.getNote(title);

      await processNote(note);
    }

    await _filterAndSortNotes();
  }

  ///
  Future _refresh() async {
    print('REFRESH');
    if (store.syncMethod.isEmpty) {
      await _load();
    } else {
      setState(() {
        _syncing = true;
      });
      String? result = await store.syncNow();
      if (result != null) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text(S.current.Sync_Error),
                  content: Text(result),
                  actions: <Widget>[
                    TextButton(
                      child: Text(S.current.Ok),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ));
      }
      if (!mounted) return;
      setState(() {
        _syncing = false;
      });

      await store.listNotes();

      store.updateTagList();

      store.filterAndSortNotes();

      if (!mounted) return;
      setState(() {});
    }
  }

  ///
  Future<void> _createNewNote([String content = '']) async {
    Note newNote = await store.createNewNote(content);

    _filterAndSortNotes();

    PrefService.setBool(ca.isPreviewMode, false);

    await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => EditPage(
              newNote,
              store,
              autofocus: true,
            )));
    // _filterAndSortNotes();
  }

  /* _setFilterTagAndRefresh(BuildContext context, String tag) {
    Navigator.of(context).pop();
    store.currentTag = tag;
    _filterAndSortNotes();
  } */
}

///
class TagDropdown extends StatefulWidget {
  ///
  TagDropdown(this.tag, this.store /* this.subTags */, this.apply,
      {this.icon,
      this.foldedByDefault = true,
      this.displayTag,
      this.hasSubTags});

  final String tag;
  /*  final List<String> subTags; */

  final NotesStore store;

  final Function apply;

  final IconData? icon;

  final bool foldedByDefault;

  final String? displayTag;

  final bool? hasSubTags;

  ///
  @override
  _TagDropdownState createState() => _TagDropdownState();
}

///
class _TagDropdownState extends State<TagDropdown> {
  late bool _folded;

  late bool _hasSubTags;

  late bool _isSelected;

  NotesStore get store => widget.store;

  ///
  @override
  void initState() {
    super.initState();

    if (widget.hasSubTags == null) {
      _hasSubTags = store.getSubTags(widget.tag).length > 0;
    } else {
      _hasSubTags = widget.hasSubTags as bool;
    }
    _isSelected = store.currentTag == widget.tag;
    _folded = widget.foldedByDefault;
    if (store.currentTag.startsWith(widget.tag)) _folded = false;
  }

  ///
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          leading: widget.icon != null
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(widget.icon,
                      color: _isSelected
                          ? Theme.of(context).colorScheme.secondary
                          : null),
                )
              : _hasSubTags
                  ? InkWell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                            _folded
                                ? MdiIcons.chevronRight
                                : MdiIcons.chevronDown,
                            color: _isSelected
                                ? Theme.of(context).colorScheme.secondary
                                : null),
                      ),
                      onTap: () {
                        setState(() {
                          _folded = !_folded;
                        });
                      },
                    )
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                    ),
          // trailing: Text(_countNotesWithTag(allNotes, tag).toString()),
          title: Text(widget.displayTag ?? widget.tag.split('/').last,
              style: _isSelected
                  ? TextStyle(color: Theme.of(context).colorScheme.secondary)
                  : null),
          trailing: Text(
              store.countNotesWithTag(store.allNotes, widget.tag).toString(),
              style: _isSelected
                  ? TextStyle(color: Theme.of(context).colorScheme.secondary)
                  : null),

          onTap: () {
            store.currentTag = widget.tag;
            widget.apply();
          },
        ),
        if (_hasSubTags && !_folded)
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                for (String subTag in store.getSubTags(widget.tag))
                  TagDropdown(widget.tag + '/' + subTag, store, widget.apply)
              ],
            ),
          )
      ],
    );
  }
}
