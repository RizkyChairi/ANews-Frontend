class ApiConfig {
   static const String baseUrl = 'http://localhost:5000/api/v1';
  
  // Endpoints
  static const String register = '$baseUrl/auth/register';
  static const String login = '$baseUrl/auth/login';
  static const String posts = '$baseUrl/posts';
  static const String categories = '$baseUrl/categories';
  
  static String postById(int id) => '$baseUrl/posts/$id';
  static String postsByCategory(int categoryId) => '$baseUrl/posts/category/$categoryId';
  static String userPosts(int userId) => '$baseUrl/posts/users/$userId/posts';
  static String userPostById(int userId, int postId) => '$baseUrl/posts/users/$userId/posts/$postId';
}