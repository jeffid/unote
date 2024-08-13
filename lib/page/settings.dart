import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:preferences/preferences.dart';
import 'package:provider/provider.dart';

import '/constant/app.dart' as ca;
import '/main.dart';
import '/generated/l10n.dart';
// import '/utils/logger.dart';
import '/provider/theme.dart';
import '/store/notes.dart';

///
class SettingsPage extends StatefulWidget {
  final NotesStore store;
  SettingsPage(this.store);
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

///
class _SettingsPageState extends State<SettingsPage> {
  NotesStore get store => widget.store;
  @override
  void initState() {
    PrefService.setDefaultValues({
      ca.theme: ThemeType.light.name,
      ca.canSearchContent: true,
      ca.canShowModeSwitcher: true,
      ca.camPairMark: false,
      ca.canAutoSave: false,
      ca.canShowVirtualTags: false,
      ca.isSortTags: true,
      ca.isDendronMode: false,
      ca.debugLogsSync: false,
    });
    super.initState();
  }

  ///
  @override
  Widget build(BuildContext context) {
    Color accentColor = themeData.colorScheme.secondary;
    // logger.d((ThemeType.light.toString(),ThemeType.light.name));

    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.Settings),
      ),
      body: ListView(children: <Widget>[
        /// Language
        PreferenceTitle(S.current.Language),
        RadioPreference(
          S.current.en,
          ca.en,
          ca.lang,
          isDefault: Intl.defaultLocale == ca.en,
          onSelect: () {
            PrefService.setString(ca.lang, ca.en);
            Intl.defaultLocale = ca.en;
            setState(() {});
          },
          activeColor: accentColor,
          inactiveColor: accentColor,
        ),
        RadioPreference(
          S.current.zhCn,
          ca.zhCn,
          ca.lang,
          isDefault: Intl.defaultLocale == ca.zhCn,
          onSelect: () {
            PrefService.setString(ca.lang, ca.zhCn);
            Intl.defaultLocale = ca.zhCn;
            setState(() {});
          },
          activeColor: accentColor,
          inactiveColor: accentColor,
        ),

        /// Theme
        PreferenceTitle(S.current.Theme),
        RadioPreference(
          S.current.Light,
          ThemeType.light.name,
          ca.theme,
          isDefault: true,
          onSelect: () {
            Provider.of<ThemeNotifier>(context, listen: false)
                .updateTheme(ThemeType.light.name);
          },
          activeColor: accentColor,
          inactiveColor: accentColor,
        ),
        RadioPreference(
          S.current.Dark,
          ThemeType.dark.name,
          ca.theme,
          onSelect: () {
            Provider.of<ThemeNotifier>(context, listen: false)
                .updateTheme(ThemeType.dark.name);
          },
          activeColor: accentColor,
          inactiveColor: accentColor,
        ),
        RadioPreference(
          S.current.Black_AMOLED,
          ThemeType.black.name,
          ca.theme,
          onSelect: () {
            Provider.of<ThemeNotifier>(context, listen: false)
                .updateTheme(ThemeType.black.name);
          },
          activeColor: accentColor,
          inactiveColor: accentColor,
        ),
        ListTile(
          title: Text(S.current.Accent_Color),
          trailing: Padding(
            padding: const EdgeInsets.only(right: 9, left: 9),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(3.0),
                color: Color(PrefService.getInt(ca.themeColor) ??
                    ThemeNotifier.defaultThemeColor.value),
              ),
              child: SizedBox(
                width: 28,
                height: 28,
              ),
            ),
          ),
          onTap: () async {
            Color? color = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      title: Text(S.current.Select_accent_color),
                      content: Container(
                        child: GridView.count(
                          crossAxisCount: 5,
                          children: [
                            for (Color color in [
                              ThemeNotifier.defaultThemeColor,
                              ...Colors.primaries,
                              ...Colors.accents,
                            ])
                              InkWell(
                                child: Container(
                                  margin: const EdgeInsets.all(5),
                                  color: color,
                                ),
                                onTap: () {
                                  Navigator.of(context).pop(color);
                                },
                              )
                          ],
                        ),
                        width: MediaQuery.of(context).size.width * .7,
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
            if (color != null) {
              PrefService.setInt(ca.themeColor, color.value);

              Provider.of<ThemeNotifier>(context, listen: false).accentColor =
                  color;
            }
          },
        ),

        /// Data Directory
        if (Platform.isAndroid) ...[
          PreferenceTitle(S.current.Data_Directory),
          SwitchPreference(
            S.current.Use_external_storage,
            ca.isExternalDirectoryEnabled,
            onChange: () async {
              if (PrefService.getString(ca.externalDirectory) == null) {
                PrefService.setString(ca.externalDirectory,
                    (await getExternalStorageDirectory())!.path);
              }

              await store.listNotes();
              await store.filterAndSortNotes();
              await store.updateTagList();

              if (mounted) setState(() {});
            },
          ),
          PreferenceHider(
            [
              ListTile(
                title: Text(S.current.Location),
                subtitle: Text(
                  PrefService.getString(ca.externalDirectory) ?? '',
                ),
                onTap: () async {
                  Directory dir;

                  final dirStr = await _pickExternalDir();

                  if (dirStr == null) {
                    return;
                  }

                  dir = Directory(dirStr);

                  if (dir.existsSync()) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: ListTile(
                          leading: CircularProgressIndicator(),
                          title: Text('Processing files...'),
                        ),
                      ),
                      barrierDismissible: false,
                    );
                    PrefService.setString(ca.externalDirectory, dir.path);

                    await store.listNotes();
                    await store.filterAndSortNotes();
                    await store.updateTagList();
                    setState(() {});
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
            ca.isExternalDirectoryDisabled,
          ),
        ],

        /// Editor
        PreferenceTitle(S.current.Editor),
        SwitchPreference(
          S.current.Auto_Save,
          ca.canAutoSave,
          activeColor: accentColor,
          inactiveThumbColor: accentColor,
        ),
        SwitchPreference(
          S.current.Use_Mode_Switcher,
          ca.canShowModeSwitcher,
          activeColor: accentColor,
          inactiveThumbColor: accentColor,
        ),
        SwitchPreference(
          S.current.Pair_Quotes,
          ca.camPairMark,
          activeColor: accentColor,
          inactiveThumbColor: accentColor,
        ),

        /// Search
        PreferenceTitle(S.current.Search),
        SwitchPreference(
          S.current.Search_content_of_notes,
          ca.canSearchContent,
          activeColor: accentColor,
          inactiveThumbColor: accentColor,
        ),

        /// Tags
        PreferenceTitle(S.current.Tags),
        SwitchPreference(
          S.current.Sort_tags_alphabetically_in_the_sidebar,
          ca.isSortTags,
          activeColor: accentColor,
          inactiveThumbColor: accentColor,
        ),

        /// More
        PreferenceTitle(S.current.More),
        ListTile(
          title: Text(S.current.Recreate_tutorial_notes),
          onTap: () async {
            if (await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: Text(S.current
                              .Do_you_want_to_recreate_the_tutorial_notes),
                          actions: <Widget>[
                            TextButton(
                              child: Text(S.current.Cancel),
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                            ),
                            TextButton(
                              child: Text(S.current.Recreate),
                              onPressed: () {
                                Navigator.of(context).pop(true);
                              },
                            )
                          ],
                        )) ??
                false) {
              await store.createTutorialNotes();
              await store.createTutorialAttachments();
              await store.listNotes();
              await store.filterAndSortNotes();
              await store.updateTagList();
            }
          },
        ),

