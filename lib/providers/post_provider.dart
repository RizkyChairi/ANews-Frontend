import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; 
import '../models/post_model.dart';
import '../services/post_service.dart';

class PostProvider extends ChangeNotifier {
  final PostService _postService = PostService();
  
  List<PostModel> _posts = [];
  List<PostModel> _userPosts = [];
  bool _isLoading = false;
  String? _errorMessage;
  int? _selectedCategoryId;

  List<PostModel> get posts => _posts;
  List<PostModel> get userPosts => _userPosts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get selectedCategoryId => _selectedCategoryId;

  Future<void> loadAllPosts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _postService.getAllPosts();

    if (result['success']) {
      _posts = result['posts'];
    } else {
      _errorMessage = result['message'];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadPostsByCategory(int? categoryId) async {
    _selectedCategoryId = categoryId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (categoryId == null) {
      await loadAllPosts();
      return;
    }

    final result = await _postService.getPostsByCategory(categoryId);

    if (result['success']) {
      _posts = result['posts'];
    } else {
      _errorMessage = result['message'];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadUserPosts(int userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _postService.getUserPosts(userId);

    if (result['success']) {
      _userPosts = result['posts'];
    } else {
      _errorMessage = result['message'];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createPost({
    required int userId,
    required String title,
    required String content,
    int? categoryId,
    XFile? imageFile,                              
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _postService.createPost(
      userId: userId,
      title: title,
      content: content,
      categoryId: categoryId,
      imageFile: imageFile,                          
    );

    _isLoading = false;
    notifyListeners();

    return result['success'];
  }

  Future<bool> updatePost({
    required int postId,
    String? title,
    String? content,
    int? categoryId,
    XFile? imageFile,                              
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _postService.updatePost(
      postId: postId,
      title: title,
      content: content,
      categoryId: categoryId,
      imageFile: imageFile,                         
    );

    _isLoading = false;
    notifyListeners();

    return result['success'];
  }

  Future<bool> deletePost(int postId) async {
    _isLoading = true;
    notifyListeners();

    final result = await _postService.deletePost(postId);

    if (result['success']) {
      _userPosts.removeWhere((post) => post.id == postId);
      _posts.removeWhere((post) => post.id == postId);
    }

    _isLoading = false;
    notifyListeners();

    return result['success'];
  }
}