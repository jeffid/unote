import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/themes/a11y-light.dart';
import 'package:markdown_widget/markdown_widget.dart';

import '/utils/logger.dart';

///
class PreviewPage extends StatefulWidget {
  ///
  PreviewPage(this.textContent);

  final String textContent;
  // final NotesStore store;
  // final RichCodeEditingController richCtrl;
  // final ThemeData theme;

  ///
  @override
  _PreviewPageState createState() => _PreviewPageState();
}

///
class _PreviewPageState extends State<PreviewPage> {
  //
  final _tocController = TocController();

  ///
  @override
  // Widget build(BuildContext context) => Scaffold(body: _buildMarkdown(context));
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          // Expanded(child: _buildTocWidget()),
          // Expanded(child: _buildMarkdown(context), flex: 3)
          Expanded(child: _buildMarkdown(context), flex: 1)
        ],
      ),
    );
  }

  ///
  Widget _buildTocWidget() => TocWidget(controller: _tocController);

  ///
  Widget _buildMarkdown(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final MarkdownConfig config =
        isDark ? MarkdownConfig.darkConfig : MarkdownConfig.defaultConfig;
    final codeWrapper =
        (child, text, language) => CodeWrapperWidget(child, text, language);

    return Padding(
      padding: EdgeInsets.fromLTRB(6, 4, 6, 4),
      child: MarkdownWidget(
        data: widget.textContent,
        tocController: _tocController,
        config: config.copy(
          configs: [
            isDark
                ? PreConfig.darkConfig.copy(wrapper: codeWrapper)
                : PreConfig().copy(wrapper: codeWrapper),
            PreConfig(theme: a11yLightTheme),
            LinkConfig(
              style: TextStyle(
                color: Colors.red,
                decoration: TextDecoration.underline,
              ),
              onTap: (url) {
                logger.d('Tapped on link: $url');
              },
            ),
          ],
        ),
      ),
    );
  }
}

///
class CodeWrapperWidget extends StatefulWidget {
  ///
  const CodeWrapperWidget(this.child, this.text, this.language, {Key? key})
      : super(key: key);

  final Widget child;
  final String text;
  final String language;

  ///
  @override
  State<CodeWrapperWidget> createState() => _PreWrapperState();
}

///
class _PreWrapperState extends State<CodeWrapperWidget> {
  ///
  late Widget _switchWidget;
  ///
  bool hasCopied = false;

  ///
  @override
  void initState() {
    super.initState();
    _switchWidget = Icon(Icons.copy_rounded, key: UniqueKey());
  }

  ///
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    //
    return Stack(
      children: [
        widget.child,
        Align(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.language.isNotEmpty)
                  SelectionContainer.disabled(
                    child: Container(
                      child: Text(widget.language),
                      margin: EdgeInsets.only(right: 2),
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            width: 0.5,
                            color: isDark ? Colors.white : Colors.black),
                      ),
                    ),
                  ),
                InkWell(
                  child: AnimatedSwitcher(
                    child: _switchWidget,
                    duration: Duration(milliseconds: 200),
                  ),
                  onTap: () async {
                    if (hasCopied) return;
                    await Clipboard.setData(ClipboardData(text: widget.text));
                    _switchWidget = Icon(Icons.check, key: UniqueKey());
                    refresh();
                    Future.delayed(Duration(seconds: 2), () {
                      hasCopied = false;
                      _switchWidget =
                          Icon(Icons.copy_rounded, key: UniqueKey());
                      refresh();
                    });
                  },
                ),
              ],
            ),
          ),
          alignment: Alignment.topRight,
        )
      ],
    );
  }

  ///
  void refresh() {
    if (mounted) setState(() {});
  }
}
