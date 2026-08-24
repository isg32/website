import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/db/models/media_asset.dart';
import '../../core/providers.dart';

class MediaLibraryScreen extends ConsumerStatefulWidget {
  const MediaLibraryScreen({super.key});

  @override
  ConsumerState<MediaLibraryScreen> createState() => _MediaLibraryScreenState();
}

class _MediaLibraryScreenState extends ConsumerState<MediaLibraryScreen> {
  bool _uploading = false;

  Future<void> _upload() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() => _uploading = true);
    try {
      final uploaded = await ref.read(cloudinaryServiceProvider).uploadImage(picked.path);
      await ref
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _createCollection() async {
    final nameController = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New collection'),
        content: TextField(controller: nameController, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, nameController.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    final slug = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    await ref.read(repositoryProvider).createMediaCollection(name: name, slug: slug);
    ref.invalidate(mediaCollectionsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final assetsAsync = ref.watch(mediaAssetsProvider);
    final collectionsAsync = ref.watch(mediaCollectionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintain Gallery'),
        actions: [
          IconButton(
            icon: const Icon(Icons.create_new_folder_outlined),
            tooltip: 'New collection',
            onPressed: _createCollection,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _uploading ? null : _upload,
        backgroundColor: Colors.black,
        child: _uploading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.add_photo_alternate_outlined),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          collectionsAsync.when(
            data: (collections) => Wrap(
              spacing: 8,
              children: collections
                  .map((c) => Chip(label: Text(c.name)))
                  .toList(growable: false),
            ),
            loading: () => const SizedBox.shrink(),
            error: (error, stackTrace) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 16),
          Text('All assets', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          assetsAsync.when(
            data: (assets) {
              if (assets.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: Text('No assets uploaded yet.')),
                );
              }
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: assets.length,
                itemBuilder: (context, index) => _AssetCard(asset: assets[index]),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text('Failed to load: $error'),
          ),
        ],
      ),
    );
  }
}

class _AssetCard extends StatelessWidget {
  const _AssetCard({required this.asset});

  final MediaAsset asset;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(asset.secureUrl, fit: BoxFit.cover),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.black54,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(
                asset.originalFilename ?? asset.cloudinaryPublicId,
                style: const TextStyle(color: Colors.white, fontSize: 10),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
