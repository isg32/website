enum ContentStatus {
  draft,
  published,
  hidden;

  String get sqlValue => name;

  static ContentStatus fromSql(String value) =>
      ContentStatus.values.firstWhere((e) => e.name == value, orElse: () => ContentStatus.draft);
}

enum BlogPostType {
  article,
  quote;

  String get sqlValue => name;

  static BlogPostType fromSql(String value) =>
      BlogPostType.values.firstWhere((e) => e.name == value, orElse: () => BlogPostType.article);
}
