import 'enums.dart';

class BlogPost {
  final int id;
  final BlogPostType postType;
  final String? title;
  final String slug;
  final String? excerpt;
  final String? quoteText;
  final int? thumbnailAssetId;
  final String contentMarkdown;
  final ContentStatus status;
  final DateTime? publishedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BlogPost({
    required this.id,
    required this.postType,
    required this.title,
    required this.slug,
    required this.excerpt,
    required this.quoteText,
    required this.thumbnailAssetId,
    required this.contentMarkdown,
    required this.status,
    required this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BlogPost.fromRow(Map<String, dynamic> row) {
    return BlogPost(
      id: row['id'] as int,
      postType: BlogPostType.fromSql(row['post_type'] as String),
      title: row['title'] as String?,
      slug: row['slug'] as String,
      excerpt: row['excerpt'] as String?,
      quoteText: row['quote_text'] as String?,
      thumbnailAssetId: row['thumbnail_asset_id'] as int?,
      contentMarkdown: row['content_markdown'] as String,
      status: ContentStatus.fromSql(row['status'] as String),
      publishedAt: row['published_at'] as DateTime?,
      createdAt: row['created_at'] as DateTime,
      updatedAt: row['updated_at'] as DateTime,
    );
  }
}
