class MediaCollection {
  final int id;
  final String name;
  final String slug;
  final DateTime createdAt;

  const MediaCollection({
    required this.id,
    required this.name,
    required this.slug,
    required this.createdAt,
  });

  factory MediaCollection.fromRow(Map<String, dynamic> row) {
    return MediaCollection(
      id: row['id'] as int,
      name: row['name'] as String,
      slug: row['slug'] as String,
      createdAt: row['created_at'] as DateTime,
    );
  }
}