        /// Experimental
        PreferenceTitle(S.current.Experimental),
        SwitchPreference(
          S.current.Enable_Dendron_support,
          ca.isDendronMode,
          desc: S.current.Dendron_is_a_VSCodeBased_NoteTaking_tool,
          onChange: () async {
            await store.listNotes();
            await store.filterAndSortNotes();
            await store.updateTagList();

            if (mounted) setState(() {});
          },
          activeColor: accentColor,
          inactiveThumbColor: accentColor,
        ),
        SwitchPreference(
          S.current.Automatic_bullet_points,
          ca.canAutoBulletMark,
          desc: S.current
              .Adds_a_bullet_point_to_a_new_line_if_the_line_before_it_had_one,
          activeColor: accentColor,
          inactiveThumbColor: accentColor,
        ),
        SwitchPreference(
          S.current.Show_virtual_tags,
          ca.canShowVirtualTags,
          desc:
              S.current.Adds_a_virtual_tag_to_notes_which_are_in_a_subdirectory,
          activeColor: accentColor,
          inactiveThumbColor: accentColor,
        ),

        // /// Preview
        // PreferenceTitle(S.current.Preview),
        // SwitchPreference(
        //   'Enable single line break syntax',
        //   'single_line_break_syntax',
        //   desc:
        //       'When enabled, single line breaks are rendered as real line breaks',
        //   activeColor: accentColor,
        //   inactiveThumbColor: accentColor,
        // ),

