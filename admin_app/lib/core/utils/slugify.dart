String slugify(String value) => value
    .toLowerCase()
    .trim()
    .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
    .replaceAll(RegExp(r'^-|-$'), '');
