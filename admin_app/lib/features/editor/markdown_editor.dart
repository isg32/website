import 'package:flutter/material.dart';

import 'markdown_preview_pane.dart';

/// Toolbar + textarea for writing Markdown. Buttons insert/wrap Markdown
/// syntax at the current selection — there is no "U" (underline) button,
/// since underline isn't standard Markdown and isn't worth the sanitizer
/// complexity for one rarely-needed style. Video is the one exception that
/// does use raw-HTML passthrough (`<video>`, via "Insert video"), because
/// Markdown has no native video syntax at all — see the sanitizer allowlist
/// in src/lib/server/markdown.ts on the web side.
class MarkdownEditor extends StatelessWidget {
  const MarkdownEditor({
    super.key,
    required this.controller,
    this.focusNode,
    this.onInsertImage,
    this.onInsertVideo,
    this.minLines = 12,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;

  /// Returns the Markdown snippet to insert (e.g. `![](https://…)`), or
  /// null if the user cancelled. Wired by the parent screen to open the
  /// media picker sheet.
  final Future<String?> Function()? onInsertImage;

  /// Same shape as [onInsertImage], but for video — returns a raw `<video>`
  /// tag snippet (Markdown has no native video syntax; see
  /// src/lib/server/markdown.ts for the sanitizer allowlist that permits it).
  final Future<String?> Function()? onInsertVideo;

  final int minLines;

  void _wrapSelection(String before, String after, {String placeholder = ''}) {
    final selection = controller.selection;
    final text = controller.text;
    final start = selection.start < 0 ? text.length : selection.start;
    final end = selection.end < 0 ? text.length : selection.end;
    final selected = text.substring(start, end);
    final replacement = selected.isEmpty ? placeholder : selected;
    final newText = text.replaceRange(start, end, '$before$replacement$after');
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
          offset: start + before.length + replacement.length),
    );
  }

  void _prefixLine(String prefix) {
    final selection = controller.selection;
    final text = controller.text;
    final cursor = selection.start < 0 ? text.length : selection.start;
    final lineStart = text.lastIndexOf('\n', cursor - 1) + 1;
    final newText = text.replaceRange(lineStart, lineStart, prefix);
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: cursor + prefix.length),
    );
  }

  void _insertAtCursor(String snippet) {
    final selection = controller.selection;
    final text = controller.text;
    final start = selection.start < 0 ? text.length : selection.start;
    final end = selection.end < 0 ? start : selection.end;
    final newText = text.replaceRange(start, end, snippet);
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + snippet.length),
    );
  }

  Future<String?> _promptForUrl(BuildContext context) {
    final urlController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Link URL'),
        content: TextField(
          controller: urlController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'https://…'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, urlController.text),
            child: const Text('Insert'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          children: [
            IconButton(
              tooltip: 'Bold',
              icon: const Icon(Icons.format_bold),
              onPressed: () =>
                  _wrapSelection('**', '**', placeholder: 'bold text'),
            ),
            IconButton(
              tooltip: 'Italic',
              icon: const Icon(Icons.format_italic),
              onPressed: () =>
                  _wrapSelection('_', '_', placeholder: 'italic text'),
            ),
            IconButton(
              tooltip: 'Heading 1',
              icon: const Text('H1'),
              onPressed: () => _prefixLine('# '),
            ),
            IconButton(
              tooltip: 'Heading 2',
              icon: const Text('H2'),
              onPressed: () => _prefixLine('## '),
            ),
            IconButton(
              tooltip: 'Quote',
              icon: const Icon(Icons.format_quote),
              onPressed: () => _prefixLine('> '),
            ),
            IconButton(
              tooltip: 'Link',
              icon: const Icon(Icons.link),
              onPressed: () async {
                final url = await _promptForUrl(context);
                if (url != null && url.isNotEmpty) {
                  _wrapSelection('[', ']($url)', placeholder: 'link text');
                }
              },
            ),
            if (onInsertImage != null)
              IconButton(
                tooltip: 'Insert image',
                icon: const Icon(Icons.image_outlined),
                onPressed: () async {
                  final snippet = await onInsertImage!();
                  if (snippet != null) _insertAtCursor(snippet);
                },
              ),
            if (onInsertVideo != null)
              IconButton(
                tooltip: 'Insert video',
                icon: const Icon(Icons.videocam_outlined),
                onPressed: () async {
                  final snippet = await onInsertVideo!();
                  if (snippet != null) _insertAtCursor(snippet);
                },
              ),
          ],
        ),
        const Divider(height: 1),
        TextField(
          controller: controller,
          focusNode: focusNode,
          maxLines: null,
          minLines: minLines,
          style: const TextStyle(fontFamily: 'monospace'),
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(12),
            hintText: 'Write in Markdown…',
          ),
        ),
      ],
    );
  }
}

/// Write/Preview tabs wired to the same controller and renderer used
/// elsewhere in this app.
class MarkdownComposer extends StatefulWidget {
  const MarkdownComposer({
    super.key,
    required this.controller,
    this.onInsertImage,
    this.onInsertVideo,
  });

  final TextEditingController controller;
  final Future<String?> Function()? onInsertImage;
  final Future<String?> Function()? onInsertVideo;

  @override
  State<MarkdownComposer> createState() => _MarkdownComposerState();
}

class _MarkdownComposerState extends State<MarkdownComposer>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController =
      TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          tabs: const [Tab(text: 'Write'), Tab(text: 'Preview')],
        ),
        SizedBox(
          height: 420,
          child: TabBarView(
            controller: _tabController,
            children: [
              MarkdownEditor(
                controller: widget.controller,
                onInsertImage: widget.onInsertImage,
                onInsertVideo: widget.onInsertVideo,
              ),
              MarkdownPreviewPane(controller: widget.controller),
            ],
          ),
        ),
      ],
    );
  }
}
