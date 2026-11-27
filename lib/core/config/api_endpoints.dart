// lib/core/config/api_endpoints.dart

class ApiEndpoints {
  // Auth endpoints (prefixed by /api/auth on FastAPI server)
  static const String signup = '/auth/signup';
  static const String login = '/auth/login';
  static const String social = '/auth/social';
  static const String completePhone = '/auth/complete-phone';
  static const String reactivate = '/auth/reactivate';
  static const String passwordReset = '/auth/password-reset';
  static const String passwordResetConfirm = '/auth/password-reset/confirm';

  // User & Profile endpoints (prefixed by /api/users on FastAPI server)
  static const String me = '/users/me';
  static const String updateMe = '/users/me';
  static const String changePassword = '/users/me/password';
  static const String deactivateMe = '/users/me/deactivate';
  static const String deleteMe = '/users/me';
  static const String emailVerification = '/users/me/email-verification';
  static const String emailVerificationConfirm = '/users/me/email-verification/confirm';

  // Delivery & OSM routing endpoints (prefixed by /api/customer on FastAPI server)
  static const String deliveryCoverage = '/customer/delivery/coverage';
  static const String deliveryEstimate = '/customer/delivery/estimate';
  static String deliveryTracking(int orderId) => '/customer/orders/$orderId/tracking';
  static String handoverCode(int orderId) => '/customer/orders/$orderId/handover-code';

  // Customer addresses & delivery zones (prefixed by /api/customer on FastAPI server)
  static const String addresses = '/customer/addresses';
  static String addressDetail(int id) => '/customer/addresses/$id';
  static const String deliveryZones = '/customer/zones';

  // Customer catalogue endpoints (prefixed by /api/customer on FastAPI server)
  static const String categories = '/customer/categories';
  static const String products = '/customer/products';
  static String productDetail(int id) => '/customer/products/$id';
  static String relatedProducts(int id) => '/customer/products/$id/related';

  // Customer orders endpoints (prefixed by /api/customer on FastAPI server)
  static const String orders = '/customer/orders';
  static String orderDetail(int id) => '/customer/orders/$id';
  static const String checkout = '/customer/orders/checkout';
  static String cancelOrder(int id) => '/customer/orders/$id/cancel';
  static String payOrderMpesa(int id) => '/customer/orders/$id/pay/mpesa';
  static String payOrderManual(int id) => '/customer/orders/$id/pay/manual';
  static String orderPaymentStatus(int id) => '/customer/orders/$id/payment-status';

  // Customer notifications (prefixed by /api/customer on FastAPI server)
  static const String notifications = '/customer/notifications';
  static String notificationRead(String id) => '/customer/notifications/$id/read';
  static const String notificationsReadAll = '/customer/notifications/read-all';
  static String notificationDelete(String id) => '/customer/notifications/$id';
  static const String notificationsClearRead = '/customer/notifications?read_only=true';

  // Customer AI recommendations (Apriori & FP-Growth)
  static const String recommendations = '/customer/recommendations';
  static const String recommendationTrack = '/customer/recommendations/track';
  static const String recommendationStats = '/customer/recommendations/stats';

  // Customer Wishlist
  static const String wishlist = '/customer/wishlist';
  static const String wishlistSync = '/customer/wishlist/sync';
  static String wishlistItem(int productId) => '/customer/wishlist/$productId';

  // Customer Product & Delivery Reviews
  static const String reviews = '/customer/reviews';
  static const String myReviews = '/customer/reviews/mine';
  static String productReviews(int productId) => '/customer/products/$productId/reviews';
  static String orderReviews(int orderId) => '/customer/orders/$orderId/reviews';
}