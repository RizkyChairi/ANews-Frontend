import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../providers/post_provider.dart';
import '../providers/category_provider.dart';
import '../widgets/post_card.dart';
import '../widgets/category_filter.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/shimmer_post_card.dart';
import '../widgets/banner_slider.dart';
import 'postdetail_page.dart';
import 'search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    await context.read<CategoryProvider>().loadCategories();

    if (!mounted) return;

    await context.read<PostProvider>().loadAllPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        title: const Text('ANews'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SearchPage(),
                ),
              );
            },
          ),
        ],
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          return CustomRefreshIndicator(
            onRefresh: _loadData,

            builder: (context, child, controller) {
              return AnimatedBuilder(
                animation: controller,

                builder: (context, _) {
                  return Stack(
                    children: [
                      Transform.translate(
                        offset: Offset(
                          0,
                          controller.value * 80,
                        ),
                        child: child,
                      ),

                      if (controller.isDragging || controller.isArmed)
                        Positioned(
                          top: controller.value * 40,
                          left: 0,
                          right: 0,

                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.all(12),

                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),

                              child: controller.isArmed
                                  ? const Icon(
                                      Icons.refresh,
                                      color: Colors.green,
                                    )
                                  : SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        value: controller.value,
                                        strokeWidth: 2,
                                        color: Colors.green,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              );
            },

            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Consumer<PostProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading && provider.posts.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      if (provider.posts.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: BannerSlider(
                          posts: provider.posts,
                        ),
                      );
                    },
                  ),

                  const CategoryFilter(),

                  const SizedBox(height: 16),

                  Consumer<PostProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading && provider.posts.isEmpty) {
                        return _buildShimmerLoading(constraints);
                      }

                      if (provider.errorMessage != null &&
                          provider.posts.isEmpty) {
                        return ErrorState(
                          message: provider.errorMessage!,
                          onRetry: _loadData,
                        );
                      }

                      if (provider.posts.isEmpty) {
                        return EmptyState(
                          icon: Icons.article_outlined,
                          title: 'Belum ada postingan',
                          subtitle:
                              'Jadilah yang pertama untuk membagikan cerita!',
                          onRetry: _loadData,
                        );
                      }

                      return _buildPosts(constraints, provider);
                    },
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerLoading(BoxConstraints constraints) {
    if (constraints.maxWidth < 600) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        itemBuilder: (_, __) => const ShimmerPostCard(),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: 4,
      itemBuilder: (_, __) => const ShimmerPostCard(),
    );
  }

  Widget _buildPosts(BoxConstraints constraints, PostProvider provider) {
    if (constraints.maxWidth < 600) {
      return AnimationLimiter(
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: provider.posts.length,
          itemBuilder: (context, index) {
            final post = provider.posts[index];

            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 500),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: PostCard(
                    post: post,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PostDetailPage(post: post),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    return AnimationLimiter(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 16,
          childAspectRatio: 0.9,
        ),
        itemCount: provider.posts.length,
        itemBuilder: (context, index) {
          final post = provider.posts[index];

          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 500),
            columnCount: 2,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: PostCard(
                  post: post,
                  isGrid: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PostDetailPage(post: post),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}