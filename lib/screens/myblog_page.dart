import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/post_provider.dart';
import '../widgets/post_card.dart';
import 'login_page.dart';
import 'editpost_page.dart';

class MyBlogPage extends StatefulWidget {
  const MyBlogPage({super.key});

  @override
  State<MyBlogPage> createState() => _MyBlogPageState();
}

class _MyBlogPageState extends State<MyBlogPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserPosts();
    });
  }

  Future<void> _loadUserPosts() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.isLoggedIn) {
      await context.read<PostProvider>().loadUserPosts(authProvider.user!.id);
    }
  }

  Future<void> _deletePost(int postId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<PostProvider>().deletePost(postId);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _editPost(dynamic post) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditPostPage(post: post),
      ),
    );

    if (result == true) {
      _loadUserPosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (!authProvider.isLoggedIn) {
      return _buildLoginPrompt();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('My Blog'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserPosts,
          ),
        ],
      ),
      body: Consumer<PostProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.userPosts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.userPosts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.article_outlined,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No posts yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Create your first post!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadUserPosts,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.userPosts.length,
              itemBuilder: (context, index) {
                final post = provider.userPosts[index];

                return Slidable(
                  key: ValueKey(post.id),
                  endActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    children: [
                  
                      SlidableAction(
                        onPressed: (_) => _editPost(post),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        icon: Icons.edit,
                        label: 'Edit',
                      ),
                     
                      SlidableAction(
                        onPressed: (_) => _deletePost(post.id),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Delete',
                      ),
                    ],
                  ),
                  child: GestureDetector(
                    onTap: () => _editPost(post),
                    child: PostCard(
                      post: post,
                      showActions: false,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 80,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 20),
              const Text(
                'Login Required',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'You need to login to see your blog posts',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}