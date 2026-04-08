/// All mock data for debug/demo mode.
class MockData {
  MockData._();

  // ══════════════════════════════════════════
  // ── MASTER USER (multi-role) ──
  // ══════════════════════════════════════════
  static const masterUser = {
    'userId': 'user_001',
    'name': 'Test User',
    'roles': ['candidate', 'business', 'admin', 'services'],
    'candidateEmail': 'candidate@test.com',
    'businessEmail': 'business@test.com',
    'adminEmail': 'admin@test.com',
    'servicesEmail': 'services@test.com',
    'password': 'test123',
  };

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

  // ══════════════════════════════════════════
  // ── BUSINESS MOCK DATA ──
  // ══════════════════════════════════════════

  static const business = {
    'id': '1',
    'name': 'The Grand London',
    'initials': 'TB',
    'contactName': 'Test Business',
    'email': 'business@test.com',
    'phone': '+44 20 7946 0958',
    'location': 'Mayfair, London UK',
    'category': 'Restaurant & Bar',
    'size': '50-100 staff',
    'subscription': 'basic',
    'profileCompletion': 70,
    'website': 'www.thegrandlondon.com',
    'description': 'A premier fine dining establishment in the heart of Mayfair, offering exceptional British and European cuisine in an elegant setting.',
  };

  static const businessProfileItems = [
    {'label': 'Add business logo', 'done': false},
    {'label': 'Set location', 'done': true},
    {'label': 'Add category', 'done': true},
    {'label': 'Add description', 'done': false},
    {'label': 'Add contact details', 'done': true},
    {'label': 'Get verified', 'done': false},
    {'label': 'Post first job', 'done': true},
  ];

  static const businessJobs = [
    {
      'id': 'bj1',
      'title': 'Waiter',
      'contract': 'Full-time',
      'salary': '£14/hr',
      'applicants': 3,
      'status': 'Active',
      'urgent': false,
      'featured': false,
      'location': 'Mayfair, London',
      'posted': '3 days ago',
      'views': 124,
      'saves': 18,
      'description': 'We are looking for an experienced Waiter to join our team at The Grand London. You will be responsible for providing exceptional table service to our guests.',
      'requirements': ['2+ years fine dining experience', 'Excellent communication skills', 'Wine knowledge preferred', 'Right to work in UK'],
      'benefits': ['Staff meals provided', 'Generous tips', 'Career progression'],
    },
    {
      'id': 'bj2',
      'title': 'Bartender',
      'contract': 'Full-time',
      'salary': '£16/hr',
      'applicants': 1,
      'status': 'Active',
      'urgent': false,
      'featured': false,
      'location': 'Mayfair, London',
      'posted': '5 days ago',
      'views': 89,
      'saves': 12,
      'description': 'Join our bar team and craft cocktails for discerning guests in our award-winning cocktail lounge.',
      'requirements': ['3+ years bartending experience', 'Cocktail knowledge essential', 'Creative and passionate'],
      'benefits': ['Staff meals', 'Tips', 'Training provided'],
    },
    {
      'id': 'bj3',
      'title': 'Chef de Partie',
      'contract': 'Full-time',
      'salary': '£18/hr',
      'applicants': 0,
      'status': 'Draft',
      'urgent': false,
      'featured': false,
      'location': 'Mayfair, London',
      'posted': '1 day ago',
      'views': 0,
      'saves': 0,
      'description': 'Seeking a talented Chef de Partie to manage a section in our busy kitchen.',
      'requirements': ['Culinary qualification', '2+ years as CDP', 'Food hygiene certificate'],
      'benefits': ['Staff meals', 'Competitive salary'],
    },
    {
      'id': 'bj4',
      'title': 'Host/Hostess',
      'contract': 'Part-time',
      'salary': '£12/hr',
      'applicants': 2,
      'status': 'Active',
      'urgent': true,
      'featured': false,
      'location': 'Mayfair, London',
      'posted': '1 day ago',
      'views': 67,
      'saves': 8,
      'description': 'We need a welcoming Host/Hostess to greet guests and manage reservations at our front desk.',
      'requirements': ['Previous hosting experience', 'Professional appearance', 'Reservation system experience'],
      'benefits': ['Flexible hours', 'Staff meals'],
    },
  ];

  static List<Map<String, dynamic>> get activeBusinessJobs =>
      businessJobs.where((j) => j['status'] == 'Active').toList().cast<Map<String, dynamic>>();

