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
}
