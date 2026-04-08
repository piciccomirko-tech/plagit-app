/// All mock data for debug/demo mode.
class MockData {
  MockData._();

  // ── Candidate ──
  static const candidate = {
    'id': '1',
    'name': 'Test Candidate',
    'initials': 'TC',
    'email': 'candidate@test.com',
    'phone': '+44 7700 900123',
    'location': 'London, UK',
    'role': 'Waiter',
    'experience': '3 years',
    'nationality': 'British',
    'languages': ['English (Fluent)', 'Italian (Native)'],
    'profileCompletion': 65,
    'plan': 'free',
    'availability': 'Immediate',
    'salary': '£14/hr',
    'contractPreference': 'Full-time',
  };

  // ── Profile Completion Items ──
  static const profileItems = [
    {'label': 'Add profile photo', 'done': false},
    {'label': 'Set location', 'done': true},
    {'label': 'Add role/title', 'done': true},
    {'label': 'Add experience', 'done': true},
    {'label': 'Add languages', 'done': true},
    {'label': 'Add phone number', 'done': true},
    {'label': 'Get verified', 'done': true},
  ];

  // ── Jobs (8) ──
  static const jobs = [
    {
      'id': '1',
      'title': 'Waiter',
      'company': 'The Ritz',
      'location': 'London',
      'salary': '£14/hr',
      'contract': 'Full-time',
      'featured': true,
      'urgent': false,
      'description': 'Join The Ritz as a Waiter and deliver exceptional dining experiences to our distinguished guests. You will work in a fast-paced, high-end environment providing world-class service.',
      'requirements': ['Minimum 2 years fine dining experience', 'Excellent communication skills', 'Wine knowledge preferred', 'Right to work in UK', 'Flexible schedule availability'],
      'benefits': ['Staff meals provided', 'Generous tips', 'Career progression', 'Health insurance'],
    },
    {
      'id': '2',
      'title': 'Bartender',
      'company': 'Nobu',
      'location': 'Dubai',
      'salary': '£16/hr',
      'contract': 'Full-time',
      'featured': true,
      'urgent': false,
      'description': 'Nobu Dubai is seeking an experienced Bartender to craft innovative cocktails and provide premium bar service in our world-renowned restaurant.',
      'requirements': ['3+ years bartending experience', 'Cocktail knowledge essential', 'Customer-focused attitude', 'Team player'],
      'benefits': ['Tax-free salary', 'Accommodation allowance', 'Flight tickets', 'Staff discounts'],
    },
    {
      'id': '3',
      'title': 'Chef de Partie',
      'company': 'Cipriani',
      'location': 'London',
      'salary': '£18/hr',
      'contract': 'Full-time',
      'featured': false,
      'urgent': true,
      'description': 'Cipriani London requires a skilled Chef de Partie to manage a section in our busy kitchen, preparing authentic Italian cuisine to the highest standards.',
      'requirements': ['Culinary qualification or equivalent', '2+ years as CDP', 'Italian cuisine knowledge', 'Food hygiene certificate', 'Ability to work under pressure'],
      'benefits': ['Staff meals', 'Competitive salary', 'Training opportunities'],
    },
    {
      'id': '4',
      'title': 'Host/Hostess',
      'company': 'Burj Al Arab',
      'location': 'Dubai',
      'salary': '£20/hr',
      'contract': 'Full-time',
      'featured': false,
      'urgent': false,
      'description': 'The iconic Burj Al Arab is looking for a Host/Hostess to welcome guests and manage reservations at our signature restaurants.',
      'requirements': ['Previous hosting experience in luxury venues', 'Fluent in English', 'Professional appearance', 'Reservation system experience'],
      'benefits': ['Tax-free salary', 'Accommodation', 'Flight tickets', 'World-class training'],
    },
    {
      'id': '5',
      'title': 'Barista',
      'company': 'Sketch London',
      'location': 'London',
      'salary': '£12/hr',
      'contract': 'Part-time',
      'featured': false,
      'urgent': false,
      'description': 'Sketch London is seeking a passionate Barista to craft specialty coffees in our uniquely artistic venue in Mayfair.',
      'requirements': ['Barista experience required', 'Latte art skills', 'Passion for coffee', 'Flexible availability'],
      'benefits': ['Staff discounts', 'Free meals on shift', 'Creative work environment'],
    },
    {
      'id': '6',
      'title': 'Sous Chef',
      'company': 'Zuma',
      'location': 'London',
      'salary': '£22/hr',
      'contract': 'Full-time',
      'featured': true,
      'urgent': false,
      'description': 'Zuma London is looking for a talented Sous Chef to support our Head Chef in delivering exceptional Japanese izakaya cuisine.',
      'requirements': ['5+ years kitchen experience', 'Japanese cuisine knowledge preferred', 'Strong leadership skills', 'Food safety certification', 'Creativity and passion'],
      'benefits': ['Competitive salary', 'Staff meals', 'Private healthcare', 'Career development'],
    },
    {
      'id': '7',
      'title': 'Restaurant Manager',
      'company': 'Four Seasons',
      'location': 'Dubai',
      'salary': '£30/hr',
      'contract': 'Full-time',
      'featured': false,
      'urgent': false,
      'description': 'Four Seasons Dubai seeks an experienced Restaurant Manager to oversee daily operations, manage a team, and deliver five-star guest experiences.',
      'requirements': ['5+ years management experience', 'Fine dining background', 'Budget management', 'Team leadership', 'Multi-language skills preferred'],
      'benefits': ['Tax-free salary', 'Luxury accommodation', 'Annual flights', 'World-class benefits package'],
    },
    {
      'id': '8',
      'title': 'Events Staff',
      'company': 'Harrods',
      'location': 'London',
      'salary': '£11/hr',
      'contract': 'Zero Hours',
      'featured': false,
      'urgent': false,
      'description': 'Harrods is recruiting Events Staff for our prestigious in-store events and private dining experiences in Knightsbridge.',
      'requirements': ['Events or hospitality experience', 'Professional demeanour', 'Flexible schedule', 'Excellent customer service'],
      'benefits': ['Staff discount', 'Flexible hours', 'Prestigious brand experience'],
    },
  ];

