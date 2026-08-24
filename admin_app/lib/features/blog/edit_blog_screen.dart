import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/db/models/blog_post.dart';
import '../../core/db/models/enums.dart';
import '../../core/providers.dart';
import 'blog_edit_screen.dart';

class EditBlogScreen extends ConsumerWidget {
  const EditBlogScreen({super.key});

  Future<void> _delete(WidgetRef ref, BlogPost post) async {
    await ref.read(repositoryProvider).deleteBlogPost(post.id);
    invalidateContentProviders(ref);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(blogPostsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Blog')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const BlogEditScreen())),
        child: const Icon(Icons.add),
      ),
      body: postsAsync.when(
        data: (posts) {
          if (posts.isEmpty) {
            return const Center(child: Text('No posts yet.'));
          }
          return ListView.separated(
            itemCount: posts.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final post = posts[index];
              final displayTitle = post.title ?? (post.quoteText ?? '(untitled quote)');
              return ListTile(
                leading: Icon(
                  post.status == ContentStatus.published
                      ? Icons.public
                      : post.status == ContentStatus.hidden
                      ? Icons.visibility_off_outlined
                      : Icons.edit_outlined,
                  size: 20,
                ),
                title: Text(displayTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(
                  [
                    post.postType == BlogPostType.quote ? 'Quote' : 'Article',
                    post.status == ContentStatus.draft ? '[DRAFT]' : '',
                  ].where((s) => s.isNotEmpty).join(' · '),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      post.publishedAt != null
                          ? DateFormat('MMM d, yyyy').format(post.publishedAt!)
                          : '--',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => BlogEditScreen(post: post)),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      onPressed: () => _delete(ref, post),
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
