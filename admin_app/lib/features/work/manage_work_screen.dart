import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/db/models/enums.dart';
import '../../core/db/models/work_project.dart';
import '../../core/providers.dart';
import 'category_manage_sheet.dart';
import 'work_edit_screen.dart';

class ManageWorkScreen extends ConsumerWidget {
  const ManageWorkScreen({super.key});

  Future<void> _delete(WidgetRef ref, WorkProject project) async {
    await ref.read(repositoryProvider).deleteWorkProject(project.id);
    invalidateContentProviders(ref);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(workProjectsProvider);
    final categoriesAsync = ref.watch(workCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Work'),
        actions: [
          IconButton(
            icon: const Icon(Icons.category_outlined),
            tooltip: 'Categories',
            onPressed: () => showCategoryManageSheet(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const WorkEditScreen())),
        child: const Icon(Icons.add),
      ),
      body: projectsAsync.when(
        data: (projects) {
          if (projects.isEmpty) {
            return const Center(child: Text('No work items yet.'));
          }
          final categoryNames = {
            for (final c in categoriesAsync.value ?? []) c.id: c.name,
          };
          return ListView.separated(
            itemCount: projects.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final project = projects[index];
              return ListTile(
                leading: Icon(
                  project.status == ContentStatus.published
                      ? Icons.public
                      : project.status == ContentStatus.hidden
                      ? Icons.visibility_off_outlined
                      : Icons.edit_outlined,
                  size: 20,
                ),
                title: Text(project.title),
                subtitle: Text(
                  [
                    if (project.categoryId != null) categoryNames[project.categoryId] ?? '',
                    project.status == ContentStatus.draft ? '[DRAFT]' : '',
                  ].where((s) => s.isNotEmpty).join(' · '),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      project.publishedAt != null
                          ? DateFormat('MMM d, yyyy').format(project.publishedAt!)
                          : '--',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => WorkEditScreen(project: project)),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      onPressed: () => _delete(ref, project),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Failed to load: $error')),
      ),
    );
  }
}
