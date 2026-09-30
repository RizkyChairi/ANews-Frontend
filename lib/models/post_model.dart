import 'user_model.dart';
import 'category_model.dart';

class PostModel {
  final int id;
  final int userId;
  final int? categoryId;
  final String title;
  final String content;
  final String? imageUrl;
  final String? imagePublicId;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final UserModel? user;
  final CategoryModel? category;

  PostModel({
    required this.id,
    required this.userId,
    this.categoryId,
    required this.title,
    required this.content,
    this.imageUrl,
    this.imagePublicId,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.category,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      categoryId: json['categoryId'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      imageUrl: json['imageUrl'],
      imagePublicId: json['imagePublicId'],
      status: json['status'] ?? 'published',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      category: json['category'] != null ? CategoryModel.fromJson(json['category']) : null,
    );
  }
}