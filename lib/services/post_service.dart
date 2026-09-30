// lib/services/postService.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';  
import '../config/api_config.dart';
import '../models/post_model.dart';
import 'auth_service.dart';

class PostService {
  final AuthService _authService = AuthService();

  // home -> get all post
  Future<Map<String, dynamic>> getAllPosts() async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.posts));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> postsJson = data['data']['posts'] ?? [];
        final posts = postsJson.map((json) => PostModel.fromJson(json)).toList();
        return {'success': true, 'posts': posts};
      }
      return {'success': false, 'message': 'Failed to load posts'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // get post by category
  Future<Map<String, dynamic>> getPostsByCategory(int categoryId) async {
    try {
      final response =
          await http.get(Uri.parse(ApiConfig.postsByCategory(categoryId)));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> postsJson = data['data']['posts'] ?? [];
        final posts = postsJson.map((json) => PostModel.fromJson(json)).toList();
        return {'success': true, 'posts': posts};
      }
      return {'success': false, 'message': 'Failed to load posts'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
//get postbyid
  Future<Map<String, dynamic>> getPostById(int id) async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.postById(id)));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final post = PostModel.fromJson(data['data']['post']);
        return {'success': true, 'post': post};
      }
      return {'success': false, 'message': 'Post not found'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // get user post -> mypost
  Future<Map<String, dynamic>> getUserPosts(int userId) async {
    try {
      final token = await _authService.getToken();

      final response = await http.get(
        Uri.parse(ApiConfig.userPosts(userId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> postsJson = data['data']['posts'] ?? [];
        final posts = postsJson.map((json) => PostModel.fromJson(json)).toList();
        return {'success': true, 'posts': posts};
      }
      return {'success': false, 'message': 'Failed to load posts'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // create post
  Future<Map<String, dynamic>> createPost({
    required int userId,
    required String title,
    required String content,
    int? categoryId,
    XFile? imageFile,                              
  }) async {
    try {
      final token = await _authService.getToken();

      var request = http.MultipartRequest('POST', Uri.parse(ApiConfig.posts));
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['userId'] = userId.toString();
      request.fields['title'] = title;
      request.fields['content'] = content;
      if (categoryId != null) {
        request.fields['categoryId'] = categoryId.toString();
      }

      
      if (imageFile != null) {
        final bytes = await imageFile.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: imageFile.name,
        ));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'message': 'Post created successfully'};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to create post',
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // upd post
  Future<Map<String, dynamic>> updatePost({
    required int postId,
    String? title,
    String? content,
    int? categoryId,
    XFile? imageFile,                              
  }) async {
    try {
      final token = await _authService.getToken();

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse(ApiConfig.postById(postId)),
      );
      request.headers['Authorization'] = 'Bearer $token';

      if (title != null) request.fields['title'] = title;
      if (content != null) request.fields['content'] = content;
      if (categoryId != null) request.fields['categoryId'] = categoryId.toString();

      if (imageFile != null) {
        final bytes = await imageFile.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: imageFile.name,
        ));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Post updated successfully'};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to update post',
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // delete post
  Future<Map<String, dynamic>> deletePost(int postId) async {
    try {
      final token = await _authService.getToken();

      final response = await http.delete(
        Uri.parse(ApiConfig.postById(postId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Post deleted successfully'};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to delete post',
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}