  // ── Applications (5) ──
  static const applications = [
    {
      'id': '1',
      'jobTitle': 'Waiter',
      'company': 'The Ritz',
      'location': 'London',
      'status': 'Applied',
      'date': '2 days ago',
      'salary': '£14/hr',
    },
    {
      'id': '2',
      'jobTitle': 'Bartender',
      'company': 'Nobu',
      'location': 'Dubai',
      'status': 'Under Review',
      'date': '3 days ago',
      'salary': '£16/hr',
    },
    {
      'id': '3',
      'jobTitle': 'Chef de Partie',
      'company': 'Cipriani',
      'location': 'London',
      'status': 'Interview Scheduled',
      'date': '5 days ago',
      'salary': '£18/hr',
      'interviewDate': 'Sat Apr 11, 4:09 PM',
      'interviewType': 'Video',
    },
    {
      'id': '4',
      'jobTitle': 'Host/Hostess',
      'company': 'Burj Al Arab',
      'location': 'Dubai',
      'status': 'Shortlisted',
      'date': '1 week ago',
      'salary': '£20/hr',
    },
    {
      'id': '5',
      'jobTitle': 'Sous Chef',
      'company': 'Zuma',
      'location': 'London',
      'status': 'Rejected',
      'date': '2 weeks ago',
      'salary': '£22/hr',
    },
  ];

  // ── Interviews (2) ──
  static const interviews = [
    {
      'id': '1',
      'jobTitle': 'Waiter',
      'company': 'The Ritz',
      'date': 'Sat, Apr 11 2026',
      'time': '4:09 PM',
      'format': 'Video',
      'status': 'Confirmed',
      'link': 'https://meet.example.com/ritz-interview',
      'notes': 'Please join 5 minutes early. Dress code: smart casual.',
    },
    {
      'id': '2',
      'jobTitle': 'Host/Hostess',
      'company': 'Burj Al Arab',
      'date': 'Mon, Apr 14 2026',
      'time': '10:00 AM',
      'format': 'In Person',
      'status': 'Invited',
      'location': 'Burj Al Arab, Jumeirah St, Dubai',
      'notes': 'Please bring your ID and arrive 10 minutes early. Ask for HR at reception.',
    },
  ];

