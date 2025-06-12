class ApiEndpoints {
  static const String baseUrl = 'https://server-morning-forest-197.fly.dev';

  // Auth endpoints
  static const String login = '$baseUrl/api/auth/login';
  static const String register = '$baseUrl/api/auth/register';
  static const String forgotPassword = '$baseUrl/api/auth/forgotPassword';
  static const String verifyOtp = '$baseUrl/api/auth/verify-otp';
  static const String resetPassword = '$baseUrl/api/auth/reset-password';
  static const String logout = '$baseUrl/api/auth/logout';
  static const String verifyToken = '$baseUrl/api/auth/verifyToken';

  // Store endpoints
  static const String stores = '$baseUrl/api/stores';
  static const String searchStores = '$baseUrl/api/stores/search';
  static const String createStore = '$baseUrl/api/stores';
  static const String updateStore = '$baseUrl/api/stores'; // PUT: /api/stores/:id
  static const String deleteStore = '$baseUrl/api/stores'; // DELETE: /api/stores/:id

  // Review endpoints
  static const String leaveReview = '$baseUrl/api/stores/:id/reviews';  // POST
  static const String getStoreReviews = '$baseUrl/api/stores/:id/reviews'; // GET
}