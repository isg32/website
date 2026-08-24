class WorkCategory {
  final int id;
  final String name;
  final String slug;
  final int sortOrder;
  final DateTime createdAt;

  const WorkCategory({
    required this.id,
    required this.name,
    required this.slug,
    required this.sortOrder,
    required this.createdAt,
  });

  factory WorkCategory.fromRow(Map<String, dynamic> row) {
    return WorkCategory(
      id: row['id'] as int,
      name: row['name'] as String,
      slug: row['slug'] as String,
      sortOrder: row['sort_order'] as int,
      createdAt: row['created_at'] as DateTime,
    );
  }
}
