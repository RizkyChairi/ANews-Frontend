import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../providers/post_provider.dart';

class CategoryFilter extends StatelessWidget {
  const CategoryFilter({super.key});

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final postProvider = context.watch<PostProvider>();

    if (categoryProvider.categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categoryProvider.categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildCategoryChip(
              context,
              label: 'All',
              isSelected: postProvider.selectedCategoryId == null,
              onTap: () {
                postProvider.loadPostsByCategory(null);
              },
            );
          }

          final category = categoryProvider.categories[index - 1];
          return _buildCategoryChip(
            context,
            label: category.name,
            isSelected: postProvider.selectedCategoryId == category.id,
            onTap: () {
              postProvider.loadPostsByCategory(category.id);
            },
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.green : Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? Colors.green.withOpacity(0.3)
                    : Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
              child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,  
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    ),
  );
  }
}