import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/models/enums.dart';
import '../../core/db/models/media_asset.dart';
import '../../core/db/models/work_project.dart';
import '../../core/providers.dart';
import '../../core/utils/slugify.dart';
import '../editor/markdown_editor.dart';
import '../media/gallery_grid.dart';
import '../media/media_picker_sheet.dart';

class WorkEditScreen extends ConsumerStatefulWidget {
  const WorkEditScreen({super.key, this.project});

  /// Null when creating a new project.
  final WorkProject? project;

  @override
  ConsumerState<WorkEditScreen> createState() => _WorkEditScreenState();
}

class _WorkEditScreenState extends ConsumerState<WorkEditScreen> {
  late final _titleController =
      TextEditingController(text: widget.project?.title ?? '');
  late final _slugController =
      TextEditingController(text: widget.project?.slug ?? '');
  late final _subtitleController =
      TextEditingController(text: widget.project?.subtitle ?? '');
  late final _summaryController =
      TextEditingController(text: widget.project?.summary ?? '');
  late final _repoUrlController =
      TextEditingController(text: widget.project?.repoUrl ?? '');
  late final _liveUrlController =
      TextEditingController(text: widget.project?.liveUrl ?? '');
  late final _contentController = TextEditingController(
    text: widget.project?.contentMarkdown ?? '',
  );

  bool _slugEdited = false;
  int? _categoryId;
  MediaAsset? _thumbnail;
  MediaAsset? _screenshot;
  bool _saving = false;

  int? _savedProjectId;

