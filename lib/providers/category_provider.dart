import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/category_service.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryService _categoryService = CategoryService();

  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadCategories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _categoryService.getAllCategories();

    if (result['success']) {
      _categories = result['categories'];
    } else {
      _errorMessage = result['message'];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createCategory({
    required String name,
    required String slug,
    String? description,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _categoryService.createCategory(
      name: name,
      slug: slug,
      description: description,
    );

    _isLoading = false;

    if (result['success'] == true) {
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }
}