  static const businessApplicants = [
    {
      'id': 'ba1',
      'name': 'Alex Chen',
      'initials': 'AC',
      'role': 'Waiter',
      'jobId': 'bj1',
      'status': 'Applied',
      'date': '1 day ago',
      'experience': '3yr exp',
      'location': 'Camden, London',
      'verified': false,
      'bio': 'Dedicated hospitality professional with 3 years of fine dining experience. Passionate about delivering exceptional guest experiences.',
      'languages': ['English (Fluent)', 'Mandarin (Native)'],
      'availability': 'Full-time',
      'salaryExpectation': '£14/hr',
    },
    {
      'id': 'ba2',
      'name': 'Maria Santos',
      'initials': 'MS',
      'role': 'Waiter',
      'jobId': 'bj1',
      'status': 'Shortlisted',
      'date': '2 days ago',
      'experience': '5yr exp',
      'location': 'Kensington, London',
      'verified': true,
      'bio': 'Experienced waitress with a background in Michelin-starred restaurants. Detail-oriented and fluent in three languages.',
      'languages': ['English (Fluent)', 'Portuguese (Native)', 'Spanish (Conversational)'],
      'availability': 'Full-time',
      'salaryExpectation': '£15/hr',
    },
    {
      'id': 'ba3',
      'name': 'James Wilson',
      'initials': 'JW',
      'role': 'Bartender',
      'jobId': 'bj2',
      'status': 'Under Review',
      'date': '1 day ago',
      'experience': '2yr exp',
      'location': 'Soho, London',
      'verified': false,
      'bio': 'Creative bartender specializing in craft cocktails. Award-winning mixologist at regional competitions.',
      'languages': ['English (Native)'],
      'availability': 'Full-time',
      'salaryExpectation': '£16/hr',
    },
    {
      'id': 'ba4',
      'name': 'Sofia Rossi',
      'initials': 'SR',
      'role': 'Host/Hostess',
      'jobId': 'bj4',
      'status': 'Applied',
      'date': '3 hrs ago',
      'experience': '1yr exp',
      'location': 'Chelsea, London',
      'verified': false,
      'bio': 'Friendly and professional with a warm personality. Eager to grow in the hospitality industry.',
      'languages': ['English (Fluent)', 'Italian (Native)'],
      'availability': 'Part-time',
      'salaryExpectation': '£12/hr',
    },
    {
      'id': 'ba5',
      'name': 'Omar Hassan',
      'initials': 'OH',
      'role': 'Host/Hostess',
      'jobId': 'bj4',
      'status': 'Shortlisted',
      'date': '1 day ago',
      'experience': '4yr exp',
      'location': 'Paddington, London',
      'verified': true,
      'bio': 'Experienced host with luxury hotel background. Fluent in Arabic and English with excellent guest relations skills.',
      'languages': ['English (Fluent)', 'Arabic (Native)', 'French (Basic)'],
      'availability': 'Full-time',
      'salaryExpectation': '£13/hr',
    },
    {
      'id': 'ba6',
      'name': 'Yuki Tanaka',
      'initials': 'YT',
      'role': 'Waiter',
      'jobId': 'bj1',
      'status': 'Interview Scheduled',
      'date': '4 days ago',
      'experience': '6yr exp',
      'location': 'Notting Hill, London',
      'verified': true,
      'bio': 'Seasoned waiter with extensive fine dining experience in Tokyo and London. Exceptional attention to detail and wine knowledge.',
      'languages': ['English (Fluent)', 'Japanese (Native)'],
      'availability': 'Full-time',
      'salaryExpectation': '£15/hr',
      'interviewDate': 'Sat Apr 11, 2:00 PM',
      'interviewType': 'Video',
    },
  ];

  static const businessInterviews = [
    {
      'id': 'bi1',
      'candidateName': 'Yuki Tanaka',
      'candidateInitials': 'YT',
      'candidateId': 'ba6',
      'jobTitle': 'Waiter',
      'date': 'Sat, Apr 11 2026',
      'time': '2:00 PM',
      'format': 'Video',
      'status': 'Confirmed',
      'link': 'https://meet.example.com/grand-london-interview',
      'notes': 'Please prepare questions about wine service experience. Candidate has 6 years of fine dining background.',
    },
    {
      'id': 'bi2',
      'candidateName': 'Omar Hassan',
      'candidateInitials': 'OH',
      'candidateId': 'ba5',
      'jobTitle': 'Host/Hostess',
      'date': 'Mon, Apr 14 2026',
      'time': '11:00 AM',
      'format': 'In Person',
      'status': 'Invited',
      'location': 'The Grand London, 45 Grosvenor Square, Mayfair, London',
      'notes': 'Ask candidate to bring ID. Meet at reception and escort to meeting room 2.',
    },
  ];

  static const businessConversations = [
    {
      'id': 'bc1',
      'candidateName': 'Alex Chen',
      'candidateInitials': 'AC',
      'jobContext': 'Waiter position',
      'lastMessage': "I'm very interested in the waiter position",
      'time': '1h ago',
      'unread': 1,
    },
    {
      'id': 'bc2',
      'candidateName': 'Yuki Tanaka',
      'candidateInitials': 'YT',
      'jobContext': 'Waiter - Interview',
      'lastMessage': 'Thank you for the interview invitation',
      'time': '3h ago',
      'unread': 0,
    },
    {
      'id': 'bc3',
      'candidateName': 'Maria Santos',
      'candidateInitials': 'MS',
      'jobContext': 'Waiter position',
      'lastMessage': 'When can I expect to hear back?',
      'time': '1d ago',
      'unread': 2,
    },
  ];

