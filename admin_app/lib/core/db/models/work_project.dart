import 'enums.dart';

class WorkProject {
  final int id;
  final int? categoryId;
  final String title;
  final String slug;
  final String? subtitle;
  final String? summary;
  final int? thumbnailAssetId;
  final String contentMarkdown;
  final int? exampleScreenshotAssetId;
  final String? repoUrl;
  final String? liveUrl;
  final ContentStatus status;
  final DateTime? publishedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WorkProject({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.slug,
    required this.subtitle,
    required this.summary,
    required this.thumbnailAssetId,
    required this.contentMarkdown,
    required this.exampleScreenshotAssetId,
    required this.repoUrl,
    required this.liveUrl,
    required this.status,
    required this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WorkProject.fromRow(Map<String, dynamic> row) {
    return WorkProject(
      id: row['id'] as int,
      categoryId: row['category_id'] as int?,
      title: row['title'] as String,
      slug: row['slug'] as String,
      subtitle: row['subtitle'] as String?,
      summary: row['summary'] as String?,
      thumbnailAssetId: row['thumbnail_asset_id'] as int?,
      contentMarkdown: row['content_markdown'] as String,
      exampleScreenshotAssetId: row['example_screenshot_asset_id'] as int?,
      repoUrl: row['repo_url'] as String?,
      liveUrl: row['live_url'] as String?,
      status: ContentStatus.fromSql(row['status'] as String),
      publishedAt: row['published_at'] as DateTime?,
      createdAt: row['created_at'] as DateTime,
      updatedAt: row['updated_at'] as DateTime,
    );
  }
}

class WorkGalleryImage {
  final int id;
  final int workProjectId;
  final int mediaAssetId;
  final int sortOrder;
  final String? caption;

  const WorkGalleryImage({
    required this.id,
    required this.workProjectId,
    required this.mediaAssetId,
    required this.sortOrder,
    required this.caption,
  });

  factory WorkGalleryImage.fromRow(Map<String, dynamic> row) {
    return WorkGalleryImage(
      id: row['id'] as int,
      workProjectId: row['work_project_id'] as int,
      mediaAssetId: row['media_asset_id'] as int,
      sortOrder: row['sort_order'] as int,
      caption: row['caption'] as String?,
    );
  }
}
