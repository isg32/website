import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';

Future<void> showCategoryManageSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _CategoryManageSheet(),
  );
}

class _CategoryManageSheet extends ConsumerStatefulWidget {
  const _CategoryManageSheet();

  @override
  ConsumerState<_CategoryManageSheet> createState() => _CategoryManageSheetState();
}

class _CategoryManageSheetState extends ConsumerState<_CategoryManageSheet> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final slug = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    await ref.read(repositoryProvider).createWorkCategory(name: name, slug: slug);
    _nameController.clear();
    ref.invalidate(workCategoriesProvider);
  }

  Future<void> _delete(int id) async {
    await ref.read(repositoryProvider).deleteWorkCategory(id);
    ref.invalidate(workCategoriesProvider);
    ref.invalidate(workProjectsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(workCategoriesProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Work Categories', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          categoriesAsync.when(
            data: (categories) => Column(
              children: categories
                  .map(
                    (c) => ListTile(
                      title: Text(c.name),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _delete(c.id),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Text('Failed to load: $error'),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(hintText: 'New category name'),
                  onSubmitted: (_) => _create(),
                ),
              ),
              IconButton(icon: const Icon(Icons.add), onPressed: _create),
            ],
          ),
        ],
      ),
    );
  }
}