  static const businessChatMessages = [
    {'sender': 'candidate', 'text': 'Hello, I recently applied for the Waiter position at The Grand London.', 'time': '9:00 AM'},
    {'sender': 'candidate', 'text': "I'm very interested in the waiter position and would love to learn more about the role.", 'time': '9:01 AM'},
    {'sender': 'business', 'text': 'Thank you for your interest, Alex. We received your application and are reviewing it.', 'time': '9:30 AM'},
    {'sender': 'business', 'text': 'Could you tell us more about your fine dining experience?', 'time': '9:31 AM'},
    {'sender': 'candidate', 'text': "I've worked at two Michelin-starred restaurants over the past 3 years. I'd be happy to discuss further.", 'time': '10:00 AM'},
  ];

  static const quickPlugCandidates = [
    {
      'id': 'qp1',
      'name': 'Tom Baker',
      'initials': 'TB',
      'role': 'Waiter',
      'location': 'London',
      'experience': '4yr exp',
      'verified': true,
      'tags': ['Fine Dining', 'Wine Knowledge', 'Customer Service'],
      'summary': 'Experienced waiter with a passion for fine dining. Known for exceptional guest relations and upselling skills.',
    },
    {
      'id': 'qp2',
      'name': 'Emma Clarke',
      'initials': 'EC',
      'role': 'Bartender',
      'location': 'London',
      'experience': '3yr exp',
      'verified': true,
      'tags': ['Cocktails', 'Mixology', 'Speed Service'],
      'summary': 'Creative mixologist with award-winning cocktail skills. Great team player with a positive attitude.',
    },
    {
      'id': 'qp3',
      'name': 'Luca Ferrari',
      'initials': 'LF',
      'role': 'Chef',
      'location': 'London',
      'experience': '7yr exp',
      'verified': false,
      'tags': ['Italian Cuisine', 'Pastry', 'Kitchen Management'],
      'summary': 'Talented chef trained in Italy with expertise in authentic Italian and modern European cuisine.',
    },
    {
      'id': 'qp4',
      'name': 'Priya Patel',
      'initials': 'PP',
      'role': 'Host/Hostess',
      'location': 'London',
      'experience': '2yr exp',
      'verified': true,
      'tags': ['Guest Relations', 'Reservations', 'Languages'],
      'summary': 'Warm and professional hostess fluent in English, Hindi, and French. Experienced with high-end reservation systems.',
    },
    {
      'id': 'qp5',
      'name': 'Ryan Murphy',
      'initials': 'RM',
      'role': 'Manager',
      'location': 'London',
      'experience': '8yr exp',
      'verified': false,
      'tags': ['Team Leadership', 'Operations', 'P&L Management'],
      'summary': 'Seasoned restaurant manager with 8 years leading teams of 30+. Strong P&L and operational excellence track record.',
    },
  ];

  static const businessNotifications = [
    {'id': 'bn1', 'title': 'New application: Alex Chen for Waiter', 'time': '1h ago', 'type': 'applicants', 'read': false, 'icon': 'person_add'},
    {'id': 'bn2', 'title': 'Interview confirmed: Yuki Tanaka', 'time': '3h ago', 'type': 'interviews', 'read': false, 'icon': 'event_available'},
    {'id': 'bn3', 'title': 'New message from Maria Santos', 'time': '5h ago', 'type': 'messages', 'read': false, 'icon': 'chat'},
    {'id': 'bn4', 'title': 'Your Waiter job has 3 new views', 'time': '1d ago', 'type': 'jobs', 'read': true, 'icon': 'visibility'},
    {'id': 'bn5', 'title': 'Sofia Rossi applied for Host/Hostess', 'time': '3h ago', 'type': 'applicants', 'read': false, 'icon': 'person_add'},
    {'id': 'bn6', 'title': 'Complete your business profile for better visibility', 'time': '2d ago', 'type': 'jobs', 'read': true, 'icon': 'business'},
  ];

  static const businessTypes = [
    'Restaurant', 'Bar', 'Hotel', 'Beach Club', 'Cafe', 'Catering',
    'Events', 'Private Dining', 'Bakery', 'Club', 'Other',
  ];

  // ══════════════════════════════════════════
  // ── ADMIN MOCK DATA ──
  // ══════════════════════════════════════════

  static const admin = {
    'name': 'Admin User',
    'initials': 'AU',
    'email': 'admin@test.com',
    'role': 'Super Admin',
  };

  static const adminStats = {
    'totalCandidates': 1247,
    'totalBusinesses': 89,
    'activeJobs': 34,
    'applicationsToday': 23,
    'interviewsThisWeek': 12,
    'pendingVerifications': 7,
    'reportedContent': 3,
    'premiumSubscribers': 156,
  };