        // PreferenceTitle(S.current.Sync),
        // RadioPreference(
        //   'No Sync',
        //   '',
        //   'sync',
        //   isDefault: true,
        //   onSelect: () {
        //     setState(() {
        //       store.syncMethod = '';
        //     });
        //   },
        // ),
        // RadioPreference(
        //   'WebDav Sync',
        //   'webdav',
        //   'sync',
        //   onSelect: () {
        //     setState(() {
        //       store.syncMethod = 'webdav';
        //     });
        //   },
        // ),
        // if (store.syncMethod == 'webdav')
        //   Column(
        //     children: <Widget>[
        //       Padding(
        //         padding: const EdgeInsets.symmetric(horizontal: 16),
        //         child: Text(
        //           'WARNING: WebDav Sync is not supported! Please use another app to sync if possible (Syncthing is recommended) and do NOT use it for important data or accounts! ',
        //           style: TextStyle(color: Colors.red),
        //         ),
        //       ),
        //       TextFieldPreference(
        //         'Host',
        //         'sync_webdav_host',
        //         hintText: 'mynextcloud.tld/remote.php/webdav/',
        //       ),
        //       TextFieldPreference(
        //         'Path',
        //         'sync_webdav_path',
        //         hintText: 'notable',
        //       ),
        //       TextFieldPreference('Username', 'sync_webdav_username'),
        //       TextFieldPreference(
        //         'Password',
        //         'sync_webdav_password',
        //         obscureText: true,
        //       ),
        //     ],
        //   ),

        // PreferenceTitle('Debug'),
        // SwitchPreference(
        //   'Create sync logfile ',
        //   'debug_logs_sync',
        // ),
      ]),
    );
  }

  ///
  Future<String?> _pickExternalDir() async {
    if (!await Permission.storage.request().isGranted) {
      return null;
    }

    var dir = await FilePicker.platform.getDirectoryPath();
    if ((dir ?? '').isNotEmpty) {
      if (await _checkIfDirectoryIsWritable(dir!)) {
        return dir;
      }
    }

    if ((await Permission.storage.request()).isDenied) {
      return null;
    }

    var externalDir = await getExternalStorageDirectory();
    if (await _checkIfDirectoryIsWritable(externalDir?.path)) {
      return externalDir?.path;
    }
    return null;
  }

  ///
  Future<bool> _checkIfDirectoryIsWritable(String? path) async {
    final testFile = File('$path/${Random().nextInt(1000000)}');

    try {
      await testFile.create(recursive: true);
      await testFile.writeAsString("This is only a test file, please ignore.");
      await testFile.delete();
    } catch (e) {
      return false;
    }
    return true;
  }
}
