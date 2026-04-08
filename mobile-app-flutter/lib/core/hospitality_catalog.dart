/// Complete hospitality category → subcategory → role hierarchy.
/// Mirrors HospitalityCatalog.swift exactly.

class HospitalityCategory {
  final String id;
  final String name;
  final String icon;
  final List<HospitalitySubcategory> subcategories;

  const HospitalityCategory({required this.id, required this.name, required this.icon, required this.subcategories});
}

class HospitalitySubcategory {
  final String id;
  final String name;
  final List<String> roles;

  const HospitalitySubcategory({required this.id, required this.name, required this.roles});
}

class HospitalityCatalog {
  HospitalityCatalog._();

  static const List<String> popularCategoryIds = [
    'restaurants', 'hotels', 'bars', 'cafes', 'catering', 'events', 'resorts', 'clubs', 'delivery', 'spa',
  ];

  static const List<String> popularRoles = [
    'Waiter', 'Runner', 'Hostess', 'Receptionist', 'Bartender', 'Barista',
    'Kitchen Porter', 'Commis Chef', 'Chef de Partie', 'Sous Chef', 'Head Chef',
    'Pastry Chef', 'Room Attendant', 'Housekeeper', 'Front Desk Agent',
    'Restaurant Manager', 'Floor Manager', 'General Manager', 'Event Waiter',
    'Event Bartender', 'Spa Therapist', 'Personal Trainer', 'Delivery Driver',
  ];