  static const adminCandidates = [
    {'id': 'ac1', 'name': 'Test Candidate', 'initials': 'TC', 'location': 'London', 'role': 'Waiter', 'status': 'Active', 'completion': 65, 'plan': 'Free', 'verified': 'Unverified', 'email': 'candidate@test.com', 'phone': '+44 7700 900123', 'joined': 'Jan 2026'},
    {'id': 'ac2', 'name': 'Sarah Johnson', 'initials': 'SJ', 'location': 'Dubai', 'role': 'Bartender', 'status': 'Active', 'completion': 90, 'plan': 'Premium', 'verified': 'Verified', 'email': 'sarah@test.com', 'phone': '+971 50 123 4567', 'joined': 'Dec 2025'},
    {'id': 'ac3', 'name': 'Marco Rossi', 'initials': 'MR', 'location': 'London', 'role': 'Chef', 'status': 'Suspended', 'completion': 45, 'plan': 'Free', 'verified': 'Unverified', 'email': 'marco@test.com', 'phone': '+44 7700 900456', 'joined': 'Feb 2026'},
    {'id': 'ac4', 'name': 'Aisha Al-Farsi', 'initials': 'AA', 'location': 'Dubai', 'role': 'Manager', 'status': 'Active', 'completion': 100, 'plan': 'Premium', 'verified': 'Verified', 'email': 'aisha@test.com', 'phone': '+971 55 987 6543', 'joined': 'Nov 2025'},
    {'id': 'ac5', 'name': 'Tom Baker', 'initials': 'TB', 'location': 'London', 'role': 'Host', 'status': 'Active', 'completion': 75, 'plan': 'Free', 'verified': 'Pending', 'email': 'tom@test.com', 'phone': '+44 7700 900789', 'joined': 'Mar 2026'},
    {'id': 'ac6', 'name': 'Emma Clarke', 'initials': 'EC', 'location': 'London', 'role': 'Barista', 'status': 'Active', 'completion': 80, 'plan': 'Premium', 'verified': 'Verified', 'email': 'emma@test.com', 'phone': '+44 7700 900012', 'joined': 'Jan 2026'},
  ];

  static const adminBusinesses = [
    {'id': 'ab1', 'name': 'The Grand London', 'initials': 'TG', 'category': 'Restaurant', 'location': 'Mayfair, London', 'status': 'Active', 'verified': 'Verified', 'plan': 'Premium', 'activeJobs': 3, 'email': 'info@grandlondon.com', 'size': '50-100', 'joined': 'Oct 2025'},
    {'id': 'ab2', 'name': 'Nobu Dubai', 'initials': 'ND', 'category': 'Bar/Restaurant', 'location': 'Dubai', 'status': 'Active', 'verified': 'Verified', 'plan': 'Premium', 'activeJobs': 1, 'email': 'hr@nobu.ae', 'size': '100-200', 'joined': 'Nov 2025'},
    {'id': 'ab3', 'name': 'Sketch London', 'initials': 'SL', 'category': 'Cafe', 'location': 'Mayfair, London', 'status': 'Active', 'verified': 'Unverified', 'plan': 'Free', 'activeJobs': 1, 'email': 'team@sketch.london', 'size': '20-50', 'joined': 'Feb 2026'},
    {'id': 'ab4', 'name': 'Suspicious Co', 'initials': 'SC', 'category': 'Unknown', 'location': 'N/A', 'status': 'Suspended', 'verified': 'Unverified', 'plan': 'Free', 'activeJobs': 0, 'email': 'contact@suspicious.co', 'size': 'Unknown', 'joined': 'Mar 2026'},
  ];

  static const adminJobs = [
    {'id': 'aj1', 'title': 'Waiter', 'business': 'The Grand London', 'businessId': 'ab1', 'status': 'Active', 'applicants': 3, 'featured': true, 'urgent': false, 'flagged': false, 'location': 'London', 'salary': '£14/hr', 'contract': 'Full-time', 'posted': '3 days ago'},
    {'id': 'aj2', 'title': 'Bartender', 'business': 'Nobu Dubai', 'businessId': 'ab2', 'status': 'Active', 'applicants': 1, 'featured': false, 'urgent': false, 'flagged': false, 'location': 'Dubai', 'salary': '£16/hr', 'contract': 'Full-time', 'posted': '5 days ago'},
    {'id': 'aj3', 'title': 'Chef', 'business': 'Sketch London', 'businessId': 'ab3', 'status': 'Paused', 'applicants': 0, 'featured': false, 'urgent': false, 'flagged': false, 'location': 'London', 'salary': '£18/hr', 'contract': 'Full-time', 'posted': '1 week ago'},
    {'id': 'aj4', 'title': 'Host', 'business': 'The Grand London', 'businessId': 'ab1', 'status': 'Active', 'applicants': 2, 'featured': false, 'urgent': true, 'flagged': false, 'location': 'London', 'salary': '£12/hr', 'contract': 'Part-time', 'posted': '1 day ago'},
    {'id': 'aj5', 'title': 'Manager', 'business': 'Suspicious Co', 'businessId': 'ab4', 'status': 'Flagged', 'applicants': 0, 'featured': false, 'urgent': false, 'flagged': true, 'location': 'N/A', 'salary': '£25/hr', 'contract': 'Full-time', 'posted': '2 days ago'},
  ];