  // ── Messages (3 conversations) ──
  static const conversations = [
    {
      'id': '1',
      'company': 'The Ritz',
      'jobContext': 'Waiter position',
      'lastMessage': "We'd love to invite you for an interview",
      'time': '2h ago',
      'unread': 2,
    },
    {
      'id': '2',
      'company': 'Nobu Dubai',
      'jobContext': 'Bartender position',
      'lastMessage': 'Your application is under review',
      'time': '1d ago',
      'unread': 0,
    },
    {
      'id': '3',
      'company': 'Cipriani',
      'jobContext': 'Chef de Partie position',
      'lastMessage': "Congratulations! You've been shortlisted",
      'time': '3d ago',
      'unread': 1,
    },
  ];

  // ── Chat messages for The Ritz conversation ──
  static const ritzMessages = [
    {'sender': 'business', 'text': 'Thank you for applying to the Waiter position at The Ritz.', 'time': '10:00 AM'},
    {'sender': 'business', 'text': 'We have reviewed your profile and are impressed with your experience.', 'time': '10:01 AM'},
    {'sender': 'candidate', 'text': 'Thank you! I\'m very excited about this opportunity.', 'time': '10:15 AM'},
    {'sender': 'business', 'text': 'We\'d love to invite you for an interview. Are you available this Saturday?', 'time': '11:30 AM'},
    {'sender': 'candidate', 'text': 'Yes, Saturday works perfectly for me. What time?', 'time': '11:45 AM'},
  ];

  // ── Notifications (6) ──
  static const notifications = [
    {'id': '1', 'title': 'New job match: Bartender at Nobu', 'time': '5min ago', 'type': 'jobs', 'read': false, 'icon': 'work'},
    {'id': '2', 'title': 'Your application was viewed by The Ritz', 'time': '1hr ago', 'type': 'applications', 'read': false, 'icon': 'visibility'},
    {'id': '3', 'title': 'Interview invite from Cipriani', 'time': '2hr ago', 'type': 'applications', 'read': false, 'icon': 'event'},
    {'id': '4', 'title': 'New message from The Ritz', 'time': '3hr ago', 'type': 'messages', 'read': false, 'icon': 'chat'},
    {'id': '5', 'title': "You've been shortlisted at Burj Al Arab", 'time': '1 day ago', 'type': 'applications', 'read': true, 'icon': 'star'},
    {'id': '6', 'title': 'Complete your profile for better matches', 'time': '2 days ago', 'type': 'jobs', 'read': true, 'icon': 'person'},
  ];

  // ── Saved Jobs (3 pre-saved) ──
  static const savedJobIds = ['1', '3', '6'];

  // ── Onboarding Roles ──
  static const onboardingRoles = [
    'Waiter', 'Bartender', 'Chef de Partie', 'Sous Chef', 'Barista',
    'Host/Hostess', 'Manager', 'Housekeeping', 'Events Staff',
    'Receptionist', 'Kitchen Porter', 'Runner', 'Other',
  ];

  // ── Availability Options ──
  static const availabilityOptions = [
    'Full-time', 'Part-time', 'Zero Hours', 'Temporary', 'Seasonal',
  ];

  // ── Experience Options ──
  static const experienceOptions = [
    'Less than 1 year',
    '1-2 years',
    '3-5 years',
    '5+ years',
  ];

  // Helper: get featured jobs only
  static List<Map<String, dynamic>> get featuredJobs =>
      jobs.where((j) => j['featured'] == true).toList().cast<Map<String, dynamic>>();

  // Helper: get London jobs only
  static List<Map<String, dynamic>> get londonJobs =>
      jobs.where((j) => j['location'] == 'London').toList().cast<Map<String, dynamic>>();

  // Helper: company color from name
  static int companyHue(String name) => (name.hashCode % 360).abs();
}
