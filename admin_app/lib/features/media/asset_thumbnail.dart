import 'package:flutter/material.dart';

import '../../core/db/models/media_asset.dart';

/// Renders a media asset as a thumbnail. Images render inline via
/// Image.network; video has no inline player in this app (no video_player
/// dependency yet), so it renders as a placeholder tile with a play icon
/// instead — see admin-panel.html's <video muted> for the web equivalent.
class AssetThumbnail extends StatelessWidget {
  const AssetThumbnail(
      {super.key, required this.asset, this.fit = BoxFit.cover});

  final MediaAsset asset;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (asset.resourceType == 'video') {
      return Container(
        color: Colors.black87,
        alignment: Alignment.center,
        child: const Icon(Icons.play_circle_outline,
            color: Colors.white, size: 32),
      );
    }
    return Image.network(asset.secureUrl, fit: fit);
  }
}