  static const adminApplications = [
    {'id': 'aa1', 'candidateName': 'Test Candidate', 'candidateId': 'ac1', 'jobTitle': 'Waiter', 'business': 'The Grand London', 'businessId': 'ab1', 'status': 'Applied', 'date': '2 days ago'},
    {'id': 'aa2', 'candidateName': 'Sarah Johnson', 'candidateId': 'ac2', 'jobTitle': 'Bartender', 'business': 'Nobu Dubai', 'businessId': 'ab2', 'status': 'Under Review', 'date': '3 days ago'},
    {'id': 'aa3', 'candidateName': 'Aisha Al-Farsi', 'candidateId': 'ac4', 'jobTitle': 'Waiter', 'business': 'The Grand London', 'businessId': 'ab1', 'status': 'Interview', 'date': '5 days ago'},
    {'id': 'aa4', 'candidateName': 'Tom Baker', 'candidateId': 'ac5', 'jobTitle': 'Host', 'business': 'The Grand London', 'businessId': 'ab1', 'status': 'Shortlisted', 'date': '1 day ago'},
    {'id': 'aa5', 'candidateName': 'Emma Clarke', 'candidateId': 'ac6', 'jobTitle': 'Waiter', 'business': 'The Grand London', 'businessId': 'ab1', 'status': 'Rejected', 'date': '1 week ago'},
    {'id': 'aa6', 'candidateName': 'Marco Rossi', 'candidateId': 'ac3', 'jobTitle': 'Chef', 'business': 'Sketch London', 'businessId': 'ab3', 'status': 'Hired', 'date': '2 weeks ago'},
  ];

  static const adminInterviews = [
    {'id': 'ai1', 'candidateName': 'Aisha Al-Farsi', 'candidateId': 'ac4', 'business': 'The Grand London', 'jobTitle': 'Waiter', 'date': 'Sat, Apr 11', 'time': '2:00 PM', 'format': 'Video', 'status': 'Confirmed'},
    {'id': 'ai2', 'candidateName': 'Tom Baker', 'candidateId': 'ac5', 'business': 'The Grand London', 'jobTitle': 'Host', 'date': 'Mon, Apr 14', 'time': '11:00 AM', 'format': 'In Person', 'status': 'Upcoming'},
    {'id': 'ai3', 'candidateName': 'Sarah Johnson', 'candidateId': 'ac2', 'business': 'Nobu Dubai', 'jobTitle': 'Bartender', 'date': 'Fri, Apr 4', 'time': '3:00 PM', 'format': 'Video', 'status': 'Completed'},
    {'id': 'ai4', 'candidateName': 'Emma Clarke', 'candidateId': 'ac6', 'business': 'The Grand London', 'jobTitle': 'Waiter', 'date': 'Wed, Apr 2', 'time': '10:00 AM', 'format': 'Phone', 'status': 'No-Show'},
  ];

  static const adminVerificationQueue = [
    {'id': 'av1', 'name': 'Tom Baker', 'type': 'Candidate', 'status': 'Pending', 'submitted': '2 days ago', 'initials': 'TB'},
    {'id': 'av2', 'name': 'Sketch London', 'type': 'Business', 'status': 'Pending', 'submitted': '1 day ago', 'initials': 'SL'},
    {'id': 'av3', 'name': 'Marco Rossi', 'type': 'Candidate', 'status': 'Pending', 'submitted': '3 days ago', 'initials': 'MR'},
  ];

  static const adminModerationReports = [
    {'id': 'am1', 'title': 'Suspicious job posting', 'entity': 'Suspicious Co', 'entityType': 'Job', 'priority': 'High', 'status': 'Open', 'date': '1 day ago', 'description': 'This job posting appears to be fake. No real business address, vague job description, and requesting personal banking details from applicants.'},
    {'id': 'am2', 'title': 'Inappropriate message content', 'entity': 'User #445', 'entityType': 'Message', 'priority': 'Medium', 'status': 'Open', 'date': '2 days ago', 'description': 'User sent inappropriate and harassing messages to multiple candidates. Screenshots attached by reporter.'},
    {'id': 'am3', 'title': 'Duplicate business profile', 'entity': 'London Cafe', 'entityType': 'Business', 'priority': 'Low', 'status': 'Resolved', 'date': '5 days ago', 'description': 'Duplicate business profile created, possibly to circumvent free plan job posting limits.'},
  ];

  static const adminSupportIssues = [
    {'id': 'as1', 'title': "Can't upload CV", 'userName': 'Test Candidate', 'userType': 'Candidate', 'status': 'Open', 'priority': 'Medium', 'created': '1 day ago', 'updated': '1 day ago', 'description': 'I keep getting an error when trying to upload my CV in PDF format. The file is 2MB which should be within limits.'},
    {'id': 'as2', 'title': 'Payment not processed', 'userName': 'The Grand London', 'userType': 'Business', 'status': 'In Review', 'priority': 'High', 'created': '2 days ago', 'updated': '1 day ago', 'description': 'Our premium subscription payment was charged but the account still shows as Free plan. Transaction ID: TXN-2026-0408.'},
    {'id': 'as3', 'title': 'Account suspended wrongly', 'userName': 'Marco Rossi', 'userType': 'Candidate', 'status': 'Waiting', 'priority': 'High', 'created': '3 days ago', 'updated': '2 days ago', 'description': 'My account was suspended without explanation. I have not violated any terms of service and need this resolved urgently for job applications.'},
  ];

