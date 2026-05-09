class AppConstants {
  // App identity
  static const String appFullName  = 'Isandla Somusa';
  static const String appShortName = 'Somusa';
  static const String appTagline   = 'No food wasted. No one hungry.';
  static const String appVersion   = '1.0.0';

  // User roles
  static const String roleDonor     = 'donor';
  static const String roleRecipient = 'recipient';
  static const String roleAdmin     = 'admin';

  // Firestore collections
  static const String colUsers         = 'users';
  static const String colDonations     = 'donations';
  static const String colRequests      = 'requests';
  static const String colPickups       = 'pickups';
  static const String colRatings       = 'ratings';
  static const String colNotifications = 'notifications';
  static const String colChats         = 'chats';

  // Donation statuses
  static const String statusAvailable = 'available';
  static const String statusClaimed   = 'claimed';
  static const String statusPickedUp  = 'picked_up';
  static const String statusExpired   = 'expired';
  static const String statusCancelled = 'cancelled';

  // Request statuses
  static const String reqPending  = 'pending';
  static const String reqApproved = 'approved';
  static const String reqRejected = 'rejected';
  static const String reqCompleted = 'completed';

  // Food categories
  static const List<String> foodCategories = [
    'Cooked meals',
    'Bread & baked goods',
    'Fruits & vegetables',
    'Dairy products',
    'Canned goods',
    'Beverages',
    'Snacks',
    'Other',
  ];

  // Pickup time slots
  static const List<String> timeSlots = [
    '07:00 - 09:00',
    '09:00 - 11:00',
    '11:00 - 13:00',
    '13:00 - 15:00',
    '15:00 - 17:00',
    '17:00 - 19:00',
  ];

  // Storage paths
  static const String storageDonationImages = 'donation_images';
  static const String storageProfileImages  = 'profile_images';

  // SharedPreferences keys
  static const String prefOnboardingDone = 'onboarding_done';
  static const String prefUserId         = 'user_id';
  static const String prefUserRole       = 'user_role';

  // Map defaults (Durban, KZN, SA)
  static const double defaultLat = -29.8587;
  static const double defaultLng =  31.0218;
  static const double defaultZoom = 13.0;
  static const double searchRadiusKm = 10.0;
}
