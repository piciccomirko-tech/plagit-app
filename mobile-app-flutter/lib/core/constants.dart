class AppConstants {
  AppConstants._();

  // User roles
  static const String roleCandidate = 'candidate';
  static const String roleBusiness = 'business';
  static const String roleAdmin = 'admin';

  // Pagination
  static const int defaultPageSize = 20;

  // Hospitality categories
  static const List<String> jobCategories = [
    'Chef',
    'Sous Chef',
    'Pastry Chef',
    'Line Cook',
    'Bartender',
    'Sommelier',
    'Waiter',
    'Host',
    'Restaurant Manager',
    'Hotel Manager',
    'Front Desk',
    'Concierge',
    'Housekeeping',
    'Event Coordinator',
    'Barista',
    'Kitchen Porter',
  ];

  // Supported languages
  static const List<String> supportedLocales = [
    'en', 'it', 'fr', 'es', 'de', 'ar', 'pt', 'ru', 'tr', 'hi', 'zh',
  ];
}
