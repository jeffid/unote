// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh_CN locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'zh_CN';

  static String m0(attachment) => "确定删除附件 <${attachment}> ? 该文件会被从硬盘中永久删除";

  static String m1(tag) => "确定要从文档中移除标签：${tag}？";

  static String m2(cd) => "请在 ${cd} 秒后重试";

  static String m3(count) => "${count} 个选中文档";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "ALL": MessageLookupByLibrary.simpleMessage("全选"),
        "About": MessageLookupByLibrary.simpleMessage("关于"),
        "Accent_Color": MessageLookupByLibrary.simpleMessage("强调色"),
        "Add": MessageLookupByLibrary.simpleMessage("添加"),
        "Add_Attachment": MessageLookupByLibrary.simpleMessage("添加附件"),
        "Add_Tag": MessageLookupByLibrary.simpleMessage("添加标签"),
        "Add_Tag_to_selected_notes":
            MessageLookupByLibrary.simpleMessage("添加标签到选中文档"),
        "Adds_a_list_mark_to_a_new_line_if_the_line_before_it_had_one":
            MessageLookupByLibrary.simpleMessage("自动在列表的新一行开头添加序列符号"),
        "Adds_a_virtual_tag_to_notes_which_are_in_a_subdirectory":
            MessageLookupByLibrary.simpleMessage("以子文件夹名作为虚拟标签"),
        "All_Notes": MessageLookupByLibrary.simpleMessage("全部文档"),
        "Auto_Save": MessageLookupByLibrary.simpleMessage("自动保存"),
        "Automatic_list_mark": MessageLookupByLibrary.simpleMessage("自动添加序列符号"),
        "Back": MessageLookupByLibrary.simpleMessage("返回"),
        "Black_AMOLED": MessageLookupByLibrary.simpleMessage("黑色 / AMOLED"),
        "Cancel": MessageLookupByLibrary.simpleMessage("取消"),
        "Choose_Tag_to_remove":
            MessageLookupByLibrary.simpleMessage("选择要移除的标签"),
        "Confirm": MessageLookupByLibrary.simpleMessage("确定"),
        "Conflict": MessageLookupByLibrary.simpleMessage("冲突"),
        "Dark": MessageLookupByLibrary.simpleMessage("暗色"),
        "Data_Directory": MessageLookupByLibrary.simpleMessage("存储文件夹"),
        "Decryption_Failed": MessageLookupByLibrary.simpleMessage("解密失败"),
        "Delete": MessageLookupByLibrary.simpleMessage("删除"),
        "Delete_Attachment": MessageLookupByLibrary.simpleMessage("删除附件"),
        "Delete_forever": MessageLookupByLibrary.simpleMessage("永久删除"),
        "Delete_selected": MessageLookupByLibrary.simpleMessage("删除选中"),
        "Dendron_is_a_VSCodeBased_NoteTaking_tool":
            MessageLookupByLibrary.simpleMessage("Dendron 是一个基于 IDEs 的笔记工具"),
        "Disable_Encryption": MessageLookupByLibrary.simpleMessage("取消加密"),
        "Do_you_really_want_to_delete_the_selected_notes":
            MessageLookupByLibrary.simpleMessage("确定要删除选中的文档吗？"),
        "Do_you_really_want_to_discard_your_current_changes":
            MessageLookupByLibrary.simpleMessage("确定放弃当前变量吗？"),
        "Do_you_want_to_delete_the_attachment": m0,
        "Do_you_want_to_exit_the_app":
            MessageLookupByLibrary.simpleMessage("确定要退出APP吗？"),
        "Do_you_want_to_recreate_the_tutorial_notes":
            MessageLookupByLibrary.simpleMessage("确定要重建教程文档吗？"),
        "Do_you_want_to_remove_the_tag_from_this_note": m1,
        "Editor": MessageLookupByLibrary.simpleMessage("编辑器"),
        "Enable_Dendron_support":
            MessageLookupByLibrary.simpleMessage("支持 Dendron 模式"),
        "Encrypt": MessageLookupByLibrary.simpleMessage("加密"),
        "Enter_Password": MessageLookupByLibrary.simpleMessage("输入密码"),
        "Exit": MessageLookupByLibrary.simpleMessage("退出"),
        "Experimental": MessageLookupByLibrary.simpleMessage("试验"),
        "Favorite": MessageLookupByLibrary.simpleMessage("收藏"),
        "Favorite_selected": MessageLookupByLibrary.simpleMessage("收藏选中"),
        "GitHub_Repo": MessageLookupByLibrary.simpleMessage("GitHub 仓库"),
        "Language": MessageLookupByLibrary.simpleMessage("语言"),
        "Light": MessageLookupByLibrary.simpleMessage("亮色"),
        "Location": MessageLookupByLibrary.simpleMessage("位置"),
        "More": MessageLookupByLibrary.simpleMessage("更多"),
        "Move_to_trash": MessageLookupByLibrary.simpleMessage("丢弃到回收站"),
        "NONE": MessageLookupByLibrary.simpleMessage("撤选"),
        "No_MD_title": MessageLookupByLibrary.simpleMessage("无文档标题"),
        "Ok": MessageLookupByLibrary.simpleMessage("完成"),
        "Pair_Quotes": MessageLookupByLibrary.simpleMessage("启用符号自动匹对"),
        "Pin": MessageLookupByLibrary.simpleMessage("置顶"),
        "Pin_selected": MessageLookupByLibrary.simpleMessage("置顶选中"),
        "Please_try_again_in_cd_second": m2,
        "Preview": MessageLookupByLibrary.simpleMessage("预览"),
        "Recreate": MessageLookupByLibrary.simpleMessage("重建"),
        "Recreate_tutorial_notes":
            MessageLookupByLibrary.simpleMessage("重建教程文档"),
        "Remove": MessageLookupByLibrary.simpleMessage("移除"),
        "Remove_Tag": MessageLookupByLibrary.simpleMessage("移除标签"),
        "Remove_Tag_from_selected_notes":
            MessageLookupByLibrary.simpleMessage("移除选中文档的标签"),
        "Restore": MessageLookupByLibrary.simpleMessage("恢复"),
        "Restore_from_trash": MessageLookupByLibrary.simpleMessage("从回收站恢复"),
        "Retry": MessageLookupByLibrary.simpleMessage("重试"),
        "Retry_password": MessageLookupByLibrary.simpleMessage("重试密码"),
        "Search": MessageLookupByLibrary.simpleMessage("搜索"),
        "Search_content_of_notes":
            MessageLookupByLibrary.simpleMessage("搜索包含文档内容"),
        "Select_accent_color": MessageLookupByLibrary.simpleMessage("选择强调色"),
        "Set_Password":
            MessageLookupByLibrary.simpleMessage("为当前文档设置密码（该密码不可找回！）"),
        "Settings": MessageLookupByLibrary.simpleMessage("设置"),
        "Show_virtual_tags":
            MessageLookupByLibrary.simpleMessage("Show virtual tags"),
        "Sort_by_Created_Date": MessageLookupByLibrary.simpleMessage("按创建日期排序"),
        "Sort_by_Title": MessageLookupByLibrary.simpleMessage("按标题排序"),
        "Sort_by_Updated_Date": MessageLookupByLibrary.simpleMessage("按更新日期排序"),
        "Sort_tags_alphabetically_in_the_sidebar":
            MessageLookupByLibrary.simpleMessage("按字符顺序为侧边栏标签排序"),
        "Star": MessageLookupByLibrary.simpleMessage("星标"),
        "Sync": MessageLookupByLibrary.simpleMessage("同步"),
        "Sync_Error": MessageLookupByLibrary.simpleMessage("同步出错"),
        "Tags": MessageLookupByLibrary.simpleMessage("标签"),
        "Theme": MessageLookupByLibrary.simpleMessage("主题"),
        "There_is_already_a_note_with_this_title":
            MessageLookupByLibrary.simpleMessage("该标题已存在"),
        "This_will_delete_them_permanently":
            MessageLookupByLibrary.simpleMessage("本操作将永久删除该文件"),
        "Trash": MessageLookupByLibrary.simpleMessage("丢弃"),
        "UnStar": MessageLookupByLibrary.simpleMessage("取消星标"),
        "Unfavorite": MessageLookupByLibrary.simpleMessage("取消收藏"),
        "Unfavorite_selected": MessageLookupByLibrary.simpleMessage("取消收藏选中"),
        "Unpin": MessageLookupByLibrary.simpleMessage("取消置顶"),
        "Unpin_selected": MessageLookupByLibrary.simpleMessage("取消置顶选中"),
        "Unsaved_changes": MessageLookupByLibrary.simpleMessage("变量未保存"),
        "Untagged": MessageLookupByLibrary.simpleMessage("无标签"),
        "Untitled": MessageLookupByLibrary.simpleMessage("未命名"),
        "Use_Mode_Switcher": MessageLookupByLibrary.simpleMessage("启用显示模式切换开关"),
        "Use_external_storage":
            MessageLookupByLibrary.simpleMessage("使用指定存储文件夹"),
        "countSelectedNotes": m3,
        "en": MessageLookupByLibrary.simpleMessage("English"),
        "zhCn": MessageLookupByLibrary.simpleMessage("中文-简体"),
        "zhHant": MessageLookupByLibrary.simpleMessage("中文-繁体")
      };
}