  @override
  void initState() {
    super.initState();
    _categoryId = widget.project?.categoryId;
    _slugEdited = widget.project != null;
    _savedProjectId = widget.project?.id;
    _titleController.addListener(() {
      if (!_slugEdited) {
        _slugController.text = slugify(_titleController.text);
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _slugController.dispose();
    _subtitleController.dispose();
    _summaryController.dispose();
    _repoUrlController.dispose();
    _liveUrlController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickThumbnail() async {
    final asset = await showAssetPickerSheet(context, ref);
    if (asset != null) setState(() => _thumbnail = asset);
  }

  Future<void> _pickScreenshot() async {
    final asset = await showAssetPickerSheet(context, ref);
    if (asset != null) setState(() => _screenshot = asset);
  }

  Future<int> _ensureSaved() async {
    final repo = ref.read(repositoryProvider);
    if (_savedProjectId == null) {
      _savedProjectId = await repo.createWorkProject(
        title: _titleController.text.trim(),
        slug: _slugController.text.trim(),
      );
    }
    await repo.updateWorkProject(
      id: _savedProjectId!,
      title: _titleController.text.trim(),
      slug: _slugController.text.trim(),
      categoryId: _categoryId,
      subtitle: _subtitleController.text.trim().isEmpty
          ? null
          : _subtitleController.text.trim(),
      summary: _summaryController.text.trim().isEmpty
          ? null
          : _summaryController.text.trim(),
      thumbnailAssetId: _thumbnail?.id ?? widget.project?.thumbnailAssetId,
      exampleScreenshotAssetId:
          _screenshot?.id ?? widget.project?.exampleScreenshotAssetId,
      repoUrl: _repoUrlController.text.trim().isEmpty
          ? null
          : _repoUrlController.text.trim(),
      liveUrl: _liveUrlController.text.trim().isEmpty
          ? null
          : _liveUrlController.text.trim(),
      contentMarkdown: _contentController.text,
    );
    return _savedProjectId!;
  }

  Future<void> _save({ContentStatus? setStatus}) async {
    if (_titleController.text.trim().isEmpty ||
        _slugController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
          const SnackBar(content: Text('Title and slug are required.')));
      return;
    }
    setState(() => _saving = true);
    try {
      final id = await _ensureSaved();
      if (setStatus != null) {
        await ref.read(repositoryProvider).setWorkProjectStatus(id, setStatus);
      }
      invalidateContentProviders(ref);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(setStatus == ContentStatus.published
                  ? 'Published.'
                  : 'Saved.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Save failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(workCategoriesProvider);
    final galleryAsync = _savedProjectId == null
        ? null
        : ref.watch(workGalleryProvider(_savedProjectId!));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project == null ? 'New Project' : 'Edit Project'),
        actions: [
          TextButton(
            onPressed:
                _saving ? null : () => _save(setStatus: ContentStatus.draft),
            child:
                const Text('Save Draft', style: TextStyle(color: Colors.black)),
          ),
          FilledButton(
            onPressed: _saving
                ? null
                : () => _save(setStatus: ContentStatus.published),
            style: FilledButton.styleFrom(backgroundColor: Colors.black),
            child: const Text('Publish'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _slugController,
            decoration: const InputDecoration(labelText: 'Slug'),
            onChanged: (_) => _slugEdited = true,
          ),
          const SizedBox(height: 12),
          categoriesAsync.when(
            data: (categories) => DropdownButtonFormField<int?>(
              value: _categoryId,
              decoration: const InputDecoration(labelText: 'Category'),
              items: [
                const DropdownMenuItem(
                    value: null, child: Text('Uncategorized')),
                ...categories.map(
                    (c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
              ],
              onChanged: (value) => setState(() => _categoryId = value),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (error, stackTrace) =>
                Text('Failed to load categories: $error'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _subtitleController,
            decoration: const InputDecoration(labelText: 'Subtitle'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _summaryController,
            decoration: const InputDecoration(
                labelText: 'Summary (listing card description)'),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _repoUrlController,
                  decoration: const InputDecoration(labelText: 'Repo URL'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _liveUrlController,
                  decoration: const InputDecoration(labelText: 'Live URL'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _AssetPickerField(
            label: 'Thumbnail',
            assetUrl: _thumbnail?.secureUrl,
            onPick: _pickThumbnail,
          ),
          const SizedBox(height: 12),
          _AssetPickerField(
            label: 'Example screenshot',
            assetUrl: _screenshot?.secureUrl,
            onPick: _pickScreenshot,
          ),
          const SizedBox(height: 20),
          Text('Content', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          MarkdownComposer(
            controller: _contentController,
            onInsertImage: () => showMediaPickerSheet(context, ref),
            onInsertVideo: () => showMediaPickerSheet(context, ref),
          ),
          const SizedBox(height: 24),
          Text('Gallery', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (_savedProjectId == null)
            const Text(
              'Save the project first to attach gallery images.',
              style: TextStyle(color: Colors.grey),
            )
          else
            galleryAsync!.when(
              data: (items) => GalleryGrid(
                items: items,
                onAdd: () async {
                  final asset = await showAssetPickerSheet(context, ref);
                  if (asset != null) {
                    await ref.read(repositoryProvider).addWorkGalleryImage(
                          _savedProjectId!,
                          asset.id,
                        );
                    ref.invalidate(workGalleryProvider(_savedProjectId!));
                  }
                },
                onRemove: (galleryImageId) async {
                  await ref
                      .read(repositoryProvider)
                      .removeWorkGalleryImage(galleryImageId);
                  ref.invalidate(workGalleryProvider(_savedProjectId!));
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) =>
                  Text('Failed to load gallery: $error'),
            ),
          const SizedBox(height: 32),
          if (widget.project != null) ...[
            OutlinedButton(
              onPressed:
                  _saving ? null : () => _save(setStatus: ContentStatus.hidden),
              child: const Text('Hide'),
            ),
          ],
        ],
      ),
    );
  }
}

class _AssetPickerField extends StatelessWidget {
  const _AssetPickerField(
      {required this.label, required this.assetUrl, required this.onPick});

  final String label;
  final String? assetUrl;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPick,
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(4),
              image: assetUrl != null
                  ? DecorationImage(
                      image: NetworkImage(assetUrl!), fit: BoxFit.cover)
                  : null,
            ),
            child: assetUrl == null
                ? const Icon(Icons.image_outlined, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }
}