  static const adminSubscriptions = [
    {'id': 'asub1', 'userName': 'Sarah Johnson', 'userType': 'Candidate', 'plan': 'Candidate Premium', 'price': '£9.99/month', 'startDate': 'Jan 15, 2026', 'renewalDate': 'Apr 15, 2026', 'status': 'Active'},
    {'id': 'asub2', 'userName': 'The Grand London', 'userType': 'Business', 'plan': 'Business Pro', 'price': '£59.99/month', 'startDate': 'Nov 1, 2025', 'renewalDate': 'May 1, 2026', 'status': 'Active'},
    {'id': 'asub3', 'userName': 'Aisha Al-Farsi', 'userType': 'Candidate', 'plan': 'Candidate Premium', 'price': '£89.99/year', 'startDate': 'Dec 1, 2025', 'renewalDate': 'Dec 1, 2026', 'status': 'Active'},
    {'id': 'asub4', 'userName': 'Nobu Dubai', 'userType': 'Business', 'plan': 'Business Premium', 'price': '£499/year', 'startDate': 'Oct 1, 2025', 'renewalDate': 'Oct 1, 2026', 'status': 'Active'},
    {'id': 'asub5', 'userName': 'Emma Clarke', 'userType': 'Candidate', 'plan': 'Candidate Premium', 'price': '£9.99/month', 'startDate': 'Mar 1, 2026', 'renewalDate': 'Apr 1, 2026', 'status': 'Expired'},
    {'id': 'asub6', 'userName': 'Test Candidate', 'userType': 'Candidate', 'plan': 'Candidate Premium', 'price': '£9.99/month', 'startDate': 'Feb 1, 2026', 'renewalDate': 'Mar 1, 2026', 'status': 'Cancelled'},
  ];

  static const adminAuditLog = [
    {'id': 'al1', 'admin': 'Admin User', 'action': 'Verified', 'target': 'Sarah Johnson', 'targetType': 'Candidate', 'timestamp': '2 hours ago', 'reason': 'ID verified successfully'},
    {'id': 'al2', 'admin': 'Admin User', 'action': 'Suspended', 'target': 'Marco Rossi', 'targetType': 'Candidate', 'timestamp': '5 hours ago', 'reason': 'Multiple complaints from businesses'},
    {'id': 'al3', 'admin': 'Admin User', 'action': 'Featured', 'target': 'Waiter at The Grand London', 'targetType': 'Job', 'timestamp': '1 day ago', 'reason': 'Premium employer feature request'},
    {'id': 'al4', 'admin': 'Admin User', 'action': 'Suspended', 'target': 'Suspicious Co', 'targetType': 'Business', 'timestamp': '1 day ago', 'reason': 'Fake business profile suspected'},
    {'id': 'al5', 'admin': 'Admin User', 'action': 'Verified', 'target': 'Nobu Dubai', 'targetType': 'Business', 'timestamp': '2 days ago', 'reason': 'Trade license verified'},
    {'id': 'al6', 'admin': 'Admin User', 'action': 'Override', 'target': 'Application #aa3', 'targetType': 'Application', 'timestamp': '3 days ago', 'reason': 'Status corrected per business request'},
    {'id': 'al7', 'admin': 'Admin User', 'action': 'Resolved', 'target': 'Report: Duplicate business', 'targetType': 'Report', 'timestamp': '5 days ago', 'reason': 'Duplicate removed, original kept'},
    {'id': 'al8', 'admin': 'Admin User', 'action': 'Verified', 'target': 'Emma Clarke', 'targetType': 'Candidate', 'timestamp': '1 week ago', 'reason': 'ID and certifications verified'},
  ];

  static const adminRecentActivity = [
    {'icon': 'person_add', 'color': 'green', 'text': 'New candidate registered: Sarah Johnson', 'time': '5min ago'},
    {'icon': 'work', 'color': 'teal', 'text': 'New job posted: Waiter at The Grand', 'time': '12min ago'},
    {'icon': 'verified', 'color': 'amber', 'text': 'Verification request: Tom Baker', 'time': '30min ago'},
    {'icon': 'flag', 'color': 'red', 'text': 'Content reported: Suspicious Co job', 'time': '1hr ago'},
    {'icon': 'star', 'color': 'purple', 'text': 'Premium subscription: Aisha Al-Farsi', 'time': '2hr ago'},
  ];

  // ══════════════════════════════════════════
  // ── SERVICE / COMPANIES MOCK DATA ──
  // ══════════════════════════════════════════

  static const serviceCategories = [
    {'name': 'Food & Beverage Suppliers', 'color': 'orange', 'icon': 'restaurant'},
    {'name': 'Event Services', 'color': 'purple', 'icon': 'celebration'},
    {'name': 'Decor & Design', 'color': 'pink', 'icon': 'palette'},
    {'name': 'Entertainment', 'color': 'amber', 'icon': 'music_note'},
    {'name': 'Equipment & Operations', 'color': 'blue', 'icon': 'build'},
    {'name': 'Cleaning & Maintenance', 'color': 'teal', 'icon': 'cleaning_services'},
  ];

