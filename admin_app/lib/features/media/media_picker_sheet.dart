import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/db/models/media_asset.dart';
import '../../core/providers.dart';

/// Opens the Media Canvas as a bottom sheet. Tapping an asset (or uploading
/// a new one) returns the `![](secure_url)` Markdown snippet to insert at
/// the editor's cursor, or null if the user backed out.
Future<String?> showMediaPickerSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _MediaPickerSheet(onSelect: (asset) => '![](${asset.secureUrl})'),
  );
}

/// Same picker, but returns the selected/uploaded MediaAsset itself — used
/// for single-image fields like a project's thumbnail or example screenshot.
Future<MediaAsset?> showAssetPickerSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<MediaAsset>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _MediaPickerSheet(onSelect: (asset) => asset),
  );
}

class _MediaPickerSheet<T> extends ConsumerStatefulWidget {
  const _MediaPickerSheet({required this.onSelect});

  final T Function(MediaAsset asset) onSelect;

  @override
  ConsumerState<_MediaPickerSheet<T>> createState() => _MediaPickerSheetState<T>();
}

class _MediaPickerSheetState<T> extends ConsumerState<_MediaPickerSheet<T>> {
  String _search = '';
  bool _uploading = false;

  Future<void> _upload() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() => _uploading = true);
    try {
      final uploaded = await ref.read(cloudinaryServiceProvider).uploadImage(picked.path);
      final assetId = await ref
          .read(repositoryProvider)
          .insertMediaAsset(
            cloudinaryPublicId: uploaded.publicId,
            secureUrl: uploaded.secureUrl,
            format: uploaded.format,
            bytes: uploaded.bytes,
            width: uploaded.width,
            height: uploaded.height,
            originalFilename: picked.name,
          );
      ref.invalidate(mediaAssetsProvider);
      final asset = MediaAsset(
        id: assetId,
        cloudinaryPublicId: uploaded.publicId,
        secureUrl: uploaded.secureUrl,
        format: uploaded.format,
        resourceType: 'image',
        bytes: uploaded.bytes,
        width: uploaded.width,
        height: uploaded.height,
        originalFilename: picked.name,
        createdAt: DateTime.now(),
      );
      if (mounted) Navigator.of(context).pop(widget.onSelect(asset));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final assetsAsync = ref.watch(mediaAssetsProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Media Canvas', style: Theme.of(context).textTheme.titleLarge),
                  ),
                  IconButton(
                    icon: _uploading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.upload),
                    onPressed: _uploading ? null : _upload,
                  ),
                ],
              ),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Search archive…',
                  prefixIcon: Icon(Icons.search),
                  isDense: true,
                ),
                onChanged: (value) => setState(() => _search = value.toLowerCase()),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: assetsAsync.when(
                  data: (assets) {
                    final filtered = _search.isEmpty
                        ? assets
                        : assets
                              .where(
                                (a) => (a.originalFilename ?? '').toLowerCase().contains(_search),
                              )
                              .toList();
                    if (filtered.isEmpty) {
                      return const Center(child: Text('No assets found.'));
                    }
                    return GridView.builder(
                      controller: scrollController,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final asset = filtered[index];
                        return _AssetTile(
                          asset: asset,
                          onTap: () => Navigator.of(context).pop(widget.onSelect(asset)),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => Center(child: Text('Failed to load: $error')),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AssetTile extends StatelessWidget {
  const _AssetTile({required this.asset, required this.onTap});

  final MediaAsset asset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Ink.image(image: NetworkImage(asset.secureUrl), fit: BoxFit.cover),
    );
  }
}
