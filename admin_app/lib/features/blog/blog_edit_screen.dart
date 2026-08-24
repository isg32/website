import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/models/blog_post.dart';
import '../../core/db/models/enums.dart';
import '../../core/db/models/media_asset.dart';
import '../../core/providers.dart';
import '../../core/utils/slugify.dart';
import '../editor/markdown_editor.dart';
import '../media/media_picker_sheet.dart';

class BlogEditScreen extends ConsumerStatefulWidget {
  const BlogEditScreen({super.key, this.post});

  /// Null when creating a new post.
  final BlogPost? post;

  @override
  ConsumerState<BlogEditScreen> createState() => _BlogEditScreenState();
}

class _BlogEditScreenState extends ConsumerState<BlogEditScreen> {
  late final _titleController = TextEditingController(text: widget.post?.title ?? '');
  late final _slugController = TextEditingController(text: widget.post?.slug ?? '');
  late final _excerptController = TextEditingController(text: widget.post?.excerpt ?? '');
  late final _quoteController = TextEditingController(text: widget.post?.quoteText ?? '');
  late final _contentController = TextEditingController(text: widget.post?.contentMarkdown ?? '');

  late BlogPostType _postType = widget.post?.postType ?? BlogPostType.article;
  bool _slugEdited = false;
  MediaAsset? _thumbnail;
  bool _saving = false;
  int? _savedPostId;

  @override
  void initState() {
    super.initState();
    _slugEdited = widget.post != null;
    _savedPostId = widget.post?.id;
    _titleController.addListener(_maybeAutoSlug);
    _quoteController.addListener(_maybeAutoSlug);
  }

  void _maybeAutoSlug() {
    if (_slugEdited) return;
    if (_postType == BlogPostType.article) {
      _slugController.text = slugify(_titleController.text);
    } else {
      final base = _quoteController.text.trim();
      _slugController.text = base.isEmpty
          ? 'quote-${DateTime.now().toIso8601String().substring(0, 10)}'
          : slugify(base.split(' ').take(6).join(' '));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _slugController.dispose();
    _excerptController.dispose();
    _quoteController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickThumbnail() async {
    final asset = await showAssetPickerSheet(context, ref);
    if (asset != null) setState(() => _thumbnail = asset);
  }

  Future<int> _ensureSaved() async {
    final repo = ref.read(repositoryProvider);
    if (_slugController.text.trim().isEmpty) _maybeAutoSlug();

    if (_savedPostId == null) {
      _savedPostId = await repo.createBlogPost(postType: _postType, slug: _slugController.text.trim());
    }
    await repo.updateBlogPost(
      id: _savedPostId!,
      postType: _postType,
      slug: _slugController.text.trim(),
      title: _postType == BlogPostType.article && _titleController.text.trim().isNotEmpty
          ? _titleController.text.trim()
          : null,
      excerpt: _excerptController.text.trim().isEmpty ? null : _excerptController.text.trim(),
      quoteText: _postType == BlogPostType.quote && _quoteController.text.trim().isNotEmpty
          ? _quoteController.text.trim()
          : null,
      thumbnailAssetId: _thumbnail?.id ?? widget.post?.thumbnailAssetId,
      contentMarkdown: _contentController.text,
    );
    return _savedPostId!;
  }

  Future<void> _save({ContentStatus? setStatus}) async {
    if (_postType == BlogPostType.article && _titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Articles need a title.')));
      return;
    }
    if (_postType == BlogPostType.quote && _quoteController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Quote posts need quote text.')));
      return;
    }
    setState(() => _saving = true);
    try {
      final id = await _ensureSaved();
      if (setStatus != null) {
        await ref.read(repositoryProvider).setBlogPostStatus(id, setStatus);
      }
      invalidateContentProviders(ref);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post == null ? 'New Post' : 'Edit Post'),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => _save(setStatus: ContentStatus.draft),
            child: const Text('Save Draft', style: TextStyle(color: Colors.black)),
          ),
          FilledButton(
            onPressed: _saving ? null : () => _save(setStatus: ContentStatus.published),
            style: FilledButton.styleFrom(backgroundColor: Colors.black),
            child: const Text('Publish'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<BlogPostType>(
            segments: const [
              ButtonSegment(value: BlogPostType.article, label: Text('Article')),
              ButtonSegment(value: BlogPostType.quote, label: Text('Quote')),
            ],
            selected: {_postType},
            onSelectionChanged: (selection) =>
                setState(() => _postType = selection.first),
          ),
          const SizedBox(height: 16),
          if (_postType == BlogPostType.article) ...[
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _excerptController,
              decoration: const InputDecoration(labelText: 'Excerpt (archive card summary)'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickThumbnail,
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(4),
                      image: _thumbnail != null
                          ? DecorationImage(
                              image: NetworkImage(_thumbnail!.secureUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _thumbnail == null
                        ? const Icon(Icons.image_outlined, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  const Text('Thumbnail'),
                ],
              ),
            ),
          ] else ...[
            TextField(
              controller: _quoteController,
              decoration: const InputDecoration(labelText: 'Quote text'),
              maxLines: 3,
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: _slugController,
            decoration: const InputDecoration(labelText: 'Slug'),
            onChanged: (_) => _slugEdited = true,
          ),
          const SizedBox(height: 20),
          Text('Content', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          MarkdownComposer(
            controller: _contentController,
            onInsertImage: () => showMediaPickerSheet(context, ref),
          ),
          const SizedBox(height: 32),
          if (widget.post != null)
            OutlinedButton(
              onPressed: _saving ? null : () => _save(setStatus: ContentStatus.hidden),
              child: const Text('Hide'),
            ),
        ],
      ),
    );
  }
}
