import 'db_client.dart';
import 'models/enums.dart';

/// Direct-SQL mutations used by the admin screens. Mirrors the SvelteKit
/// side's src/lib/server/db/queries/ modules, except these ones write.
/// Only ever DML here — schema changes belong to Drizzle migrations.
class Repository {
  Repository(this._db);

  final DbClient _db;

  // ---- Work categories ----------------------------------------------

  Future<int> createWorkCategory(
      {required String name, required String slug}) async {
    final rows = await _db.execute(
      'INSERT INTO work_categories (name, slug) VALUES (@name, @slug) RETURNING id',
      {'name': name, 'slug': slug},
    );
    return rows.first['id'] as int;
  }

  Future<void> renameWorkCategory(int id,
      {required String name, required String slug}) async {
    await _db.execute(
      'UPDATE work_categories SET name = @name, slug = @slug WHERE id = @id',
      {'id': id, 'name': name, 'slug': slug},
    );
  }

  Future<void> deleteWorkCategory(int id) async {
    // work_projects.category_id is ON DELETE SET NULL — safe, items fall
    // back to "Uncategorized" on the public site rather than being blocked.
    await _db.execute('DELETE FROM work_categories WHERE id = @id', {'id': id});
  }

  // ---- Media -----------------------------------------------------------

  Future<int> insertMediaAsset({
    required String cloudinaryPublicId,
    required String secureUrl,
    String? format,
    String resourceType = 'image',
    int? bytes,
    int? width,
    int? height,
    String? originalFilename,
  }) async {
    final rows = await _db.execute(
      '''
      INSERT INTO media_assets
        (cloudinary_public_id, secure_url, format, resource_type, bytes, width, height, original_filename)
      VALUES
        (@publicId, @secureUrl, @format, @resourceType, @bytes, @width, @height, @originalFilename)
      RETURNING id
      ''',
      {
        'publicId': cloudinaryPublicId,
        'secureUrl': secureUrl,
        'format': format,
        'resourceType': resourceType,
        'bytes': bytes,
        'width': width,
        'height': height,
        'originalFilename': originalFilename,
      },
    );
    return rows.first['id'] as int;
  }

  Future<int> createMediaCollection(
      {required String name, required String slug}) async {
    final rows = await _db.execute(
      'INSERT INTO media_collections (name, slug) VALUES (@name, @slug) RETURNING id',
      {'name': name, 'slug': slug},
    );
    return rows.first['id'] as int;
  }

  Future<void> addAssetToCollection(int assetId, int collectionId) async {
    await _db.execute(
      '''
      INSERT INTO media_collection_assets (collection_id, media_asset_id)
      VALUES (@collectionId, @assetId)
      ON CONFLICT DO NOTHING
      ''',
      {'collectionId': collectionId, 'assetId': assetId},
    );
  }

  // ---- Work projects -----------------------------------------------------

  Future<int> createWorkProject({
    required String title,
    required String slug,
    int? categoryId,
    String? subtitle,
    String? summary,
    int? thumbnailAssetId,
    String contentMarkdown = '',
  }) async {
    final rows = await _db.execute(
      '''
      INSERT INTO work_projects
        (title, slug, category_id, subtitle, summary, thumbnail_asset_id, content_markdown)
      VALUES
        (@title, @slug, @categoryId, @subtitle, @summary, @thumbnailAssetId, @contentMarkdown)
      RETURNING id
      ''',
      {
        'title': title,
        'slug': slug,
        'categoryId': categoryId,
        'subtitle': subtitle,
        'summary': summary,
        'thumbnailAssetId': thumbnailAssetId,
        'contentMarkdown': contentMarkdown,
      },
    );
    return rows.first['id'] as int;
  }

  Future<void> updateWorkProject({
    required int id,
    required String title,
    required String slug,
    int? categoryId,
    String? subtitle,
    String? summary,
    int? thumbnailAssetId,
    int? exampleScreenshotAssetId,
    String? repoUrl,
    String? liveUrl,
    required String contentMarkdown,
  }) async {
    await _db.execute(
      '''
      UPDATE work_projects SET
        title = @title,
        slug = @slug,
        category_id = @categoryId,
        subtitle = @subtitle,
        summary = @summary,
        thumbnail_asset_id = @thumbnailAssetId,
        example_screenshot_asset_id = @exampleScreenshotAssetId,
        repo_url = @repoUrl,
        live_url = @liveUrl,
        content_markdown = @contentMarkdown,
        updated_at = now()
      WHERE id = @id
      ''',
      {
        'id': id,
        'title': title,
        'slug': slug,
        'categoryId': categoryId,
        'subtitle': subtitle,
        'summary': summary,
        'thumbnailAssetId': thumbnailAssetId,
        'exampleScreenshotAssetId': exampleScreenshotAssetId,
        'repoUrl': repoUrl,
        'liveUrl': liveUrl,
        'contentMarkdown': contentMarkdown,
      },
    );
  }

