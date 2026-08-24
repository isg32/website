import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

/// Live preview of a Markdown TextEditingController's contents, debounced
/// off text changes so it doesn't re-render on every keystroke.
class MarkdownPreviewPane extends StatefulWidget {
  const MarkdownPreviewPane({super.key, required this.controller});

  final TextEditingController controller;

  @override
  State<MarkdownPreviewPane> createState() => _MarkdownPreviewPaneState();
}

class _MarkdownPreviewPaneState extends State<MarkdownPreviewPane> {
  Timer? _debounce;
  late String _text = widget.controller.text;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  void _onChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _text = widget.controller.text);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_text.trim().isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Text('Nothing to preview yet…', style: TextStyle(color: Colors.grey)),
      );
    }
    return Markdown(data: _text, padding: const EdgeInsets.all(12));
  }
}
