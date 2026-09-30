import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/category_model.dart';
import 'auth_service.dart';

class CategoryService {
  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>> getAllCategories() async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.categories));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> categoriesJson = data['data']['categories'] ?? [];
        final categories = categoriesJson.map((json) => CategoryModel.fromJson(json)).toList();
        return {'success': true, 'categories': categories};
      } else {
        return {'success': false, 'message': 'Failed to load categories'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> createCategory({
    required String name,
    required String slug,
    String? description,
  }) async {
    try {
      final token = await _authService.getToken();
      
      final response = await http.post(
        Uri.parse(ApiConfig.categories),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'slug': slug,
          'description': description,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'message': 'Category created successfully'};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed to create category'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}