class MediaAsset {
  final int id;
  final String cloudinaryPublicId;
  final String secureUrl;
  final String? format;
  final String resourceType;
  final int? bytes;
  final int? width;
  final int? height;
  final String? originalFilename;
  final DateTime createdAt;

  const MediaAsset({
    required this.id,
    required this.cloudinaryPublicId,
    required this.secureUrl,
    required this.format,
    required this.resourceType,
    required this.bytes,
    required this.width,
    required this.height,
    required this.originalFilename,
    required this.createdAt,
  });

  factory MediaAsset.fromRow(Map<String, dynamic> row) {
    return MediaAsset(
      id: row['id'] as int,
      cloudinaryPublicId: row['cloudinary_public_id'] as String,
      secureUrl: row['secure_url'] as String,
      format: row['format'] as String?,
      resourceType: row['resource_type'] as String,
      bytes: row['bytes'] as int?,
      width: row['width'] as int?,
      height: row['height'] as int?,
      originalFilename: row['original_filename'] as String?,
      createdAt: row['created_at'] as DateTime,
    );
  }
}
