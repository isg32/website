import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../work/category_manage_sheet.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.category_outlined),
            title: const Text('Work categories'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showCategoryManageSheet(context),
          ),
          const Divider(height: 1),
          const ListTile(
            leading: Icon(Icons.dns_outlined),
            title: Text('Connection'),
            subtitle: Text('Connected directly to Neon Postgres as app_writer.'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () => ref.read(sessionProvider.notifier).signOut(),
          ),
        ],
      ),
    );
  }
}
