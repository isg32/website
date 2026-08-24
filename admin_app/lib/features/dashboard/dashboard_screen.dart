import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../blog/blog_edit_screen.dart';
import '../blog/edit_blog_screen.dart';
import '../media/media_library_screen.dart';
import '../settings/settings_screen.dart';
import '../work/manage_work_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => ref.read(sessionProvider.notifier).signOut(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'MANAGING DIGITAL ARCHIVE',
            style: TextStyle(fontSize: 11, letterSpacing: 1.2, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          _NavTile(
            icon: Icons.work_outline,
            label: 'Manage Work',
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ManageWorkScreen())),
          ),
          _NavTile(
            icon: Icons.edit_note,
            label: 'Edit Blog',
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const EditBlogScreen())),
          ),
          _NavTile(
            icon: Icons.photo_library_outlined,
            label: 'Media Library',
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const MediaLibraryScreen())),
          ),
          _NavTile(
            icon: Icons.settings_outlined,
            label: 'Settings',
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.black,
              minimumSize: const Size.fromHeight(48),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Create New Post'),
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const BlogEditScreen())),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
