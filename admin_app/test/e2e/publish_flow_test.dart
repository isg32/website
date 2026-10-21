// End-to-end check of the admin publishing path against the real stack:
// this app's own CloudinaryService + Repository (as app_writer) write
// content, and the SvelteKit site (as app_reader) must serve it. Creates
// throwaway `e2e-*` rows plus one Cloudinary upload, and removes them all
// in tearDownAll.
//
// Needs the site running (`npm run dev`, ideally with NEON_DB_URL set to
// the app_reader URL so read grants are exercised too), then:
//
//   flutter test test/e2e --dart-define-from-file=env.json \
//     --dart-define=SITE_URL=http://localhost:5173
//
// Not part of the default `flutter test` run's expectations: it skips
// itself when DB_HOST/CLOUDINARY_* aren't defined.
import 'dart:convert';
import 'dart:io';

import 'package:admin_app/core/cloudinary/cloudinary_service.dart';
import 'package:admin_app/core/db/db_client.dart';
import 'package:admin_app/core/db/models/enums.dart';
import 'package:admin_app/core/db/repository.dart';
import 'package:cloudinary_sdk/cloudinary_sdk.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

const _siteUrl =
    String.fromEnvironment('SITE_URL', defaultValue: 'http://localhost:5173');
const _configured = String.fromEnvironment('DB_HOST') != '' &&
    String.fromEnvironment('CLOUDINARY_API_SECRET') != '';

// 1x1 PNG, enough for Cloudinary to accept as a real image upload.
final _pngBytes = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
);