  Future<void> deleteWorkProject(int id) async {
    await _db.execute('DELETE FROM work_projects WHERE id = @id', {'id': id});
  }

  Future<void> setWorkProjectStatus(int id, ContentStatus status) async {
    await _setContentStatus(table: 'work_projects', id: id, status: status);
  }

  /// Appends to the end of the gallery unless [sortOrder] is given.
  Future<void> addWorkGalleryImage(int workProjectId, int mediaAssetId,
      {int? sortOrder}) async {
    await _db.execute(
      '''
      INSERT INTO work_gallery_images (work_project_id, media_asset_id, sort_order)
      VALUES (@workProjectId, @mediaAssetId, COALESCE(@sortOrder::int, (
        SELECT COALESCE(MAX(sort_order) + 1, 0) FROM work_gallery_images
        WHERE work_project_id = @workProjectId
      )))
      ''',
      {
        'workProjectId': workProjectId,
        'mediaAssetId': mediaAssetId,
        'sortOrder': sortOrder
      },
    );
  }

  Future<void> removeWorkGalleryImage(int id) async {
    await _db
        .execute('DELETE FROM work_gallery_images WHERE id = @id', {'id': id});
  }

  // ---- Blog posts ----------------------------------------------------

  Future<int> createBlogPost({
    required BlogPostType postType,
    required String slug,
    String? title,
    String? excerpt,
    String? quoteText,
    int? thumbnailAssetId,
    String contentMarkdown = '',
  }) async {
    final rows = await _db.execute(
      '''
      INSERT INTO blog_posts
        (post_type, slug, title, excerpt, quote_text, thumbnail_asset_id, content_markdown)
      VALUES
        (@postType::blog_post_type, @slug, @title, @excerpt, @quoteText, @thumbnailAssetId, @contentMarkdown)
      RETURNING id
      ''',
      {
        'postType': postType.sqlValue,
        'slug': slug,
        'title': title,
        'excerpt': excerpt,
        'quoteText': quoteText,
        'thumbnailAssetId': thumbnailAssetId,
        'contentMarkdown': contentMarkdown,
      },
    );
    return rows.first['id'] as int;
  }

  Future<void> updateBlogPost({
    required int id,
    required BlogPostType postType,
    required String slug,
    String? title,
    String? excerpt,
    String? quoteText,
    int? thumbnailAssetId,
    required String contentMarkdown,
  }) async {
    await _db.execute(
      '''
      UPDATE blog_posts SET
        post_type = @postType::blog_post_type,
        slug = @slug,
        title = @title,
        excerpt = @excerpt,
        quote_text = @quoteText,
        thumbnail_asset_id = @thumbnailAssetId,
        content_markdown = @contentMarkdown,
        updated_at = now()
      WHERE id = @id
      ''',
      {
        'id': id,
        'postType': postType.sqlValue,
        'slug': slug,
        'title': title,
        'excerpt': excerpt,
        'quoteText': quoteText,
        'thumbnailAssetId': thumbnailAssetId,
        'contentMarkdown': contentMarkdown,
      },
    );
  }

  Future<void> deleteBlogPost(int id) async {
    await _db.execute('DELETE FROM blog_posts WHERE id = @id', {'id': id});
  }

  Future<void> setBlogPostStatus(int id, ContentStatus status) async {
    await _setContentStatus(table: 'blog_posts', id: id, status: status);
  }

  /// Appends to the end of the gallery unless [sortOrder] is given.
  Future<void> addBlogGalleryImage(int blogPostId, int mediaAssetId,
      {int? sortOrder}) async {
    await _db.execute(
      '''
      INSERT INTO blog_gallery_images (blog_post_id, media_asset_id, sort_order)
      VALUES (@blogPostId, @mediaAssetId, COALESCE(@sortOrder::int, (
        SELECT COALESCE(MAX(sort_order) + 1, 0) FROM blog_gallery_images
        WHERE blog_post_id = @blogPostId
      )))
      ''',
      {
        'blogPostId': blogPostId,
        'mediaAssetId': mediaAssetId,
        'sortOrder': sortOrder
      },
    );
  }

  Future<void> removeBlogGalleryImage(int id) async {
    await _db
        .execute('DELETE FROM blog_gallery_images WHERE id = @id', {'id': id});
  }

  // ---- shared status transition -----------------------------------------

  /// published_at is set once, on first transition to 'published', and
  /// preserved across later published <-> hidden toggles.
  Future<void> _setContentStatus({
    required String table,
    required int id,
    required ContentStatus status,
  }) async {
    if (status == ContentStatus.published) {
      await _db.execute(
        '''
        UPDATE $table SET
          status = @status::content_status,
          published_at = COALESCE(published_at, now()),
          updated_at = now()
        WHERE id = @id
        ''',
        {'id': id, 'status': status.sqlValue},
      );
    } else {
      await _db.execute(
        'UPDATE $table SET status = @status::content_status, updated_at = now() WHERE id = @id',
        {'id': id, 'status': status.sqlValue},
      );
    }
  }
}