  static const serviceCompanies = [
    {'id': 'sc1', 'name': 'Bloom & Co', 'initials': 'BC', 'category': 'Event Services', 'subcategory': 'Florist', 'location': 'London', 'featured': true, 'verified': true, 'premium': true, 'description': 'London\'s premier event florist specializing in luxury arrangements for weddings, corporate events, and hospitality venues. We create stunning floral designs that transform any space.', 'phone': '+44 20 7946 1234', 'website': 'www.bloomandco.com', 'services': ['Wedding Flowers', 'Event Arrangements', 'Venue Decoration', 'Weekly Subscriptions'], 'distance': '1.2 mi'},
    {'id': 'sc2', 'name': 'Elite Beverages', 'initials': 'EB', 'category': 'Food & Beverage Suppliers', 'subcategory': 'Drink Supplier', 'location': 'Dubai', 'featured': true, 'verified': true, 'premium': false, 'description': 'Premium beverage supplier serving hotels, restaurants, and bars across the UAE. From craft cocktails to fine wines, we deliver excellence in every bottle.', 'phone': '+971 4 123 4567', 'website': 'www.elitebeverages.ae', 'services': ['Wine Supply', 'Spirits', 'Craft Cocktails', 'Non-Alcoholic Range'], 'distance': '3.5 mi'},
    {'id': 'sc3', 'name': 'Sound & Vision DJ', 'initials': 'SV', 'category': 'Entertainment', 'subcategory': 'DJ Services', 'location': 'London', 'featured': false, 'verified': true, 'premium': false, 'description': 'Professional DJ and AV services for events of all sizes. State-of-the-art equipment and experienced DJs to make your event unforgettable.', 'phone': '+44 7700 900567', 'website': 'www.soundvisiondj.com', 'services': ['DJ Services', 'AV Hire', 'Lighting', 'Live Streaming'], 'distance': '2.8 mi'},
    {'id': 'sc4', 'name': "Chef's Table Supplies", 'initials': 'CT', 'category': 'Equipment & Operations', 'subcategory': 'Kitchen Equipment', 'location': 'London', 'featured': false, 'verified': false, 'premium': true, 'description': 'Your one-stop shop for professional kitchen equipment. We supply top-quality commercial kitchen gear to restaurants, hotels, and catering companies.', 'phone': '+44 20 7946 5678', 'website': 'www.chefstable.co.uk', 'services': ['Commercial Ovens', 'Refrigeration', 'Cookware', 'Installation'], 'distance': '4.1 mi'},
    {'id': 'sc5', 'name': 'Golden Events Decor', 'initials': 'GE', 'category': 'Decor & Design', 'subcategory': 'Event Decor', 'location': 'Dubai', 'featured': true, 'verified': false, 'premium': false, 'description': 'Luxury event decoration and design services. We specialize in creating breathtaking settings for weddings, galas, and corporate events in Dubai.', 'phone': '+971 50 987 6543', 'website': 'www.goldenevents.ae', 'services': ['Event Design', 'Venue Styling', 'Furniture Hire', 'Lighting Design'], 'distance': '5.0 mi'},
    {'id': 'sc6', 'name': 'CleanPro Services', 'initials': 'CP', 'category': 'Cleaning & Maintenance', 'subcategory': 'Cleaning', 'location': 'London', 'featured': false, 'verified': false, 'premium': false, 'description': 'Professional cleaning services for hospitality businesses. We keep your venue spotless with eco-friendly products and reliable teams.', 'phone': '+44 20 7946 9012', 'website': '', 'services': ['Deep Cleaning', 'Daily Maintenance', 'Kitchen Cleaning', 'Post-Event Cleanup'], 'distance': '0.8 mi'},
    {'id': 'sc7', 'name': 'FoodCo Suppliers', 'initials': 'FS', 'category': 'Food & Beverage Suppliers', 'subcategory': 'Food Supplier', 'location': 'London', 'featured': false, 'verified': true, 'premium': false, 'description': 'Fresh food supplier delivering quality ingredients to restaurants and caterers across London. Farm-to-table produce, meats, and specialty items.', 'phone': '+44 20 7946 3456', 'website': 'www.foodco.co.uk', 'services': ['Fresh Produce', 'Meat & Poultry', 'Dairy', 'Specialty Items'], 'distance': '3.2 mi'},
    {'id': 'sc8', 'name': 'TechPos Solutions', 'initials': 'TP', 'category': 'Equipment & Operations', 'subcategory': 'POS Software', 'location': 'Dubai', 'featured': false, 'verified': false, 'premium': true, 'description': 'Modern POS systems designed for hospitality. Cloud-based solutions for restaurants, bars, and hotels with real-time analytics and inventory management.', 'phone': '+971 4 567 8901', 'website': 'www.techpos.ae', 'services': ['POS Systems', 'Inventory Management', 'Analytics', 'Staff Scheduling'], 'distance': '6.0 mi'},
  ];

  static List<Map<String, dynamic>> get featuredCompanies =>
      serviceCompanies.where((c) => c['featured'] == true).toList().cast<Map<String, dynamic>>();

  static List<Map<String, dynamic>> get londonCompanies =>
      serviceCompanies.where((c) => c['location'] == 'London').toList().cast<Map<String, dynamic>>();

