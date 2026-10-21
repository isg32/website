import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth/auth_gate_service.dart';
import 'cloudinary/cloudinary_service.dart';
import 'db/db_client.dart';
import 'db/models/blog_post.dart';
import 'db/models/media_asset.dart';
import 'db/models/media_collection.dart';
import 'db/models/work_category.dart';
import 'db/models/work_project.dart';
import 'db/repository.dart';

final dbClientProvider = Provider<DbClient>((ref) => DbClient.instance);

final repositoryProvider =
    Provider<Repository>((ref) => Repository(ref.watch(dbClientProvider)));

final authGateServiceProvider =
    Provider<AuthGateService>((ref) => AuthGateService());

final cloudinaryServiceProvider =
    Provider<CloudinaryService>((ref) => CloudinaryService());

/// Whether the app-level login gate currently considers the user signed in.
/// Not tied to any per-request auth — see AuthGateService for why.
class SessionNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() {
    return ref.read(authGateServiceProvider).hasValidSession();
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(authGateServiceProvider)
          .signIn(email: email, password: password);
      return true;
    });
  }

  Future<void> signOut() async {
    await ref.read(authGateServiceProvider).signOut();
    state = const AsyncData(false);
  }
}

final sessionProvider =
    AsyncNotifierProvider<SessionNotifier, bool>(SessionNotifier.new);

final workCategoriesProvider =
    FutureProvider.autoDispose<List<WorkCategory>>((ref) async {
  final db = ref.watch(dbClientProvider);
  final rows =
      await db.query('SELECT * FROM work_categories ORDER BY sort_order, name');
  return rows.map(WorkCategory.fromRow).toList();
});

final workProjectsProvider =
    FutureProvider.autoDispose<List<WorkProject>>((ref) async {
  final db = ref.watch(dbClientProvider);
  final rows =
      await db.query('SELECT * FROM work_projects ORDER BY created_at DESC');
  return rows.map(WorkProject.fromRow).toList();
});

final blogPostsProvider =
    FutureProvider.autoDispose<List<BlogPost>>((ref) async {
  final db = ref.watch(dbClientProvider);
  final rows =
      await db.query('SELECT * FROM blog_posts ORDER BY created_at DESC');
  return rows.map(BlogPost.fromRow).toList();
});

final mediaAssetsProvider =
    FutureProvider.autoDispose<List<MediaAsset>>((ref) async {
  final db = ref.watch(dbClientProvider);
  final rows =
      await db.query('SELECT * FROM media_assets ORDER BY created_at DESC');
  return rows.map(MediaAsset.fromRow).toList();
});

final mediaCollectionsProvider =
    FutureProvider.autoDispose<List<MediaCollection>>((ref) async {
  final db = ref.watch(dbClientProvider);
  final rows = await db.query('SELECT * FROM media_collections ORDER BY name');
  return rows.map(MediaCollection.fromRow).toList();
});

class GalleryItem {
  const GalleryItem(
      {required this.galleryImageId,
      required this.caption,
      required this.asset});

  final int galleryImageId;
  final String? caption;
  final MediaAsset asset;
}

/// A project's gallery images (bottom-of-detail-page grid), in order.
final workGalleryProvider = FutureProvider.autoDispose
    .family<List<GalleryItem>, int>((ref, workProjectId) async {
  final db = ref.watch(dbClientProvider);
  final rows = await db.query(
    '''
    SELECT wgi.id AS gallery_image_id, wgi.caption, ma.*
    FROM work_gallery_images wgi
    INNER JOIN media_assets ma ON ma.id = wgi.media_asset_id
    WHERE wgi.work_project_id = @id
    ORDER BY wgi.sort_order
    ''',
    {'id': workProjectId},
  );
  return rows
      .map(
        (row) => GalleryItem(
          galleryImageId: row['gallery_image_id'] as int,
          caption: row['caption'] as String?,
          asset: MediaAsset.fromRow(row),
        ),
      )
      .toList();
});

/// A blog post's gallery images (bottom-of-detail-page grid), in order.
final blogGalleryProvider = FutureProvider.autoDispose
    .family<List<GalleryItem>, int>((ref, blogPostId) async {
  final db = ref.watch(dbClientProvider);
  final rows = await db.query(
    '''
    SELECT bgi.id AS gallery_image_id, bgi.caption, ma.*
    FROM blog_gallery_images bgi
    INNER JOIN media_assets ma ON ma.id = bgi.media_asset_id
    WHERE bgi.blog_post_id = @id
    ORDER BY bgi.sort_order
    ''',
    {'id': blogPostId},
  );
  return rows
      .map(
        (row) => GalleryItem(
          galleryImageId: row['gallery_image_id'] as int,
          caption: row['caption'] as String?,
          asset: MediaAsset.fromRow(row),
        ),
      )
      .toList();
});

/// Assets belonging to one collection, for the Media Canvas grouped view.
final collectionAssetsProvider = FutureProvider.autoDispose
    .family<List<MediaAsset>, int>((ref, collectionId) async {
  final db = ref.watch(dbClientProvider);
  final rows = await db.query(
    '''
    SELECT ma.* FROM media_assets ma
    INNER JOIN media_collection_assets mca ON mca.media_asset_id = ma.id
    WHERE mca.collection_id = @collectionId
    ORDER BY mca.sort_order
    ''',
    {'collectionId': collectionId},
  );
  return rows.map(MediaAsset.fromRow).toList();
});

/// Invalidates every list provider that reads from the DB — call after any
/// mutation so screens refetch, mirroring the web app's invalidateAll().
void invalidateContentProviders(WidgetRef ref) {
  ref.invalidate(workCategoriesProvider);
  ref.invalidate(workProjectsProvider);
  ref.invalidate(blogPostsProvider);
  ref.invalidate(mediaAssetsProvider);
  ref.invalidate(mediaCollectionsProvider);
}