  static final List<HospitalityCategory> categories = [
    HospitalityCategory(id: 'back_office', name: 'Back Office', icon: '🖥️', subcategories: [
      HospitalitySubcategory(id: 'bo_accounting', name: 'Accounting & Finance', roles: ['Accountant', 'Bookkeeper', 'Financial Controller', 'Payroll Specialist']),
      HospitalitySubcategory(id: 'bo_admin', name: 'Administration', roles: ['Administrative Assistant', 'Data Entry Clerk', 'Office Manager', 'Receptionist']),
      HospitalitySubcategory(id: 'bo_hr', name: 'Human Resources', roles: ['HR Coordinator', 'HR Manager', 'Recruiter', 'Training Coordinator']),
      HospitalitySubcategory(id: 'bo_it', name: 'IT & Systems', roles: ['IT Manager', 'IT Support Specialist', 'Systems Administrator']),
      HospitalitySubcategory(id: 'bo_marketing', name: 'Marketing & Sales', roles: ['Digital Marketing Specialist', 'Marketing Manager', 'Revenue Manager', 'Sales Manager']),
    ]),
    HospitalityCategory(id: 'bakeries', name: 'Bakeries & Pastry', icon: '🎂', subcategories: [
      HospitalitySubcategory(id: 'bak_artisan', name: 'Artisan Bakery', roles: ['Artisan Baker', 'Bread Baker', 'Sourdough Specialist']),
      HospitalitySubcategory(id: 'bak_choc', name: 'Chocolaterie', roles: ['Chocolatier', 'Confectioner']),
      HospitalitySubcategory(id: 'bak_pastry', name: 'Pastry Shop', roles: ['Cake Decorator', 'Pastry Chef', 'Viennoiserie Baker']),
      HospitalitySubcategory(id: 'bak_prod', name: 'Production Bakery', roles: ['Production Baker', 'Production Line Lead', 'Quality Controller']),
    ]),
    HospitalityCategory(id: 'bars', name: 'Bars', icon: '🍷', subcategories: [
      HospitalitySubcategory(id: 'bar_cocktail', name: 'Cocktail Bar', roles: ['Barback', 'Head Bartender', 'Mixologist']),
      HospitalitySubcategory(id: 'bar_hotel', name: 'Hotel Bar', roles: ['Bartender', 'Lounge Manager', 'Sommelier']),
      HospitalitySubcategory(id: 'bar_lounge', name: 'Lounge Bar', roles: ['Barback', 'Bartender', 'Hostess', 'Floor Manager']),
      HospitalitySubcategory(id: 'bar_pub', name: 'Pub & Gastropub', roles: ['Cellar Manager', 'Bartender', 'Pub Manager']),
      HospitalitySubcategory(id: 'bar_rooftop', name: 'Rooftop Bar', roles: ['Barback', 'Bartender', 'Hostess', 'Floor Manager', 'Waiter']),
      HospitalitySubcategory(id: 'bar_wine', name: 'Wine Bar', roles: ['Bartender', 'Sommelier', 'Wine Steward']),
    ]),
    HospitalityCategory(id: 'cafes', name: 'Cafés', icon: '☕', subcategories: [
      HospitalitySubcategory(id: 'cafe_bakery', name: 'Bakery Café', roles: ['Baker', 'Barista', 'Cashier', 'Pastry Chef']),
      HospitalitySubcategory(id: 'cafe_brunch', name: 'Brunch & Breakfast', roles: ['Brunch Cook', 'Cafe Manager', 'Server']),
      HospitalitySubcategory(id: 'cafe_coffee', name: 'Coffee Shop', roles: ['Barista', 'Head Barista', 'Coffee Roaster', 'Shift Lead']),
      HospitalitySubcategory(id: 'cafe_tea', name: 'Tea Room', roles: ['Server', 'Tea Specialist']),
    ]),
    HospitalityCategory(id: 'catering', name: 'Catering', icon: '🥡', subcategories: [
      HospitalitySubcategory(id: 'cat_corporate', name: 'Corporate Catering', roles: ['Catering Chef', 'Catering Coordinator', 'Catering Server']),
      HospitalitySubcategory(id: 'cat_event', name: 'Event Catering', roles: ['Event Chef', 'Catering Manager', 'Catering Server', 'Setup Crew']),
      HospitalitySubcategory(id: 'cat_luxury', name: 'Luxury Catering', roles: ['Butler', 'Head Chef', 'Catering Manager', 'Waiter', 'Sommelier']),
      HospitalitySubcategory(id: 'cat_mobile', name: 'Mobile Catering', roles: ['Food Truck Operator', 'Mobile Cook']),
      HospitalitySubcategory(id: 'cat_private', name: 'Private Catering', roles: ['Butler', 'Private Chef', 'Private Server']),
      HospitalitySubcategory(id: 'cat_wedding', name: 'Wedding Catering', roles: ['Head Chef', 'Catering Coordinator', 'Catering Manager', 'Event Waiter', 'Setup Crew']),
    ]),
    HospitalityCategory(id: 'clubs', name: 'Clubs & Nightlife', icon: '🎵', subcategories: [
      HospitalitySubcategory(id: 'club_beach', name: 'Beach Club', roles: ['Beach Bartender', 'Host', 'Beach Club Manager', 'Server']),
      HospitalitySubcategory(id: 'club_lounge', name: 'Lounge', roles: ['Bartender', 'Hostess', 'VIP Host']),
      HospitalitySubcategory(id: 'club_members', name: 'Members Club', roles: ['Bartender', 'Concierge', 'Hostess', 'General Manager', 'Waiter']),
      HospitalitySubcategory(id: 'club_night', name: 'Nightclub', roles: ['Bartender', 'Door Host', 'DJ', 'Club Manager', 'Promoter', 'Security']),
    ]),
    HospitalityCategory(id: 'corporate', name: 'Corporate Hospitality', icon: '🏢', subcategories: [
      HospitalitySubcategory(id: 'corp_canteen', name: 'Corporate Canteen', roles: ['Canteen Chef', 'Canteen Manager', 'Server']),
      HospitalitySubcategory(id: 'corp_exec', name: 'Executive Dining', roles: ['Butler', 'Executive Chef', 'Server']),
      HospitalitySubcategory(id: 'corp_vip', name: 'VIP Lounge', roles: ['Lounge Attendant', 'Bartender', 'Lounge Manager']),
    ]),
    HospitalityCategory(id: 'cruises', name: 'Cruises & Yachts', icon: '⛴️', subcategories: [
      HospitalitySubcategory(id: 'cr_cruise', name: 'Cruise Ship', roles: ['Bartender', 'Cabin Steward', 'Cruise Chef', 'Entertainment Host', "Maitre D'", 'Waiter']),
      HospitalitySubcategory(id: 'cr_river', name: 'River Cruise', roles: ['Chef', 'Server', 'Steward']),
      HospitalitySubcategory(id: 'cr_yacht', name: 'Yacht', roles: ['Deckhand', 'Stewardess', 'Yacht Chef']),
    ]),
    HospitalityCategory(id: 'delivery', name: 'Delivery', icon: '🚲', subcategories: [
      HospitalitySubcategory(id: 'del_catering', name: 'Catering Delivery', roles: ['Delivery Driver', 'Event Delivery Assistant', 'Logistics Coordinator', 'Setup Crew']),
      HospitalitySubcategory(id: 'del_dark', name: 'Dark Kitchen Delivery', roles: ['Dispatch Coordinator', 'Kitchen Dispatcher', 'Order Packer', 'Shift Supervisor']),
      HospitalitySubcategory(id: 'del_premium', name: 'Premium / VIP Delivery', roles: ['Chauffeur Delivery', 'Client Delivery Concierge', 'Luxury Delivery Assistant']),
      HospitalitySubcategory(id: 'del_restaurant', name: 'Restaurant Delivery', roles: ['Dispatch Coordinator', 'Delivery Driver', 'Order Packer', 'Delivery Rider', 'Delivery Supervisor']),
    ]),
    HospitalityCategory(id: 'entertainment', name: 'Entertainment', icon: '🎭', subcategories: [
      HospitalitySubcategory(id: 'ent_club', name: 'Club Shows', roles: ['Dancer', 'DJ', 'Fire Performer', 'Showgirl', 'Stage Performer']),
      HospitalitySubcategory(id: 'ent_family', name: 'Family Entertainment', roles: ['Activity Host', 'Character Performer', 'Event Host', 'Kids Entertainer']),
      HospitalitySubcategory(id: 'ent_hotel', name: 'Hotel Entertainment', roles: ['Activities Host', 'DJ', 'Entertainment Host', 'Live Singer', 'Pianist']),
      HospitalitySubcategory(id: 'ent_live', name: 'Live Music Venue', roles: ['DJ', 'Entertainment Manager', 'Live Singer', 'MC / Host', 'Musician']),
      HospitalitySubcategory(id: 'ent_night', name: 'Night Entertainment', roles: ['Dancer', 'DJ', 'Entertainment Coordinator', 'Performer', 'VIP Hostess']),
      HospitalitySubcategory(id: 'ent_resort', name: 'Resort Entertainment', roles: ['Activities Host', 'DJ', 'Entertainer', 'Entertainment Manager', 'MC / Host']),
      HospitalitySubcategory(id: 'ent_wedding', name: 'Wedding Entertainment', roles: ['DJ', 'Live Singer', 'MC / Host', 'Musician', 'Wedding Entertainer']),
    ]),
    HospitalityCategory(id: 'events', name: 'Events & Banqueting', icon: '🎉', subcategories: [
      HospitalitySubcategory(id: 'evt_banquet', name: 'Banqueting', roles: ['Banquet Captain', 'Banquet Chef', 'Banquet Manager', 'Banquet Server']),
      HospitalitySubcategory(id: 'evt_conference', name: 'Conference & Exhibition', roles: ['AV Technician', 'Conference Coordinator', 'Registration Staff']),
      HospitalitySubcategory(id: 'evt_exhibition', name: 'Exhibitions', roles: ['Event Bartender', 'Event Coordinator', 'Hostess', 'Event Waiter']),
      HospitalitySubcategory(id: 'evt_floral', name: 'Floral & Decoration', roles: ['Event Decorator', 'Floral Designer', 'Florist', 'Venue Stylist', 'Wedding Decorator']),
      HospitalitySubcategory(id: 'evt_gala', name: 'Gala Dinners', roles: ['Event Bartender', 'Head Chef', 'Banquet Manager', 'Sommelier', 'Event Waiter']),
      HospitalitySubcategory(id: 'evt_wedding', name: 'Weddings', roles: ['Florist', 'Wedding Coordinator', 'Wedding Server']),
    ]),
    HospitalityCategory(id: 'fitness', name: 'Fitness & Wellness', icon: '🏋️', subcategories: [
      HospitalitySubcategory(id: 'fit_gym', name: 'Gym', roles: ['Club Manager', 'Fitness Manager', 'Gym Instructor', 'Membership Advisor', 'Personal Trainer', 'Receptionist']),
      HospitalitySubcategory(id: 'fit_nutrition', name: 'Nutrition Studio', roles: ['Dietitian', 'Nutritionist', 'Receptionist', 'Wellness Coach']),
      HospitalitySubcategory(id: 'fit_spa', name: 'Spa', roles: ['Club Manager', 'Membership Advisor', 'Receptionist', 'Wellness Coach']),
      HospitalitySubcategory(id: 'fit_wellness', name: 'Wellness Center', roles: ['Club Manager', 'Dietitian', 'Fitness Manager', 'Nutritionist', 'Receptionist', 'Wellness Coach']),
    ]),
    HospitalityCategory(id: 'healthcare', name: 'Healthcare Hospitality', icon: '🏥', subcategories: [
      HospitalitySubcategory(id: 'hc_clinic', name: 'Clinic', roles: ['Cleaner', 'Front Desk Agent', 'Hospitality Assistant', 'Receptionist']),
      HospitalitySubcategory(id: 'hc_hospital', name: 'Hospital', roles: ['Catering Assistant', 'Cleaner', 'Guest Services', 'Housekeeper', 'Patient Services Coordinator', 'Porter', 'Receptionist']),
      HospitalitySubcategory(id: 'hc_wellness', name: 'Medical Wellness Center', roles: ['Front Desk Agent', 'Guest Services', 'Hospitality Assistant', 'Patient Services Coordinator', 'Receptionist']),
    ]),
    HospitalityCategory(id: 'hotels', name: 'Hotels', icon: '🏨', subcategories: [
      HospitalitySubcategory(id: 'htl_boutique', name: 'Boutique Hotel', roles: ['Concierge', 'General Manager', 'Receptionist']),
      HospitalitySubcategory(id: 'htl_business', name: 'Business Hotel', roles: ['Concierge', 'Front Desk Agent', 'General Manager', 'Housekeeper', 'Receptionist', 'Room Attendant']),
      HospitalitySubcategory(id: 'htl_fb', name: 'Food & Beverage', roles: ['Banquet Chef', 'Breakfast Cook', 'F&B Manager', 'Room Service Attendant', 'Waiter']),
      HospitalitySubcategory(id: 'htl_front', name: 'Front Office', roles: ['Bellboy', 'Concierge', 'Front Office Manager', 'Night Auditor', 'Receptionist']),
      HospitalitySubcategory(id: 'htl_house', name: 'Housekeeping', roles: ['Housekeeping Manager', 'Laundry Attendant', 'Room Attendant', 'Turndown Attendant']),
      HospitalitySubcategory(id: 'htl_luxury', name: 'Luxury Hotel', roles: ['Bellboy', 'Butler', 'Concierge', 'Front Desk Agent', 'General Manager', 'Housekeeper', 'Receptionist', 'Room Attendant', 'Sommelier', 'Waiter']),
      HospitalitySubcategory(id: 'htl_maint', name: 'Maintenance', roles: ['Maintenance Engineer', 'Maintenance Manager', 'Pool Technician']),
      HospitalitySubcategory(id: 'htl_serviced', name: 'Serviced Apartments', roles: ['Front Desk Agent', 'General Manager', 'Housekeeper', 'Maintenance Engineer', 'Receptionist']),
    ]),
    HospitalityCategory(id: 'luxury', name: 'Luxury Hospitality', icon: '👑', subcategories: [
      HospitalitySubcategory(id: 'lux_estate', name: 'Private Estate', roles: ['Butler', 'Private Chef', 'Estate Manager', 'Housekeeper']),
      HospitalitySubcategory(id: 'lux_palace', name: 'Palace Hotel', roles: ['Chef Concierge', 'Executive Chef', 'General Manager', 'Head Sommelier', 'Valet']),
      HospitalitySubcategory(id: 'lux_villa', name: 'Luxury Villa', roles: ['Villa Butler', 'Villa Chef', 'Villa Host', 'Villa Manager']),
    ]),
    HospitalityCategory(id: 'private_dining', name: 'Private Dining', icon: '🍽️', subcategories: [
      HospitalitySubcategory(id: 'pd_home', name: 'Home Dining Experience', roles: ['Private Chef', 'Private Server', 'Sommelier']),
      HospitalitySubcategory(id: 'pd_members', name: "Members' Club", roles: ['Bartender', 'Club Chef', 'Host', 'Club Manager']),
      HospitalitySubcategory(id: 'pd_supper', name: 'Supper Club', roles: ['Chef', 'Host', 'Server']),
    ]),
    HospitalityCategory(id: 'resorts', name: 'Resorts', icon: '☀️', subcategories: [
      HospitalitySubcategory(id: 'res_allinc', name: 'All-Inclusive Resort', roles: ['Activities Coordinator', 'Bartender', 'Resort Chef', 'Waiter', 'Entertainer']),
      HospitalitySubcategory(id: 'res_beach', name: 'Beach Resort', roles: ['Bartender', 'Concierge', 'General Manager', 'Housekeeper', 'Waiter']),
      HospitalitySubcategory(id: 'res_boutique', name: 'Boutique Resort', roles: ['Chef', 'Concierge', 'General Manager']),
      HospitalitySubcategory(id: 'res_golf', name: 'Golf Resort', roles: ['Bartender', 'General Manager', 'Golf Pro', 'Receptionist', 'Waiter']),
      HospitalitySubcategory(id: 'res_ski', name: 'Ski Resort', roles: ['Chalet Host', 'Chef', 'Ski Instructor', 'Server']),
      HospitalitySubcategory(id: 'res_spa', name: 'Spa Resort', roles: ['General Manager', 'Receptionist', 'Spa Therapist', 'Waiter', 'Wellness Coach']),
    ]),
    HospitalityCategory(id: 'restaurants', name: 'Restaurants', icon: '🍴', subcategories: [
      HospitalitySubcategory(id: 'rest_casual', name: 'Casual Dining', roles: ['Chef', 'Hostess', 'Line Cook', 'Restaurant Manager', 'Food Runner', 'Waiter']),
      HospitalitySubcategory(id: 'rest_fast', name: 'Fast Casual', roles: ['Cashier', 'Cook', 'Shift Manager']),
      HospitalitySubcategory(id: 'rest_fine', name: 'Fine Dining', roles: ['Chef de Partie', 'Commis Chef', 'Executive Chef', 'Kitchen Porter', "Maitre D'", 'Sommelier', 'Sous Chef', 'Waiter']),
      HospitalitySubcategory(id: 'rest_pizza', name: 'Pizzeria', roles: ['Pizzaiolo', 'Pizza Helper', 'Server']),
      HospitalitySubcategory(id: 'rest_qsr', name: 'Quick Service', roles: ['Cashier', 'Crew Member', 'Store Manager']),
      HospitalitySubcategory(id: 'rest_specialty', name: 'Specialty Restaurant', roles: ['Head Chef', 'Hostess', 'Restaurant Manager', 'Sous Chef', 'Waiter']),
    ]),
    HospitalityCategory(id: 'schools', name: 'Schools & Training', icon: '🎓', subcategories: [
      HospitalitySubcategory(id: 'sch_barista', name: 'Barista Academy', roles: ['Barista Trainer', 'Program Coordinator', 'School Administrator']),
      HospitalitySubcategory(id: 'sch_bar', name: 'Bartending Academy', roles: ['Hospitality Trainer', 'Program Coordinator', 'School Administrator']),
      HospitalitySubcategory(id: 'sch_culinary', name: 'Culinary School', roles: ['Chef Instructor', 'Culinary Instructor', 'Program Coordinator', 'School Administrator']),
      HospitalitySubcategory(id: 'sch_hosp', name: 'Hospitality School', roles: ['Academic Coordinator', 'Hospitality Trainer', 'Operations Manager', 'Program Coordinator', 'School Administrator']),
      HospitalitySubcategory(id: 'sch_hotel', name: 'Hotel Management School', roles: ['Admissions Advisor', 'Hospitality Trainer', 'Program Coordinator', 'School Administrator']),
    ]),
    HospitalityCategory(id: 'spa', name: 'Spa & Wellness', icon: '🍃', subcategories: [
      HospitalitySubcategory(id: 'spa_day', name: 'Day Spa', roles: ['Beauty Therapist', 'Massage Therapist', 'Spa Receptionist']),
      HospitalitySubcategory(id: 'spa_fitness', name: 'Fitness & Gym', roles: ['Fitness Instructor', 'Personal Trainer', 'Yoga Instructor']),
      HospitalitySubcategory(id: 'spa_hotel', name: 'Hotel Spa', roles: ['Spa Attendant', 'Spa Manager', 'Spa Therapist']),
      HospitalitySubcategory(id: 'spa_standalone', name: 'Standalone Spa', roles: ['Beauty Therapist', 'Massage Therapist', 'Spa Manager', 'Receptionist', 'Spa Therapist']),
      HospitalitySubcategory(id: 'spa_wellness', name: 'Wellness Center', roles: ['Dietitian', 'Nutritionist', 'Personal Trainer', 'Receptionist', 'Spa Therapist']),
    ]),
    HospitalityCategory(id: 'specialty_kitchens', name: 'Specialty Kitchens', icon: '🔥', subcategories: [
      HospitalitySubcategory(id: 'sk_cloud', name: 'Cloud Kitchen', roles: ['Cloud Kitchen Chef', 'Kitchen Manager', 'Packer']),
      HospitalitySubcategory(id: 'sk_commissary', name: 'Commissary Kitchen', roles: ['Production Chef', 'Kitchen Porter', 'Prep Cook']),
      HospitalitySubcategory(id: 'sk_test', name: 'Test Kitchen / R&D', roles: ['Food Stylist', 'R&D Chef', 'Recipe Developer']),
    ]),
    HospitalityCategory(id: 'support', name: 'Support Services', icon: '🔧', subcategories: [
      HospitalitySubcategory(id: 'sup_cleaning', name: 'Cleaning & Janitorial', roles: ['Cleaner', 'Janitor', 'Cleaning Supervisor']),
      HospitalitySubcategory(id: 'sup_fire', name: 'Fire Safety', roles: ['Fire Marshal', 'Fire Safety Officer', 'Safety Coordinator']),
      HospitalitySubcategory(id: 'sup_food_safety', name: 'Food Safety', roles: ['Food Safety Manager', 'Food Safety Officer', 'HACCP Officer', 'Quality Control Officer']),
      HospitalitySubcategory(id: 'sup_health', name: 'Health & Safety', roles: ['Compliance Officer', 'Health & Safety Manager', 'HSE Officer']),
      HospitalitySubcategory(id: 'sup_logistics', name: 'Logistics & Supply', roles: ['Delivery Driver', 'Purchasing Manager', 'Warehouse Operative']),
      HospitalitySubcategory(id: 'sup_security', name: 'Security', roles: ['CCTV Operator', 'Security Guard', 'Security Manager']),
    ]),
    HospitalityCategory(id: 'travel', name: 'Travel Hospitality', icon: '✈️', subcategories: [
      HospitalitySubcategory(id: 'tr_airline', name: 'Airline Catering', roles: ['Airline Chef', 'Catering Loader', 'Menu Planner']),
      HospitalitySubcategory(id: 'tr_airport', name: 'Airport Lounge', roles: ['Bartender', 'Lounge Host', 'Server']),
      HospitalitySubcategory(id: 'tr_train', name: 'Train Dining', roles: ['Chef', 'Server', 'Steward']),
    ]),
  ];

  /// Find a category by ID.
  static HospitalityCategory? findCategory(String id) {
    try { return categories.firstWhere((c) => c.id == id); } catch (_) { return null; }
  }

  /// Build display path: "Category > Subcategory > Role".
  static String displayPath({String? categoryId, String? subcategoryId, String? roleId}) {
    final parts = <String>[];
    final cat = categoryId != null ? findCategory(categoryId) : null;
    if (cat != null) {
      parts.add(cat.name);
      if (subcategoryId != null) {
        try {
          final sub = cat.subcategories.firstWhere((s) => s.id == subcategoryId);
          parts.add(sub.name);
          if (roleId != null && sub.roles.contains(roleId)) parts.add(roleId);
        } catch (_) {}
      }
    }
    return parts.join(' › ');
  }
}