void main() {
  final db = DbClient.instance;
  final repo = Repository(db);
  final run = 'e2e-${DateTime.now().millisecondsSinceEpoch}';

  int? categoryId;
  int? projectId;
  int? articleId;
  int? quoteId;
  int? assetId;
  UploadedAsset? uploaded;

  Future<http.Response> get(String path) =>
      http.get(Uri.parse('$_siteUrl$path'));

  Future<DateTime?> publishedAt(String table, int id) async {
    final rows = await db.query(
        'SELECT published_at FROM $table WHERE id = @id', {'id': id});
    return rows.first['published_at'] as DateTime?;
  }

  tearDownAll(() async {
    if (!_configured) return;
    if (projectId != null) await repo.deleteWorkProject(projectId!);
    if (articleId != null) await repo.deleteBlogPost(articleId!);
    if (quoteId != null) await repo.deleteBlogPost(quoteId!);
    if (categoryId != null) await repo.deleteWorkCategory(categoryId!);
    if (assetId != null) {
      await db.execute('DELETE FROM media_assets WHERE id = @id', {'id': assetId});
    }
    if (uploaded != null) {
      await Cloudinary.full(
        apiKey: const String.fromEnvironment('CLOUDINARY_API_KEY'),
        apiSecret: const String.fromEnvironment('CLOUDINARY_API_SECRET'),
        cloudName: const String.fromEnvironment('CLOUDINARY_CLOUD_NAME'),
      ).deleteResource(
          publicId: uploaded!.publicId,
          resourceType: CloudinaryResourceType.image);
    }
    await db.close();
  });

  test('upload → media_assets row', () async {
    final file = File('${Directory.systemTemp.path}/$run.png')
      ..writeAsBytesSync(_pngBytes);
    uploaded = await CloudinaryService().uploadImage(file.path, folder: 'e2e');
    file.deleteSync();
    expect(uploaded!.secureUrl, startsWith('https://res.cloudinary.com/'));

    assetId = await repo.insertMediaAsset(
      cloudinaryPublicId: uploaded!.publicId,
      secureUrl: uploaded!.secureUrl,
      format: uploaded!.format,
      resourceType: uploaded!.resourceType,
      bytes: uploaded!.bytes,
      width: uploaded!.width,
      height: uploaded!.height,
      originalFilename: '$run.png',
    );
  }, skip: !_configured);

  test('work project: draft is hidden, publish shows it, hide 404s',
      () async {
    categoryId =
        await repo.createWorkCategory(name: 'E2E $run', slug: run);
    // Same create-then-update sequence as WorkEditScreen._ensureSaved.
    projectId = await repo.createWorkProject(title: 'E2E $run', slug: run);
    await repo.updateWorkProject(
      id: projectId!,
      title: 'E2E $run',
      slug: run,
      categoryId: categoryId,
      subtitle: 'Subtitle $run',
      summary: 'Summary $run',
      thumbnailAssetId: assetId,
      exampleScreenshotAssetId: assetId,
      liveUrl: 'https://example.com/$run',
      contentMarkdown: '## Body $run\n\n![](${uploaded!.secureUrl})',
    );
    await repo.addWorkGalleryImage(projectId!, assetId!);
    await repo.addWorkGalleryImage(projectId!, assetId!);
    final orders = await db.query(
      'SELECT sort_order FROM work_gallery_images WHERE work_project_id = @id ORDER BY id',
      {'id': projectId},
    );
    expect(orders.map((r) => r['sort_order']), [0, 1]);

    expect((await get('/work/$run')).statusCode, 404, reason: 'draft leaked');

    await repo.setWorkProjectStatus(projectId!, ContentStatus.published);
    final page = await get('/work/$run');
    expect(page.statusCode, 200);
    expect(page.body, contains('Subtitle $run'));
    expect(page.body, contains('Body $run'));
    expect(page.body, contains(uploaded!.secureUrl));
    expect(page.body, contains('https://example.com/$run'));
    expect((await get('/work')).body, contains('E2E $run'));

    final firstPublishedAt = await publishedAt('work_projects', projectId!);
    expect(firstPublishedAt, isNotNull);

    await repo.setWorkProjectStatus(projectId!, ContentStatus.hidden);
    expect((await get('/work/$run')).statusCode, 404);

    await repo.setWorkProjectStatus(projectId!, ContentStatus.published);
    expect(await publishedAt('work_projects', projectId!), firstPublishedAt,
        reason: 'published_at must survive hidden -> published');
  }, skip: !_configured);

  test('blog article with gallery, and a quote post', () async {
    articleId = await repo.createBlogPost(
        postType: BlogPostType.article, slug: '$run-article');
    await repo.updateBlogPost(
      id: articleId!,
      postType: BlogPostType.article,
      slug: '$run-article',
      title: 'Article $run',
      excerpt: 'Excerpt $run',
      thumbnailAssetId: assetId,
      contentMarkdown:
          'Text $run\n\n<video src="${uploaded!.secureUrl}" controls></video>',
    );
    await repo.addBlogGalleryImage(articleId!, assetId!);
    expect((await get('/blog/$run-article')).statusCode, 404);

    await repo.setBlogPostStatus(articleId!, ContentStatus.published);
    final article = await get('/blog/$run-article');
    expect(article.statusCode, 200);
    expect(article.body, contains('Article $run'));
    expect(article.body, contains('<video src="${uploaded!.secureUrl}"'),
        reason: 'sanitizer should keep the inline <video>');
    expect(
      RegExp(RegExp.escape(uploaded!.secureUrl)).allMatches(article.body).length,
      greaterThanOrEqualTo(3),
      reason: 'thumbnail + inline video + gallery item',
    );

    quoteId = await repo.createBlogPost(
        postType: BlogPostType.quote, slug: '$run-quote');
    await repo.updateBlogPost(
      id: quoteId!,
      postType: BlogPostType.quote,
      slug: '$run-quote',
      quoteText: 'Quote $run',
      contentMarkdown: '',
    );
    await repo.setBlogPostStatus(quoteId!, ContentStatus.published);
    final quote = await get('/blog/$run-quote');
    expect(quote.statusCode, 200);
    expect(quote.body, contains('Quote $run'));

    final archive = await get('/blog');
    expect(archive.body, contains('Article $run'));
    expect(archive.body, contains('Quote $run'));
  }, skip: !_configured);
}
