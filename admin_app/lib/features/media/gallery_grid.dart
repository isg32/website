import 'package:flutter/material.dart';

import '../../core/providers.dart' show GalleryItem;
import 'asset_thumbnail.dart';

/// A wrap of gallery tiles (image or video, see AssetThumbnail) plus a
/// trailing "add" tile — shared between the work project and blog post
/// gallery sections, which are otherwise identical.
class GalleryGrid extends StatelessWidget {
  const GalleryGrid(
      {super.key,
      required this.items,
      required this.onAdd,
      required this.onRemove});

  final List<GalleryItem> items;
  final Future<void> Function() onAdd;
  final Future<void> Function(int galleryImageId) onRemove;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final item in items)
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                    width: 90,
                    height: 90,
                    child: AssetThumbnail(asset: item.asset)),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 16, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                    minimumSize: const Size(24, 24),
                  ),
                  onPressed: () => onRemove(item.galleryImageId),
                ),
              ),
            ],
          ),
        InkWell(
          onTap: onAdd,
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
