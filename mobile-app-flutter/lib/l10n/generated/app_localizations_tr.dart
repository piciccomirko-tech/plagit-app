// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'Plagit';

  @override
  String get welcome => 'Welcome';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get createAccount => 'Create Account';

  @override
  String get createBusinessAccount => 'Create Business Account';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get email => 'Email address';

  @override
  String get password => 'Password';

  @override
  String get continueLabel => 'Continue';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get done => 'Done';

  @override
  String get retry => 'Retry';

  @override
  String get search => 'Search';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get apply => 'Apply';

  @override
  String get clear => 'Clear';

  @override
  String get clearAll => 'Clear all';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get confirm => 'Confirm';

  @override
  String get home => 'Home';

  @override
  String get jobs => 'Jobs';

  @override
  String get messages => 'Messages';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get logout => 'Log out';

  @override
  String get categoryAndRole => 'Category & Role';

  @override
  String get selectCategory => 'Select Category';

  @override
  String get subcategory => 'Subcategory';

  @override
  String get role => 'Role';

  @override
  String get recentSearches => 'Recent searches';

  @override
  String noResultsFor(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get mostPopular => 'Most Popular';

  @override
  String get allCategories => 'All Categories';

  @override
  String get selectVenueTypeAndRole => 'Select venue type and required role';

  @override
  String get selectCategoryAndRole => 'Select category and role';

  @override
  String get businessDetails => 'Business Details';

  @override
  String get yourDetails => 'Your Details';

  @override
  String get companyName => 'Company Name';

  @override
  String get contactPerson => 'Contact Person';

  @override
  String get location => 'Location';

  @override
  String get website => 'Website';

  @override
  String get fullName => 'Full Name';

  @override
  String get yearsExperience => 'Years of experience';

  @override
  String get languagesSpoken => 'Languages spoken';

  @override
  String get jobType => 'Job Type';

  @override
  String get jobTypeFullTime => 'Full-time';

  @override
  String get jobTypePartTime => 'Part-time';

  @override
  String get jobTypeTemporary => 'Temporary';

  @override
  String get jobTypeFreelance => 'Freelance';

  @override
  String get openToInternational => 'Open to international candidates';

  @override
  String get passwordHint => 'Password (min 8 characters)';

  @override
  String get termsOfServiceNote =>
      'By creating an account you agree to our Terms of Service and Privacy Policy.';

  @override
  String get networkError => 'Network error';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get loading => 'Loading…';

  @override
  String get errorGeneric => 'An unexpected error occurred. Please try again.';

  @override
  String get joinAsCandidate => 'Join as Candidate';

  @override
  String get joinAsBusiness => 'Join as Business';

  @override
  String get findYourNextRole => 'Find your next role in hospitality';

  @override
  String get candidateLoginSubtitle =>
      'Connect with top employers in London, Dubai and beyond.';

  @override
  String get businessLoginSubtitle =>
      'Reach top hospitality talent and grow your team.';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get lookingForStaff => 'Looking for staff? ';

  @override
  String get lookingForJob => 'Looking for a job? ';

  @override
  String get switchToBusiness => 'Switch to Business';

  @override
  String get switchToCandidate => 'Switch to Candidate';

  @override
  String get createYourProfile =>
      'Create your profile and start getting discovered by top employers.';

  @override
  String get createBusinessProfile =>
      'Create your business profile and start hiring top hospitality talent.';

  @override
  String get locationCityCountry => 'Location (city, country)';

  @override
  String get termsAgreement =>
      'By creating an account you agree to our Terms of Service and Privacy Policy.';

  @override
  String get searchHospitalityHint => 'Search category, subcategory or role…';

  @override
  String get mostCommonRoles => 'Most Common Roles';

  @override
  String get allRoles => 'All Roles';

  @override
  String suggestionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count suggestions',
      one: '1 suggestion',
    );
    return '$_temp0';
  }

  @override
  String subcategoriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count subcategories',
      one: '1 subcategory',
    );
    return '$_temp0';
  }

  @override
  String rolesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count roles',
      one: '1 role',
    );
    return '$_temp0';
  }

  @override
  String get kindCategory => 'Category';

  @override
  String get kindSubcategory => 'Subcategory';

  @override
  String get kindRole => 'Role';

  @override
  String get resetPassword => 'Reset password';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your email and we\'ll send you a link to reset your password.';

  @override
  String get sendResetLink => 'Send reset link';

  @override
  String get resetEmailSent =>
      'If an account exists for that email, a reset link has been sent.';

  @override
  String get profileSetupTitle => 'Complete your profile';

  @override
  String get profileSetupSubtitle =>
      'A complete profile gets discovered faster.';

  @override
  String get uploadPhoto => 'Upload photo';

  @override
  String get uploadCV => 'Upload CV';

  @override
  String get skipForNow => 'Skip for now';

  @override
  String get finish => 'Finish';

  @override
  String get noInternet => 'No internet connection. Please check your network.';

  @override
  String get tryAgain => 'Try again';

  @override
  String get emptyJobs => 'No jobs yet';

  @override
  String get emptyApplications => 'No applications yet';

  @override
  String get emptyMessages => 'No messages yet';

  @override
  String get emptyNotifications => 'You\'re all caught up';

  @override
  String get onboardingRoleTitle => 'What role are you looking for?';

  @override
  String get onboardingRoleSubtitle => 'Select all that apply';

  @override
  String get onboardingExperienceTitle => 'How much experience do you have?';

  @override
  String get onboardingLocationTitle => 'Where are you based?';

  @override
  String get onboardingLocationHint => 'Enter your city or postcode';

  @override
  String get useMyCurrentLocation => 'Use my current location';

  @override
  String get onboardingAvailabilityTitle => 'What are you looking for?';

  @override
  String get finishSetup => 'Finish Setup';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get findJobs => 'Find Jobs';

  @override
  String get applications => 'Applications';

  @override
  String get community => 'Community';

  @override
  String get recommendedForYou => 'Recommended For You';

  @override
  String get seeAll => 'See all';

  @override
  String get searchJobsHint => 'Search jobs, roles, locations…';

  @override
  String get searchJobs => 'Search Jobs';

  @override
  String get postedJob => 'Posted';

  @override
  String get applyNow => 'Apply Now';

  @override
  String get applied => 'Applied';

  @override
  String get saveJob => 'Save';

  @override
  String get saved => 'Saved';

  @override
  String get jobDescription => 'Job description';

  @override
  String get requirements => 'Requirements';

  @override
  String get benefits => 'Benefits';

  @override
  String get salary => 'Salary';

  @override
  String get contract => 'Contract';

  @override
  String get schedule => 'Schedule';

  @override
  String get viewCompany => 'View company';

  @override
  String get interview => 'Interview';

  @override
  String get interviews => 'Interviews';

  @override
  String get notifications => 'Notifications';

  @override
  String get matches => 'Matches';

  @override
  String get quickPlug => 'Quick Plug';

  @override
  String get discover => 'Discover';

  @override
  String get shortlist => 'Shortlist';

  @override
  String get message => 'Message';

  @override
  String get messageCandidate => 'Message';

  @override
  String get nextInterview => 'Next Interview';

  @override
  String get loadingDashboard => 'Loading dashboard…';

  @override
  String get tryAgainCta => 'Try Again';

  @override
  String get careerDashboard => 'CAREER DASHBOARD';

  @override
  String get yourNextInterview => 'Your next interview\nis lined up';

  @override
  String get yourCareerTakingOff => 'Your career\nis taking off';

  @override
  String get yourCareerOnTheMove => 'Your career\nis on the move';

  @override
  String get yourJourneyStartsHere => 'Your journey\nstarts here';

  @override
  String get applyFirstJob => 'Apply to your first job to get started';

  @override
  String get interviewComingUp => 'Interview coming up';

  @override
  String get unlockPlagitPremium => 'Unlock Plagit Premium';

  @override
  String get premiumSubtitle => 'Stand out to top venues — get matched faster';

  @override
  String get premiumActive => 'Premium Active';

  @override
  String get premiumActiveSubtitle =>
      'Priority visibility enabled · Manage plan';

  @override
  String get noJobsFound => 'No jobs match your search';

  @override
  String get noApplicationsYet => 'No applications yet';

  @override
  String get startApplying => 'Start exploring jobs to apply';

  @override
  String get noMessagesYet => 'No messages yet';

  @override
  String get allCaughtUp => 'You\'re all caught up';

  @override
  String get noNotificationsYet => 'No notifications yet';

  @override
  String get about => 'About';

  @override
  String get experience => 'Experience';

  @override
  String get skills => 'Skills';

  @override
  String get languages => 'Languages';

  @override
  String get availability => 'Availability';

  @override
  String get verified => 'Verified';

  @override
  String get totalViews => 'Total Views';

  @override
  String get verifiedVenuePrefix => 'Verified';

  @override
  String get notVerified => 'Not verified';

  @override
  String get pendingReview => 'Pending review';

  @override
  String get viewProfile => 'View profile';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get share => 'Share';

  @override
  String get report => 'Report';

  @override
  String get block => 'Block';

  @override
  String get typeMessage => 'Type a message…';

  @override
  String get send => 'Send';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get now => 'now';

  @override
  String minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '${count}m ago',
      one: '1m ago',
    );
    return '$_temp0';
  }

  @override
  String hoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '${count}h ago',
      one: '1h ago',
    );
    return '$_temp0';
  }

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '${count}d ago',
      one: '1d ago',
    );
    return '$_temp0';
  }

  @override
  String get filters => 'Filters';

  @override
  String get refineSearch => 'Refine Search';

  @override
  String get distance => 'Distance';

  @override
  String get applyFilters => 'Apply Filters';

  @override
  String get reset => 'Reset';

  @override
  String noResultsTitle(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get noResultsSubtitle =>
      'Try a different keyword or clear the search.';

  @override
  String get recentSearchesEmptyTitle => 'No recent searches';

  @override
  String get recentSearchesEmptyHint => 'Your recent searches will appear here';

  @override
  String get allJobs => 'All jobs';

  @override
  String get nearby => 'Nearby';

  @override
  String get saved2 => 'Saved';

  @override
  String get remote => 'Remote';

  @override
  String get inPerson => 'In person';

  @override
  String get aboutTheJob => 'About the job';

  @override
  String get aboutCompany => 'About the company';

  @override
  String get applyForJob => 'Apply for this job';

  @override
  String get unsaveJob => 'Unsave';

  @override
  String get noJobsNearby => 'No jobs nearby';

  @override
  String get noSavedJobs => 'No saved jobs';

  @override
  String get adjustFilters => 'Adjust your filters to see more jobs';

  @override
  String get fullTime => 'Full-time';

  @override
  String get partTime => 'Part-time';

  @override
  String get temporary => 'Temporary';

  @override
  String get freelance => 'Freelance';

  @override
  String postedAgo(String time) {
    return 'Posted $time';
  }

  @override
  String kmAway(String km) {
    return '$km km away';
  }

  @override
  String get jobDetails => 'Job Details';

  @override
  String get aboutThisRole => 'About this role';

  @override
  String get aboutTheBusiness => 'About the business';

  @override
  String get urgentHiring => 'Urgent Hiring';

  @override
  String get distanceRadius => 'Distance Radius';

  @override
  String get contractType => 'Contract Type';

  @override
  String get shiftType => 'Shift Type';

  @override
  String get all => 'All';

  @override
  String get casual => 'Casual';

  @override
  String get seasonal => 'Seasonal';

  @override
  String get morning => 'Morning';

  @override
  String get afternoon => 'Afternoon';

  @override
  String get evening => 'Evening';

  @override
  String get night => 'Night';

  @override
  String get startDate => 'Start Date';

  @override
  String get shiftHours => 'Shift Hours';

  @override
  String get category => 'Category';

  @override
  String get venueType => 'Venue Type';

  @override
  String get employment => 'Employment';

  @override
  String get pay => 'Pay';

  @override
  String get duration => 'Duration';

  @override
  String get weeklyHours => 'Weekly hours';

  @override
  String get businessLocation => 'Business Location';

  @override
  String get jobViews => 'Job Views';

  @override
  String positions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Positions',
      one: '1 Position',
    );
    return '$_temp0';
  }

  @override
  String monthsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months',
      one: '1 month',
    );
    return '$_temp0';
  }

  @override
  String get myApplications => 'My Applications';

  @override
  String get active => 'Active';

  @override
  String get interviewStatus => 'Interview';

  @override
  String get rejected => 'Rejected';

  @override
  String get offer => 'Offer';

  @override
  String appliedOn(String date) {
    return 'Applied $date';
  }

  @override
  String get viewJob => 'View job';

  @override
  String get withdraw => 'Withdraw application';

  @override
  String get applicationStatus => 'Application status';

  @override
  String get noConversations => 'No conversations yet';

  @override
  String get startConversation => 'Reply to a job to start chatting';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String lastSeen(String time) {
    return 'Last seen $time';
  }

  @override
  String get newNotification => 'New';

  @override
  String get markAllRead => 'Mark all as read';

  @override
  String get yourProfile => 'Your Profile';

  @override
  String completionPercent(int percent) {
    return '$percent% complete';
  }

  @override
  String get personalDetails => 'Personal Details';

  @override
  String get phone => 'Phone';

  @override
  String get bio => 'Bio';

  @override
  String get addPhoto => 'Add photo';

  @override
  String get addCV => 'Add CV';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get logoutConfirm => 'Are you sure you want to log out?';

  @override
  String get subscription => 'Subscription';

  @override
  String get support => 'Support';

  @override
  String get privacy => 'Privacy';

  @override
  String get terms => 'Terms';

  @override
  String get applicationDetails => 'Application Details';

  @override
  String get timeline => 'Timeline';

  @override
  String get submitted => 'Submitted';

  @override
  String get underReview => 'Under review';

  @override
  String get interviewScheduled => 'Interview scheduled';

  @override
  String get offerExtended => 'Offer extended';

  @override
  String get withdrawApp => 'Withdraw application';

  @override
  String get withdrawConfirm =>
      'Are you sure you want to withdraw this application?';

  @override
  String get applicationWithdrawn => 'Application withdrawn';

  @override
  String get statusApplied => 'Applied';

  @override
  String get statusInReview => 'In Review';

  @override
  String get statusInterview => 'Interview';

  @override
  String get statusHired => 'Hired';

  @override
  String get statusClosed => 'Closed';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get statusOffer => 'Offer';

  @override
  String get messagesSearch => 'Search messages…';

  @override
  String get noMessagesTitle => 'No messages yet';

  @override
  String get noMessagesSubtitle => 'Reply to a job to start chatting';

  @override
  String get youOnline => 'You\'re online';

  @override
  String get noNotificationsTitle => 'No notifications yet';

  @override
  String get noNotificationsSubtitle =>
      'We\'ll let you know when something happens';

  @override
  String get today2 => 'Today';

  @override
  String get earlier => 'Earlier';

  @override
  String get completeYourProfile => 'Complete your profile';

  @override
  String get profileCompletion => 'Profile completion';

  @override
  String get personalInfo => 'Personal info';

  @override
  String get professional => 'Professional';

  @override
  String get preferences => 'Preferences';

  @override
  String get documents => 'Documents';

  @override
  String get myCV => 'My CV';

  @override
  String get premium => 'Premium';

  @override
  String get addLanguages => 'Add languages';

  @override
  String get addExperience => 'Add experience';

  @override
  String get addAvailability => 'Add availability';

  @override
  String get matchesTitle => 'Your Matches';

  @override
  String get noMatchesTitle => 'No matches yet';

  @override
  String get noMatchesSubtitle =>
      'Keep applying — your matches will appear here';

  @override
  String get interestedBusinesses => 'Interested Businesses';

  @override
  String get accept => 'Accept';

  @override
  String get decline => 'Decline';

  @override
  String get newMatch => 'New match';

  @override
  String get quickPlugTitle => 'Quick Plug';

  @override
  String get quickPlugEmpty => 'No new businesses right now';

  @override
  String get quickPlugSubtitle => 'Check back later for fresh opportunities';

  @override
  String get uploadYourCV => 'Upload your CV';

  @override
  String get cvSubtitle => 'Add a CV to apply faster and stand out';

  @override
  String get chooseFile => 'Choose file';

  @override
  String get removeCV => 'Remove CV';

  @override
  String get noCVUploaded => 'No CV uploaded yet';

  @override
  String get discoverCompanies => 'Discover Companies';

  @override
  String get exploreSubtitle => 'Explore top hospitality businesses';

  @override
  String get follow => 'Follow';

  @override
  String get following => 'Following';

  @override
  String get view => 'View';

  @override
  String get selectLanguages => 'Select languages';

  @override
  String selectedCount(int count) {
    return '$count selected';
  }

  @override
  String get allLanguages => 'All Languages';

  @override
  String get uploadCVBig =>
      'Upload your CV to pre-fill your profile automatically and save time.';

  @override
  String get supportedFormats => 'Supported formats: PDF, DOC, DOCX';

  @override
  String get fillManually => 'Fill Manually';

  @override
  String get fillManuallySubtitle =>
      'Enter your details yourself and complete your profile step by step.';

  @override
  String get photoUploadSoon =>
      'Photo upload coming soon — use a professional avatar in the meantime.';

  @override
  String get yourCV => 'Your CV';

  @override
  String get aboutYou => 'About You';

  @override
  String get optional => 'Optional';

  @override
  String get completeProfile => 'Complete Profile';

  @override
  String get openToRelocation => 'Open to relocation';

  @override
  String get matchLabel => 'Match';

  @override
  String get accepted => 'Accepted';

  @override
  String get deny => 'Deny';

  @override
  String get featured => 'Featured';

  @override
  String get reviewYourProfile => 'Review Your Profile';

  @override
  String get nothingSavedYet => 'Nothing will be saved until you confirm.';

  @override
  String get editAnyField => 'You can edit any extracted field before saving.';

  @override
  String get saveToProfile => 'Save to Profile';

  @override
  String get findCompanies => 'Find Companies';

  @override
  String get mapView => 'Map View';

  @override
  String get mapComingSoon => 'Map view coming soon.';

  @override
  String get noCompaniesFound => 'No companies found';

  @override
  String get tryWiderRadius => 'Try a wider radius or different category.';

  @override
  String get verifiedOnly => 'Verified Only';

  @override
  String get resetFilters => 'Reset Filters';

  @override
  String get available => 'Available';

  @override
  String lookingFor(String role) {
    return 'Looking for: $role';
  }

  @override
  String get boostMyProfile => 'Boost My Profile';

  @override
  String get openToRelocationTravel => 'Open to Relocation / Travel';

  @override
  String get tellEmployersAboutYourself => 'Tell employers about yourself…';

  @override
  String get profileUpdated => 'Profile updated';

  @override
  String get contractPreference => 'Contract Preference';

  @override
  String get restorePurchases => 'Restore Purchases';

  @override
  String get languagePickerSoon => 'Language picker coming soon';

  @override
  String get selectCategoryRoleShort => 'Select category & role';

  @override
  String get cvUploadSoon => 'CV upload coming soon';

  @override
  String get restorePurchasesSoon => 'Restore purchases coming soon';

  @override
  String get photoUploadShort => 'Photo upload coming soon';

  @override
  String get hireBestTalent => 'Hire the best hospitality talent';

  @override
  String get businessLoginSub =>
      'Post jobs and connect with verified candidates.';

  @override
  String get lookingForWork => 'Looking for work? ';

  @override
  String get postJob => 'Post a Job';

  @override
  String get editJob => 'Edit Job';

  @override
  String get jobTitle => 'Job Title';

  @override
  String get jobDescription2 => 'Job Description';

  @override
  String get publish => 'Publish';

  @override
  String get saveDraft => 'Save Draft';

  @override
  String get applicantsTitle => 'Applicants';

  @override
  String get newApplicants => 'New applicants';

  @override
  String get noApplicantsYet => 'No applicants yet';

  @override
  String get noApplicantsSubtitle =>
      'Applicants will appear here once they apply.';

  @override
  String get scheduleInterview => 'Schedule Interview';

  @override
  String get sendInvite => 'Send Invite';

  @override
  String get interviewSent => 'Interview invite sent';

  @override
  String get rejectCandidate => 'Reject';

  @override
  String get shortlistCandidate => 'Shortlist';

  @override
  String get hiringDashboard => 'HIRING DASHBOARD';

  @override
  String get yourPipelineActive => 'Your pipeline\nis active';

  @override
  String get postJobToStart => 'Post a job to start hiring';

  @override
  String reviewApplicants(int count) {
    return 'Review $count new applicants';
  }

  @override
  String replyMessages(int count) {
    return 'Reply to $count unread messages';
  }

  @override
  String get interviews2 => 'Interviews';

  @override
  String get businessProfile => 'Company Profile';

  @override
  String get venueGallery => 'Venue Gallery';

  @override
  String get addPhotos => 'Add photos';

  @override
  String get businessName => 'Business name';

  @override
  String get venueTypeLabel => 'Venue type';

  @override
  String selectedItems(int count) {
    return '$count selected';
  }

  @override
  String get hiringProgress => 'Hiring Progress';

  @override
  String get unlockBusinessPremium => 'Unlock Business Premium';

  @override
  String get businessPremiumSubtitle => 'Get priority access to top candidates';

  @override
  String get scheduleFromApplicants => 'Schedule from applicants';

  @override
  String get recentApplicants => 'Recent Applicants';

  @override
  String get viewAll => 'View All ›';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String get candidatePipeline => 'Candidate Pipeline';

  @override
  String get allApplicants => 'All Applicants';

  @override
  String get searchCandidates => 'Search candidates, jobs, interviews...';

  @override
  String get thisWeek => 'This Week';

  @override
  String get thisMonth => 'This Month';

  @override
  String get allTime => 'All Time';

  @override
  String get post => 'Post';

  @override
  String get candidates => 'Candidates';

  @override
  String get applicantDetail => 'Applicant Details';

  @override
  String get candidateProfile => 'Candidate Profile';

  @override
  String get shortlistTitle => 'Shortlist';

  @override
  String get noShortlistedCandidates => 'No shortlisted candidates yet';

  @override
  String get shortlistEmpty => 'Candidates you shortlist will appear here';

  @override
  String get removeFromShortlist => 'Remove from shortlist';

  @override
  String get viewMessages => 'View Messages';

  @override
  String get manageJobs => 'Manage Jobs';

  @override
  String get yourJobs => 'Your Jobs';

  @override
  String get noJobsPosted => 'No jobs posted yet';

  @override
  String get noJobsPostedSubtitle => 'Post your first job to start hiring';

  @override
  String get draftJobs => 'Drafts';

  @override
  String get activeJobs => 'Active';

  @override
  String get expiredJobs => 'Expired';

  @override
  String get closedJobs => 'Closed';

  @override
  String get createJob => 'Create Job';

  @override
  String get jobDetailsTitle => 'Job Details';

  @override
  String get salaryRange => 'Salary range';

  @override
  String get currency => 'Currency';

  @override
  String get monthly => 'Monthly';

  @override
  String get annual => 'Annual';

  @override
  String get hourly => 'Hourly';

  @override
  String get minSalary => 'Min';

  @override
  String get maxSalary => 'Max';

  @override
  String get perks => 'Perks';

  @override
  String get addPerk => 'Add perk';

  @override
  String get remove => 'Remove';

  @override
  String get preview => 'Preview';

  @override
  String get publishJob => 'Publish Job';

  @override
  String get jobPublished => 'Job published';

  @override
  String get jobUpdated => 'Job updated';

  @override
  String get jobSavedDraft => 'Saved as draft';

  @override
  String get fillRequired => 'Please fill in the required fields';

  @override
  String get jobUrgent => 'Mark as urgent';

  @override
  String get addAtLeastOne => 'Add at least one requirement';

  @override
  String get createUpdate => 'Create Update';

  @override
  String get shareCompanyNews => 'Share company news';

  @override
  String get addStory => 'Add Story';

  @override
  String get showWorkplace => 'Show your workplace';

  @override
  String get viewShortlist => 'View Shortlist';

  @override
  String get yourSavedCandidates => 'Your saved candidates';

  @override
  String get inviteCandidate => 'Invite Candidate';

  @override
  String get reachOutDirectly => 'Reach out directly';

  @override
  String activeJobsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active jobs',
      one: '1 active job',
    );
    return '$_temp0';
  }

  @override
  String get employmentType => 'Employment Type';

  @override
  String get requiredRole => 'Required Role';

  @override
  String get selectCategoryRole2 => 'Select category & role';

  @override
  String get hiresNeeded => 'Hires needed';

  @override
  String get compensation => 'Compensation';

  @override
  String get useSalaryRange => 'Use salary range';

  @override
  String get contractDuration => 'Contract duration';

  @override
  String get limitReached => 'Limit Reached';

  @override
  String get upgradePlan => 'Upgrade Plan';

  @override
  String usingXofY(int used, int total) {
    return 'You\'re using $used of $total job posts.';
  }

  @override
  String get businessInterviewsTitle => 'Interviews';

  @override
  String get noInterviewsYet => 'No interviews scheduled';

  @override
  String get scheduleFirstInterview =>
      'Schedule your first interview with a candidate';

  @override
  String get sendInterviewInvite => 'Send interview invite';

  @override
  String get interviewSentTitle => 'Invite sent!';

  @override
  String get interviewSentSubtitle => 'The candidate has been notified.';

  @override
  String get scheduleInterviewTitle => 'Schedule Interview';

  @override
  String get interviewType => 'Interview Type';

  @override
  String get inPersonInterview => 'In person';

  @override
  String get videoCallInterview => 'Video call';

  @override
  String get phoneCallInterview => 'Phone call';

  @override
  String get interviewDate => 'Date';

  @override
  String get interviewTime => 'Time';

  @override
  String get interviewLocation => 'Location';

  @override
  String get interviewNotes => 'Notes';

  @override
  String get optionalLabel => 'Optional';

  @override
  String get sendInviteCta => 'Send Invite';

  @override
  String messagesCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count messages',
      one: '1 message',
    );
    return '$_temp0';
  }

  @override
  String get noNewMessages => 'No new messages';

  @override
  String get subscriptionTitle => 'Subscription';

  @override
  String get currentPlan => 'Current plan';

  @override
  String get manage => 'Manage';

  @override
  String get upgrade => 'Upgrade';

  @override
  String get renewalDate => 'Renewal date';

  @override
  String get nearbyTalent => 'Nearby Talent';

  @override
  String get searchNearby => 'Search nearby';

  @override
  String get communityTitle => 'Community';

  @override
  String get createPost => 'Create post';

  @override
  String get insights => 'Insights';

  @override
  String get viewsLabel => 'Views';

  @override
  String get applicationsLabel => 'Applications';

  @override
  String get conversionRate => 'Conversion rate';

  @override
  String get topPerformingJob => 'Top Performing Job';

  @override
  String get viewAllSimple => 'View All';

  @override
  String get viewAllApplicantsForJob => 'View all applicants for this job';

  @override
  String get noUpcomingInterviews => 'No upcoming interviews';

  @override
  String get noActivityYet => 'No activity yet';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get renewsAutomatically => 'Renews automatically';

  @override
  String get plagitBusinessPlans => 'Plagit Business Plans';

  @override
  String get scaleYourHiringSubtitle =>
      'Scale your hiring with the right plan for your business.';

  @override
  String get yearly => 'Yearly';

  @override
  String get saveWithAnnualBilling => 'Save more with annual billing';

  @override
  String get chooseYourPlanSubtitle =>
      'Choose the plan that fits your hiring needs.';

  @override
  String continueWithPlan(String plan) {
    return 'Continue with $plan';
  }

  @override
  String get subscriptionAutoRenewNote =>
      'Subscription auto-renews. Cancel anytime in Settings.';

  @override
  String get purchaseFlowComingSoon => 'Purchase flow coming soon';

  @override
  String get applicant => 'Applicant';

  @override
  String get applicantNotFound => 'Applicant not found';

  @override
  String get cvViewerComingSoon => 'CV viewer coming soon';

  @override
  String get viewCV => 'View CV';

  @override
  String get application => 'Application';

  @override
  String get messagingComingSoon => 'Messaging coming soon';

  @override
  String get interviewConfirmed => 'Interview confirmed';

  @override
  String get interviewMarkedCompleted => 'Interview marked as completed';

  @override
  String get cancelInterviewConfirm =>
      'Are you sure you want to cancel this interview?';

  @override
  String get yesCancel => 'Yes, Cancel';

  @override
  String get interviewNotFound => 'Interview not found';

  @override
  String get openingMeetingLink => 'Opening meeting link...';

  @override
  String get rescheduleComingSoon => 'Reschedule feature coming soon';

  @override
  String get notesFeatureComingSoon => 'Notes feature coming soon';

  @override
  String get candidateMarkedHired => 'Candidate marked as hired!';

  @override
  String get feedbackComingSoon => 'Feedback feature coming soon';

  @override
  String get googleMapsComingSoon => 'Google Maps integration coming soon';

  @override
  String get noCandidatesNearby => 'No candidates nearby';

  @override
  String get tryExpandingRadius => 'Try expanding your search radius.';

  @override
  String get candidate => 'Candidate';

  @override
  String get forOpenPosition => 'For open position';

  @override
  String get dateAndTimeUpper => 'DATE & TIME';

  @override
  String get interviewTypeUpper => 'INTERVIEW TYPE';

  @override
  String get timezoneUpper => 'TIMEZONE';

  @override
  String get highlights => 'Highlights';

  @override
  String get cvNotAvailable => 'CV not available';

  @override
  String get cvWillAppearHere => 'Will appear here once uploaded';

  @override
  String get seenEveryone => 'You\'ve seen everyone';

  @override
  String get checkBackForCandidates => 'Check back later for new candidates.';

  @override
  String get dailyLimitReached => 'Daily limit reached';

  @override
  String get upgradeForUnlimitedSwipes => 'Upgrade for unlimited swipes.';

  @override
  String get distanceUpper => 'DISTANCE';

  @override
  String get inviteToInterview => 'Invite to Interview';

  @override
  String get details => 'Details';

  @override
  String get shortlistedSuccessfully => 'Shortlisted successfully';

  @override
  String get tabDashboard => 'Dashboard';

  @override
  String get tabCandidates => 'Candidates';

  @override
  String get tabActivity => 'Activity';

  @override
  String get statusPosted => 'Posted';

  @override
  String get statusApplicants => 'Applicants';

  @override
  String get statusInterviewsShort => 'Interviews';

  @override
  String get statusHiredShort => 'Hired';

  @override
  String get jobLiveVisible => 'Your job post is live and visible';

  @override
  String get postJobShort => 'Post Job';

  @override
  String get messagesTitle => 'Messages';

  @override
  String get online2 => 'Online now';

  @override
  String get candidateUpper => 'CANDIDATE';

  @override
  String get searchConversationsHint =>
      'Search conversations, candidates, roles…';

  @override
  String get filterUnread => 'Unread';

  @override
  String get filterAll => 'All';

  @override
  String get whenCandidatesMessage =>
      'When candidates message you, conversations will appear here.';

  @override
  String get trySwitchingFilter => 'Try switching to a different filter.';

  @override
  String get reply => 'Reply';

  @override
  String get selectItems => 'Select items';

  @override
  String countSelected(int count) {
    return '$count selected';
  }

  @override
  String get selectAll => 'Select all';

  @override
  String get deleteConversation => 'Delete conversation?';

  @override
  String get deleteAllConversations => 'Delete all conversations?';

  @override
  String get deleteSelectedNote =>
      'Selected chats will be removed from your inbox. The candidate still keeps their copy.';

  @override
  String get deleteAll => 'Delete all';

  @override
  String get selectConversations => 'Select conversations';

  @override
  String get feedTab => 'Feed';

  @override
  String get myPostsTab => 'My Posts';

  @override
  String get savedTab => 'Saved';

  @override
  String postingAs(String name) {
    return 'Posting as $name';
  }

  @override
  String get noPostsYet => 'You haven\'t posted yet';

  @override
  String get nothingHereYet => 'Nothing here yet';

  @override
  String get shareVenueUpdate =>
      'Share an update from your venue to start building your community presence.';

  @override
  String get communityPostsAppearHere =>
      'Posts from the community will appear here.';

  @override
  String get createFirstPost => 'Create First Post';

  @override
  String get yourPostUpper => 'YOUR POST';

  @override
  String get businessLabel => 'Business';

  @override
  String get profileNotAvailable => 'Profile not available';

  @override
  String get companyProfile => 'Company Profile';

  @override
  String get premiumVenue => 'Premium venue';

  @override
  String get businessDetailsTitle => 'Business Details';

  @override
  String get businessNameLabel => 'Business Name';

  @override
  String get categoryLabel => 'Category';

  @override
  String get locationLabel => 'Location';

  @override
  String get verificationLabel => 'Verification';

  @override
  String get pendingLabel => 'Pending';

  @override
  String get notSet => 'Not set';

  @override
  String get contactLabel => 'Contact';

  @override
  String get emailLabel => 'Email';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get editProfileTitle => 'Edit Profile';

  @override
  String get companyNameField => 'Company Name';

  @override
  String get phoneField => 'Phone';

  @override
  String get locationField => 'Location';

  @override
  String get signOut => 'Sign Out';

  @override
  String get signOutTitle => 'Sign out?';

  @override
  String get signOutConfirm => 'Are you sure you want to sign out?';

  @override
  String activeCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active',
      one: '1 active',
    );
    return '$_temp0';
  }

  @override
  String newThisWeekLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count new this week',
      one: '1 new this week',
    );
    return '$_temp0';
  }

  @override
  String get jobStatusActive => 'Active';

  @override
  String get jobStatusPaused => 'Paused';

  @override
  String get jobStatusClosed => 'Closed';

  @override
  String get jobStatusDraft => 'Draft';

  @override
  String get contractCasual => 'Casual';

  @override
  String get planBasic => 'Basic';

  @override
  String get planPro => 'Pro';

  @override
  String get planPremium => 'Premium';

  @override
  String get bestForMaxVisibility => 'Best for Maximum Visibility';

  @override
  String saveDollarsPerYear(String currency, String amount) {
    return 'Save $currency$amount/year';
  }

  @override
  String get planBasicFeature1 => 'Post up to 3 jobs';

  @override
  String get planBasicFeature2 => 'View applicant profiles';

  @override
  String get planBasicFeature3 => 'Basic candidate search';

  @override
  String get planBasicFeature4 => 'Email support';

  @override
  String get planProFeature1 => 'Post up to 10 jobs';

  @override
  String get planProFeature2 => 'Advanced candidate search';

  @override
  String get planProFeature3 => 'Priority applicant sorting';

  @override
  String get planProFeature4 => 'Quick Plug access';

  @override
  String get planProFeature5 => 'Chat support';

  @override
  String get planPremiumFeature1 => 'Unlimited job postings';

  @override
  String get planPremiumFeature2 => 'Featured job listings';

  @override
  String get planPremiumFeature3 => 'Advanced analytics';

  @override
  String get planPremiumFeature4 => 'Quick Plug unlimited';

  @override
  String get planPremiumFeature5 => 'Priority candidate matching';

  @override
  String get planPremiumFeature6 => 'Dedicated account manager';

  @override
  String get currentSelectionCheck => 'Current Selection ✓';

  @override
  String selectPlanName(String plan) {
    return 'Select $plan';
  }

  @override
  String get perYear => '/year';

  @override
  String get perMonth => '/month';

  @override
  String get jobTitleHintExample => 'e.g. Senior Chef';

  @override
  String get locationHintExample => 'e.g. Dubai, UAE';

  @override
  String annualSalaryLabel(String currency) {
    return 'Annual salary ($currency)';
  }

  @override
  String monthlyPayLabel(String currency) {
    return 'Monthly pay ($currency)';
  }

  @override
  String hourlyRateLabel(String currency) {
    return 'Hourly rate ($currency)';
  }

  @override
  String minSalaryLabel(String currency) {
    return 'Min ($currency)';
  }

  @override
  String maxSalaryLabel(String currency) {
    return 'Max ($currency)';
  }

  @override
  String get hoursPerWeekLabel => 'Hours / week';

  @override
  String get expectedHoursWeekLabel => 'Expected hours / week (optional)';

  @override
  String get bonusTipsLabel => 'Bonus / Tips (optional)';

  @override
  String get bonusTipsHint => 'e.g. Tips & service charge';

  @override
  String get housingIncludedLabel => 'Housing included';

  @override
  String get travelIncludedLabel => 'Travel included';

  @override
  String get overtimeAvailableLabel => 'Overtime available';

  @override
  String get flexibleScheduleLabel => 'Flexible schedule';

  @override
  String get weekendShiftsLabel => 'Weekend shifts';

  @override
  String get describeRoleHint =>
      'Describe the role, responsibilities, and what makes this job great...';

  @override
  String get requirementsHint => 'Skills, experience, certifications needed...';

  @override
  String previewPrefix(String text) {
    return 'Preview: $text';
  }

  @override
  String monthsShort(int count) {
    return '$count mo';
  }

  @override
  String get roleAll => 'All';

  @override
  String get roleChef => 'Chef';

  @override
  String get roleWaiter => 'Waiter';

  @override
  String get roleBartender => 'Bartender';

  @override
  String get roleHost => 'Host';

  @override
  String get roleManager => 'Manager';

  @override
  String get roleReception => 'Reception';

  @override
  String get roleKitchenPorter => 'Kitchen Porter';

  @override
  String get roleRelocate => 'Relocate';

  @override
  String get experience02Years => '0-2 years';

  @override
  String get experience35Years => '3-5 years';

  @override
  String get experience5PlusYears => '5+ years';

  @override
  String get roleUpper => 'ROLE';

  @override
  String get experienceUpper => 'EXPERIENCE';

  @override
  String get cvLabel => 'CV';

  @override
  String get addShort => 'Add';

  @override
  String photosCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos',
      one: '1 photo',
    );
    return '$_temp0';
  }

  @override
  String candidatesFoundCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count candidates found',
      one: '1 candidate found',
    );
    return '$_temp0';
  }

  @override
  String get maxKmLabel => 'max 50 km';

  @override
  String get shortlistAction => 'Shortlist';

  @override
  String get messageAction => 'Message';

  @override
  String get interviewAction => 'Interview';

  @override
  String get viewAction => 'View';

  @override
  String get rejectAction => 'Reject';

  @override
  String get basedIn => 'Based in';

  @override
  String get verificationPending => 'Verification pending';

  @override
  String get refreshAction => 'Refresh';

  @override
  String get upgradeAction => 'Upgrade';

  @override
  String get searchJobsByTitleHint => 'Search jobs by title, role or location…';

  @override
  String xShortlisted(String name) {
    return '$name shortlisted';
  }

  @override
  String xRejected(String name) {
    return '$name rejected';
  }

  @override
  String rejectConfirmName(String name) {
    return 'Are you sure you want to reject $name?';
  }

  @override
  String appliedToRoleOn(String role, String date) {
    return 'Applied to $role on $date';
  }

  @override
  String appliedDatePrefix(String date) {
    return 'Applied $date';
  }

  @override
  String get salaryExpectationTitle => 'Salary Expectation';

  @override
  String get previousEmployer => 'Previous Employer';

  @override
  String get earlierVenue => 'Earlier Venue';

  @override
  String get presentLabel => 'Present';

  @override
  String get skillCustomerService => 'Customer Service';

  @override
  String get skillTeamwork => 'Teamwork';

  @override
  String get skillCommunication => 'Communication';

  @override
  String get stepApplied => 'Applied';

  @override
  String get stepViewed => 'Viewed';

  @override
  String get stepShortlisted => 'Shortlisted';

  @override
  String get stepInterviewScheduled => 'Interview Scheduled';

  @override
  String get stepRejected => 'Rejected';

  @override
  String get stepUnderReview => 'Under Review';

  @override
  String get stepPendingReview => 'Pending Review';

  @override
  String get sortNewest => 'Newest';

  @override
  String get sortMostExperienced => 'Most Experienced';

  @override
  String get sortBestMatch => 'Best Match';

  @override
  String get filterApplied => 'Applied';

  @override
  String get filterUnderReview => 'Under Review';

  @override
  String get filterShortlisted => 'Shortlisted';

  @override
  String get filterInterview => 'Interview';

  @override
  String get filterHired => 'Hired';

  @override
  String get filterRejected => 'Rejected';

  @override
  String get confirmed => 'Confirmed';

  @override
  String get pending => 'Pending';

  @override
  String get completed => 'Completed';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get videoLabel => 'Video';

  @override
  String get viewDetails => 'View Details';

  @override
  String get interviewDetails => 'Interview Details';

  @override
  String get interviewConfirmedHeadline => 'Interview confirmed';

  @override
  String get interviewConfirmedSubline =>
      'You\'re all set. We\'ll remind you closer to the time.';

  @override
  String get dateLabel => 'Date';

  @override
  String get timeLabel => 'Time';

  @override
  String get formatLabel => 'Format';

  @override
  String get joinMeeting => 'Join';

  @override
  String get viewJobAction => 'View Job';

  @override
  String get addToCalendar => 'Add to Calendar';

  @override
  String get needsYourAttention => 'Needs your attention';

  @override
  String get reviewAction => 'Review';

  @override
  String applicationsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count applications',
      one: '1 application',
    );
    return '$_temp0';
  }

  @override
  String get sortMostRecent => 'Most Recent';

  @override
  String get interviewScheduledLabel => 'Interview Scheduled';

  @override
  String get editAction => 'Edit';

  @override
  String get currentPlanLabel => 'Current Plan';

  @override
  String get freePlan => 'Free Plan';

  @override
  String get profileStrength => 'Profile Strength';

  @override
  String get detailsLabel => 'Details';

  @override
  String get basedInLabel => 'Based In';

  @override
  String get verificationLabel2 => 'Verification';

  @override
  String get contactLabel2 => 'Contact';

  @override
  String get notSetLabel => 'Not set';

  @override
  String get chipAll => 'All';

  @override
  String get chipFullTime => 'Full-time';

  @override
  String get chipPartTime => 'Part-time';

  @override
  String get chipTemporary => 'Temporary';

  @override
  String get chipCasual => 'Casual';

  @override
  String get sortBestMatchLabel => 'Best Match';

  @override
  String get sortAZ => 'A-Z';

  @override
  String get sortBy => 'Sort by';

  @override
  String get featuredBadge => 'Featured';

  @override
  String get urgentBadge => 'Urgent';

  @override
  String get salaryOnRequest => 'Salary on request';

  @override
  String get upgradeToPremium => 'Upgrade to Premium';

  @override
  String get urgentJobsOnly => 'Urgent Jobs Only';

  @override
  String get showOnlyUrgentListings => 'Show only urgent listings';

  @override
  String get verifiedBusinessesOnly => 'Verified Businesses Only';

  @override
  String get showOnlyVerifiedBusinesses => 'Show only verified businesses';

  @override
  String get split => 'Split';

  @override
  String get payUpper => 'PAY';

  @override
  String get typeUpper => 'TYPE';

  @override
  String get whereUpper => 'WHERE';

  @override
  String get payLabel => 'Pay';

  @override
  String get typeLabel => 'Type';

  @override
  String get whereLabel => 'Where';

  @override
  String get whereYouWillWork => 'Where you\'ll work';

  @override
  String get mapPreviewDirections => 'Map preview · open for full directions';

  @override
  String get directionsAction => 'Directions';

  @override
  String get communityTabForYou => 'For You';

  @override
  String get communityTabFollowing => 'Following';

  @override
  String get communityTabNearby => 'Nearby';

  @override
  String get communityTabSaved => 'Saved';

  @override
  String get viewProfileAction => 'View profile';

  @override
  String get copyLinkAction => 'Copy link';

  @override
  String get savePostAction => 'Save post';

  @override
  String get unsavePostAction => 'Unsave post';

  @override
  String get hideThisPost => 'Hide this post';

  @override
  String get reportPost => 'Report post';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get newPostTitle => 'New Post';

  @override
  String get youLabel => 'You';

  @override
  String get postingToCommunityAsBusiness => 'Posting to Community as Business';

  @override
  String get postingToCommunityAsPro =>
      'Posting to Community as Hospitality Pro';

  @override
  String get whatsOnYourMind => 'What\'s on your mind?';

  @override
  String get publishAction => 'Publish';

  @override
  String get attachmentPhoto => 'Photo';

  @override
  String get attachmentVideo => 'Video';

  @override
  String get attachmentLocation => 'Location';

  @override
  String get boostMyProfileCta => 'Boost My Profile';

  @override
  String get unlockYourFullPotential => 'Unlock your full potential';

  @override
  String get annualPlan => 'Annual';

  @override
  String get monthlyPlan => 'Monthly';

  @override
  String get bestValueBadge => 'BEST VALUE';

  @override
  String get whatsIncluded => 'What\'s included';

  @override
  String get continueWithAnnual => 'Continue with Annual';

  @override
  String get continueWithMonthly => 'Continue with Monthly';

  @override
  String get maybeLater => 'Maybe later';

  @override
  String get restorePurchasesLabel => 'Restore Purchases';

  @override
  String get subscriptionAutoRenewsNote =>
      'Subscription auto-renews. Cancel anytime in Settings.';

  @override
  String get appStatusPillApplied => 'Applied';

  @override
  String get appStatusPillUnderReview => 'Under Review';

  @override
  String get appStatusPillShortlisted => 'Shortlisted';

  @override
  String get appStatusPillInterviewInvited => 'Interview Invited';

  @override
  String get appStatusPillInterviewScheduled => 'Interview Scheduled';

  @override
  String get appStatusPillHired => 'Hired';

  @override
  String get appStatusPillRejected => 'Rejected';

  @override
  String get appStatusPillWithdrawn => 'Withdrawn';

  @override
  String get jobActionPause => 'Pause Job';

  @override
  String get jobActionResume => 'Resume Job';

  @override
  String get jobActionClose => 'Close Job';

  @override
  String get statusConfirmedLower => 'confirmed';

  @override
  String get postInsightsTitle => 'Post Insights';

  @override
  String get postInsightsSubtitle => 'Who\'s seeing your content';

  @override
  String get recentViewers => 'Recent Viewers';

  @override
  String get lockedBadge => 'LOCKED';

  @override
  String get viewerBreakdown => 'Viewer Breakdown';

  @override
  String get viewersByRole => 'Viewers by Role';

  @override
  String get topLocations => 'Top Locations';

  @override
  String get businesses => 'Businesses';

  @override
  String get saveToCollectionTitle => 'Save to Collection';

  @override
  String get chooseCategory => 'Choose Category';

  @override
  String get removeFromCollection => 'Remove from collection';

  @override
  String newApplicationTemplate(String role) {
    return 'New Application — $role';
  }

  @override
  String get categoryRestaurants => 'Restaurants';

  @override
  String get categoryCookingVideos => 'Cooking Videos';

  @override
  String get categoryJobsTips => 'Jobs Tips';

  @override
  String get categoryHospitalityNews => 'Hospitality News';

  @override
  String get categoryRecipes => 'Recipes';

  @override
  String get categoryOther => 'Other';

  @override
  String get premiumHeroTagline =>
      'More visibility, priority alerts, and advanced filters built for serious hospitality professionals.';

  @override
  String get benefitAdvancedFilters => 'Advanced search filters';

  @override
  String get benefitPriorityNotifications => 'Priority job notifications';

  @override
  String get benefitProfileVisibility => 'Increased profile visibility';

  @override
  String get benefitPremiumBadge => 'Premium profile badge';

  @override
  String get benefitEarlyAccess => 'Early access to new jobs';

  @override
  String get unlockCandidatePremium => 'Unlock Candidate Premium';

  @override
  String get getStartedAction => 'Get Started';

  @override
  String get findYourFirstJob => 'Find your first job';

  @override
  String get browseHospitalityRolesNearby =>
      'Browse hundreds of hospitality roles near you';

  @override
  String get seeWhoViewedYourPostTitle => 'See Who Viewed Your Post';

  @override
  String get upgradeToPremiumCta => 'Upgrade to Premium';

  @override
  String get upgradeToPremiumSubtitle =>
      'Upgrade to Premium to see verified businesses, recruiters, and hospitality leaders who viewed your content.';

  @override
  String get verifiedBusinessViewers => 'Verified business viewers';

  @override
  String get recruiterHiringManagerActivity =>
      'Recruiter & hiring-manager activity';

  @override
  String get cityLevelReachBreakdown => 'City-level reach breakdown';

  @override
  String liveApplicationsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count live',
      one: '1 live',
    );
    return '$_temp0';
  }

  @override
  String nearbyJobsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nearby',
      one: '1 nearby',
    );
    return '$_temp0';
  }

  @override
  String jobsNearYouCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jobs near you',
      one: '1 job near you',
    );
    return '$_temp0';
  }

  @override
  String applicationsUnderReviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count applications under review',
      one: '1 application under review',
    );
    return '$_temp0';
  }

  @override
  String interviewsScheduledCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count interviews scheduled',
      one: '1 interview scheduled',
    );
    return '$_temp0';
  }

  @override
  String unreadMessagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unread messages',
      one: '1 unread message',
    );
    return '$_temp0';
  }

  @override
  String unreadMessagesFromEmployersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unread messages from employers',
      one: '1 unread message from employers',
    );
    return '$_temp0';
  }

  @override
  String stepsLeftCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count steps left',
      one: '1 step left',
    );
    return '$_temp0';
  }

  @override
  String get profileCompleteGreatWork => 'Profile complete — great work';

  @override
  String yearsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count years',
      one: '1 year',
    );
    return '$_temp0';
  }

  @override
  String get perHour => '/hr';

  @override
  String hoursPerWeekShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hrs/week',
      one: '1 hr/week',
    );
    return '$_temp0';
  }

  @override
  String forMonthsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'for $count months',
      one: 'for 1 month',
    );
    return '$_temp0';
  }

  @override
  String interviewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count interviews',
      one: '1 interview',
    );
    return '$_temp0';
  }

  @override
  String get quickActionFindJobs => 'Find Jobs';

  @override
  String get quickActionMyApplications => 'My Applications';

  @override
  String get quickActionUpdateProfile => 'Update Profile';

  @override
  String get quickActionCreatePost => 'Create Post';

  @override
  String get quickActionViewInterviews => 'View Interviews';

  @override
  String get confirmSubscriptionTitle => 'Confirm Subscription';

  @override
  String get confirmAndSubscribeCta => 'Confirm & Subscribe';

  @override
  String get timelineLabel => 'Timeline';

  @override
  String get interviewLabel => 'Interview';

  @override
  String get payOnRequest => 'Pay on request';

  @override
  String get rateOnRequest => 'Rate on request';

  @override
  String get quickActionFindJobsSubtitle => 'Discover roles near you';

  @override
  String get quickActionMyApplicationsSubtitle => 'Track every application';

  @override
  String get quickActionUpdateProfileSubtitle =>
      'Improve your visibility & match score';

  @override
  String get quickActionCreatePostSubtitle =>
      'Share your work with the community';

  @override
  String get quickActionViewInterviewsSubtitle => 'Prepare for what\'s next';

  @override
  String get offerLabel => 'Offer';

  @override
  String hiringForTemplate(String role) {
    return '$role için işe alım';
  }

  @override
  String get tapToOpenInMaps => 'Tap to open in Maps';

  @override
  String get alreadyAppliedToJob => 'You have already applied to this job.';

  @override
  String get changePhoto => 'Change Photo';

  @override
  String get changeAvatar => 'Change Avatar';

  @override
  String get addPhotoAction => 'Add Photo';

  @override
  String get nationalityLabel => 'Nationality';

  @override
  String get targetRoleLabel => 'Target Role';

  @override
  String get salaryExpectationLabel => 'Salary Expectation';

  @override
  String get addLanguageCta => '+ Add Language';

  @override
  String get experienceLabel => 'Experience';

  @override
  String get nameLabel => 'Name';

  @override
  String get zeroHours => 'Zero Hours';

  @override
  String get checkInterviewDetailsLine => 'Check your interview details';

  @override
  String get interviewInvitedSubline =>
      'The employer wants to interview you — confirm a time';

  @override
  String get shortlistedSubline =>
      'You made the shortlist — wait for the next step';

  @override
  String get underReviewSubline => 'Employer is reviewing your profile';

  @override
  String get hiredHeadline => 'Hired';

  @override
  String get hiredSubline => 'Congratulations! You received an offer';

  @override
  String get applicationSubmittedHeadline => 'Application Submitted';

  @override
  String get applicationSubmittedSubline =>
      'The employer will review your application';

  @override
  String get withdrawnHeadline => 'Withdrawn';

  @override
  String get withdrawnSubline => 'You have withdrawn this application';

  @override
  String get notSelectedHeadline => 'Not Selected';

  @override
  String get notSelectedSubline => 'Thank you for your interest';

  @override
  String jobsFoundCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count iş bulundu',
      one: '1 iş bulundu',
    );
    return '$_temp0';
  }

  @override
  String applicationsTotalCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'toplam $count',
      one: 'toplam 1',
    );
    return '$_temp0';
  }

  @override
  String applicationsInReviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count inceleniyor',
      one: '1 inceleniyor',
    );
    return '$_temp0';
  }

  @override
  String applicationsLiveCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aktif',
      one: '1 aktif',
    );
    return '$_temp0';
  }

  @override
  String interviewsPendingConfirmTime(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count görüşme bekliyor — bir saat onayla.',
      one: '1 görüşme bekliyor — bir saat onayla.',
    );
    return '$_temp0';
  }

  @override
  String notifInterviewConfirmedTitle(String name) {
    return 'Interview Confirmed — $name';
  }

  @override
  String notifInterviewRequestTitle(String name) {
    return 'Interview Request — $name';
  }

  @override
  String notifApplicationUpdateTitle(String name) {
    return 'Application Update — $name';
  }

  @override
  String notifOfferReceivedTitle(String name) {
    return 'Offer Received — $name';
  }

  @override
  String notifMessageFromTitle(String name) {
    return 'Message from — $name';
  }

  @override
  String notifInterviewReminderTitle(String name) {
    return 'Interview Reminder — $name';
  }

  @override
  String notifProfileViewedTitle(String name) {
    return 'Profile Viewed — $name';
  }

  @override
  String notifNewJobMatchTitle(String name) {
    return 'New job match — $name';
  }

  @override
  String notifApplicationViewedTitle(String name) {
    return 'Application viewed by — $name';
  }

  @override
  String notifShortlistedTitle(String name) {
    return 'Shortlisted at — $name';
  }

  @override
  String get notifCompleteProfile => 'Complete your profile for better matches';

  @override
  String get notifCompleteBusinessProfile =>
      'Complete your business profile for better visibility';

  @override
  String notifNewJobViews(String role, String count) {
    return 'Your $role job has $count new views';
  }

  @override
  String notifAppliedForRole(String name, String role) {
    return '$name applied for $role';
  }

  @override
  String notifNewApplicationNameRole(String name, String role) {
    return 'New application: $name for $role';
  }

  @override
  String get chatTyping => 'Typing...';

  @override
  String get chatStatusSeen => 'Seen';

  @override
  String get chatStatusDelivered => 'Delivered';

  @override
  String get entryTagline =>
      'The staffing platform for hospitality professionals.';

  @override
  String get entryFindWork => 'Find Work';

  @override
  String get entryFindWorkSubtitle => 'Browse jobs and get hired by top venues';

  @override
  String get entryHireStaff => 'Hire Staff';

  @override
  String get entryHireStaffSubtitle =>
      'Post jobs and find the best hospitality talent';

  @override
  String get entryFindCompanies => 'Find Companies';

  @override
  String get entryFindCompaniesSubtitle =>
      'Discover hospitality venues and service providers';

  @override
  String get servicesEntryTitle => 'Looking for Companies';

  @override
  String get servicesHospitalityServices => 'Hospitality Services';

  @override
  String get servicesEntrySubtitle =>
      'Register your service company or find hospitality providers near you';

  @override
  String get servicesRegisterCardTitle => 'Register as a Business';

  @override
  String get servicesRegisterCardSubtitle =>
      'List your hospitality service and get discovered by clients';

  @override
  String get servicesLookingCardTitle => 'I\'m Looking for a Business';

  @override
  String get servicesLookingCardSubtitle =>
      'Find hospitality service providers near you';

  @override
  String get registerBusinessTitle => 'Register Your Business';

  @override
  String get enterCompanyName => 'Enter company name';

  @override
  String get subcategoryOptional => 'Subcategory (optional)';

  @override
  String get subcategoryHintFloristDj => 'e.g. Florist, DJ Services';

  @override
  String get searchCompaniesHint => 'Search companies...';

  @override
  String get browseCategories => 'Browse Categories';

  @override
  String companiesFoundCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count companies found',
      one: '1 company found',
    );
    return '$_temp0';
  }

  @override
  String get serviceCategoryFoodBeverage => 'Food & Beverage Suppliers';

  @override
  String get serviceCategoryEventServices => 'Event Services';

  @override
  String get serviceCategoryDecorDesign => 'Decor & Design';

  @override
  String get serviceCategoryEntertainment => 'Entertainment';

  @override
  String get serviceCategoryEquipmentOps => 'Equipment & Operations';

  @override
  String get serviceCategoryCleaningMaintenance => 'Cleaning & Maintenance';

  @override
  String distanceMiles(String value) {
    return '$value mi';
  }

  @override
  String distanceKilometers(String value) {
    return '$value km';
  }

  @override
  String get postDetailTitle => 'Post';

  @override
  String get likeAction => 'Like';

  @override
  String get commentAction => 'Comment';

  @override
  String get saveActionLabel => 'Save';

  @override
  String get commentsTitle => 'Comments';

  @override
  String get addCommentHint => 'Add a comment…';

  @override
  String likesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count likes',
      one: '1 like',
    );
    return '$_temp0';
  }

  @override
  String commentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comments',
      one: '1 comment',
    );
    return '$_temp0';
  }

  @override
  String savesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count saves',
      one: '1 save',
    );
    return '$_temp0';
  }

  @override
  String timeAgoMinutesShort(int count) {
    return '${count}m';
  }

  @override
  String timeAgoHoursShort(int count) {
    return '${count}h';
  }

  @override
  String timeAgoDaysShort(int count) {
    return '${count}d';
  }

  @override
  String get timeAgoNow => 'now';

  @override
  String get activityTitle => 'Activity';

  @override
  String get activityLikedPost => 'liked your post';

  @override
  String get activityCommented => 'commented on your post';

  @override
  String get activityStartedFollowing => 'started following you';

  @override
  String get activityMentioned => 'mentioned you';

  @override
  String get activitySystemUpdate => 'sent you an update';

  @override
  String get noActivityYetDesc =>
      'When people like, comment, or follow you, it will show here.';

  @override
  String get activeStatus => 'Active';

  @override
  String get activeBadge => 'ACTIVE';

  @override
  String get nextRenewalLabel => 'Next renewal';

  @override
  String get startedLabel => 'Started';

  @override
  String get statusLabel => 'Status';

  @override
  String get billingAndCancellation => 'Billing & cancellation';

  @override
  String get billingAndCancellationCopy =>
      'Your subscription is billed through your App Store / Google Play account. You can cancel anytime from your device Settings — you keep premium access until the renewal date.';

  @override
  String get premiumIsActive => 'Premium is active';

  @override
  String get premiumThanksCopy =>
      'Thanks for supporting Plagit. You have full access to every premium feature.';

  @override
  String get manageSubscription => 'Manage Subscription';

  @override
  String get candidatePremiumPlanName => 'Candidate Premium';

  @override
  String renewsOnDate(String date) {
    return 'Renews on $date';
  }

  @override
  String get fullViewerAccessLine =>
      'Full viewer access · all insights unlocked';

  @override
  String get premiumActiveBadge => 'Premium active';

  @override
  String get fullInsightsUnlocked =>
      'Full insights and viewer details unlocked.';

  @override
  String get noViewersInCategory => 'No viewers in this category yet';

  @override
  String get onlyVerifiedViewersShown =>
      'Only verified viewers with public profiles are shown.';

  @override
  String get notEnoughDataYet => 'Not enough data yet.';

  @override
  String get noViewInsightsYet => 'No view insights yet';

  @override
  String get noViewInsightsDesc =>
      'Insights will appear once your post gets more views.';

  @override
  String get suspiciousEngagementDetected => 'Suspicious engagement detected';

  @override
  String get patternReviewRequired => 'Pattern review required';

  @override
  String get adminInsightsFooter =>
      'Admin view — same insights the author sees, plus moderation flags. Aggregated only, no individual viewer identity is exposed.';

  @override
  String get viewerKindBusiness => 'Business';

  @override
  String get viewerKindCandidate => 'Candidate';

  @override
  String get viewerKindRecruiter => 'Recruiter';

  @override
  String get viewerKindHiringManager => 'Hiring Manager';

  @override
  String get viewerKindBusinessesPlural => 'Businesses';

  @override
  String get viewerKindCandidatesPlural => 'Candidates';

  @override
  String get viewerKindRecruitersPlural => 'Recruiters';

  @override
  String get viewerKindHiringManagersPlural => 'Hiring Managers';

  @override
  String get searchPeoplePostsVenuesHint => 'Search people, posts, venues…';

  @override
  String get searchCommunityTitle => 'Search Community';

  @override
  String get roleSommelier => 'Sommelier';

  @override
  String get candidatePremiumActivated => 'You are now Candidate Premium';

  @override
  String get purchasesRestoredPremium =>
      'Purchases restored — you are now Candidate Premium';

  @override
  String get nothingToRestore => 'Nothing to restore';

  @override
  String get noValidSubscriptionPremiumRemoved =>
      'No valid subscription found — premium access removed';

  @override
  String restoreFailedWithError(String error) {
    return 'Restore failed. $error';
  }

  @override
  String get subscriptionTitleAnnual => 'Candidate Premium · Annual';

  @override
  String get subscriptionTitleMonthly => 'Candidate Premium · Monthly';

  @override
  String pricePerYearSlash(String price) {
    return '$price / year';
  }

  @override
  String pricePerMonthSlash(String price) {
    return '$price / month';
  }

  @override
  String get nearbyJobsTitle => 'Nearby Jobs';

  @override
  String get expandRadius => 'Expand Radius';

  @override
  String get noJobsInRadius => 'No jobs in this radius';

  @override
  String jobsWithinRadius(int count, int radius) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jobs within $radius miles',
      one: '1 job within $radius miles',
    );
    return '$_temp0';
  }

  @override
  String get interviewAcceptedSnack => 'Interview accepted!';

  @override
  String get declineInterviewTitle => 'Decline Interview';

  @override
  String get declineInterviewConfirm =>
      'Are you sure you want to decline this interview?';

  @override
  String get addedToCalendar => 'Added to calendar';

  @override
  String get removeCompanyTitle => 'Remove?';

  @override
  String get removeCompanyConfirm =>
      'Are you sure you want to remove this company from your saved list?';

  @override
  String get signOutAllRolesConfirm =>
      'Are you sure you want to sign out of all roles?';

  @override
  String get tapToViewAllConversations => 'Tap to view all conversations';

  @override
  String get savedJobsTitle => 'Saved Jobs';

  @override
  String savedJobsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count saved jobs',
      one: '1 saved job',
    );
    return '$_temp0';
  }

  @override
  String get removeFromSavedTitle => 'Remove from saved?';

  @override
  String get removeFromSavedConfirm =>
      'This job will be removed from your saved list.';

  @override
  String get noSavedJobsSubtitle => 'Browse jobs and save the ones you like';

  @override
  String get browseJobsAction => 'Browse Jobs';

  @override
  String matchingJobsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count matching jobs',
      one: '1 matching job',
    );
    return '$_temp0';
  }

  @override
  String get savedPostsTitle => 'Saved Posts';

  @override
  String get searchSavedPostsHint => 'Search saved posts…';

  @override
  String get skipAction => 'Skip';

  @override
  String get submitAction => 'Submit';

  @override
  String get doneAction => 'Done';

  @override
  String get resetYourPasswordTitle => 'Reset your password';

  @override
  String get enterEmailForResetCode =>
      'Enter your email to receive a reset code';

  @override
  String get sendResetCode => 'Send Reset Code';

  @override
  String get enterResetCode => 'Enter reset code';

  @override
  String get resendCode => 'Resend Code';

  @override
  String get passwordResetComplete => 'Password reset complete';

  @override
  String get backToSignIn => 'Back to Sign In';

  @override
  String get passwordChanged => 'Password Changed';

  @override
  String get passwordUpdatedShort =>
      'Your password has been successfully updated.';

  @override
  String get passwordUpdatedRelogin =>
      'Your password has been updated. Please log in again with your new password.';

  @override
  String get updatePassword => 'Update Password';

  @override
  String get changePasswordTitle => 'Change Password';

  @override
  String get passwordRequirements => 'Password Requirements';

  @override
  String get newPasswordHint => 'New Password (min 8 characters)';

  @override
  String get confirmPasswordField => 'Confirm Password';

  @override
  String get enterEmailField => 'Enter email';

  @override
  String get enterPasswordField => 'Enter password';

  @override
  String get welcomeBack => 'Welcome back!';

  @override
  String get selectHowToUse => 'Select how you want to use Plagit today';

  @override
  String get continueAsCandidate => 'Continue as Candidate';

  @override
  String get continueAsBusiness => 'Continue as Business';

  @override
  String get signInToPlagit => 'Sign In to Plagit';

  @override
  String get enterCredentials => 'Enter your credentials to continue';

  @override
  String get adminPortal => 'Admin Portal';

  @override
  String get plagitAdmin => 'Plagit Admin';

  @override
  String get signInToAdminAccount => 'Sign in to your admin account';

  @override
  String get admin => 'Admin';

  @override
  String get searchJobsRolesRestaurantsHint =>
      'Search jobs, roles, restaurants...';

  @override
  String get exploreNearbyJobs => 'Explore Nearby Jobs';

  @override
  String get findOpportunitiesOnMap =>
      'Find opportunities on the map around you';

  @override
  String get featuredJobs => 'Featured Jobs';

  @override
  String get jobsNearYou => 'Jobs Near You';

  @override
  String get jobsMatchingRoleType => 'Jobs matching your role and job type';

  @override
  String get availableNow => 'Available Now';

  @override
  String get noNearbyJobsYet => 'No nearby jobs yet';

  @override
  String get tryIncreasingRadius =>
      'Try increasing the radius or changing filters';

  @override
  String get checkBackForOpportunities =>
      'Check back soon for new opportunities';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get okAction => 'OK';

  @override
  String get onlineNow => 'Online now';

  @override
  String get businessUpper => 'BUSINESS';

  @override
  String get waitingForBusinessFirstMessage =>
      'Waiting for the business to send the first message';

  @override
  String get whenEmployersMessageYou =>
      'When employers message you, they\'ll appear here.';

  @override
  String get replyToCandidate => 'Reply to candidate…';

  @override
  String get quickFeedback => 'Quick Feedback';

  @override
  String get helpImproveMatches => 'Help us improve your matches';

  @override
  String get thanksForFeedback => 'Thanks for your feedback!';

  @override
  String get accountSettings => 'Account Settings';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get privacyAndSecurity => 'Privacy & Security';

  @override
  String get helpAndSupport => 'Help & Support';

  @override
  String get activeRoleUpper => 'ACTIVE ROLE';

  @override
  String get meetingLink => 'Meeting Link';

  @override
  String get joinMeeting2 => 'Join meeting';

  @override
  String get notes => 'Notes';

  @override
  String get completeBusinessProfileTitle => 'Complete your business profile';

  @override
  String get businessDescription => 'Business description';

  @override
  String get finishSetupAction => 'Finish Setup';

  @override
  String get describeBusinessHintLong =>
      'Describe your business, culture, and what makes it a great place to work... (min 150 characters suggested)';

  @override
  String get describeBusinessHintShort => 'Describe your business...';

  @override
  String get writeShortIntroAboutYourself =>
      'Write a short intro about yourself...';

  @override
  String get createBusinessAccountTitle => 'Create Business Account';

  @override
  String get businessDetailsSection => 'Business Details';

  @override
  String get openToInternationalCandidates =>
      'Open to international candidates';

  @override
  String get createAccountShort => 'Create Account';

  @override
  String get yourDetailsSection => 'Your Details';

  @override
  String get jobTypeField => 'Job Type';

  @override
  String get communityFeed => 'Community Feed';

  @override
  String get postPublished => 'Post published';

  @override
  String get postHidden => 'Post hidden';

  @override
  String get postReportedReview => 'Post reported — admin will review';

  @override
  String get postNotFound => 'Post not found';

  @override
  String get goBack => 'Go back';

  @override
  String get linkCopied => 'Link copied';

  @override
  String get removedFromSaved => 'Removed from saved';

  @override
  String get noPostsFound => 'No posts found';

  @override
  String get tipsStoriesAdvice =>
      'Tips, stories, and advice from hospitality professionals';

  @override
  String get searchTalentPostsRolesHint => 'Search talent, posts, roles…';

  @override
  String get videoAttachmentsComingSoon => 'Video attachments coming soon';

  @override
  String get locationTaggingComingSoon => 'Location tagging coming soon';

  @override
  String get fullImageViewerComingSoon => 'Full image viewer coming soon';

  @override
  String get shareComingSoon => 'Share coming soon';

  @override
  String get findServices => 'Find Services';

  @override
  String get findHospitalityServices => 'Find Hospitality Services';

  @override
  String get browseServices => 'Browse Services';

  @override
  String get searchServicesCompaniesLocationsHint =>
      'Search services, companies, locations...';

  @override
  String get searchCompaniesServicesLocationsHint =>
      'Search companies, services, locations...';

  @override
  String get nearbyCompanies => 'Nearby Companies';

  @override
  String get nearYou => 'Near You';

  @override
  String get listLabel => 'List';

  @override
  String get mapViewLabel => 'Map view';

  @override
  String get noServicesFound => 'No services found';

  @override
  String get noCompaniesFoundNearby => 'No companies found nearby';

  @override
  String get noSavedCompanies => 'No saved companies';

  @override
  String get savedCompaniesTitle => 'Saved Companies';

  @override
  String get saveCompaniesForLater =>
      'Save companies you like to find them easily later';

  @override
  String get latestUpdates => 'Latest Updates';

  @override
  String get noPromotions => 'No promotions';

  @override
  String get companyHasNoPromotions => 'This company has no active promotions.';

  @override
  String get companyHasNoUpdates => 'This company has not posted any updates.';

  @override
  String get promotionsAndOffers => 'Promotions & Offers';

  @override
  String get promotionNotFound => 'Promotion not found';

  @override
  String get promotionDetails => 'Promotion Details';

  @override
  String get termsAndConditions => 'Terms & Conditions';

  @override
  String get relatedPosts => 'Related Posts';

  @override
  String get viewOffer => 'View Offer';

  @override
  String get offerBadge => 'OFFER';

  @override
  String get requestQuote => 'Request Quote';

  @override
  String get sendRequest => 'Send Request';

  @override
  String get quoteRequestSent => 'Quote request sent!';

  @override
  String get inquiry => 'Inquiry';

  @override
  String get dateNeeded => 'Date Needed';

  @override
  String get serviceType => 'Service Type';

  @override
  String get serviceArea => 'Service Area';

  @override
  String get servicesOffered => 'Services Offered';

  @override
  String get servicesLabel => 'Services';

  @override
  String get servicePlans => 'Service Plans';

  @override
  String get growYourServiceBusiness => 'Grow Your Service Business';

  @override
  String get getDiscoveredPremium =>
      'Get discovered by more clients with a premium listing.';

  @override
  String get unlockPremium => 'Unlock Premium';

  @override
  String get getMoreVisibility => 'Get more visibility and better matches';

  @override
  String get plagitPremiumUpper => 'PLAGIT PREMIUM';

  @override
  String get premiumOnly => 'Premium Only';

  @override
  String get savePercent17 => 'Save 17%';

  @override
  String get registerBusinessCta => 'Register Business';

  @override
  String get registrationSubmitted => 'Registration Submitted';

  @override
  String get serviceDescription => 'Service Description';

  @override
  String get describeServicesHint =>
      'Describe your services, experience, and what makes you stand out...';

  @override
  String get websiteOptional => 'Website (optional)';

  @override
  String get viewCompanyProfileCta => 'View Company Profile';

  @override
  String get contactCompany => 'Contact Company';

  @override
  String get aboutUs => 'About Us';

  @override
  String get address => 'Address';

  @override
  String get city => 'City';

  @override
  String get yourLocation => 'Your location';

  @override
  String get enterYourCity => 'Enter your city';

  @override
  String get clearFilters => 'Clear Filters';

  @override
  String get tryDifferentSearchTerm => 'Try a different search term';

  @override
  String get tryDifferentOrAdjust =>
      'Try a different search, category, or adjust your filters.';

  @override
  String get noPostsYetCompany => 'No posts yet';

  @override
  String requestQuoteFromCompany(String companyName) {
    return 'Request a Quote from $companyName';
  }

  @override
  String validUntilDate(String validUntil) {
    return 'Valid until $validUntil';
  }

  @override
  String get employerCheckingProfile =>
      'An employer is checking your profile right now';

  @override
  String profileStrengthPercent(int percent) {
    return 'Your profile is $percent% complete';
  }

  @override
  String get profileGetsMoreViews => 'A complete profile gets 3× more views';

  @override
  String get applicationUpdate => 'Application Update';

  @override
  String get findJobsAndApply => 'Find jobs and apply';

  @override
  String get manageJobsAndHiring => 'Manage jobs and hiring';

  @override
  String get managePlatform => 'Manage platform';

  @override
  String get findHospitalityCompanies => 'Find hospitality companies';

  @override
  String get candidateMessages => 'CANDIDATE MESSAGES';

  @override
  String get businessMessages => 'BUSINESS MESSAGES';

  @override
  String get serviceInquiries => 'SERVICE INQUIRIES';

  @override
  String get acceptInterview => 'Accept Interview';

  @override
  String get adminMenuDashboard => 'Dashboard';

  @override
  String get adminMenuUsers => 'Users';

  @override
  String get adminMenuCandidates => 'Candidates';

  @override
  String get adminMenuBusinesses => 'Businesses';

  @override
  String get adminMenuJobs => 'Jobs';

  @override
  String get adminMenuApplications => 'Applications';

  @override
  String get adminMenuBookings => 'Bookings';

  @override
  String get adminMenuPayments => 'Payments';

  @override
  String get adminMenuMessages => 'Messages';

  @override
  String get adminMenuNotifications => 'Notifications';

  @override
  String get adminMenuReports => 'Reports';

  @override
  String get adminMenuAnalytics => 'Analytics';

  @override
  String get adminMenuSettings => 'Settings';

  @override
  String get adminMenuSupport => 'Support';

  @override
  String get adminMenuModeration => 'Moderation';

  @override
  String get adminMenuRoles => 'Roles';

  @override
  String get adminMenuInvoices => 'Invoices';

  @override
  String get adminMenuLogs => 'Logs';

  @override
  String get adminMenuIntegrations => 'Integrations';

  @override
  String get adminMenuLogout => 'Logout';

  @override
  String get adminActionApprove => 'Approve';

  @override
  String get adminActionReject => 'Reject';

  @override
  String get adminActionSuspend => 'Suspend';

  @override
  String get adminActionActivate => 'Activate';

  @override
  String get adminActionDelete => 'Delete';

  @override
  String get adminActionExport => 'Export';

  @override
  String get adminSectionOverview => 'Overview';

  @override
  String get adminSectionManagement => 'Management';

  @override
  String get adminSectionFinance => 'Finance';

  @override
  String get adminSectionOperations => 'Operations';

  @override
  String get adminSectionSystem => 'System';

  @override
  String get adminStatTotalUsers => 'Total Users';

  @override
  String get adminStatActiveJobs => 'Active Jobs';

  @override
  String get adminStatPendingApprovals => 'Pending Approvals';

  @override
  String get adminStatRevenue => 'Revenue';

  @override
  String get adminStatBookingsToday => 'Bookings Today';

  @override
  String get adminStatNewSignups => 'New Signups';

  @override
  String get adminStatConversionRate => 'Conversion Rate';

  @override
  String get adminMiscWelcome => 'Welcome back';

  @override
  String get adminMiscLoading => 'Loading…';

  @override
  String get adminMiscNoData => 'No data available';

  @override
  String get adminMiscSearchPlaceholder => 'Search…';

  @override
  String get adminMenuContent => 'Content';

  @override
  String get adminMenuMore => 'More';

  @override
  String get adminMenuVerifications => 'Verifications';

  @override
  String get adminMenuSubscriptions => 'Subscriptions';

  @override
  String get adminMenuCommunity => 'Community';

  @override
  String get adminMenuInterviews => 'Interviews';

  @override
  String get adminMenuMatches => 'Matches';

  @override
  String get adminMenuFeaturedContent => 'Featured Content';

  @override
  String get adminMenuAuditLog => 'Audit Log';

  @override
  String get adminMenuChangePassword => 'Change Password';

  @override
  String get adminSectionPeople => 'People';

  @override
  String get adminSectionHiring => 'Hiring Operations';

  @override
  String get adminSectionContentComm => 'Content & Communication';

  @override
  String get adminSectionRevenue => 'Business & Revenue';

  @override
  String get adminSectionToolsContent => 'Tools & Content';

  @override
  String get adminSectionQuickActions => 'Quick Actions';

  @override
  String get adminSectionNeedsAttention => 'Needs Attention';

  @override
  String get adminStatActiveBusinesses => 'Active Businesses';

  @override
  String get adminStatApplicationsToday => 'Applications Today';

  @override
  String get adminStatInterviewsToday => 'Interviews Today';

  @override
  String get adminStatFlaggedContent => 'Flagged Content';

  @override
  String get adminStatActiveSubs => 'Active Subs';

  @override
  String get adminActionFlagged => 'Flagged';

  @override
  String get adminActionFeatured => 'Featured';

  @override
  String get adminActionReviewFlagged => 'Review Flagged Content';

  @override
  String get adminActionTodayInterviews => 'Today\'s Interviews';

  @override
  String get adminActionOpenReports => 'Open Reports';

  @override
  String get adminActionManageSubscriptions => 'Manage Subscriptions';

  @override
  String get adminActionAnalyticsDashboard => 'Analytics Dashboard';

  @override
  String get adminActionSendNotification => 'Send Notification';

  @override
  String get adminActionCreateCommunityPost => 'Create Community Post';

  @override
  String get adminActionRetry => 'Retry';

  @override
  String get adminMiscGreetingMorning => 'Good morning';

  @override
  String get adminMiscGreetingAfternoon => 'Good afternoon';

  @override
  String get adminMiscGreetingEvening => 'Good evening';

  @override
  String get adminMiscAllClear => 'All clear — nothing needs attention.';

  @override
  String get adminSubtitleAllUsers => 'All platform users';

  @override
  String get adminSubtitleCandidates => 'Job seeker profiles';

  @override
  String get adminSubtitleBusinesses => 'Employer accounts';

  @override
  String get adminSubtitleJobs => 'Active job listings';

  @override
  String get adminSubtitleApplications => 'Submitted applications';

  @override
  String get adminSubtitleInterviews => 'Scheduled interviews';

  @override
  String get adminSubtitleMatches => 'Role and job type matches';

  @override
  String get adminSubtitleVerifications => 'Review pending verifications';

  @override
  String get adminSubtitleReports => 'Flags and moderation';

  @override
  String get adminSubtitleSupport => 'Open support issues';

  @override
  String get adminSubtitleMessages => 'User conversations';

  @override
  String get adminSubtitleNotifications => 'Push & in-app alerts';

  @override
  String get adminSubtitleCommunity => 'Posts and discussions';

  @override
  String get adminSubtitleFeaturedContent => 'Highlighted content';

  @override
  String get adminSubtitleSubscriptions => 'Plans and billing';

  @override
  String get adminSubtitleAuditLog => 'Admin activity logs';

  @override
  String get adminSubtitleAnalytics => 'Platform metrics';

  @override
  String get adminSubtitleSettings => 'Platform configuration';

  @override
  String get adminSubtitleUsersPage => 'Manage platform accounts';

  @override
  String get adminSubtitleContentPage => 'Jobs, applications, and interviews';

  @override
  String get adminSubtitleModerationPage =>
      'Verifications, reports, and support';

  @override
  String get adminSubtitleMorePage => 'Settings, analytics, and account';

  @override
  String get adminSubtitleAnalyticsHero => 'KPIs, trends, and platform health';

  @override
  String get adminBadgeUrgent => 'Urgent';

  @override
  String get adminBadgeReview => 'Review';

  @override
  String get adminBadgeAction => 'Action';

  @override
  String get adminMenuAllUsers => 'All Users';

  @override
  String get adminMiscSuperAdmin => 'Super Admin';

  @override
  String adminBadgeNToday(int count) {
    return '$count today';
  }

  @override
  String adminBadgeNOpen(int count) {
    return '$count open';
  }

  @override
  String adminBadgeNActive(int count) {
    return '$count active';
  }

  @override
  String adminBadgeNUnread(int count) {
    return '$count unread';
  }

  @override
  String adminBadgeNPending(int count) {
    return '$count pending';
  }

  @override
  String adminBadgeNPosts(int count) {
    return '$count posts';
  }

  @override
  String adminBadgeNFeatured(int count) {
    return '$count featured';
  }

  @override
  String get adminStatusActive => 'Active';

  @override
  String get adminStatusPaused => 'Paused';

  @override
  String get adminStatusClosed => 'Closed';

  @override
  String get adminStatusDraft => 'Draft';

  @override
  String get adminStatusFlagged => 'Flagged';

  @override
  String get adminStatusSuspended => 'Suspended';

  @override
  String get adminStatusPending => 'Pending';

  @override
  String get adminStatusConfirmed => 'Confirmed';

  @override
  String get adminStatusCompleted => 'Completed';

  @override
  String get adminStatusCancelled => 'Cancelled';

  @override
  String get adminStatusAccepted => 'Accepted';

  @override
  String get adminStatusDenied => 'Denied';

  @override
  String get adminStatusExpired => 'Expired';

  @override
  String get adminStatusResolved => 'Resolved';

  @override
  String get adminStatusScheduled => 'Scheduled';

  @override
  String get adminStatusBanned => 'Banned';

  @override
  String get adminStatusVerified => 'Verified';

  @override
  String get adminStatusFailed => 'Failed';

  @override
  String get adminStatusSuccess => 'Success';

  @override
  String get adminStatusDelivered => 'Delivered';

  @override
  String get adminFilterAll => 'All';

  @override
  String get adminFilterToday => 'Today';

  @override
  String get adminFilterUnread => 'Unread';

  @override
  String get adminFilterRead => 'Read';

  @override
  String get adminFilterCandidates => 'Candidates';

  @override
  String get adminFilterBusinesses => 'Businesses';

  @override
  String get adminFilterAdmins => 'Admins';

  @override
  String get adminFilterCandidate => 'Candidate';

  @override
  String get adminFilterBusiness => 'Business';

  @override
  String get adminFilterSystem => 'System';

  @override
  String get adminFilterPinned => 'Pinned';

  @override
  String get adminFilterEmployers => 'Employers';

  @override
  String get adminFilterBanners => 'Banners';

  @override
  String get adminFilterBilling => 'Billing';

  @override
  String get adminFilterFeaturedEmployer => 'Featured Employer';

  @override
  String get adminFilterFeaturedJob => 'Featured Job';

  @override
  String get adminFilterHomeBanner => 'Home Banner';

  @override
  String get adminEmptyAdjustFilters => 'Try adjusting filters.';

  @override
  String get adminEmptyJobsTitle => 'No jobs';

  @override
  String get adminEmptyJobsSub => 'No jobs match.';

  @override
  String get adminEmptyUsersTitle => 'No users match';

  @override
  String get adminEmptyMessagesTitle => 'No messages';

  @override
  String get adminEmptyMessagesSub => 'No conversations to show.';

  @override
  String get adminEmptyReportsTitle => 'No reports';

  @override
  String get adminEmptyReportsSub => 'No user reports to review.';

  @override
  String get adminEmptyBusinessesTitle => 'No businesses';

  @override
  String get adminEmptyBusinessesSub => 'No businesses match.';

  @override
  String get adminEmptyNotifsTitle => 'No notifications match';

  @override
  String get adminEmptySubsTitle => 'No subscriptions';

  @override
  String get adminEmptySubsSub => 'No subscriptions match.';

  @override
  String get adminEmptyLogsTitle => 'No logs match';

  @override
  String get adminEmptyContentTitle => 'No content matches';

  @override
  String get adminEmptyInterviewsTitle => 'No interviews';

  @override
  String get adminEmptyInterviewsSub => 'No interviews match.';

  @override
  String get adminEmptyFeedback => 'Feedback data will appear here';

  @override
  String get adminEmptyMatchNotifs => 'Match notifications will appear here';

  @override
  String get adminTitleMatchManagement => 'Match Management';

  @override
  String get adminTitleAdminLogs => 'Admin Logs';

  @override
  String get adminTitleContentFeatured => 'Content / Featured';

  @override
  String get adminTabFeedback => 'Feedback';

  @override
  String get adminTabStats => 'Stats';

  @override
  String get adminSortNewest => 'Newest';

  @override
  String get adminSortPriority => 'Priority';

  @override
  String get adminStatTotalMatches => 'Total Matches';

  @override
  String get adminStatAccepted => 'Accepted';

  @override
  String get adminStatDenied => 'Denied';

  @override
  String get adminStatFeedbackCount => 'Feedback';

  @override
  String get adminStatMatchQuality => 'Match Quality Score';

  @override
  String get adminStatTotal => 'Total';

  @override
  String get adminStatPendingCount => 'Pending';

  @override
  String get adminStatNotificationsCount => 'Notifications';

  @override
  String get adminStatActiveCount => 'Active';

  @override
  String get adminSectionPlatformSettings => 'Platform Settings';

  @override
  String get adminSectionNotificationSettings => 'Notification Settings';

  @override
  String get adminSettingMaintenanceTitle => 'Maintenance Mode';

  @override
  String get adminSettingMaintenanceSub => 'Disable access for all users';

  @override
  String get adminSettingNewRegsTitle => 'New Registrations';

  @override
  String get adminSettingNewRegsSub => 'Allow new user sign-ups';

  @override
  String get adminSettingFeaturedJobsTitle => 'Featured Jobs';

  @override
  String get adminSettingFeaturedJobsSub => 'Show featured jobs on home';

  @override
  String get adminSettingEmailNotifsTitle => 'Email Notifications';

  @override
  String get adminSettingEmailNotifsSub => 'Send email alerts';

  @override
  String get adminSettingPushNotifsTitle => 'Push Notifications';

  @override
  String get adminSettingPushNotifsSub => 'Send push notifications';

  @override
  String get adminActionSaveChanges => 'Save Changes';

  @override
  String get adminToastSettingsSaved => 'Settings saved';

  @override
  String get adminActionResolve => 'Resolve';

  @override
  String get adminActionDismiss => 'Dismiss';

  @override
  String get adminActionBanUser => 'Ban User';

  @override
  String get adminSearchUsersHint => 'Search name, email, role, location...';

  @override
  String get adminMiscPositive => 'positive';

  @override
  String adminCountUsers(int count) {
    return '$count users';
  }

  @override
  String adminCountNotifs(int count) {
    return '$count notifications';
  }

  @override
  String adminCountLogs(int count) {
    return '$count log entries';
  }

  @override
  String adminCountItems(int count) {
    return '$count items';
  }

  @override
  String adminBadgeNRetried(int count) {
    return 'Retried x$count';
  }

  @override
  String get adminStatusApplied => 'Applied';

  @override
  String get adminStatusUnderReview => 'Under Review';

  @override
  String get adminStatusShortlisted => 'Shortlisted';

  @override
  String get adminStatusInterview => 'Interview';

  @override
  String get adminStatusHired => 'Hired';

  @override
  String get adminStatusRejected => 'Rejected';

  @override
  String get adminStatusOpen => 'Open';

  @override
  String get adminStatusInReview => 'In Review';

  @override
  String get adminStatusWaiting => 'Waiting';

  @override
  String get adminPriorityHigh => 'High';

  @override
  String get adminPriorityMedium => 'Medium';

  @override
  String get adminPriorityLow => 'Low';

  @override
  String get adminActionViewProfile => 'View Profile';

  @override
  String get adminActionVerify => 'Verify';

  @override
  String get adminActionReview => 'Review';

  @override
  String get adminActionOverride => 'Override';

  @override
  String get adminEmptyCandidatesTitle => 'No candidates';

  @override
  String get adminEmptyApplicationsTitle => 'No applications';

  @override
  String get adminEmptyVerificationsTitle => 'No pending verifications';

  @override
  String get adminEmptyIssuesTitle => 'No issues found';

  @override
  String get adminEmptyAuditTitle => 'No audit entries found';

  @override
  String get adminSearchCandidatesTitle => 'Search candidates';

  @override
  String get adminSearchCandidatesHint => 'Search by name, email or role…';

  @override
  String get adminSearchAuditHint => 'Search audit log…';

  @override
  String get adminMiscUnknown => 'Unknown';

  @override
  String adminCountTotal(int count) {
    return '$count total';
  }

  @override
  String adminBadgeNFlagged(int count) {
    return '$count flagged';
  }

  @override
  String adminBadgeNDaysWaiting(int count) {
    return '$count days waiting';
  }

  @override
  String get adminPeriodWeek => 'Week';

  @override
  String get adminPeriodMonth => 'Month';

  @override
  String get adminPeriodYear => 'Year';

  @override
  String get adminKpiNewCandidates => 'New Candidates';

  @override
  String get adminKpiNewBusinesses => 'New Businesses';

  @override
  String get adminKpiJobsPosted => 'Jobs Posted';

  @override
  String get adminSectionApplicationFunnel => 'Application Funnel';

  @override
  String get adminSectionPlatformGrowth => 'Platform Growth';

  @override
  String get adminSectionPremiumConversion => 'Premium Conversion';

  @override
  String get adminSectionTopLocations => 'Top Locations';

  @override
  String get adminStatusViewed => 'Viewed';

  @override
  String get adminWeekdayMon => 'Mon';

  @override
  String get adminWeekdayTue => 'Tue';

  @override
  String get adminWeekdayWed => 'Wed';

  @override
  String get adminWeekdayThu => 'Thu';

  @override
  String get adminWeekdayFri => 'Fri';

  @override
  String get adminWeekdaySat => 'Sat';

  @override
  String get adminWeekdaySun => 'Sun';

  @override
  String get adminFilterReported => 'Reported';

  @override
  String get adminFilterHidden => 'Hidden';

  @override
  String get adminEmptyPostsTitle => 'No posts';

  @override
  String get adminEmptyContentFilter => 'No content matches this filter.';

  @override
  String get adminBannerReportedReview => 'REPORTED — REVIEW REQUIRED';

  @override
  String get adminBannerHiddenFromFeed => 'HIDDEN FROM FEED';

  @override
  String get adminActionInsights => 'Insights';

  @override
  String get adminActionHide => 'Hide';

  @override
  String get adminActionRemove => 'Remove';

  @override
  String get adminActionCancel => 'Cancel';

  @override
  String get adminDialogRemovePostTitle => 'Remove Post?';

  @override
  String get adminDialogRemovePostBody =>
      'This permanently deletes the post and its comments. This action cannot be undone.';

  @override
  String get adminSnackbarReportCleared => 'Report cleared';

  @override
  String get adminSnackbarPostHidden => 'Post hidden from feed';

  @override
  String get adminSnackbarPostRemoved => 'Post removed';

  @override
  String adminCountReported(int count) {
    return '$count reported';
  }

  @override
  String adminCountHidden(int count) {
    return '$count hidden';
  }

  @override
  String adminMiscPremiumOutOfTotal(int premium, int total) {
    return '$premium premium out of $total total';
  }

  @override
  String get adminActionUnverify => 'Unverify';

  @override
  String get adminActionReactivate => 'Reactivate';

  @override
  String get adminActionFeature => 'Feature';

  @override
  String get adminActionUnfeature => 'Unfeature';

  @override
  String get adminActionFlagAccount => 'Flag Account';

  @override
  String get adminActionUnflagAccount => 'Unflag Account';

  @override
  String get adminActionConfirm => 'Confirm';

  @override
  String get adminDialogVerifyBusinessTitle => 'Verify Business';

  @override
  String get adminDialogUnverifyBusinessTitle => 'Unverify Business';

  @override
  String get adminDialogSuspendBusinessTitle => 'Suspend Business';

  @override
  String get adminDialogReactivateBusinessTitle => 'Reactivate Business';

  @override
  String get adminDialogVerifyCandidateTitle => 'Verify Candidate';

  @override
  String get adminDialogSuspendCandidateTitle => 'Suspend Candidate';

  @override
  String get adminDialogReactivateCandidateTitle => 'Reactivate Candidate';

  @override
  String get adminSnackbarBusinessVerified => 'Business verified';

  @override
  String get adminSnackbarVerificationRemoved => 'Verification removed';

  @override
  String get adminSnackbarBusinessSuspended => 'Business suspended';

  @override
  String get adminSnackbarBusinessReactivated => 'Business reactivated';

  @override
  String get adminSnackbarBusinessFeatured => 'Business featured';

  @override
  String get adminSnackbarBusinessUnfeatured => 'Business unfeatured';

  @override
  String get adminSnackbarUserVerified => 'User verified';

  @override
  String get adminSnackbarUserSuspended => 'User suspended';

  @override
  String get adminSnackbarUserReactivated => 'User reactivated';

  @override
  String get adminTabProfile => 'Profile';

  @override
  String get adminTabActivity => 'Activity';

  @override
  String get adminTabNotes => 'Notes';

  @override
  String adminDialogVerifyBody(String name) {
    return 'Mark $name as verified?';
  }

  @override
  String adminDialogUnverifyBody(String name) {
    return 'Remove verification from $name?';
  }

  @override
  String adminDialogReactivateBody(String name) {
    return 'Reactivate $name?';
  }

  @override
  String adminDialogSuspendBusinessBody(String name) {
    return 'Suspend $name? All jobs will be paused.';
  }

  @override
  String adminDialogSuspendCandidateBody(String name) {
    return 'Suspend $name? They will lose access.';
  }

  @override
  String get adminFieldName => 'Name';

  @override
  String get adminFieldEmail => 'Email';

  @override
  String get adminFieldPhone => 'Phone';

  @override
  String get adminFieldLocation => 'Location';

  @override
  String get adminFieldPlan => 'Plan';

  @override
  String get adminFieldVerified => 'Verified';

  @override
  String get adminFieldStatus => 'Status';

  @override
  String get adminFieldJoined => 'Joined';

  @override
  String get adminFieldCategory => 'Category';

  @override
  String get adminFieldSize => 'Size';

  @override
  String get adminFieldRole => 'Role';

  @override
  String get adminFieldProfileCompletion => 'Profile Completion';

  @override
  String get adminStatApplicants => 'Applicants';

  @override
  String get adminStatSaved => 'Saved';

  @override
  String get adminPlaceholderAddNote => 'Add a note...';

  @override
  String get adminEmptyNoJobsPosted => 'No jobs posted';
}