  static const serviceFeedPosts = [
    {'id': 'sp1', 'companyId': 'sc1', 'company': 'Bloom & Co', 'companyInitials': 'BC', 'category': 'Event Services', 'text': 'Spring flowers now available for events! Book your arrangements early for the best selection of seasonal blooms.', 'mediaType': 'photo', 'time': '2hr ago', 'isPromo': false},
    {'id': 'sp2', 'companyId': 'sc2', 'company': 'Elite Beverages', 'companyInitials': 'EB', 'category': 'Food & Beverage Suppliers', 'text': 'New cocktail range for summer 2026 — featuring 12 signature blends crafted by award-winning mixologists.', 'mediaType': 'photo', 'time': '5hr ago', 'isPromo': false},
    {'id': 'sp3', 'companyId': 'sc3', 'company': 'Sound & Vision DJ', 'companyInitials': 'SV', 'category': 'Entertainment', 'text': 'Available for your next event! From intimate dinners to large galas, we bring the perfect soundtrack.', 'mediaType': 'video', 'time': '1 day ago', 'isPromo': false},
    {'id': 'sp4', 'companyId': 'sc4', 'company': "Chef's Table Supplies", 'companyInitials': 'CT', 'category': 'Equipment & Operations', 'text': '50% off kitchen equipment this week! Don\'t miss our biggest sale of the year on commercial ovens and refrigeration units.', 'mediaType': 'promo', 'time': '2 days ago', 'isPromo': true},
    {'id': 'sp5', 'companyId': 'sc5', 'company': 'Golden Events Decor', 'companyInitials': 'GE', 'category': 'Decor & Design', 'text': 'See our latest Dubai ballroom setup — a stunning gold and ivory theme for 500 guests. Contact us for your next event!', 'mediaType': 'photo', 'time': '3 days ago', 'isPromo': false},
  ];

  static const servicePromotions = [
    {'id': 'promo1', 'companyId': 'sc4', 'company': "Chef's Table Supplies", 'companyInitials': 'CT', 'title': '50% off all orders over £500', 'description': 'Massive sale on commercial kitchen equipment including ovens, refrigerators, and cookware. Use code SPRING50 at checkout.', 'validUntil': 'Apr 30, 2026', 'active': true},
    {'id': 'promo2', 'companyId': 'sc2', 'company': 'Elite Beverages', 'companyInitials': 'EB', 'title': 'Free delivery on first order', 'description': 'New customers get free delivery on their first beverage order, no minimum spend required.', 'validUntil': 'Apr 15, 2026', 'active': true},
    {'id': 'promo3', 'companyId': 'sc6', 'company': 'CleanPro Services', 'companyInitials': 'CP', 'title': 'Spring cleaning package £199', 'description': 'Complete deep clean for your venue including kitchen, dining area, and restrooms. Limited time offer.', 'validUntil': 'May 1, 2026', 'active': true},
  ];

  static const serviceSavedCompanyIds = ['sc1', 'sc2', 'sc3'];

  static const serviceConversations = [
    {'id': 'smc1', 'companyId': 'sc1', 'company': 'Bloom & Co', 'companyInitials': 'BC', 'lastMessage': 'Thank you for your inquiry!', 'time': '1h ago', 'unread': 1, 'context': 'Quote request'},
    {'id': 'smc2', 'companyId': 'sc4', 'company': "Chef's Table Supplies", 'companyInitials': 'CT', 'lastMessage': "We'd be happy to arrange a quote", 'time': '1d ago', 'unread': 0, 'context': 'Equipment inquiry'},
  ];

  static const serviceChatMessages = [
    {'sender': 'user', 'text': "Hi, I'm interested in your event flower arrangements for a corporate dinner next month.", 'time': '10:00 AM'},
    {'sender': 'company', 'text': "Thank you for reaching out! We'd love to help with your event. Could you share more details about the venue and number of guests?", 'time': '10:15 AM'},
    {'sender': 'user', 'text': 'It will be at a hotel in Mayfair, approximately 80 guests. We are looking for table centrepieces and entrance arrangements.', 'time': '10:30 AM'},
    {'sender': 'company', 'text': "That sounds wonderful! We have extensive experience with Mayfair venues. I'll prepare a quote for you. Thank you for your inquiry!", 'time': '11:00 AM'},
  ];

  static const serviceNotifications = [
    {'id': 'sn1', 'title': 'New message from Bloom & Co', 'time': '10min ago', 'type': 'messages', 'read': false},
    {'id': 'sn2', 'title': "Chef's Table has a new promotion", 'time': '1hr ago', 'type': 'promotions', 'read': false},
    {'id': 'sn3', 'title': 'Elite Beverages posted an update', 'time': '2hr ago', 'type': 'updates', 'read': true},
    {'id': 'sn4', 'title': 'New company near you: CleanPro', 'time': '1 day ago', 'type': 'updates', 'read': true},
    {'id': 'sn5', 'title': 'Complete your preferences for better matches', 'time': '2 days ago', 'type': 'updates', 'read': true},
  ];
}
