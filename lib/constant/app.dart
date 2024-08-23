/// App
const String appName = 'iNote';
const String gitHubRepo = 'https://github.com/inote-flutter/inote';
/// PopupMenuButton
const String menuPin='pin';
const String menuFavorite='favorite';
const String menuEncrypt='encrypt';
const String menuAddTag='addTag';
const String menuRemoveTag='removeTag';
const String menuAddAttachment='addAttachment';
const String menuRemoveAttachment='removeAttachment';
const String menuTrash='trash';
// const String menu_='';

/// Setting keys for local storage.
const String prefix = 'inote_';
// sync remote file system
const String sync = 'sync';
const String syncWebdavHost = 'sync_webdav_host';
const String syncWebdavPath = 'sync_webdav_path';
const String syncWebdavUsername = 'sync_webdav_username';
const String syncWebdavPassword = 'sync_webdav_password';
// theme selection(e.g., light, dark)
const String theme = 'theme';
const String themeColor = 'theme_color';
// language selectio
const String lang = 'lang';
const List<String> supportedLang = [en, zhCn]; // first one is default.
const String en = 'en';
const String zhCn = 'zh_CN';
const String zhHant = 'zh_Hant';
// List page
const String sortKey = 'sort_key';
const String isSortAsc = 'is_sort_asc';
const String sortByTitle = 'sort_by_title';
// const String sortByTitle = 'title';
const String sortByCreated = 'sort_by_created';
const String sortByUpdated = 'sort_by_updated';
// search options
const String canSearchContent = 'can_search_content';
// Editor page
const String canShowModeSwitcher = 'can_show_mode_switcher';
const String isPreviewMode = 'is_preview_mode';
const String canAutoSave = 'can_auto_save';
const String canPairMark = 'can_pair_mark';
const String canAutoListMark = 'can_auto_list_mark';
// tag
const String currentTag = 'current_tag';
const String canShowVirtualTags = 'can_show_virtual_tags';
const String isSortTags = 'is_sort_tags';
// notes data
const String dataDirectory = 'data_directory';
const String notesDirectory = 'notes_directory';
const String assetsDirectory = 'assets_directory';
const String externalDirectory = 'external_directory';
const String isExternalDirectoryEnabled = 'is_external_directory_enabled';
const String isExternalDirectoryDisabled = '!' + isExternalDirectoryEnabled;
// safety
const String isScreenLock = 'is_screen_lock';
const String screenLockPwd = 'screen_lock_pwd';
const String screenLockDuration = 'screen_lock_duration';
// other
const String isDendronMode = 'is_dendron_mode';
const String debugLogsSync = 'debug_logs_sync';
