import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('it'),
    Locale('pt'),
    Locale('ru'),
    Locale('tr'),
    Locale('zh'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Plagit'**
  String get appName;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @createBusinessAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Business Account'**
  String get createBusinessAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @jobs.
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get jobs;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @categoryAndRole.
  ///
  /// In en, this message translates to:
  /// **'Category & Role'**
  String get categoryAndRole;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// No description provided for @subcategory.
  ///
  /// In en, this message translates to:
  /// **'Subcategory'**
  String get subcategory;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get recentSearches;

  /// No description provided for @noResultsFor.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String noResultsFor(String query);

  /// No description provided for @mostPopular.
  ///
  /// In en, this message translates to:
  /// **'Most Popular'**
  String get mostPopular;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get allCategories;

  /// No description provided for @selectVenueTypeAndRole.
  ///
  /// In en, this message translates to:
  /// **'Select venue type and required role'**
  String get selectVenueTypeAndRole;

  /// No description provided for @selectCategoryAndRole.
  ///
  /// In en, this message translates to:
  /// **'Select category and role'**
  String get selectCategoryAndRole;

  /// No description provided for @businessDetails.
  ///
  /// In en, this message translates to:
  /// **'Business Details'**
  String get businessDetails;

  /// No description provided for @yourDetails.
  ///
  /// In en, this message translates to:
  /// **'Your Details'**
  String get yourDetails;

  /// No description provided for @companyName.
  ///
  /// In en, this message translates to:
  /// **'Company Name'**
  String get companyName;

  /// No description provided for @contactPerson.
  ///
  /// In en, this message translates to:
  /// **'Contact Person'**
  String get contactPerson;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @yearsExperience.
  ///
  /// In en, this message translates to:
  /// **'Years of experience'**
  String get yearsExperience;

  /// No description provided for @languagesSpoken.
  ///
  /// In en, this message translates to:
  /// **'Languages spoken'**
  String get languagesSpoken;

  /// No description provided for @jobType.
  ///
  /// In en, this message translates to:
  /// **'Job Type'**
  String get jobType;

  /// No description provided for @jobTypeFullTime.
  ///
  /// In en, this message translates to:
  /// **'Full-time'**
  String get jobTypeFullTime;

  /// No description provided for @jobTypePartTime.
  ///
  /// In en, this message translates to:
  /// **'Part-time'**
  String get jobTypePartTime;

  /// No description provided for @jobTypeTemporary.
  ///
  /// In en, this message translates to:
  /// **'Temporary'**
  String get jobTypeTemporary;

  /// No description provided for @jobTypeFreelance.
  ///
  /// In en, this message translates to:
  /// **'Freelance'**
  String get jobTypeFreelance;

  /// No description provided for @openToInternational.
  ///
  /// In en, this message translates to:
  /// **'Open to international candidates'**
  String get openToInternational;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Password (min 8 characters)'**
  String get passwordHint;

  /// No description provided for @termsOfServiceNote.
  ///
  /// In en, this message translates to:
  /// **'By creating an account you agree to our Terms of Service and Privacy Policy.'**
  String get termsOfServiceNote;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error'**
  String get networkError;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get errorGeneric;

  /// No description provided for @joinAsCandidate.
  ///
  /// In en, this message translates to:
  /// **'Join as Candidate'**
  String get joinAsCandidate;

  /// No description provided for @joinAsBusiness.
  ///
  /// In en, this message translates to:
  /// **'Join as Business'**
  String get joinAsBusiness;

  /// No description provided for @findYourNextRole.
  ///
  /// In en, this message translates to:
  /// **'Find your next role in hospitality'**
  String get findYourNextRole;

  /// No description provided for @candidateLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Connect with top employers in London, Dubai and beyond.'**
  String get candidateLoginSubtitle;

  /// No description provided for @businessLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reach top hospitality talent and grow your team.'**
  String get businessLoginSubtitle;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @lookingForStaff.
  ///
  /// In en, this message translates to:
  /// **'Looking for staff? '**
  String get lookingForStaff;

  /// No description provided for @lookingForJob.
  ///
  /// In en, this message translates to:
  /// **'Looking for a job? '**
  String get lookingForJob;

  /// No description provided for @switchToBusiness.
  ///
  /// In en, this message translates to:
  /// **'Switch to Business'**
  String get switchToBusiness;

  /// No description provided for @switchToCandidate.
  ///
  /// In en, this message translates to:
  /// **'Switch to Candidate'**
  String get switchToCandidate;

  /// No description provided for @createYourProfile.
  ///
  /// In en, this message translates to:
  /// **'Create your profile and start getting discovered by top employers.'**
  String get createYourProfile;

  /// No description provided for @createBusinessProfile.
  ///
  /// In en, this message translates to:
  /// **'Create your business profile and start hiring top hospitality talent.'**
  String get createBusinessProfile;

  /// No description provided for @locationCityCountry.
  ///
  /// In en, this message translates to:
  /// **'Location (city, country)'**
  String get locationCityCountry;

  /// No description provided for @termsAgreement.
  ///
  /// In en, this message translates to:
  /// **'By creating an account you agree to our Terms of Service and Privacy Policy.'**
  String get termsAgreement;

  /// No description provided for @searchHospitalityHint.
  ///
  /// In en, this message translates to:
  /// **'Search category, subcategory or role…'**
  String get searchHospitalityHint;

  /// No description provided for @mostCommonRoles.
  ///
  /// In en, this message translates to:
  /// **'Most Common Roles'**
  String get mostCommonRoles;

  /// No description provided for @allRoles.
  ///
  /// In en, this message translates to:
  /// **'All Roles'**
  String get allRoles;

  /// No description provided for @suggestionCount.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{1 suggestion}other{{count} suggestions}}'**
  String suggestionCount(int count);

  /// No description provided for @subcategoriesCount.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{1 subcategory}other{{count} subcategories}}'**
  String subcategoriesCount(int count);

  /// No description provided for @rolesCount.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{1 role}other{{count} roles}}'**
  String rolesCount(int count);

  /// No description provided for @kindCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get kindCategory;

  /// No description provided for @kindSubcategory.
  ///
  /// In en, this message translates to:
  /// **'Subcategory'**
  String get kindSubcategory;

  /// No description provided for @kindRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get kindRole;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPassword;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you a link to reset your password.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendResetLink;

  /// No description provided for @resetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'If an account exists for that email, a reset link has been sent.'**
  String get resetEmailSent;

  /// No description provided for @profileSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile'**
  String get profileSetupTitle;

  /// No description provided for @profileSetupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A complete profile gets discovered faster.'**
  String get profileSetupSubtitle;

  /// No description provided for @uploadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload photo'**
  String get uploadPhoto;

  /// No description provided for @uploadCV.
  ///
  /// In en, this message translates to:
  /// **'Upload CV'**
  String get uploadCV;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your network.'**
  String get noInternet;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @emptyJobs.
  ///
  /// In en, this message translates to:
  /// **'No jobs yet'**
  String get emptyJobs;

  /// No description provided for @emptyApplications.
  ///
  /// In en, this message translates to:
  /// **'No applications yet'**
  String get emptyApplications;

  /// No description provided for @emptyMessages.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get emptyMessages;

  /// No description provided for @emptyNotifications.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up'**
  String get emptyNotifications;

  /// No description provided for @onboardingRoleTitle.
  ///
  /// In en, this message translates to:
  /// **'What role are you looking for?'**
  String get onboardingRoleTitle;

  /// No description provided for @onboardingRoleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select all that apply'**
  String get onboardingRoleSubtitle;

  /// No description provided for @onboardingExperienceTitle.
  ///
  /// In en, this message translates to:
  /// **'How much experience do you have?'**
  String get onboardingExperienceTitle;

  /// No description provided for @onboardingLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Where are you based?'**
  String get onboardingLocationTitle;

  /// No description provided for @onboardingLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your city or postcode'**
  String get onboardingLocationHint;

  /// No description provided for @useMyCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my current location'**
  String get useMyCurrentLocation;

  /// No description provided for @onboardingAvailabilityTitle.
  ///
  /// In en, this message translates to:
  /// **'What are you looking for?'**
  String get onboardingAvailabilityTitle;

  /// No description provided for @finishSetup.
  ///
  /// In en, this message translates to:
  /// **'Finish Setup'**
  String get finishSetup;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @findJobs.
  ///
  /// In en, this message translates to:
  /// **'Find Jobs'**
  String get findJobs;

  /// No description provided for @applications.
  ///
  /// In en, this message translates to:
  /// **'Applications'**
  String get applications;

  /// No description provided for @community.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get community;

  /// No description provided for @recommendedForYou.
  ///
  /// In en, this message translates to:
  /// **'Recommended For You'**
  String get recommendedForYou;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @searchJobsHint.
  ///
  /// In en, this message translates to:
  /// **'Search jobs, roles, locations…'**
  String get searchJobsHint;

  /// No description provided for @searchJobs.
  ///
  /// In en, this message translates to:
  /// **'Search Jobs'**
  String get searchJobs;

  /// No description provided for @postedJob.
  ///
  /// In en, this message translates to:
  /// **'Posted'**
  String get postedJob;

  /// No description provided for @applyNow.
  ///
  /// In en, this message translates to:
  /// **'Apply Now'**
  String get applyNow;

  /// No description provided for @applied.
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get applied;

  /// No description provided for @saveJob.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveJob;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @jobDescription.
  ///
  /// In en, this message translates to:
  /// **'Job description'**
  String get jobDescription;

  /// No description provided for @requirements.
  ///
  /// In en, this message translates to:
  /// **'Requirements'**
  String get requirements;

  /// No description provided for @benefits.
  ///
  /// In en, this message translates to:
  /// **'Benefits'**
  String get benefits;

  /// No description provided for @salary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get salary;

  /// No description provided for @contract.
  ///
  /// In en, this message translates to:
  /// **'Contract'**
  String get contract;

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// No description provided for @viewCompany.
  ///
  /// In en, this message translates to:
  /// **'View company'**
  String get viewCompany;

  /// No description provided for @interview.
  ///
  /// In en, this message translates to:
  /// **'Interview'**
  String get interview;

  /// No description provided for @interviews.
  ///
  /// In en, this message translates to:
  /// **'Interviews'**
  String get interviews;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @matches.
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get matches;

  /// No description provided for @quickPlug.
  ///
  /// In en, this message translates to:
  /// **'Quick Plug'**
  String get quickPlug;

  /// No description provided for @discover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discover;

  /// No description provided for @shortlist.
  ///
  /// In en, this message translates to:
  /// **'Shortlist'**
  String get shortlist;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @messageCandidate.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get messageCandidate;

  /// No description provided for @nextInterview.
  ///
  /// In en, this message translates to:
  /// **'Next Interview'**
  String get nextInterview;

  /// No description provided for @loadingDashboard.
  ///
  /// In en, this message translates to:
  /// **'Loading dashboard…'**
  String get loadingDashboard;

  /// No description provided for @tryAgainCta.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgainCta;

  /// No description provided for @careerDashboard.
  ///
  /// In en, this message translates to:
  /// **'CAREER DASHBOARD'**
  String get careerDashboard;

  /// No description provided for @yourNextInterview.
  ///
  /// In en, this message translates to:
  /// **'Your next interview\nis lined up'**
  String get yourNextInterview;

  /// No description provided for @yourCareerTakingOff.
  ///
  /// In en, this message translates to:
  /// **'Your career\nis taking off'**
  String get yourCareerTakingOff;

  /// No description provided for @yourCareerOnTheMove.
  ///
  /// In en, this message translates to:
  /// **'Your career\nis on the move'**
  String get yourCareerOnTheMove;

  /// No description provided for @yourJourneyStartsHere.
  ///
  /// In en, this message translates to:
  /// **'Your journey\nstarts here'**
  String get yourJourneyStartsHere;

  /// No description provided for @applyFirstJob.
  ///
  /// In en, this message translates to:
  /// **'Apply to your first job to get started'**
  String get applyFirstJob;

  /// No description provided for @interviewComingUp.
  ///
  /// In en, this message translates to:
  /// **'Interview coming up'**
  String get interviewComingUp;

  /// No description provided for @unlockPlagitPremium.
  ///
  /// In en, this message translates to:
  /// **'Unlock Plagit Premium'**
  String get unlockPlagitPremium;

  /// No description provided for @premiumSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stand out to top venues — get matched faster'**
  String get premiumSubtitle;

  /// No description provided for @premiumActive.
  ///
  /// In en, this message translates to:
  /// **'Premium Active'**
  String get premiumActive;

  /// No description provided for @premiumActiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Priority visibility enabled · Manage plan'**
  String get premiumActiveSubtitle;

  /// No description provided for @noJobsFound.
  ///
  /// In en, this message translates to:
  /// **'No jobs match your search'**
  String get noJobsFound;

  /// No description provided for @noApplicationsYet.
  ///
  /// In en, this message translates to:
  /// **'No applications yet'**
  String get noApplicationsYet;

  /// No description provided for @startApplying.
  ///
  /// In en, this message translates to:
  /// **'Start exploring jobs to apply'**
  String get startApplying;

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessagesYet;

  /// No description provided for @allCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up'**
  String get allCaughtUp;

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsYet;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @experience.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get experience;

  /// No description provided for @skills.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get skills;

  /// No description provided for @languages.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get languages;

  /// No description provided for @availability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get availability;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @totalViews.
  ///
  /// In en, this message translates to:
  /// **'Total Views'**
  String get totalViews;

  /// No description provided for @verifiedVenuePrefix.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verifiedVenuePrefix;

  /// No description provided for @notVerified.
  ///
  /// In en, this message translates to:
  /// **'Not verified'**
  String get notVerified;

  /// No description provided for @pendingReview.
  ///
  /// In en, this message translates to:
  /// **'Pending review'**
  String get pendingReview;

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'View profile'**
  String get viewProfile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @block.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get block;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message…'**
  String get typeMessage;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get now;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{1m ago}other{{count}m ago}}'**
  String minutesAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{1h ago}other{{count}h ago}}'**
  String hoursAgo(int count);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{1d ago}other{{count}d ago}}'**
  String daysAgo(int count);

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @refineSearch.
  ///
  /// In en, this message translates to:
  /// **'Refine Search'**
  String get refineSearch;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @noResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String noResultsTitle(String query);

  /// No description provided for @noResultsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try a different keyword or clear the search.'**
  String get noResultsSubtitle;

  /// No description provided for @recentSearchesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No recent searches'**
  String get recentSearchesEmptyTitle;

  /// No description provided for @recentSearchesEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Your recent searches will appear here'**
  String get recentSearchesEmptyHint;

  /// No description provided for @allJobs.
  ///
  /// In en, this message translates to:
  /// **'All jobs'**
  String get allJobs;

  /// No description provided for @nearby.
  ///
  /// In en, this message translates to:
  /// **'Nearby'**
  String get nearby;

  /// No description provided for @saved2.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved2;

  /// No description provided for @remote.
  ///
  /// In en, this message translates to:
  /// **'Remote'**
  String get remote;

  /// No description provided for @inPerson.
  ///
  /// In en, this message translates to:
  /// **'In person'**
  String get inPerson;

  /// No description provided for @aboutTheJob.
  ///
  /// In en, this message translates to:
  /// **'About the job'**
  String get aboutTheJob;

  /// No description provided for @aboutCompany.
  ///
  /// In en, this message translates to:
  /// **'About the company'**
  String get aboutCompany;

  /// No description provided for @applyForJob.
  ///
  /// In en, this message translates to:
  /// **'Apply for this job'**
  String get applyForJob;

  /// No description provided for @unsaveJob.
  ///
  /// In en, this message translates to:
  /// **'Unsave'**
  String get unsaveJob;

  /// No description provided for @noJobsNearby.
  ///
  /// In en, this message translates to:
  /// **'No jobs nearby'**
  String get noJobsNearby;

  /// No description provided for @noSavedJobs.
  ///
  /// In en, this message translates to:
  /// **'No saved jobs'**
  String get noSavedJobs;

  /// No description provided for @adjustFilters.
  ///
  /// In en, this message translates to:
  /// **'Adjust your filters to see more jobs'**
  String get adjustFilters;

  /// No description provided for @fullTime.
  ///
  /// In en, this message translates to:
  /// **'Full-time'**
  String get fullTime;

  /// No description provided for @partTime.
  ///
  /// In en, this message translates to:
  /// **'Part-time'**
  String get partTime;

  /// No description provided for @temporary.
  ///
  /// In en, this message translates to:
  /// **'Temporary'**
  String get temporary;

  /// No description provided for @freelance.
  ///
  /// In en, this message translates to:
  /// **'Freelance'**
  String get freelance;

  /// No description provided for @postedAgo.
  ///
  /// In en, this message translates to:
  /// **'Posted {time}'**
  String postedAgo(String time);

  /// No description provided for @kmAway.
  ///
  /// In en, this message translates to:
  /// **'{km} km away'**
  String kmAway(String km);

  /// No description provided for @jobDetails.
  ///
  /// In en, this message translates to:
  /// **'Job Details'**
  String get jobDetails;

  /// No description provided for @aboutThisRole.
  ///
  /// In en, this message translates to:
  /// **'About this role'**
  String get aboutThisRole;

  /// No description provided for @aboutTheBusiness.
  ///
  /// In en, this message translates to:
  /// **'About the business'**
  String get aboutTheBusiness;

  /// No description provided for @urgentHiring.
  ///
  /// In en, this message translates to:
  /// **'Urgent Hiring'**
  String get urgentHiring;

  /// No description provided for @distanceRadius.
  ///
  /// In en, this message translates to:
  /// **'Distance Radius'**
  String get distanceRadius;

  /// No description provided for @contractType.
  ///
  /// In en, this message translates to:
  /// **'Contract Type'**
  String get contractType;

  /// No description provided for @shiftType.
  ///
  /// In en, this message translates to:
  /// **'Shift Type'**
  String get shiftType;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @casual.
  ///
  /// In en, this message translates to:
  /// **'Casual'**
  String get casual;

  /// No description provided for @seasonal.
  ///
  /// In en, this message translates to:
  /// **'Seasonal'**
  String get seasonal;

  /// No description provided for @morning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get morning;

  /// No description provided for @afternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get afternoon;

  /// No description provided for @evening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get evening;

  /// No description provided for @night.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get night;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @shiftHours.
  ///
  /// In en, this message translates to:
  /// **'Shift Hours'**
  String get shiftHours;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @venueType.
  ///
  /// In en, this message translates to:
  /// **'Venue Type'**
  String get venueType;

  /// No description provided for @employment.
  ///
  /// In en, this message translates to:
  /// **'Employment'**
  String get employment;

  /// No description provided for @pay.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get pay;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @weeklyHours.
  ///
  /// In en, this message translates to:
  /// **'Weekly hours'**
  String get weeklyHours;

  /// No description provided for @businessLocation.
  ///
  /// In en, this message translates to:
  /// **'Business Location'**
  String get businessLocation;

  /// No description provided for @jobViews.
  ///
  /// In en, this message translates to:
  /// **'Job Views'**
  String get jobViews;

  /// No description provided for @positions.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{1 Position}other{{count} Positions}}'**
  String positions(int count);

  /// No description provided for @monthsCount.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{1 month}other{{count} months}}'**
  String monthsCount(int count);

  /// No description provided for @myApplications.
  ///
  /// In en, this message translates to:
  /// **'My Applications'**
  String get myApplications;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @interviewStatus.
  ///
  /// In en, this message translates to:
  /// **'Interview'**
  String get interviewStatus;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @offer.
  ///
  /// In en, this message translates to:
  /// **'Offer'**
  String get offer;

  /// No description provided for @appliedOn.
  ///
  /// In en, this message translates to:
  /// **'Applied {date}'**
  String appliedOn(String date);

  /// No description provided for @viewJob.
  ///
  /// In en, this message translates to:
  /// **'View job'**
  String get viewJob;

  /// No description provided for @withdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw application'**
  String get withdraw;

  /// No description provided for @applicationStatus.
  ///
  /// In en, this message translates to:
  /// **'Application status'**
  String get applicationStatus;

  /// No description provided for @noConversations.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get noConversations;

  /// No description provided for @startConversation.
  ///
  /// In en, this message translates to:
  /// **'Reply to a job to start chatting'**
  String get startConversation;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @lastSeen.
  ///
  /// In en, this message translates to:
  /// **'Last seen {time}'**
  String lastSeen(String time);

  /// No description provided for @newNotification.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newNotification;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllRead;

  /// No description provided for @yourProfile.
  ///
  /// In en, this message translates to:
  /// **'Your Profile'**
  String get yourProfile;

  /// No description provided for @completionPercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}% complete'**
  String completionPercent(int percent);

  /// No description provided for @personalDetails.
  ///
  /// In en, this message translates to:
  /// **'Personal Details'**
  String get personalDetails;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get addPhoto;

  /// No description provided for @addCV.
  ///
  /// In en, this message translates to:
  /// **'Add CV'**
  String get addCV;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirm;

  /// No description provided for @subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscription;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get terms;

  /// No description provided for @applicationDetails.
  ///
  /// In en, this message translates to:
  /// **'Application Details'**
  String get applicationDetails;

  /// No description provided for @timeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get timeline;

  /// No description provided for @submitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get submitted;

  /// No description provided for @underReview.
  ///
  /// In en, this message translates to:
  /// **'Under review'**
  String get underReview;

  /// No description provided for @interviewScheduled.
  ///
  /// In en, this message translates to:
  /// **'Interview scheduled'**
  String get interviewScheduled;

  /// No description provided for @offerExtended.
  ///
  /// In en, this message translates to:
  /// **'Offer extended'**
  String get offerExtended;

  /// No description provided for @withdrawApp.
  ///
  /// In en, this message translates to:
  /// **'Withdraw application'**
  String get withdrawApp;

  /// No description provided for @withdrawConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to withdraw this application?'**
  String get withdrawConfirm;

  /// No description provided for @applicationWithdrawn.
  ///
  /// In en, this message translates to:
  /// **'Application withdrawn'**
  String get applicationWithdrawn;

  /// No description provided for @statusApplied.
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get statusApplied;

  /// No description provided for @statusInReview.
  ///
  /// In en, this message translates to:
  /// **'In Review'**
  String get statusInReview;

  /// No description provided for @statusInterview.
  ///
  /// In en, this message translates to:
  /// **'Interview'**
  String get statusInterview;

  /// No description provided for @statusHired.
  ///
  /// In en, this message translates to:
  /// **'Hired'**
  String get statusHired;

  /// No description provided for @statusClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get statusClosed;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @statusOffer.
  ///
  /// In en, this message translates to:
  /// **'Offer'**
  String get statusOffer;

  /// No description provided for @messagesSearch.
  ///
  /// In en, this message translates to:
  /// **'Search messages…'**
  String get messagesSearch;

  /// No description provided for @noMessagesTitle.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessagesTitle;

  /// No description provided for @noMessagesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reply to a job to start chatting'**
  String get noMessagesSubtitle;

  /// No description provided for @youOnline.
  ///
  /// In en, this message translates to:
  /// **'You\'re online'**
  String get youOnline;

  /// No description provided for @noNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsTitle;

  /// No description provided for @noNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll let you know when something happens'**
  String get noNotificationsSubtitle;

  /// No description provided for @today2.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today2;

  /// No description provided for @earlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get earlier;

  /// No description provided for @completeYourProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile'**
  String get completeYourProfile;

  /// No description provided for @profileCompletion.
  ///
  /// In en, this message translates to:
  /// **'Profile completion'**
  String get profileCompletion;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal info'**
  String get personalInfo;

  /// No description provided for @professional.
  ///
  /// In en, this message translates to:
  /// **'Professional'**
  String get professional;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documents;

  /// No description provided for @myCV.
  ///
  /// In en, this message translates to:
  /// **'My CV'**
  String get myCV;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @addLanguages.
  ///
  /// In en, this message translates to:
  /// **'Add languages'**
  String get addLanguages;

  /// No description provided for @addExperience.
  ///
  /// In en, this message translates to:
  /// **'Add experience'**
  String get addExperience;

  /// No description provided for @addAvailability.
  ///
  /// In en, this message translates to:
  /// **'Add availability'**
  String get addAvailability;

  /// No description provided for @matchesTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Matches'**
  String get matchesTitle;

  /// No description provided for @noMatchesTitle.
  ///
  /// In en, this message translates to:
  /// **'No matches yet'**
  String get noMatchesTitle;

  /// No description provided for @noMatchesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep applying — your matches will appear here'**
  String get noMatchesSubtitle;

  /// No description provided for @interestedBusinesses.
  ///
  /// In en, this message translates to:
  /// **'Interested Businesses'**
  String get interestedBusinesses;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @newMatch.
  ///
  /// In en, this message translates to:
  /// **'New match'**
  String get newMatch;

  /// No description provided for @quickPlugTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Plug'**
  String get quickPlugTitle;

  /// No description provided for @quickPlugEmpty.
  ///
  /// In en, this message translates to:
  /// **'No new businesses right now'**
  String get quickPlugEmpty;

  /// No description provided for @quickPlugSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check back later for fresh opportunities'**
  String get quickPlugSubtitle;

  /// No description provided for @uploadYourCV.
  ///
  /// In en, this message translates to:
  /// **'Upload your CV'**
  String get uploadYourCV;

  /// No description provided for @cvSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add a CV to apply faster and stand out'**
  String get cvSubtitle;

  /// No description provided for @chooseFile.
  ///
  /// In en, this message translates to:
  /// **'Choose file'**
  String get chooseFile;

  /// No description provided for @removeCV.
  ///
  /// In en, this message translates to:
  /// **'Remove CV'**
  String get removeCV;

  /// No description provided for @noCVUploaded.
  ///
  /// In en, this message translates to:
  /// **'No CV uploaded yet'**
  String get noCVUploaded;

  /// No description provided for @discoverCompanies.
  ///
  /// In en, this message translates to:
  /// **'Discover Companies'**
  String get discoverCompanies;

  /// No description provided for @exploreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Explore top hospitality businesses'**
  String get exploreSubtitle;

  /// No description provided for @follow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get follow;

  /// No description provided for @following.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get following;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @selectLanguages.
  ///
  /// In en, this message translates to:
  /// **'Select languages'**
  String get selectLanguages;

  /// No description provided for @selectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selectedCount(int count);

  /// No description provided for @allLanguages.
  ///
  /// In en, this message translates to:
  /// **'All Languages'**
  String get allLanguages;

  /// No description provided for @uploadCVBig.
  ///
  /// In en, this message translates to:
  /// **'Upload your CV to pre-fill your profile automatically and save time.'**
  String get uploadCVBig;

  /// No description provided for @supportedFormats.
  ///
  /// In en, this message translates to:
  /// **'Supported formats: PDF, DOC, DOCX'**
  String get supportedFormats;

  /// No description provided for @fillManually.
  ///
  /// In en, this message translates to:
  /// **'Fill Manually'**
  String get fillManually;

  /// No description provided for @fillManuallySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your details yourself and complete your profile step by step.'**
  String get fillManuallySubtitle;

  /// No description provided for @photoUploadSoon.
  ///
  /// In en, this message translates to:
  /// **'Photo upload coming soon — use a professional avatar in the meantime.'**
  String get photoUploadSoon;

  /// No description provided for @yourCV.
  ///
  /// In en, this message translates to:
  /// **'Your CV'**
  String get yourCV;

  /// No description provided for @aboutYou.
  ///
  /// In en, this message translates to:
  /// **'About You'**
  String get aboutYou;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @completeProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete Profile'**
  String get completeProfile;

  /// No description provided for @openToRelocation.
  ///
  /// In en, this message translates to:
  /// **'Open to relocation'**
  String get openToRelocation;

  /// No description provided for @matchLabel.
  ///
  /// In en, this message translates to:
  /// **'Match'**
  String get matchLabel;

  /// No description provided for @accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get accepted;

  /// No description provided for @deny.
  ///
  /// In en, this message translates to:
  /// **'Deny'**
  String get deny;

  /// No description provided for @featured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get featured;

  /// No description provided for @reviewYourProfile.
  ///
  /// In en, this message translates to:
  /// **'Review Your Profile'**
  String get reviewYourProfile;

  /// No description provided for @nothingSavedYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing will be saved until you confirm.'**
  String get nothingSavedYet;

  /// No description provided for @editAnyField.
  ///
  /// In en, this message translates to:
  /// **'You can edit any extracted field before saving.'**
  String get editAnyField;

  /// No description provided for @saveToProfile.
  ///
  /// In en, this message translates to:
  /// **'Save to Profile'**
  String get saveToProfile;

  /// No description provided for @findCompanies.
  ///
  /// In en, this message translates to:
  /// **'Find Companies'**
  String get findCompanies;

  /// No description provided for @mapView.
  ///
  /// In en, this message translates to:
  /// **'Map View'**
  String get mapView;

  /// No description provided for @mapComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Map view coming soon.'**
  String get mapComingSoon;

  /// No description provided for @noCompaniesFound.
  ///
  /// In en, this message translates to:
  /// **'No companies found'**
  String get noCompaniesFound;

  /// No description provided for @tryWiderRadius.
  ///
  /// In en, this message translates to:
  /// **'Try a wider radius or different category.'**
  String get tryWiderRadius;

  /// No description provided for @verifiedOnly.
  ///
  /// In en, this message translates to:
  /// **'Verified Only'**
  String get verifiedOnly;

  /// No description provided for @resetFilters.
  ///
  /// In en, this message translates to:
  /// **'Reset Filters'**
  String get resetFilters;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @lookingFor.
  ///
  /// In en, this message translates to:
  /// **'Looking for: {role}'**
  String lookingFor(String role);

  /// No description provided for @boostMyProfile.
  ///
  /// In en, this message translates to:
  /// **'Boost My Profile'**
  String get boostMyProfile;

  /// No description provided for @openToRelocationTravel.
  ///
  /// In en, this message translates to:
  /// **'Open to Relocation / Travel'**
  String get openToRelocationTravel;

  /// No description provided for @tellEmployersAboutYourself.
  ///
  /// In en, this message translates to:
  /// **'Tell employers about yourself…'**
  String get tellEmployersAboutYourself;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdated;

  /// No description provided for @contractPreference.
  ///
  /// In en, this message translates to:
  /// **'Contract Preference'**
  String get contractPreference;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restorePurchases;

  /// No description provided for @languagePickerSoon.
  ///
  /// In en, this message translates to:
  /// **'Language picker coming soon'**
  String get languagePickerSoon;

  /// No description provided for @selectCategoryRoleShort.
  ///
  /// In en, this message translates to:
  /// **'Select category & role'**
  String get selectCategoryRoleShort;

  /// No description provided for @cvUploadSoon.
  ///
  /// In en, this message translates to:
  /// **'CV upload coming soon'**
  String get cvUploadSoon;

  /// No description provided for @restorePurchasesSoon.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases coming soon'**
  String get restorePurchasesSoon;

  /// No description provided for @photoUploadShort.
  ///
  /// In en, this message translates to:
  /// **'Photo upload coming soon'**
  String get photoUploadShort;

  /// No description provided for @hireBestTalent.
  ///
  /// In en, this message translates to:
  /// **'Hire the best hospitality talent'**
  String get hireBestTalent;

  /// No description provided for @businessLoginSub.
  ///
  /// In en, this message translates to:
  /// **'Post jobs and connect with verified candidates.'**
  String get businessLoginSub;

  /// No description provided for @lookingForWork.
  ///
  /// In en, this message translates to:
  /// **'Looking for work? '**
  String get lookingForWork;

  /// No description provided for @postJob.
  ///
  /// In en, this message translates to:
  /// **'Post a Job'**
  String get postJob;

  /// No description provided for @editJob.
  ///
  /// In en, this message translates to:
  /// **'Edit Job'**
  String get editJob;

  /// No description provided for @jobTitle.
  ///
  /// In en, this message translates to:
  /// **'Job Title'**
  String get jobTitle;

  /// No description provided for @jobDescription2.
  ///
  /// In en, this message translates to:
  /// **'Job Description'**
  String get jobDescription2;

  /// No description provided for @publish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publish;

  /// No description provided for @saveDraft.
  ///
  /// In en, this message translates to:
  /// **'Save Draft'**
  String get saveDraft;

  /// No description provided for @applicantsTitle.
  ///
  /// In en, this message translates to:
  /// **'Applicants'**
  String get applicantsTitle;

  /// No description provided for @newApplicants.
  ///
  /// In en, this message translates to:
  /// **'New applicants'**
  String get newApplicants;

  /// No description provided for @noApplicantsYet.
  ///
  /// In en, this message translates to:
  /// **'No applicants yet'**
  String get noApplicantsYet;

  /// No description provided for @noApplicantsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Applicants will appear here once they apply.'**
  String get noApplicantsSubtitle;

  /// No description provided for @scheduleInterview.
  ///
  /// In en, this message translates to:
  /// **'Schedule Interview'**
  String get scheduleInterview;

  /// No description provided for @sendInvite.
  ///
  /// In en, this message translates to:
  /// **'Send Invite'**
  String get sendInvite;

  /// No description provided for @interviewSent.
  ///
  /// In en, this message translates to:
  /// **'Interview invite sent'**
  String get interviewSent;

  /// No description provided for @rejectCandidate.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get rejectCandidate;

  /// No description provided for @shortlistCandidate.
  ///
  /// In en, this message translates to:
  /// **'Shortlist'**
  String get shortlistCandidate;

  /// No description provided for @hiringDashboard.
  ///
  /// In en, this message translates to:
  /// **'HIRING DASHBOARD'**
  String get hiringDashboard;

  /// No description provided for @yourPipelineActive.
  ///
  /// In en, this message translates to:
  /// **'Your pipeline\nis active'**
  String get yourPipelineActive;

  /// No description provided for @postJobToStart.
  ///
  /// In en, this message translates to:
  /// **'Post a job to start hiring'**
  String get postJobToStart;

  /// No description provided for @reviewApplicants.
  ///
  /// In en, this message translates to:
  /// **'Review {count} new applicants'**
  String reviewApplicants(int count);

  /// No description provided for @replyMessages.
  ///
  /// In en, this message translates to:
  /// **'Reply to {count} unread messages'**
  String replyMessages(int count);

  /// No description provided for @interviews2.
  ///
  /// In en, this message translates to:
  /// **'Interviews'**
  String get interviews2;

  /// No description provided for @businessProfile.
  ///
  /// In en, this message translates to:
  /// **'Company Profile'**
  String get businessProfile;

  /// No description provided for @venueGallery.
  ///
  /// In en, this message translates to:
  /// **'Venue Gallery'**
  String get venueGallery;

  /// No description provided for @addPhotos.
  ///
  /// In en, this message translates to:
  /// **'Add photos'**
  String get addPhotos;

  /// No description provided for @businessName.
  ///
  /// In en, this message translates to:
  /// **'Business name'**
  String get businessName;

  /// No description provided for @venueTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Venue type'**
  String get venueTypeLabel;

  /// No description provided for @selectedItems.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selectedItems(int count);

  /// No description provided for @hiringProgress.
  ///
  /// In en, this message translates to:
  /// **'Hiring Progress'**
  String get hiringProgress;

  /// No description provided for @unlockBusinessPremium.
  ///
  /// In en, this message translates to:
  /// **'Unlock Business Premium'**
  String get unlockBusinessPremium;

  /// No description provided for @businessPremiumSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get priority access to top candidates'**
  String get businessPremiumSubtitle;

  /// No description provided for @scheduleFromApplicants.
  ///
  /// In en, this message translates to:
  /// **'Schedule from applicants'**
  String get scheduleFromApplicants;

  /// No description provided for @recentApplicants.
  ///
  /// In en, this message translates to:
  /// **'Recent Applicants'**
  String get recentApplicants;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All ›'**
  String get viewAll;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @candidatePipeline.
  ///
  /// In en, this message translates to:
  /// **'Candidate Pipeline'**
  String get candidatePipeline;

  /// No description provided for @allApplicants.
  ///
  /// In en, this message translates to:
  /// **'All Applicants'**
  String get allApplicants;

  /// No description provided for @searchCandidates.
  ///
  /// In en, this message translates to:
  /// **'Search candidates, jobs, interviews...'**
  String get searchCandidates;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

  /// No description provided for @post.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get post;

  /// No description provided for @candidates.
  ///
  /// In en, this message translates to:
  /// **'Candidates'**
  String get candidates;

  /// No description provided for @applicantDetail.
  ///
  /// In en, this message translates to:
  /// **'Applicant Details'**
  String get applicantDetail;

  /// No description provided for @candidateProfile.
  ///
  /// In en, this message translates to:
  /// **'Candidate Profile'**
  String get candidateProfile;

  /// No description provided for @shortlistTitle.
  ///
  /// In en, this message translates to:
  /// **'Shortlist'**
  String get shortlistTitle;

  /// No description provided for @noShortlistedCandidates.
  ///
  /// In en, this message translates to:
  /// **'No shortlisted candidates yet'**
  String get noShortlistedCandidates;

  /// No description provided for @shortlistEmpty.
  ///
  /// In en, this message translates to:
  /// **'Candidates you shortlist will appear here'**
  String get shortlistEmpty;

  /// No description provided for @removeFromShortlist.
  ///
  /// In en, this message translates to:
  /// **'Remove from shortlist'**
  String get removeFromShortlist;

  /// No description provided for @viewMessages.
  ///
  /// In en, this message translates to:
  /// **'View Messages'**
  String get viewMessages;

  /// No description provided for @manageJobs.
  ///
  /// In en, this message translates to:
  /// **'Manage Jobs'**
  String get manageJobs;

  /// No description provided for @yourJobs.
  ///
  /// In en, this message translates to:
  /// **'Your Jobs'**
  String get yourJobs;

  /// No description provided for @noJobsPosted.
  ///
  /// In en, this message translates to:
  /// **'No jobs posted yet'**
  String get noJobsPosted;

  /// No description provided for @noJobsPostedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Post your first job to start hiring'**
  String get noJobsPostedSubtitle;

  /// No description provided for @draftJobs.
  ///
  /// In en, this message translates to:
  /// **'Drafts'**
  String get draftJobs;

  /// No description provided for @activeJobs.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeJobs;

  /// No description provided for @expiredJobs.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expiredJobs;

  /// No description provided for @closedJobs.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closedJobs;

  /// No description provided for @createJob.
  ///
  /// In en, this message translates to:
  /// **'Create Job'**
  String get createJob;

  /// No description provided for @jobDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Job Details'**
  String get jobDetailsTitle;

  /// No description provided for @salaryRange.
  ///
  /// In en, this message translates to:
  /// **'Salary range'**
  String get salaryRange;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @annual.
  ///
  /// In en, this message translates to:
  /// **'Annual'**
  String get annual;

  /// No description provided for @hourly.
  ///
  /// In en, this message translates to:
  /// **'Hourly'**
  String get hourly;

  /// No description provided for @minSalary.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get minSalary;

  /// No description provided for @maxSalary.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get maxSalary;

  /// No description provided for @perks.
  ///
  /// In en, this message translates to:
  /// **'Perks'**
  String get perks;

  /// No description provided for @addPerk.
  ///
  /// In en, this message translates to:
  /// **'Add perk'**
  String get addPerk;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @publishJob.
  ///
  /// In en, this message translates to:
  /// **'Publish Job'**
  String get publishJob;

  /// No description provided for @jobPublished.
  ///
  /// In en, this message translates to:
  /// **'Job published'**
  String get jobPublished;

  /// No description provided for @jobUpdated.
  ///
  /// In en, this message translates to:
  /// **'Job updated'**
  String get jobUpdated;

  /// No description provided for @jobSavedDraft.
  ///
  /// In en, this message translates to:
  /// **'Saved as draft'**
  String get jobSavedDraft;

  /// No description provided for @fillRequired.
  ///
  /// In en, this message translates to:
  /// **'Please fill in the required fields'**
  String get fillRequired;

  /// No description provided for @jobUrgent.
  ///
  /// In en, this message translates to:
  /// **'Mark as urgent'**
  String get jobUrgent;

  /// No description provided for @addAtLeastOne.
  ///
  /// In en, this message translates to:
  /// **'Add at least one requirement'**
  String get addAtLeastOne;

  /// No description provided for @createUpdate.
  ///
  /// In en, this message translates to:
  /// **'Create Update'**
  String get createUpdate;

  /// No description provided for @shareCompanyNews.
  ///
  /// In en, this message translates to:
  /// **'Share company news'**
  String get shareCompanyNews;

  /// No description provided for @addStory.
  ///
  /// In en, this message translates to:
  /// **'Add Story'**
  String get addStory;

  /// No description provided for @showWorkplace.
  ///
  /// In en, this message translates to:
  /// **'Show your workplace'**
  String get showWorkplace;

  /// No description provided for @viewShortlist.
  ///
  /// In en, this message translates to:
  /// **'View Shortlist'**
  String get viewShortlist;

  /// No description provided for @yourSavedCandidates.
  ///
  /// In en, this message translates to:
  /// **'Your saved candidates'**
  String get yourSavedCandidates;

  /// No description provided for @inviteCandidate.
  ///
  /// In en, this message translates to:
  /// **'Invite Candidate'**
  String get inviteCandidate;

  /// No description provided for @reachOutDirectly.
  ///
  /// In en, this message translates to:
  /// **'Reach out directly'**
  String get reachOutDirectly;

  /// No description provided for @activeJobsCount.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{1 active job}other{{count} active jobs}}'**
  String activeJobsCount(int count);

  /// No description provided for @employmentType.
  ///
  /// In en, this message translates to:
  /// **'Employment Type'**
  String get employmentType;

  /// No description provided for @requiredRole.
  ///
  /// In en, this message translates to:
  /// **'Required Role'**
  String get requiredRole;

  /// No description provided for @selectCategoryRole2.
  ///
  /// In en, this message translates to:
  /// **'Select category & role'**
  String get selectCategoryRole2;

  /// No description provided for @hiresNeeded.
  ///
  /// In en, this message translates to:
  /// **'Hires needed'**
  String get hiresNeeded;

  /// No description provided for @compensation.
  ///
  /// In en, this message translates to:
  /// **'Compensation'**
  String get compensation;

  /// No description provided for @useSalaryRange.
  ///
  /// In en, this message translates to:
  /// **'Use salary range'**
  String get useSalaryRange;

  /// No description provided for @contractDuration.
  ///
  /// In en, this message translates to:
  /// **'Contract duration'**
  String get contractDuration;

  /// No description provided for @limitReached.
  ///
  /// In en, this message translates to:
  /// **'Limit Reached'**
  String get limitReached;

  /// No description provided for @upgradePlan.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Plan'**
  String get upgradePlan;

  /// No description provided for @usingXofY.
  ///
  /// In en, this message translates to:
  /// **'You\'re using {used} of {total} job posts.'**
  String usingXofY(int used, int total);

  /// No description provided for @businessInterviewsTitle.
  ///
  /// In en, this message translates to:
  /// **'Interviews'**
  String get businessInterviewsTitle;

  /// No description provided for @noInterviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No interviews scheduled'**
  String get noInterviewsYet;

  /// No description provided for @scheduleFirstInterview.
  ///
  /// In en, this message translates to:
  /// **'Schedule your first interview with a candidate'**
  String get scheduleFirstInterview;

  /// No description provided for @sendInterviewInvite.
  ///
  /// In en, this message translates to:
  /// **'Send interview invite'**
  String get sendInterviewInvite;

  /// No description provided for @interviewSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite sent!'**
  String get interviewSentTitle;

  /// No description provided for @interviewSentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The candidate has been notified.'**
  String get interviewSentSubtitle;

  /// No description provided for @scheduleInterviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule Interview'**
  String get scheduleInterviewTitle;

  /// No description provided for @interviewType.
  ///
  /// In en, this message translates to:
  /// **'Interview Type'**
  String get interviewType;

  /// No description provided for @inPersonInterview.
  ///
  /// In en, this message translates to:
  /// **'In person'**
  String get inPersonInterview;

  /// No description provided for @videoCallInterview.
  ///
  /// In en, this message translates to:
  /// **'Video call'**
  String get videoCallInterview;

  /// No description provided for @phoneCallInterview.
  ///
  /// In en, this message translates to:
  /// **'Phone call'**
  String get phoneCallInterview;

  /// No description provided for @interviewDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get interviewDate;

  /// No description provided for @interviewTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get interviewTime;

  /// No description provided for @interviewLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get interviewLocation;

  /// No description provided for @interviewNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get interviewNotes;

  /// No description provided for @optionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optionalLabel;

  /// No description provided for @sendInviteCta.
  ///
  /// In en, this message translates to:
  /// **'Send Invite'**
  String get sendInviteCta;

  /// No description provided for @messagesCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{1 message}other{{count} messages}}'**
  String messagesCountLabel(int count);

  /// No description provided for @noNewMessages.
  ///
  /// In en, this message translates to:
  /// **'No new messages'**
  String get noNewMessages;

  /// No description provided for @subscriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscriptionTitle;

  /// No description provided for @currentPlan.
  ///
  /// In en, this message translates to:
  /// **'Current plan'**
  String get currentPlan;

  /// No description provided for @manage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manage;

  /// No description provided for @upgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade;

  /// No description provided for @renewalDate.
  ///
  /// In en, this message translates to:
  /// **'Renewal date'**
  String get renewalDate;

  /// No description provided for @nearbyTalent.
  ///
  /// In en, this message translates to:
  /// **'Nearby Talent'**
  String get nearbyTalent;

  /// No description provided for @searchNearby.
  ///
  /// In en, this message translates to:
  /// **'Search nearby'**
  String get searchNearby;

  /// No description provided for @communityTitle.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get communityTitle;

  /// No description provided for @createPost.
  ///
  /// In en, this message translates to:
  /// **'Create post'**
  String get createPost;

  /// No description provided for @insights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insights;

  /// No description provided for @viewsLabel.
  ///
  /// In en, this message translates to:
  /// **'Views'**
  String get viewsLabel;

  /// No description provided for @applicationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Applications'**
  String get applicationsLabel;

  /// No description provided for @conversionRate.
  ///
  /// In en, this message translates to:
  /// **'Conversion rate'**
  String get conversionRate;

  /// No description provided for @topPerformingJob.
  ///
  /// In en, this message translates to:
  /// **'Top Performing Job'**
  String get topPerformingJob;

  /// No description provided for @viewAllSimple.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAllSimple;

  /// No description provided for @viewAllApplicantsForJob.
  ///
  /// In en, this message translates to:
  /// **'View all applicants for this job'**
  String get viewAllApplicantsForJob;

  /// No description provided for @noUpcomingInterviews.
  ///
  /// In en, this message translates to:
  /// **'No upcoming interviews'**
  String get noUpcomingInterviews;

  /// No description provided for @noActivityYet.
  ///
  /// In en, this message translates to:
  /// **'No activity yet'**
  String get noActivityYet;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @renewsAutomatically.
  ///
  /// In en, this message translates to:
  /// **'Renews automatically'**
  String get renewsAutomatically;

  /// No description provided for @plagitBusinessPlans.
  ///
  /// In en, this message translates to:
  /// **'Plagit Business Plans'**
  String get plagitBusinessPlans;

  /// No description provided for @scaleYourHiringSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scale your hiring with the right plan for your business.'**
  String get scaleYourHiringSubtitle;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @saveWithAnnualBilling.
  ///
  /// In en, this message translates to:
  /// **'Save more with annual billing'**
  String get saveWithAnnualBilling;

  /// No description provided for @chooseYourPlanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the plan that fits your hiring needs.'**
  String get chooseYourPlanSubtitle;

  /// No description provided for @continueWithPlan.
  ///
  /// In en, this message translates to:
  /// **'Continue with {plan}'**
  String continueWithPlan(String plan);

  /// No description provided for @subscriptionAutoRenewNote.
  ///
  /// In en, this message translates to:
  /// **'Subscription auto-renews. Cancel anytime in Settings.'**
  String get subscriptionAutoRenewNote;

  /// No description provided for @purchaseFlowComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Purchase flow coming soon'**
  String get purchaseFlowComingSoon;

  /// No description provided for @applicant.
  ///
  /// In en, this message translates to:
  /// **'Applicant'**
  String get applicant;

  /// No description provided for @applicantNotFound.
  ///
  /// In en, this message translates to:
  /// **'Applicant not found'**
  String get applicantNotFound;

  /// No description provided for @cvViewerComingSoon.
  ///
  /// In en, this message translates to:
  /// **'CV viewer coming soon'**
  String get cvViewerComingSoon;

  /// No description provided for @viewCV.
  ///
  /// In en, this message translates to:
  /// **'View CV'**
  String get viewCV;

  /// No description provided for @application.
  ///
  /// In en, this message translates to:
  /// **'Application'**
  String get application;

  /// No description provided for @messagingComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Messaging coming soon'**
  String get messagingComingSoon;

  /// No description provided for @interviewConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Interview confirmed'**
  String get interviewConfirmed;

  /// No description provided for @interviewMarkedCompleted.
  ///
  /// In en, this message translates to:
  /// **'Interview marked as completed'**
  String get interviewMarkedCompleted;

  /// No description provided for @cancelInterviewConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this interview?'**
  String get cancelInterviewConfirm;

  /// No description provided for @yesCancel.
  ///
  /// In en, this message translates to:
  /// **'Yes, Cancel'**
  String get yesCancel;

  /// No description provided for @interviewNotFound.
  ///
  /// In en, this message translates to:
  /// **'Interview not found'**
  String get interviewNotFound;

  /// No description provided for @openingMeetingLink.
  ///
  /// In en, this message translates to:
  /// **'Opening meeting link...'**
  String get openingMeetingLink;

  /// No description provided for @rescheduleComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Reschedule feature coming soon'**
  String get rescheduleComingSoon;

  /// No description provided for @notesFeatureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Notes feature coming soon'**
  String get notesFeatureComingSoon;

  /// No description provided for @candidateMarkedHired.
  ///
  /// In en, this message translates to:
  /// **'Candidate marked as hired!'**
  String get candidateMarkedHired;

  /// No description provided for @feedbackComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Feedback feature coming soon'**
  String get feedbackComingSoon;

  /// No description provided for @googleMapsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Google Maps integration coming soon'**
  String get googleMapsComingSoon;

  /// No description provided for @noCandidatesNearby.
  ///
  /// In en, this message translates to:
  /// **'No candidates nearby'**
  String get noCandidatesNearby;

  /// No description provided for @tryExpandingRadius.
  ///
  /// In en, this message translates to:
  /// **'Try expanding your search radius.'**
  String get tryExpandingRadius;

  /// No description provided for @candidate.
  ///
  /// In en, this message translates to:
  /// **'Candidate'**
  String get candidate;

  /// No description provided for @forOpenPosition.
  ///
  /// In en, this message translates to:
  /// **'For open position'**
  String get forOpenPosition;

  /// No description provided for @dateAndTimeUpper.
  ///
  /// In en, this message translates to:
  /// **'DATE & TIME'**
  String get dateAndTimeUpper;

  /// No description provided for @interviewTypeUpper.
  ///
  /// In en, this message translates to:
  /// **'INTERVIEW TYPE'**
  String get interviewTypeUpper;

  /// No description provided for @timezoneUpper.
  ///
  /// In en, this message translates to:
  /// **'TIMEZONE'**
  String get timezoneUpper;

  /// No description provided for @highlights.
  ///
  /// In en, this message translates to:
  /// **'Highlights'**
  String get highlights;

  /// No description provided for @cvNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'CV not available'**
  String get cvNotAvailable;

  /// No description provided for @cvWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Will appear here once uploaded'**
  String get cvWillAppearHere;

  /// No description provided for @seenEveryone.
  ///
  /// In en, this message translates to:
  /// **'You\'ve seen everyone'**
  String get seenEveryone;

  /// No description provided for @checkBackForCandidates.
  ///
  /// In en, this message translates to:
  /// **'Check back later for new candidates.'**
  String get checkBackForCandidates;

  /// No description provided for @dailyLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Daily limit reached'**
  String get dailyLimitReached;

  /// No description provided for @upgradeForUnlimitedSwipes.
  ///
  /// In en, this message translates to:
  /// **'Upgrade for unlimited swipes.'**
  String get upgradeForUnlimitedSwipes;

  /// No description provided for @distanceUpper.
  ///
  /// In en, this message translates to:
  /// **'DISTANCE'**
  String get distanceUpper;

  /// No description provided for @inviteToInterview.
  ///
  /// In en, this message translates to:
  /// **'Invite to Interview'**
  String get inviteToInterview;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @shortlistedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Shortlisted successfully'**
  String get shortlistedSuccessfully;

  /// No description provided for @tabDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get tabDashboard;

  /// No description provided for @tabCandidates.
  ///
  /// In en, this message translates to:
  /// **'Candidates'**
  String get tabCandidates;

  /// No description provided for @tabActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get tabActivity;

  /// No description provided for @statusPosted.
  ///
  /// In en, this message translates to:
  /// **'Posted'**
  String get statusPosted;

  /// No description provided for @statusApplicants.
  ///
  /// In en, this message translates to:
  /// **'Applicants'**
  String get statusApplicants;

  /// No description provided for @statusInterviewsShort.
  ///
  /// In en, this message translates to:
  /// **'Interviews'**
  String get statusInterviewsShort;

  /// No description provided for @statusHiredShort.
  ///
  /// In en, this message translates to:
  /// **'Hired'**
  String get statusHiredShort;

  /// No description provided for @jobLiveVisible.
  ///
  /// In en, this message translates to:
  /// **'Your job post is live and visible'**
  String get jobLiveVisible;

  /// No description provided for @postJobShort.
  ///
  /// In en, this message translates to:
  /// **'Post Job'**
  String get postJobShort;

  /// No description provided for @messagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messagesTitle;

  /// No description provided for @online2.
  ///
  /// In en, this message translates to:
  /// **'Online now'**
  String get online2;

  /// No description provided for @candidateUpper.
  ///
  /// In en, this message translates to:
  /// **'CANDIDATE'**
  String get candidateUpper;

  /// No description provided for @searchConversationsHint.
  ///
  /// In en, this message translates to:
  /// **'Search conversations, candidates, roles…'**
  String get searchConversationsHint;

  /// No description provided for @filterUnread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get filterUnread;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @whenCandidatesMessage.
  ///
  /// In en, this message translates to:
  /// **'When candidates message you, conversations will appear here.'**
  String get whenCandidatesMessage;

  /// No description provided for @trySwitchingFilter.
  ///
  /// In en, this message translates to:
  /// **'Try switching to a different filter.'**
  String get trySwitchingFilter;

  /// No description provided for @reply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get reply;

  /// No description provided for @selectItems.
  ///
  /// In en, this message translates to:
  /// **'Select items'**
  String get selectItems;

  /// No description provided for @countSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String countSelected(int count);

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get selectAll;

  /// No description provided for @deleteConversation.
  ///
  /// In en, this message translates to:
  /// **'Delete conversation?'**
  String get deleteConversation;

  /// No description provided for @deleteAllConversations.
  ///
  /// In en, this message translates to:
  /// **'Delete all conversations?'**
  String get deleteAllConversations;

  /// No description provided for @deleteSelectedNote.
  ///
  /// In en, this message translates to:
  /// **'Selected chats will be removed from your inbox. The candidate still keeps their copy.'**
  String get deleteSelectedNote;

  /// No description provided for @deleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete all'**
  String get deleteAll;

  /// No description provided for @selectConversations.
  ///
  /// In en, this message translates to:
  /// **'Select conversations'**
  String get selectConversations;

  /// No description provided for @feedTab.
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get feedTab;

  /// No description provided for @myPostsTab.
  ///
  /// In en, this message translates to:
  /// **'My Posts'**
  String get myPostsTab;

  /// No description provided for @savedTab.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get savedTab;

  /// No description provided for @postingAs.
  ///
  /// In en, this message translates to:
  /// **'Posting as {name}'**
  String postingAs(String name);

  /// No description provided for @noPostsYet.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t posted yet'**
  String get noPostsYet;

  /// No description provided for @nothingHereYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get nothingHereYet;

  /// No description provided for @shareVenueUpdate.
  ///
  /// In en, this message translates to:
  /// **'Share an update from your venue to start building your community presence.'**
  String get shareVenueUpdate;

  /// No description provided for @communityPostsAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Posts from the community will appear here.'**
  String get communityPostsAppearHere;

  /// No description provided for @createFirstPost.
  ///
  /// In en, this message translates to:
  /// **'Create First Post'**
  String get createFirstPost;

  /// No description provided for @yourPostUpper.
  ///
  /// In en, this message translates to:
  /// **'YOUR POST'**
  String get yourPostUpper;

  /// No description provided for @businessLabel.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get businessLabel;

  /// No description provided for @profileNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Profile not available'**
  String get profileNotAvailable;

  /// No description provided for @companyProfile.
  ///
  /// In en, this message translates to:
  /// **'Company Profile'**
  String get companyProfile;

  /// No description provided for @premiumVenue.
  ///
  /// In en, this message translates to:
  /// **'Premium venue'**
  String get premiumVenue;

  /// No description provided for @businessDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Business Details'**
  String get businessDetailsTitle;

  /// No description provided for @businessNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Business Name'**
  String get businessNameLabel;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationLabel;

  /// No description provided for @verificationLabel.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get verificationLabel;

  /// No description provided for @pendingLabel.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingLabel;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @contactLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contactLabel;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTitle;

  /// No description provided for @companyNameField.
  ///
  /// In en, this message translates to:
  /// **'Company Name'**
  String get companyNameField;

  /// No description provided for @phoneField.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneField;

  /// No description provided for @locationField.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationField;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @signOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get signOutTitle;

  /// No description provided for @signOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutConfirm;

  /// No description provided for @activeCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{1 active}other{{count} active}}'**
  String activeCountLabel(int count);

  /// No description provided for @newThisWeekLabel.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{1 new this week}other{{count} new this week}}'**
  String newThisWeekLabel(int count);

  /// No description provided for @jobStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get jobStatusActive;

  /// No description provided for @jobStatusPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get jobStatusPaused;

  /// No description provided for @jobStatusClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get jobStatusClosed;

  /// No description provided for @jobStatusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get jobStatusDraft;

  /// No description provided for @contractCasual.
  ///
  /// In en, this message translates to:
  /// **'Casual'**
  String get contractCasual;

  /// No description provided for @planBasic.
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get planBasic;

  /// No description provided for @planPro.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get planPro;

  /// No description provided for @planPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get planPremium;

  /// No description provided for @bestForMaxVisibility.
  ///
  /// In en, this message translates to:
  /// **'Best for Maximum Visibility'**
  String get bestForMaxVisibility;

  /// No description provided for @saveDollarsPerYear.
  ///
  /// In en, this message translates to:
  /// **'Save {currency}{amount}/year'**
  String saveDollarsPerYear(String currency, String amount);

  /// No description provided for @planBasicFeature1.
  ///
  /// In en, this message translates to:
  /// **'Post up to 3 jobs'**
  String get planBasicFeature1;

  /// No description provided for @planBasicFeature2.
  ///
  /// In en, this message translates to:
  /// **'View applicant profiles'**
  String get planBasicFeature2;

  /// No description provided for @planBasicFeature3.
  ///
  /// In en, this message translates to:
  /// **'Basic candidate search'**
  String get planBasicFeature3;

  /// No description provided for @planBasicFeature4.
  ///
  /// In en, this message translates to:
  /// **'Email support'**
  String get planBasicFeature4;

  /// No description provided for @planProFeature1.
  ///
  /// In en, this message translates to:
  /// **'Post up to 10 jobs'**
  String get planProFeature1;

  /// No description provided for @planProFeature2.
  ///
  /// In en, this message translates to:
  /// **'Advanced candidate search'**
  String get planProFeature2;

  /// No description provided for @planProFeature3.
  ///
  /// In en, this message translates to:
  /// **'Priority applicant sorting'**
  String get planProFeature3;

  /// No description provided for @planProFeature4.
  ///
  /// In en, this message translates to:
  /// **'Quick Plug access'**
  String get planProFeature4;

  /// No description provided for @planProFeature5.
  ///
  /// In en, this message translates to:
  /// **'Chat support'**
  String get planProFeature5;

  /// No description provided for @planPremiumFeature1.
  ///
  /// In en, this message translates to:
  /// **'Unlimited job postings'**
  String get planPremiumFeature1;

  /// No description provided for @planPremiumFeature2.
  ///
  /// In en, this message translates to:
  /// **'Featured job listings'**
  String get planPremiumFeature2;

  /// No description provided for @planPremiumFeature3.
  ///
  /// In en, this message translates to:
  /// **'Advanced analytics'**
  String get planPremiumFeature3;

  /// No description provided for @planPremiumFeature4.
  ///
  /// In en, this message translates to:
  /// **'Quick Plug unlimited'**
  String get planPremiumFeature4;

  /// No description provided for @planPremiumFeature5.
  ///
  /// In en, this message translates to:
  /// **'Priority candidate matching'**
  String get planPremiumFeature5;

  /// No description provided for @planPremiumFeature6.
  ///
  /// In en, this message translates to:
  /// **'Dedicated account manager'**
  String get planPremiumFeature6;

  /// No description provided for @currentSelectionCheck.
  ///
  /// In en, this message translates to:
  /// **'Current Selection ✓'**
  String get currentSelectionCheck;

  /// No description provided for @selectPlanName.
  ///
  /// In en, this message translates to:
  /// **'Select {plan}'**
  String selectPlanName(String plan);

  /// No description provided for @perYear.
  ///
  /// In en, this message translates to:
  /// **'/year'**
  String get perYear;

  /// No description provided for @perMonth.
  ///
  /// In en, this message translates to:
  /// **'/month'**
  String get perMonth;

  /// No description provided for @jobTitleHintExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. Senior Chef'**
  String get jobTitleHintExample;

  /// No description provided for @locationHintExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. Dubai, UAE'**
  String get locationHintExample;

  /// No description provided for @annualSalaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Annual salary ({currency})'**
  String annualSalaryLabel(String currency);

  /// No description provided for @monthlyPayLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly pay ({currency})'**
  String monthlyPayLabel(String currency);

  /// No description provided for @hourlyRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Hourly rate ({currency})'**
  String hourlyRateLabel(String currency);

  /// No description provided for @minSalaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Min ({currency})'**
  String minSalaryLabel(String currency);

  /// No description provided for @maxSalaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Max ({currency})'**
  String maxSalaryLabel(String currency);

  /// No description provided for @hoursPerWeekLabel.
  ///
  /// In en, this message translates to:
  /// **'Hours / week'**
  String get hoursPerWeekLabel;

  /// No description provided for @expectedHoursWeekLabel.
  ///
  /// In en, this message translates to:
  /// **'Expected hours / week (optional)'**
  String get expectedHoursWeekLabel;

  /// No description provided for @bonusTipsLabel.
  ///
  /// In en, this message translates to:
  /// **'Bonus / Tips (optional)'**
  String get bonusTipsLabel;

  /// No description provided for @bonusTipsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Tips & service charge'**
  String get bonusTipsHint;

  /// No description provided for @housingIncludedLabel.
  ///
  /// In en, this message translates to:
  /// **'Housing included'**
  String get housingIncludedLabel;

  /// No description provided for @travelIncludedLabel.
  ///
  /// In en, this message translates to:
  /// **'Travel included'**
  String get travelIncludedLabel;

  /// No description provided for @overtimeAvailableLabel.
  ///
  /// In en, this message translates to:
  /// **'Overtime available'**
  String get overtimeAvailableLabel;

  /// No description provided for @flexibleScheduleLabel.
  ///
  /// In en, this message translates to:
  /// **'Flexible schedule'**
  String get flexibleScheduleLabel;

  /// No description provided for @weekendShiftsLabel.
  ///
  /// In en, this message translates to:
  /// **'Weekend shifts'**
  String get weekendShiftsLabel;

  /// No description provided for @describeRoleHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the role, responsibilities, and what makes this job great...'**
  String get describeRoleHint;

  /// No description provided for @requirementsHint.
  ///
  /// In en, this message translates to:
  /// **'Skills, experience, certifications needed...'**
  String get requirementsHint;

  /// No description provided for @previewPrefix.
  ///
  /// In en, this message translates to:
  /// **'Preview: {text}'**
  String previewPrefix(String text);

  /// No description provided for @monthsShort.
  ///
  /// In en, this message translates to:
  /// **'{count} mo'**
  String monthsShort(int count);

  /// No description provided for @roleAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get roleAll;

  /// No description provided for @roleChef.
  ///
  /// In en, this message translates to:
  /// **'Chef'**
  String get roleChef;

  /// No description provided for @roleWaiter.
  ///
  /// In en, this message translates to:
  /// **'Waiter'**
  String get roleWaiter;

  /// No description provided for @roleBartender.
  ///
  /// In en, this message translates to:
  /// **'Bartender'**
  String get roleBartender;

  /// No description provided for @roleHost.
  ///
  /// In en, this message translates to:
  /// **'Host'**
  String get roleHost;

  /// No description provided for @roleManager.
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get roleManager;

  /// No description provided for @roleReception.
  ///
  /// In en, this message translates to:
  /// **'Reception'**
  String get roleReception;

  /// No description provided for @roleKitchenPorter.
  ///
  /// In en, this message translates to:
  /// **'Kitchen Porter'**
  String get roleKitchenPorter;

  /// No description provided for @roleRelocate.
  ///
  /// In en, this message translates to:
  /// **'Relocate'**
  String get roleRelocate;

  /// No description provided for @experience02Years.
  ///
  /// In en, this message translates to:
  /// **'0-2 years'**
  String get experience02Years;

  /// No description provided for @experience35Years.
  ///
  /// In en, this message translates to:
  /// **'3-5 years'**
  String get experience35Years;

  /// No description provided for @experience5PlusYears.
  ///
  /// In en, this message translates to:
  /// **'5+ years'**
  String get experience5PlusYears;

  /// No description provided for @roleUpper.
  ///
  /// In en, this message translates to:
  /// **'ROLE'**
  String get roleUpper;

  /// No description provided for @experienceUpper.
  ///
  /// In en, this message translates to:
  /// **'EXPERIENCE'**
  String get experienceUpper;

  /// No description provided for @cvLabel.
  ///
  /// In en, this message translates to:
  /// **'CV'**
  String get cvLabel;

  /// No description provided for @addShort.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addShort;

  /// No description provided for @photosCount.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{1 photo}other{{count} photos}}'**
  String photosCount(int count);

  /// No description provided for @candidatesFoundCount.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{1 candidate found}other{{count} candidates found}}'**
  String candidatesFoundCount(int count);

  /// No description provided for @maxKmLabel.
  ///
  /// In en, this message translates to:
  /// **'max 50 km'**
  String get maxKmLabel;

  /// No description provided for @shortlistAction.
  ///
  /// In en, this message translates to:
  /// **'Shortlist'**
  String get shortlistAction;

  /// No description provided for @messageAction.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get messageAction;

  /// No description provided for @interviewAction.
  ///
  /// In en, this message translates to:
  /// **'Interview'**
  String get interviewAction;

  /// No description provided for @viewAction.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get viewAction;

  /// No description provided for @rejectAction.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get rejectAction;

  /// No description provided for @basedIn.
  ///
  /// In en, this message translates to:
  /// **'Based in'**
  String get basedIn;

  /// No description provided for @verificationPending.
  ///
  /// In en, this message translates to:
  /// **'Verification pending'**
  String get verificationPending;

  /// No description provided for @refreshAction.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refreshAction;

  /// No description provided for @upgradeAction.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgradeAction;

  /// No description provided for @searchJobsByTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Search jobs by title, role or location…'**
  String get searchJobsByTitleHint;

  /// No description provided for @xShortlisted.
  ///
  /// In en, this message translates to:
  /// **'{name} shortlisted'**
  String xShortlisted(String name);

  /// No description provided for @xRejected.
  ///
  /// In en, this message translates to:
  /// **'{name} rejected'**
  String xRejected(String name);

  /// No description provided for @rejectConfirmName.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reject {name}?'**
  String rejectConfirmName(String name);

  /// No description provided for @appliedToRoleOn.
  ///
  /// In en, this message translates to:
  /// **'Applied to {role} on {date}'**
  String appliedToRoleOn(String role, String date);

  /// No description provided for @appliedDatePrefix.
  ///
  /// In en, this message translates to:
  /// **'Applied {date}'**
  String appliedDatePrefix(String date);

  /// No description provided for @salaryExpectationTitle.
  ///
  /// In en, this message translates to:
  /// **'Salary Expectation'**
  String get salaryExpectationTitle;

  /// No description provided for @previousEmployer.
  ///
  /// In en, this message translates to:
  /// **'Previous Employer'**
  String get previousEmployer;

  /// No description provided for @earlierVenue.
  ///
  /// In en, this message translates to:
  /// **'Earlier Venue'**
  String get earlierVenue;

  /// No description provided for @presentLabel.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get presentLabel;

  /// No description provided for @skillCustomerService.
  ///
  /// In en, this message translates to:
  /// **'Customer Service'**
  String get skillCustomerService;

  /// No description provided for @skillTeamwork.
  ///
  /// In en, this message translates to:
  /// **'Teamwork'**
  String get skillTeamwork;

  /// No description provided for @skillCommunication.
  ///
  /// In en, this message translates to:
  /// **'Communication'**
  String get skillCommunication;

  /// No description provided for @stepApplied.
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get stepApplied;

  /// No description provided for @stepViewed.
  ///
  /// In en, this message translates to:
  /// **'Viewed'**
  String get stepViewed;

  /// No description provided for @stepShortlisted.
  ///
  /// In en, this message translates to:
  /// **'Shortlisted'**
  String get stepShortlisted;

  /// No description provided for @stepInterviewScheduled.
  ///
  /// In en, this message translates to:
  /// **'Interview Scheduled'**
  String get stepInterviewScheduled;

  /// No description provided for @stepRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get stepRejected;

  /// No description provided for @stepUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Under Review'**
  String get stepUnderReview;

  /// No description provided for @stepPendingReview.
  ///
  /// In en, this message translates to:
  /// **'Pending Review'**
  String get stepPendingReview;

  /// No description provided for @sortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get sortNewest;

  /// No description provided for @sortMostExperienced.
  ///
  /// In en, this message translates to:
  /// **'Most Experienced'**
  String get sortMostExperienced;

  /// No description provided for @sortBestMatch.
  ///
  /// In en, this message translates to:
  /// **'Best Match'**
  String get sortBestMatch;

  /// No description provided for @filterApplied.
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get filterApplied;

  /// No description provided for @filterUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Under Review'**
  String get filterUnderReview;

  /// No description provided for @filterShortlisted.
  ///
  /// In en, this message translates to:
  /// **'Shortlisted'**
  String get filterShortlisted;

  /// No description provided for @filterInterview.
  ///
  /// In en, this message translates to:
  /// **'Interview'**
  String get filterInterview;

  /// No description provided for @filterHired.
  ///
  /// In en, this message translates to:
  /// **'Hired'**
  String get filterHired;

  /// No description provided for @filterRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get filterRejected;

  /// No description provided for @confirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get confirmed;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @videoLabel.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get videoLabel;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @interviewDetails.
  ///
  /// In en, this message translates to:
  /// **'Interview Details'**
  String get interviewDetails;

  /// No description provided for @interviewConfirmedHeadline.
  ///
  /// In en, this message translates to:
  /// **'Interview confirmed'**
  String get interviewConfirmedHeadline;

  /// No description provided for @interviewConfirmedSubline.
  ///
  /// In en, this message translates to:
  /// **'You\'re all set. We\'ll remind you closer to the time.'**
  String get interviewConfirmedSubline;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeLabel;

  /// No description provided for @formatLabel.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get formatLabel;

  /// No description provided for @joinMeeting.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get joinMeeting;

  /// No description provided for @viewJobAction.
  ///
  /// In en, this message translates to:
  /// **'View Job'**
  String get viewJobAction;

  /// No description provided for @addToCalendar.
  ///
  /// In en, this message translates to:
  /// **'Add to Calendar'**
  String get addToCalendar;

  /// No description provided for @needsYourAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs your attention'**
  String get needsYourAttention;

  /// No description provided for @reviewAction.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get reviewAction;

  /// No description provided for @applicationsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 application} other{{count} applications}}'**
  String applicationsCount(int count);

  /// No description provided for @sortMostRecent.
  ///
  /// In en, this message translates to:
  /// **'Most Recent'**
  String get sortMostRecent;

  /// No description provided for @interviewScheduledLabel.
  ///
  /// In en, this message translates to:
  /// **'Interview Scheduled'**
  String get interviewScheduledLabel;

  /// No description provided for @editAction.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editAction;

  /// No description provided for @currentPlanLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Plan'**
  String get currentPlanLabel;

  /// No description provided for @freePlan.
  ///
  /// In en, this message translates to:
  /// **'Free Plan'**
  String get freePlan;

  /// No description provided for @profileStrength.
  ///
  /// In en, this message translates to:
  /// **'Profile Strength'**
  String get profileStrength;

  /// No description provided for @detailsLabel.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get detailsLabel;

  /// No description provided for @basedInLabel.
  ///
  /// In en, this message translates to:
  /// **'Based In'**
  String get basedInLabel;

  /// No description provided for @verificationLabel2.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get verificationLabel2;

  /// No description provided for @contactLabel2.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contactLabel2;

  /// No description provided for @notSetLabel.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSetLabel;

  /// No description provided for @chipAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get chipAll;

  /// No description provided for @chipFullTime.
  ///
  /// In en, this message translates to:
  /// **'Full-time'**
  String get chipFullTime;

  /// No description provided for @chipPartTime.
  ///
  /// In en, this message translates to:
  /// **'Part-time'**
  String get chipPartTime;

  /// No description provided for @chipTemporary.
  ///
  /// In en, this message translates to:
  /// **'Temporary'**
  String get chipTemporary;

  /// No description provided for @chipCasual.
  ///
  /// In en, this message translates to:
  /// **'Casual'**
  String get chipCasual;

  /// No description provided for @sortBestMatchLabel.
  ///
  /// In en, this message translates to:
  /// **'Best Match'**
  String get sortBestMatchLabel;

  /// No description provided for @sortAZ.
  ///
  /// In en, this message translates to:
  /// **'A-Z'**
  String get sortAZ;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @featuredBadge.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get featuredBadge;

  /// No description provided for @urgentBadge.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get urgentBadge;

  /// No description provided for @salaryOnRequest.
  ///
  /// In en, this message translates to:
  /// **'Salary on request'**
  String get salaryOnRequest;

  /// No description provided for @upgradeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremium;

  /// No description provided for @urgentJobsOnly.
  ///
  /// In en, this message translates to:
  /// **'Urgent Jobs Only'**
  String get urgentJobsOnly;

  /// No description provided for @showOnlyUrgentListings.
  ///
  /// In en, this message translates to:
  /// **'Show only urgent listings'**
  String get showOnlyUrgentListings;

  /// No description provided for @verifiedBusinessesOnly.
  ///
  /// In en, this message translates to:
  /// **'Verified Businesses Only'**
  String get verifiedBusinessesOnly;

  /// No description provided for @showOnlyVerifiedBusinesses.
  ///
  /// In en, this message translates to:
  /// **'Show only verified businesses'**
  String get showOnlyVerifiedBusinesses;

  /// No description provided for @split.
  ///
  /// In en, this message translates to:
  /// **'Split'**
  String get split;

  /// No description provided for @payUpper.
  ///
  /// In en, this message translates to:
  /// **'PAY'**
  String get payUpper;

  /// No description provided for @typeUpper.
  ///
  /// In en, this message translates to:
  /// **'TYPE'**
  String get typeUpper;

  /// No description provided for @whereUpper.
  ///
  /// In en, this message translates to:
  /// **'WHERE'**
  String get whereUpper;

  /// No description provided for @payLabel.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get payLabel;

  /// No description provided for @typeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get typeLabel;

  /// No description provided for @whereLabel.
  ///
  /// In en, this message translates to:
  /// **'Where'**
  String get whereLabel;

  /// No description provided for @whereYouWillWork.
  ///
  /// In en, this message translates to:
  /// **'Where you\'ll work'**
  String get whereYouWillWork;

  /// No description provided for @mapPreviewDirections.
  ///
  /// In en, this message translates to:
  /// **'Map preview · open for full directions'**
  String get mapPreviewDirections;

  /// No description provided for @directionsAction.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get directionsAction;

  /// No description provided for @communityTabForYou.
  ///
  /// In en, this message translates to:
  /// **'For You'**
  String get communityTabForYou;

  /// No description provided for @communityTabFollowing.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get communityTabFollowing;

  /// No description provided for @communityTabNearby.
  ///
  /// In en, this message translates to:
  /// **'Nearby'**
  String get communityTabNearby;

  /// No description provided for @communityTabSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get communityTabSaved;

  /// No description provided for @viewProfileAction.
  ///
  /// In en, this message translates to:
  /// **'View profile'**
  String get viewProfileAction;

  /// No description provided for @copyLinkAction.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get copyLinkAction;

  /// No description provided for @savePostAction.
  ///
  /// In en, this message translates to:
  /// **'Save post'**
  String get savePostAction;

  /// No description provided for @unsavePostAction.
  ///
  /// In en, this message translates to:
  /// **'Unsave post'**
  String get unsavePostAction;

  /// No description provided for @hideThisPost.
  ///
  /// In en, this message translates to:
  /// **'Hide this post'**
  String get hideThisPost;

  /// No description provided for @reportPost.
  ///
  /// In en, this message translates to:
  /// **'Report post'**
  String get reportPost;

  /// No description provided for @cancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelAction;

  /// No description provided for @newPostTitle.
  ///
  /// In en, this message translates to:
  /// **'New Post'**
  String get newPostTitle;

  /// No description provided for @youLabel.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get youLabel;

  /// No description provided for @postingToCommunityAsBusiness.
  ///
  /// In en, this message translates to:
  /// **'Posting to Community as Business'**
  String get postingToCommunityAsBusiness;

  /// No description provided for @postingToCommunityAsPro.
  ///
  /// In en, this message translates to:
  /// **'Posting to Community as Hospitality Pro'**
  String get postingToCommunityAsPro;

  /// No description provided for @whatsOnYourMind.
  ///
  /// In en, this message translates to:
  /// **'What\'s on your mind?'**
  String get whatsOnYourMind;

  /// No description provided for @publishAction.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publishAction;

  /// No description provided for @attachmentPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get attachmentPhoto;

  /// No description provided for @attachmentVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get attachmentVideo;

  /// No description provided for @attachmentLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get attachmentLocation;

  /// No description provided for @boostMyProfileCta.
  ///
  /// In en, this message translates to:
  /// **'Boost My Profile'**
  String get boostMyProfileCta;

  /// No description provided for @unlockYourFullPotential.
  ///
  /// In en, this message translates to:
  /// **'Unlock your full potential'**
  String get unlockYourFullPotential;

  /// No description provided for @annualPlan.
  ///
  /// In en, this message translates to:
  /// **'Annual'**
  String get annualPlan;

  /// No description provided for @monthlyPlan.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthlyPlan;

  /// No description provided for @bestValueBadge.
  ///
  /// In en, this message translates to:
  /// **'BEST VALUE'**
  String get bestValueBadge;

  /// No description provided for @whatsIncluded.
  ///
  /// In en, this message translates to:
  /// **'What\'s included'**
  String get whatsIncluded;

  /// No description provided for @continueWithAnnual.
  ///
  /// In en, this message translates to:
  /// **'Continue with Annual'**
  String get continueWithAnnual;

  /// No description provided for @continueWithMonthly.
  ///
  /// In en, this message translates to:
  /// **'Continue with Monthly'**
  String get continueWithMonthly;

  /// No description provided for @maybeLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe later'**
  String get maybeLater;

  /// No description provided for @restorePurchasesLabel.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restorePurchasesLabel;

  /// No description provided for @subscriptionAutoRenewsNote.
  ///
  /// In en, this message translates to:
  /// **'Subscription auto-renews. Cancel anytime in Settings.'**
  String get subscriptionAutoRenewsNote;

  /// No description provided for @appStatusPillApplied.
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get appStatusPillApplied;

  /// No description provided for @appStatusPillUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Under Review'**
  String get appStatusPillUnderReview;

  /// No description provided for @appStatusPillShortlisted.
  ///
  /// In en, this message translates to:
  /// **'Shortlisted'**
  String get appStatusPillShortlisted;

  /// No description provided for @appStatusPillInterviewInvited.
  ///
  /// In en, this message translates to:
  /// **'Interview Invited'**
  String get appStatusPillInterviewInvited;

  /// No description provided for @appStatusPillInterviewScheduled.
  ///
  /// In en, this message translates to:
  /// **'Interview Scheduled'**
  String get appStatusPillInterviewScheduled;

  /// No description provided for @appStatusPillHired.
  ///
  /// In en, this message translates to:
  /// **'Hired'**
  String get appStatusPillHired;

  /// No description provided for @appStatusPillRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get appStatusPillRejected;

  /// No description provided for @appStatusPillWithdrawn.
  ///
  /// In en, this message translates to:
  /// **'Withdrawn'**
  String get appStatusPillWithdrawn;

  /// No description provided for @jobActionPause.
  ///
  /// In en, this message translates to:
  /// **'Pause Job'**
  String get jobActionPause;

  /// No description provided for @jobActionResume.
  ///
  /// In en, this message translates to:
  /// **'Resume Job'**
  String get jobActionResume;

  /// No description provided for @jobActionClose.
  ///
  /// In en, this message translates to:
  /// **'Close Job'**
  String get jobActionClose;

  /// No description provided for @statusConfirmedLower.
  ///
  /// In en, this message translates to:
  /// **'confirmed'**
  String get statusConfirmedLower;

  /// No description provided for @postInsightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Post Insights'**
  String get postInsightsTitle;

  /// No description provided for @postInsightsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Who\'s seeing your content'**
  String get postInsightsSubtitle;

  /// No description provided for @recentViewers.
  ///
  /// In en, this message translates to:
  /// **'Recent Viewers'**
  String get recentViewers;

  /// No description provided for @lockedBadge.
  ///
  /// In en, this message translates to:
  /// **'LOCKED'**
  String get lockedBadge;

  /// No description provided for @viewerBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Viewer Breakdown'**
  String get viewerBreakdown;

  /// No description provided for @viewersByRole.
  ///
  /// In en, this message translates to:
  /// **'Viewers by Role'**
  String get viewersByRole;

  /// No description provided for @topLocations.
  ///
  /// In en, this message translates to:
  /// **'Top Locations'**
  String get topLocations;

  /// No description provided for @businesses.
  ///
  /// In en, this message translates to:
  /// **'Businesses'**
  String get businesses;

  /// No description provided for @saveToCollectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Save to Collection'**
  String get saveToCollectionTitle;

  /// No description provided for @chooseCategory.
  ///
  /// In en, this message translates to:
  /// **'Choose Category'**
  String get chooseCategory;

  /// No description provided for @removeFromCollection.
  ///
  /// In en, this message translates to:
  /// **'Remove from collection'**
  String get removeFromCollection;

  /// No description provided for @newApplicationTemplate.
  ///
  /// In en, this message translates to:
  /// **'New Application — {role}'**
  String newApplicationTemplate(String role);

  /// No description provided for @categoryRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get categoryRestaurants;

  /// No description provided for @categoryCookingVideos.
  ///
  /// In en, this message translates to:
  /// **'Cooking Videos'**
  String get categoryCookingVideos;

  /// No description provided for @categoryJobsTips.
  ///
  /// In en, this message translates to:
  /// **'Jobs Tips'**
  String get categoryJobsTips;

  /// No description provided for @categoryHospitalityNews.
  ///
  /// In en, this message translates to:
  /// **'Hospitality News'**
  String get categoryHospitalityNews;

  /// No description provided for @categoryRecipes.
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get categoryRecipes;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @premiumHeroTagline.
  ///
  /// In en, this message translates to:
  /// **'More visibility, priority alerts, and advanced filters built for serious hospitality professionals.'**
  String get premiumHeroTagline;

  /// No description provided for @benefitAdvancedFilters.
  ///
  /// In en, this message translates to:
  /// **'Advanced search filters'**
  String get benefitAdvancedFilters;

  /// No description provided for @benefitPriorityNotifications.
  ///
  /// In en, this message translates to:
  /// **'Priority job notifications'**
  String get benefitPriorityNotifications;

  /// No description provided for @benefitProfileVisibility.
  ///
  /// In en, this message translates to:
  /// **'Increased profile visibility'**
  String get benefitProfileVisibility;

  /// No description provided for @benefitPremiumBadge.
  ///
  /// In en, this message translates to:
  /// **'Premium profile badge'**
  String get benefitPremiumBadge;

  /// No description provided for @benefitEarlyAccess.
  ///
  /// In en, this message translates to:
  /// **'Early access to new jobs'**
  String get benefitEarlyAccess;

  /// No description provided for @unlockCandidatePremium.
  ///
  /// In en, this message translates to:
  /// **'Unlock Candidate Premium'**
  String get unlockCandidatePremium;

  /// No description provided for @getStartedAction.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStartedAction;

  /// No description provided for @findYourFirstJob.
  ///
  /// In en, this message translates to:
  /// **'Find your first job'**
  String get findYourFirstJob;

  /// No description provided for @browseHospitalityRolesNearby.
  ///
  /// In en, this message translates to:
  /// **'Browse hundreds of hospitality roles near you'**
  String get browseHospitalityRolesNearby;

  /// No description provided for @seeWhoViewedYourPostTitle.
  ///
  /// In en, this message translates to:
  /// **'See Who Viewed Your Post'**
  String get seeWhoViewedYourPostTitle;

  /// No description provided for @upgradeToPremiumCta.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremiumCta;

  /// No description provided for @upgradeToPremiumSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium to see verified businesses, recruiters, and hospitality leaders who viewed your content.'**
  String get upgradeToPremiumSubtitle;

  /// No description provided for @verifiedBusinessViewers.
  ///
  /// In en, this message translates to:
  /// **'Verified business viewers'**
  String get verifiedBusinessViewers;

  /// No description provided for @recruiterHiringManagerActivity.
  ///
  /// In en, this message translates to:
  /// **'Recruiter & hiring-manager activity'**
  String get recruiterHiringManagerActivity;

  /// No description provided for @cityLevelReachBreakdown.
  ///
  /// In en, this message translates to:
  /// **'City-level reach breakdown'**
  String get cityLevelReachBreakdown;

  /// No description provided for @liveApplicationsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 live} other{{count} live}}'**
  String liveApplicationsCount(int count);

  /// No description provided for @nearbyJobsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 nearby} other{{count} nearby}}'**
  String nearbyJobsCount(int count);

  /// No description provided for @jobsNearYouCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 job near you} other{{count} jobs near you}}'**
  String jobsNearYouCount(int count);

  /// No description provided for @applicationsUnderReviewCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 application under review} other{{count} applications under review}}'**
  String applicationsUnderReviewCount(int count);

  /// No description provided for @interviewsScheduledCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 interview scheduled} other{{count} interviews scheduled}}'**
  String interviewsScheduledCount(int count);

  /// No description provided for @unreadMessagesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 unread message} other{{count} unread messages}}'**
  String unreadMessagesCount(int count);

  /// No description provided for @unreadMessagesFromEmployersCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 unread message from employers} other{{count} unread messages from employers}}'**
  String unreadMessagesFromEmployersCount(int count);

  /// No description provided for @stepsLeftCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 step left} other{{count} steps left}}'**
  String stepsLeftCount(int count);

  /// No description provided for @profileCompleteGreatWork.
  ///
  /// In en, this message translates to:
  /// **'Profile complete — great work'**
  String get profileCompleteGreatWork;

  /// No description provided for @yearsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 year} other{{count} years}}'**
  String yearsCount(int count);

  /// No description provided for @perHour.
  ///
  /// In en, this message translates to:
  /// **'/hr'**
  String get perHour;

  /// No description provided for @hoursPerWeekShort.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hr/week} other{{count} hrs/week}}'**
  String hoursPerWeekShort(int count);

  /// No description provided for @forMonthsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{for 1 month} other{for {count} months}}'**
  String forMonthsCount(int count);

  /// No description provided for @interviewsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 interview} other{{count} interviews}}'**
  String interviewsCount(int count);

  /// No description provided for @quickActionFindJobs.
  ///
  /// In en, this message translates to:
  /// **'Find Jobs'**
  String get quickActionFindJobs;

  /// No description provided for @quickActionMyApplications.
  ///
  /// In en, this message translates to:
  /// **'My Applications'**
  String get quickActionMyApplications;

  /// No description provided for @quickActionUpdateProfile.
  ///
  /// In en, this message translates to:
  /// **'Update Profile'**
  String get quickActionUpdateProfile;

  /// No description provided for @quickActionCreatePost.
  ///
  /// In en, this message translates to:
  /// **'Create Post'**
  String get quickActionCreatePost;

  /// No description provided for @quickActionViewInterviews.
  ///
  /// In en, this message translates to:
  /// **'View Interviews'**
  String get quickActionViewInterviews;

  /// No description provided for @confirmSubscriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Subscription'**
  String get confirmSubscriptionTitle;

  /// No description provided for @confirmAndSubscribeCta.
  ///
  /// In en, this message translates to:
  /// **'Confirm & Subscribe'**
  String get confirmAndSubscribeCta;

  /// No description provided for @timelineLabel.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get timelineLabel;

  /// No description provided for @interviewLabel.
  ///
  /// In en, this message translates to:
  /// **'Interview'**
  String get interviewLabel;

  /// No description provided for @payOnRequest.
  ///
  /// In en, this message translates to:
  /// **'Pay on request'**
  String get payOnRequest;

  /// No description provided for @rateOnRequest.
  ///
  /// In en, this message translates to:
  /// **'Rate on request'**
  String get rateOnRequest;

  /// No description provided for @quickActionFindJobsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover roles near you'**
  String get quickActionFindJobsSubtitle;

  /// No description provided for @quickActionMyApplicationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track every application'**
  String get quickActionMyApplicationsSubtitle;

  /// No description provided for @quickActionUpdateProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Improve your visibility & match score'**
  String get quickActionUpdateProfileSubtitle;

  /// No description provided for @quickActionCreatePostSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share your work with the community'**
  String get quickActionCreatePostSubtitle;

  /// No description provided for @quickActionViewInterviewsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Prepare for what\'s next'**
  String get quickActionViewInterviewsSubtitle;

  /// No description provided for @offerLabel.
  ///
  /// In en, this message translates to:
  /// **'Offer'**
  String get offerLabel;

  /// No description provided for @hiringForTemplate.
  ///
  /// In en, this message translates to:
  /// **'Hiring for {role}'**
  String hiringForTemplate(String role);

  /// No description provided for @tapToOpenInMaps.
  ///
  /// In en, this message translates to:
  /// **'Tap to open in Maps'**
  String get tapToOpenInMaps;

  /// No description provided for @alreadyAppliedToJob.
  ///
  /// In en, this message translates to:
  /// **'You have already applied to this job.'**
  String get alreadyAppliedToJob;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get changePhoto;

  /// No description provided for @changeAvatar.
  ///
  /// In en, this message translates to:
  /// **'Change Avatar'**
  String get changeAvatar;

  /// No description provided for @addPhotoAction.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addPhotoAction;

  /// No description provided for @nationalityLabel.
  ///
  /// In en, this message translates to:
  /// **'Nationality'**
  String get nationalityLabel;

  /// No description provided for @targetRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Target Role'**
  String get targetRoleLabel;

  /// No description provided for @salaryExpectationLabel.
  ///
  /// In en, this message translates to:
  /// **'Salary Expectation'**
  String get salaryExpectationLabel;

  /// No description provided for @addLanguageCta.
  ///
  /// In en, this message translates to:
  /// **'+ Add Language'**
  String get addLanguageCta;

  /// No description provided for @experienceLabel.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get experienceLabel;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @zeroHours.
  ///
  /// In en, this message translates to:
  /// **'Zero Hours'**
  String get zeroHours;

  /// No description provided for @checkInterviewDetailsLine.
  ///
  /// In en, this message translates to:
  /// **'Check your interview details'**
  String get checkInterviewDetailsLine;

  /// No description provided for @interviewInvitedSubline.
  ///
  /// In en, this message translates to:
  /// **'The employer wants to interview you — confirm a time'**
  String get interviewInvitedSubline;

  /// No description provided for @shortlistedSubline.
  ///
  /// In en, this message translates to:
  /// **'You made the shortlist — wait for the next step'**
  String get shortlistedSubline;

  /// No description provided for @underReviewSubline.
  ///
  /// In en, this message translates to:
  /// **'Employer is reviewing your profile'**
  String get underReviewSubline;

  /// No description provided for @hiredHeadline.
  ///
  /// In en, this message translates to:
  /// **'Hired'**
  String get hiredHeadline;

  /// No description provided for @hiredSubline.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! You received an offer'**
  String get hiredSubline;

  /// No description provided for @applicationSubmittedHeadline.
  ///
  /// In en, this message translates to:
  /// **'Application Submitted'**
  String get applicationSubmittedHeadline;

  /// No description provided for @applicationSubmittedSubline.
  ///
  /// In en, this message translates to:
  /// **'The employer will review your application'**
  String get applicationSubmittedSubline;

  /// No description provided for @withdrawnHeadline.
  ///
  /// In en, this message translates to:
  /// **'Withdrawn'**
  String get withdrawnHeadline;

  /// No description provided for @withdrawnSubline.
  ///
  /// In en, this message translates to:
  /// **'You have withdrawn this application'**
  String get withdrawnSubline;

  /// No description provided for @notSelectedHeadline.
  ///
  /// In en, this message translates to:
  /// **'Not Selected'**
  String get notSelectedHeadline;

  /// No description provided for @notSelectedSubline.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your interest'**
  String get notSelectedSubline;

  /// No description provided for @jobsFoundCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 job found} other{{count} jobs found}}'**
  String jobsFoundCount(int count);

  /// No description provided for @applicationsTotalCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 total} other{{count} total}}'**
  String applicationsTotalCount(int count);

  /// No description provided for @applicationsInReviewCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 in review} other{{count} in review}}'**
  String applicationsInReviewCount(int count);

  /// No description provided for @applicationsLiveCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 live} other{{count} live}}'**
  String applicationsLiveCount(int count);

  /// No description provided for @interviewsPendingConfirmTime.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 interview pending — confirm a time.} other{{count} interviews pending — confirm a time.}}'**
  String interviewsPendingConfirmTime(int count);

  /// No description provided for @notifInterviewConfirmedTitle.
  ///
  /// In en, this message translates to:
  /// **'Interview Confirmed — {name}'**
  String notifInterviewConfirmedTitle(String name);

  /// No description provided for @notifInterviewRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Interview Request — {name}'**
  String notifInterviewRequestTitle(String name);

  /// No description provided for @notifApplicationUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'Application Update — {name}'**
  String notifApplicationUpdateTitle(String name);

  /// No description provided for @notifOfferReceivedTitle.
  ///
  /// In en, this message translates to:
  /// **'Offer Received — {name}'**
  String notifOfferReceivedTitle(String name);

  /// No description provided for @notifMessageFromTitle.
  ///
  /// In en, this message translates to:
  /// **'Message from — {name}'**
  String notifMessageFromTitle(String name);

  /// No description provided for @notifInterviewReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Interview Reminder — {name}'**
  String notifInterviewReminderTitle(String name);

  /// No description provided for @notifProfileViewedTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile Viewed — {name}'**
  String notifProfileViewedTitle(String name);

  /// No description provided for @notifNewJobMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'New job match — {name}'**
  String notifNewJobMatchTitle(String name);

  /// No description provided for @notifApplicationViewedTitle.
  ///
  /// In en, this message translates to:
  /// **'Application viewed by — {name}'**
  String notifApplicationViewedTitle(String name);

  /// No description provided for @notifShortlistedTitle.
  ///
  /// In en, this message translates to:
  /// **'Shortlisted at — {name}'**
  String notifShortlistedTitle(String name);

  /// No description provided for @notifCompleteProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile for better matches'**
  String get notifCompleteProfile;

  /// No description provided for @notifCompleteBusinessProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete your business profile for better visibility'**
  String get notifCompleteBusinessProfile;

  /// No description provided for @notifNewJobViews.
  ///
  /// In en, this message translates to:
  /// **'Your {role} job has {count} new views'**
  String notifNewJobViews(String role, String count);

  /// No description provided for @notifAppliedForRole.
  ///
  /// In en, this message translates to:
  /// **'{name} applied for {role}'**
  String notifAppliedForRole(String name, String role);

  /// No description provided for @notifNewApplicationNameRole.
  ///
  /// In en, this message translates to:
  /// **'New application: {name} for {role}'**
  String notifNewApplicationNameRole(String name, String role);

  /// No description provided for @chatTyping.
  ///
  /// In en, this message translates to:
  /// **'Typing...'**
  String get chatTyping;

  /// No description provided for @chatStatusSeen.
  ///
  /// In en, this message translates to:
  /// **'Seen'**
  String get chatStatusSeen;

  /// No description provided for @chatStatusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get chatStatusDelivered;

  /// No description provided for @entryTagline.
  ///
  /// In en, this message translates to:
  /// **'The staffing platform for hospitality professionals.'**
  String get entryTagline;

  /// No description provided for @entryFindWork.
  ///
  /// In en, this message translates to:
  /// **'Find Work'**
  String get entryFindWork;

  /// No description provided for @entryFindWorkSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse jobs and get hired by top venues'**
  String get entryFindWorkSubtitle;

  /// No description provided for @entryHireStaff.
  ///
  /// In en, this message translates to:
  /// **'Hire Staff'**
  String get entryHireStaff;

  /// No description provided for @entryHireStaffSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Post jobs and find the best hospitality talent'**
  String get entryHireStaffSubtitle;

  /// No description provided for @entryFindCompanies.
  ///
  /// In en, this message translates to:
  /// **'Find Companies'**
  String get entryFindCompanies;

  /// No description provided for @entryFindCompaniesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover hospitality venues and service providers'**
  String get entryFindCompaniesSubtitle;

  /// No description provided for @servicesEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Looking for Companies'**
  String get servicesEntryTitle;

  /// No description provided for @servicesHospitalityServices.
  ///
  /// In en, this message translates to:
  /// **'Hospitality Services'**
  String get servicesHospitalityServices;

  /// No description provided for @servicesEntrySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Register your service company or find hospitality providers near you'**
  String get servicesEntrySubtitle;

  /// No description provided for @servicesRegisterCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Register as a Business'**
  String get servicesRegisterCardTitle;

  /// No description provided for @servicesRegisterCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'List your hospitality service and get discovered by clients'**
  String get servicesRegisterCardSubtitle;

  /// No description provided for @servicesLookingCardTitle.
  ///
  /// In en, this message translates to:
  /// **'I\'m Looking for a Business'**
  String get servicesLookingCardTitle;

  /// No description provided for @servicesLookingCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find hospitality service providers near you'**
  String get servicesLookingCardSubtitle;

  /// No description provided for @registerBusinessTitle.
  ///
  /// In en, this message translates to:
  /// **'Register Your Business'**
  String get registerBusinessTitle;

  /// No description provided for @enterCompanyName.
  ///
  /// In en, this message translates to:
  /// **'Enter company name'**
  String get enterCompanyName;

  /// No description provided for @subcategoryOptional.
  ///
  /// In en, this message translates to:
  /// **'Subcategory (optional)'**
  String get subcategoryOptional;

  /// No description provided for @subcategoryHintFloristDj.
  ///
  /// In en, this message translates to:
  /// **'e.g. Florist, DJ Services'**
  String get subcategoryHintFloristDj;

  /// No description provided for @searchCompaniesHint.
  ///
  /// In en, this message translates to:
  /// **'Search companies...'**
  String get searchCompaniesHint;

  /// No description provided for @browseCategories.
  ///
  /// In en, this message translates to:
  /// **'Browse Categories'**
  String get browseCategories;

  /// No description provided for @companiesFoundCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 company found} other{{count} companies found}}'**
  String companiesFoundCount(int count);

  /// No description provided for @serviceCategoryFoodBeverage.
  ///
  /// In en, this message translates to:
  /// **'Food & Beverage Suppliers'**
  String get serviceCategoryFoodBeverage;

  /// No description provided for @serviceCategoryEventServices.
  ///
  /// In en, this message translates to:
  /// **'Event Services'**
  String get serviceCategoryEventServices;

  /// No description provided for @serviceCategoryDecorDesign.
  ///
  /// In en, this message translates to:
  /// **'Decor & Design'**
  String get serviceCategoryDecorDesign;

  /// No description provided for @serviceCategoryEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get serviceCategoryEntertainment;

  /// No description provided for @serviceCategoryEquipmentOps.
  ///
  /// In en, this message translates to:
  /// **'Equipment & Operations'**
  String get serviceCategoryEquipmentOps;

  /// No description provided for @serviceCategoryCleaningMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Cleaning & Maintenance'**
  String get serviceCategoryCleaningMaintenance;

  /// No description provided for @distanceMiles.
  ///
  /// In en, this message translates to:
  /// **'{value} mi'**
  String distanceMiles(String value);

  /// No description provided for @distanceKilometers.
  ///
  /// In en, this message translates to:
  /// **'{value} km'**
  String distanceKilometers(String value);

  /// No description provided for @postDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get postDetailTitle;

  /// No description provided for @likeAction.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get likeAction;

  /// No description provided for @commentAction.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get commentAction;

  /// No description provided for @saveActionLabel.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveActionLabel;

  /// No description provided for @commentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get commentsTitle;

  /// No description provided for @addCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Add a comment…'**
  String get addCommentHint;

  /// No description provided for @likesCount.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{1 like}other{{count} likes}}'**
  String likesCount(int count);

  /// No description provided for @commentsCount.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{1 comment}other{{count} comments}}'**
  String commentsCount(int count);

  /// No description provided for @savesCount.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{1 save}other{{count} saves}}'**
  String savesCount(int count);

  /// No description provided for @timeAgoMinutesShort.
  ///
  /// In en, this message translates to:
  /// **'{count}m'**
  String timeAgoMinutesShort(int count);

  /// No description provided for @timeAgoHoursShort.
  ///
  /// In en, this message translates to:
  /// **'{count}h'**
  String timeAgoHoursShort(int count);

  /// No description provided for @timeAgoDaysShort.
  ///
  /// In en, this message translates to:
  /// **'{count}d'**
  String timeAgoDaysShort(int count);

  /// No description provided for @timeAgoNow.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get timeAgoNow;

  /// No description provided for @activityTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activityTitle;

  /// No description provided for @activityLikedPost.
  ///
  /// In en, this message translates to:
  /// **'liked your post'**
  String get activityLikedPost;

  /// No description provided for @activityCommented.
  ///
  /// In en, this message translates to:
  /// **'commented on your post'**
  String get activityCommented;

  /// No description provided for @activityStartedFollowing.
  ///
  /// In en, this message translates to:
  /// **'started following you'**
  String get activityStartedFollowing;

  /// No description provided for @activityMentioned.
  ///
  /// In en, this message translates to:
  /// **'mentioned you'**
  String get activityMentioned;

  /// No description provided for @activitySystemUpdate.
  ///
  /// In en, this message translates to:
  /// **'sent you an update'**
  String get activitySystemUpdate;

  /// No description provided for @noActivityYetDesc.
  ///
  /// In en, this message translates to:
  /// **'When people like, comment, or follow you, it will show here.'**
  String get noActivityYetDesc;

  /// No description provided for @activeStatus.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeStatus;

  /// No description provided for @activeBadge.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get activeBadge;

  /// No description provided for @nextRenewalLabel.
  ///
  /// In en, this message translates to:
  /// **'Next renewal'**
  String get nextRenewalLabel;

  /// No description provided for @startedLabel.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get startedLabel;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// No description provided for @billingAndCancellation.
  ///
  /// In en, this message translates to:
  /// **'Billing & cancellation'**
  String get billingAndCancellation;

  /// No description provided for @billingAndCancellationCopy.
  ///
  /// In en, this message translates to:
  /// **'Your subscription is billed through your App Store / Google Play account. You can cancel anytime from your device Settings — you keep premium access until the renewal date.'**
  String get billingAndCancellationCopy;

  /// No description provided for @premiumIsActive.
  ///
  /// In en, this message translates to:
  /// **'Premium is active'**
  String get premiumIsActive;

  /// No description provided for @premiumThanksCopy.
  ///
  /// In en, this message translates to:
  /// **'Thanks for supporting Plagit. You have full access to every premium feature.'**
  String get premiumThanksCopy;

  /// No description provided for @manageSubscription.
  ///
  /// In en, this message translates to:
  /// **'Manage Subscription'**
  String get manageSubscription;

  /// No description provided for @candidatePremiumPlanName.
  ///
  /// In en, this message translates to:
  /// **'Candidate Premium'**
  String get candidatePremiumPlanName;

  /// No description provided for @renewsOnDate.
  ///
  /// In en, this message translates to:
  /// **'Renews on {date}'**
  String renewsOnDate(String date);

  /// No description provided for @fullViewerAccessLine.
  ///
  /// In en, this message translates to:
  /// **'Full viewer access · all insights unlocked'**
  String get fullViewerAccessLine;

  /// No description provided for @premiumActiveBadge.
  ///
  /// In en, this message translates to:
  /// **'Premium active'**
  String get premiumActiveBadge;

  /// No description provided for @fullInsightsUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Full insights and viewer details unlocked.'**
  String get fullInsightsUnlocked;

  /// No description provided for @noViewersInCategory.
  ///
  /// In en, this message translates to:
  /// **'No viewers in this category yet'**
  String get noViewersInCategory;

  /// No description provided for @onlyVerifiedViewersShown.
  ///
  /// In en, this message translates to:
  /// **'Only verified viewers with public profiles are shown.'**
  String get onlyVerifiedViewersShown;

  /// No description provided for @notEnoughDataYet.
  ///
  /// In en, this message translates to:
  /// **'Not enough data yet.'**
  String get notEnoughDataYet;

  /// No description provided for @noViewInsightsYet.
  ///
  /// In en, this message translates to:
  /// **'No view insights yet'**
  String get noViewInsightsYet;

  /// No description provided for @noViewInsightsDesc.
  ///
  /// In en, this message translates to:
  /// **'Insights will appear once your post gets more views.'**
  String get noViewInsightsDesc;

  /// No description provided for @suspiciousEngagementDetected.
  ///
  /// In en, this message translates to:
  /// **'Suspicious engagement detected'**
  String get suspiciousEngagementDetected;

  /// No description provided for @patternReviewRequired.
  ///
  /// In en, this message translates to:
  /// **'Pattern review required'**
  String get patternReviewRequired;

  /// No description provided for @adminInsightsFooter.
  ///
  /// In en, this message translates to:
  /// **'Admin view — same insights the author sees, plus moderation flags. Aggregated only, no individual viewer identity is exposed.'**
  String get adminInsightsFooter;

  /// No description provided for @viewerKindBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get viewerKindBusiness;

  /// No description provided for @viewerKindCandidate.
  ///
  /// In en, this message translates to:
  /// **'Candidate'**
  String get viewerKindCandidate;

  /// No description provided for @viewerKindRecruiter.
  ///
  /// In en, this message translates to:
  /// **'Recruiter'**
  String get viewerKindRecruiter;

  /// No description provided for @viewerKindHiringManager.
  ///
  /// In en, this message translates to:
  /// **'Hiring Manager'**
  String get viewerKindHiringManager;

  /// No description provided for @viewerKindBusinessesPlural.
  ///
  /// In en, this message translates to:
  /// **'Businesses'**
  String get viewerKindBusinessesPlural;

  /// No description provided for @viewerKindCandidatesPlural.
  ///
  /// In en, this message translates to:
  /// **'Candidates'**
  String get viewerKindCandidatesPlural;

  /// No description provided for @viewerKindRecruitersPlural.
  ///
  /// In en, this message translates to:
  /// **'Recruiters'**
  String get viewerKindRecruitersPlural;

  /// No description provided for @viewerKindHiringManagersPlural.
  ///
  /// In en, this message translates to:
  /// **'Hiring Managers'**
  String get viewerKindHiringManagersPlural;

  /// No description provided for @searchPeoplePostsVenuesHint.
  ///
  /// In en, this message translates to:
  /// **'Search people, posts, venues…'**
  String get searchPeoplePostsVenuesHint;

  /// No description provided for @searchCommunityTitle.
  ///
  /// In en, this message translates to:
  /// **'Search Community'**
  String get searchCommunityTitle;

  /// No description provided for @roleSommelier.
  ///
  /// In en, this message translates to:
  /// **'Sommelier'**
  String get roleSommelier;

  /// No description provided for @candidatePremiumActivated.
  ///
  /// In en, this message translates to:
  /// **'You are now Candidate Premium'**
  String get candidatePremiumActivated;

  /// No description provided for @purchasesRestoredPremium.
  ///
  /// In en, this message translates to:
  /// **'Purchases restored — you are now Candidate Premium'**
  String get purchasesRestoredPremium;

  /// No description provided for @nothingToRestore.
  ///
  /// In en, this message translates to:
  /// **'Nothing to restore'**
  String get nothingToRestore;

  /// No description provided for @noValidSubscriptionPremiumRemoved.
  ///
  /// In en, this message translates to:
  /// **'No valid subscription found — premium access removed'**
  String get noValidSubscriptionPremiumRemoved;

  /// No description provided for @restoreFailedWithError.
  ///
  /// In en, this message translates to:
  /// **'Restore failed. {error}'**
  String restoreFailedWithError(String error);

  /// No description provided for @subscriptionTitleAnnual.
  ///
  /// In en, this message translates to:
  /// **'Candidate Premium · Annual'**
  String get subscriptionTitleAnnual;

  /// No description provided for @subscriptionTitleMonthly.
  ///
  /// In en, this message translates to:
  /// **'Candidate Premium · Monthly'**
  String get subscriptionTitleMonthly;

  /// No description provided for @pricePerYearSlash.
  ///
  /// In en, this message translates to:
  /// **'{price} / year'**
  String pricePerYearSlash(String price);

  /// No description provided for @pricePerMonthSlash.
  ///
  /// In en, this message translates to:
  /// **'{price} / month'**
  String pricePerMonthSlash(String price);

  /// No description provided for @nearbyJobsTitle.
  ///
  /// In en, this message translates to:
  /// **'Nearby Jobs'**
  String get nearbyJobsTitle;

  /// No description provided for @expandRadius.
  ///
  /// In en, this message translates to:
  /// **'Expand Radius'**
  String get expandRadius;

  /// No description provided for @noJobsInRadius.
  ///
  /// In en, this message translates to:
  /// **'No jobs in this radius'**
  String get noJobsInRadius;

  /// No description provided for @jobsWithinRadius.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 job within {radius} miles} other{{count} jobs within {radius} miles}}'**
  String jobsWithinRadius(int count, int radius);

  /// No description provided for @interviewAcceptedSnack.
  ///
  /// In en, this message translates to:
  /// **'Interview accepted!'**
  String get interviewAcceptedSnack;

  /// No description provided for @declineInterviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Decline Interview'**
  String get declineInterviewTitle;

  /// No description provided for @declineInterviewConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to decline this interview?'**
  String get declineInterviewConfirm;

  /// No description provided for @addedToCalendar.
  ///
  /// In en, this message translates to:
  /// **'Added to calendar'**
  String get addedToCalendar;

  /// No description provided for @removeCompanyTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove?'**
  String get removeCompanyTitle;

  /// No description provided for @removeCompanyConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this company from your saved list?'**
  String get removeCompanyConfirm;

  /// No description provided for @signOutAllRolesConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out of all roles?'**
  String get signOutAllRolesConfirm;

  /// No description provided for @tapToViewAllConversations.
  ///
  /// In en, this message translates to:
  /// **'Tap to view all conversations'**
  String get tapToViewAllConversations;

  /// No description provided for @savedJobsTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved Jobs'**
  String get savedJobsTitle;

  /// No description provided for @savedJobsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 saved job} other{{count} saved jobs}}'**
  String savedJobsCount(int count);

  /// No description provided for @removeFromSavedTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove from saved?'**
  String get removeFromSavedTitle;

  /// No description provided for @removeFromSavedConfirm.
  ///
  /// In en, this message translates to:
  /// **'This job will be removed from your saved list.'**
  String get removeFromSavedConfirm;

  /// No description provided for @noSavedJobsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse jobs and save the ones you like'**
  String get noSavedJobsSubtitle;

  /// No description provided for @browseJobsAction.
  ///
  /// In en, this message translates to:
  /// **'Browse Jobs'**
  String get browseJobsAction;

  /// No description provided for @matchingJobsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 matching job} other{{count} matching jobs}}'**
  String matchingJobsCount(int count);

  /// No description provided for @savedPostsTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved Posts'**
  String get savedPostsTitle;

  /// No description provided for @searchSavedPostsHint.
  ///
  /// In en, this message translates to:
  /// **'Search saved posts…'**
  String get searchSavedPostsHint;

  /// No description provided for @skipAction.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipAction;

  /// No description provided for @submitAction.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submitAction;

  /// No description provided for @doneAction.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneAction;

  /// No description provided for @resetYourPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get resetYourPasswordTitle;

  /// No description provided for @enterEmailForResetCode.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to receive a reset code'**
  String get enterEmailForResetCode;

  /// No description provided for @sendResetCode.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Code'**
  String get sendResetCode;

  /// No description provided for @enterResetCode.
  ///
  /// In en, this message translates to:
  /// **'Enter reset code'**
  String get enterResetCode;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resendCode;

  /// No description provided for @passwordResetComplete.
  ///
  /// In en, this message translates to:
  /// **'Password reset complete'**
  String get passwordResetComplete;

  /// No description provided for @backToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to Sign In'**
  String get backToSignIn;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password Changed'**
  String get passwordChanged;

  /// No description provided for @passwordUpdatedShort.
  ///
  /// In en, this message translates to:
  /// **'Your password has been successfully updated.'**
  String get passwordUpdatedShort;

  /// No description provided for @passwordUpdatedRelogin.
  ///
  /// In en, this message translates to:
  /// **'Your password has been updated. Please log in again with your new password.'**
  String get passwordUpdatedRelogin;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get updatePassword;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordTitle;

  /// No description provided for @passwordRequirements.
  ///
  /// In en, this message translates to:
  /// **'Password Requirements'**
  String get passwordRequirements;

  /// No description provided for @newPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'New Password (min 8 characters)'**
  String get newPasswordHint;

  /// No description provided for @confirmPasswordField.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordField;

  /// No description provided for @enterEmailField.
  ///
  /// In en, this message translates to:
  /// **'Enter email'**
  String get enterEmailField;

  /// No description provided for @enterPasswordField.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get enterPasswordField;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcomeBack;

  /// No description provided for @selectHowToUse.
  ///
  /// In en, this message translates to:
  /// **'Select how you want to use Plagit today'**
  String get selectHowToUse;

  /// No description provided for @continueAsCandidate.
  ///
  /// In en, this message translates to:
  /// **'Continue as Candidate'**
  String get continueAsCandidate;

  /// No description provided for @continueAsBusiness.
  ///
  /// In en, this message translates to:
  /// **'Continue as Business'**
  String get continueAsBusiness;

  /// No description provided for @signInToPlagit.
  ///
  /// In en, this message translates to:
  /// **'Sign In to Plagit'**
  String get signInToPlagit;

  /// No description provided for @enterCredentials.
  ///
  /// In en, this message translates to:
  /// **'Enter your credentials to continue'**
  String get enterCredentials;

  /// No description provided for @adminPortal.
  ///
  /// In en, this message translates to:
  /// **'Admin Portal'**
  String get adminPortal;

  /// No description provided for @plagitAdmin.
  ///
  /// In en, this message translates to:
  /// **'Plagit Admin'**
  String get plagitAdmin;

  /// No description provided for @signInToAdminAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your admin account'**
  String get signInToAdminAccount;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @searchJobsRolesRestaurantsHint.
  ///
  /// In en, this message translates to:
  /// **'Search jobs, roles, restaurants...'**
  String get searchJobsRolesRestaurantsHint;

  /// No description provided for @exploreNearbyJobs.
  ///
  /// In en, this message translates to:
  /// **'Explore Nearby Jobs'**
  String get exploreNearbyJobs;

  /// No description provided for @findOpportunitiesOnMap.
  ///
  /// In en, this message translates to:
  /// **'Find opportunities on the map around you'**
  String get findOpportunitiesOnMap;

  /// No description provided for @featuredJobs.
  ///
  /// In en, this message translates to:
  /// **'Featured Jobs'**
  String get featuredJobs;

  /// No description provided for @jobsNearYou.
  ///
  /// In en, this message translates to:
  /// **'Jobs Near You'**
  String get jobsNearYou;

  /// No description provided for @jobsMatchingRoleType.
  ///
  /// In en, this message translates to:
  /// **'Jobs matching your role and job type'**
  String get jobsMatchingRoleType;

  /// No description provided for @availableNow.
  ///
  /// In en, this message translates to:
  /// **'Available Now'**
  String get availableNow;

  /// No description provided for @noNearbyJobsYet.
  ///
  /// In en, this message translates to:
  /// **'No nearby jobs yet'**
  String get noNearbyJobsYet;

  /// No description provided for @tryIncreasingRadius.
  ///
  /// In en, this message translates to:
  /// **'Try increasing the radius or changing filters'**
  String get tryIncreasingRadius;

  /// No description provided for @checkBackForOpportunities.
  ///
  /// In en, this message translates to:
  /// **'Check back soon for new opportunities'**
  String get checkBackForOpportunities;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @okAction.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get okAction;

  /// No description provided for @onlineNow.
  ///
  /// In en, this message translates to:
  /// **'Online now'**
  String get onlineNow;

  /// No description provided for @businessUpper.
  ///
  /// In en, this message translates to:
  /// **'BUSINESS'**
  String get businessUpper;

  /// No description provided for @waitingForBusinessFirstMessage.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the business to send the first message'**
  String get waitingForBusinessFirstMessage;

  /// No description provided for @whenEmployersMessageYou.
  ///
  /// In en, this message translates to:
  /// **'When employers message you, they\'ll appear here.'**
  String get whenEmployersMessageYou;

  /// No description provided for @replyToCandidate.
  ///
  /// In en, this message translates to:
  /// **'Reply to candidate…'**
  String get replyToCandidate;

  /// No description provided for @quickFeedback.
  ///
  /// In en, this message translates to:
  /// **'Quick Feedback'**
  String get quickFeedback;

  /// No description provided for @helpImproveMatches.
  ///
  /// In en, this message translates to:
  /// **'Help us improve your matches'**
  String get helpImproveMatches;

  /// No description provided for @thanksForFeedback.
  ///
  /// In en, this message translates to:
  /// **'Thanks for your feedback!'**
  String get thanksForFeedback;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @privacyAndSecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacyAndSecurity;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// No description provided for @activeRoleUpper.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE ROLE'**
  String get activeRoleUpper;

  /// No description provided for @meetingLink.
  ///
  /// In en, this message translates to:
  /// **'Meeting Link'**
  String get meetingLink;

  /// No description provided for @joinMeeting2.
  ///
  /// In en, this message translates to:
  /// **'Join meeting'**
  String get joinMeeting2;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @completeBusinessProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete your business profile'**
  String get completeBusinessProfileTitle;

  /// No description provided for @businessDescription.
  ///
  /// In en, this message translates to:
  /// **'Business description'**
  String get businessDescription;

  /// No description provided for @finishSetupAction.
  ///
  /// In en, this message translates to:
  /// **'Finish Setup'**
  String get finishSetupAction;

  /// No description provided for @describeBusinessHintLong.
  ///
  /// In en, this message translates to:
  /// **'Describe your business, culture, and what makes it a great place to work... (min 150 characters suggested)'**
  String get describeBusinessHintLong;

  /// No description provided for @describeBusinessHintShort.
  ///
  /// In en, this message translates to:
  /// **'Describe your business...'**
  String get describeBusinessHintShort;

  /// No description provided for @writeShortIntroAboutYourself.
  ///
  /// In en, this message translates to:
  /// **'Write a short intro about yourself...'**
  String get writeShortIntroAboutYourself;

  /// No description provided for @createBusinessAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Business Account'**
  String get createBusinessAccountTitle;

  /// No description provided for @businessDetailsSection.
  ///
  /// In en, this message translates to:
  /// **'Business Details'**
  String get businessDetailsSection;

  /// No description provided for @openToInternationalCandidates.
  ///
  /// In en, this message translates to:
  /// **'Open to international candidates'**
  String get openToInternationalCandidates;

  /// No description provided for @createAccountShort.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountShort;

  /// No description provided for @yourDetailsSection.
  ///
  /// In en, this message translates to:
  /// **'Your Details'**
  String get yourDetailsSection;

  /// No description provided for @jobTypeField.
  ///
  /// In en, this message translates to:
  /// **'Job Type'**
  String get jobTypeField;

  /// No description provided for @communityFeed.
  ///
  /// In en, this message translates to:
  /// **'Community Feed'**
  String get communityFeed;

  /// No description provided for @postPublished.
  ///
  /// In en, this message translates to:
  /// **'Post published'**
  String get postPublished;

  /// No description provided for @postHidden.
  ///
  /// In en, this message translates to:
  /// **'Post hidden'**
  String get postHidden;

  /// No description provided for @postReportedReview.
  ///
  /// In en, this message translates to:
  /// **'Post reported — admin will review'**
  String get postReportedReview;

  /// No description provided for @postNotFound.
  ///
  /// In en, this message translates to:
  /// **'Post not found'**
  String get postNotFound;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get goBack;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get linkCopied;

  /// No description provided for @removedFromSaved.
  ///
  /// In en, this message translates to:
  /// **'Removed from saved'**
  String get removedFromSaved;

  /// No description provided for @noPostsFound.
  ///
  /// In en, this message translates to:
  /// **'No posts found'**
  String get noPostsFound;

  /// No description provided for @tipsStoriesAdvice.
  ///
  /// In en, this message translates to:
  /// **'Tips, stories, and advice from hospitality professionals'**
  String get tipsStoriesAdvice;

  /// No description provided for @searchTalentPostsRolesHint.
  ///
  /// In en, this message translates to:
  /// **'Search talent, posts, roles…'**
  String get searchTalentPostsRolesHint;

  /// No description provided for @videoAttachmentsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Video attachments coming soon'**
  String get videoAttachmentsComingSoon;

  /// No description provided for @locationTaggingComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Location tagging coming soon'**
  String get locationTaggingComingSoon;

  /// No description provided for @fullImageViewerComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Full image viewer coming soon'**
  String get fullImageViewerComingSoon;

  /// No description provided for @shareComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Share coming soon'**
  String get shareComingSoon;

  /// No description provided for @findServices.
  ///
  /// In en, this message translates to:
  /// **'Find Services'**
  String get findServices;

  /// No description provided for @findHospitalityServices.
  ///
  /// In en, this message translates to:
  /// **'Find Hospitality Services'**
  String get findHospitalityServices;

  /// No description provided for @browseServices.
  ///
  /// In en, this message translates to:
  /// **'Browse Services'**
  String get browseServices;

  /// No description provided for @searchServicesCompaniesLocationsHint.
  ///
  /// In en, this message translates to:
  /// **'Search services, companies, locations...'**
  String get searchServicesCompaniesLocationsHint;

  /// No description provided for @searchCompaniesServicesLocationsHint.
  ///
  /// In en, this message translates to:
  /// **'Search companies, services, locations...'**
  String get searchCompaniesServicesLocationsHint;

  /// No description provided for @nearbyCompanies.
  ///
  /// In en, this message translates to:
  /// **'Nearby Companies'**
  String get nearbyCompanies;

  /// No description provided for @nearYou.
  ///
  /// In en, this message translates to:
  /// **'Near You'**
  String get nearYou;

  /// No description provided for @listLabel.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get listLabel;

  /// No description provided for @mapViewLabel.
  ///
  /// In en, this message translates to:
  /// **'Map view'**
  String get mapViewLabel;

  /// No description provided for @noServicesFound.
  ///
  /// In en, this message translates to:
  /// **'No services found'**
  String get noServicesFound;

  /// No description provided for @noCompaniesFoundNearby.
  ///
  /// In en, this message translates to:
  /// **'No companies found nearby'**
  String get noCompaniesFoundNearby;

  /// No description provided for @noSavedCompanies.
  ///
  /// In en, this message translates to:
  /// **'No saved companies'**
  String get noSavedCompanies;

  /// No description provided for @savedCompaniesTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved Companies'**
  String get savedCompaniesTitle;

  /// No description provided for @saveCompaniesForLater.
  ///
  /// In en, this message translates to:
  /// **'Save companies you like to find them easily later'**
  String get saveCompaniesForLater;

  /// No description provided for @latestUpdates.
  ///
  /// In en, this message translates to:
  /// **'Latest Updates'**
  String get latestUpdates;

  /// No description provided for @noPromotions.
  ///
  /// In en, this message translates to:
  /// **'No promotions'**
  String get noPromotions;

  /// No description provided for @companyHasNoPromotions.
  ///
  /// In en, this message translates to:
  /// **'This company has no active promotions.'**
  String get companyHasNoPromotions;

  /// No description provided for @companyHasNoUpdates.
  ///
  /// In en, this message translates to:
  /// **'This company has not posted any updates.'**
  String get companyHasNoUpdates;

  /// No description provided for @promotionsAndOffers.
  ///
  /// In en, this message translates to:
  /// **'Promotions & Offers'**
  String get promotionsAndOffers;

  /// No description provided for @promotionNotFound.
  ///
  /// In en, this message translates to:
  /// **'Promotion not found'**
  String get promotionNotFound;

  /// No description provided for @promotionDetails.
  ///
  /// In en, this message translates to:
  /// **'Promotion Details'**
  String get promotionDetails;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsAndConditions;

  /// No description provided for @relatedPosts.
  ///
  /// In en, this message translates to:
  /// **'Related Posts'**
  String get relatedPosts;

  /// No description provided for @viewOffer.
  ///
  /// In en, this message translates to:
  /// **'View Offer'**
  String get viewOffer;

  /// No description provided for @offerBadge.
  ///
  /// In en, this message translates to:
  /// **'OFFER'**
  String get offerBadge;

  /// No description provided for @requestQuote.
  ///
  /// In en, this message translates to:
  /// **'Request Quote'**
  String get requestQuote;

  /// No description provided for @sendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send Request'**
  String get sendRequest;

  /// No description provided for @quoteRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Quote request sent!'**
  String get quoteRequestSent;

  /// No description provided for @inquiry.
  ///
  /// In en, this message translates to:
  /// **'Inquiry'**
  String get inquiry;

  /// No description provided for @dateNeeded.
  ///
  /// In en, this message translates to:
  /// **'Date Needed'**
  String get dateNeeded;

  /// No description provided for @serviceType.
  ///
  /// In en, this message translates to:
  /// **'Service Type'**
  String get serviceType;

  /// No description provided for @serviceArea.
  ///
  /// In en, this message translates to:
  /// **'Service Area'**
  String get serviceArea;

  /// No description provided for @servicesOffered.
  ///
  /// In en, this message translates to:
  /// **'Services Offered'**
  String get servicesOffered;

  /// No description provided for @servicesLabel.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get servicesLabel;

  /// No description provided for @servicePlans.
  ///
  /// In en, this message translates to:
  /// **'Service Plans'**
  String get servicePlans;

  /// No description provided for @growYourServiceBusiness.
  ///
  /// In en, this message translates to:
  /// **'Grow Your Service Business'**
  String get growYourServiceBusiness;

  /// No description provided for @getDiscoveredPremium.
  ///
  /// In en, this message translates to:
  /// **'Get discovered by more clients with a premium listing.'**
  String get getDiscoveredPremium;

  /// No description provided for @unlockPremium.
  ///
  /// In en, this message translates to:
  /// **'Unlock Premium'**
  String get unlockPremium;

  /// No description provided for @getMoreVisibility.
  ///
  /// In en, this message translates to:
  /// **'Get more visibility and better matches'**
  String get getMoreVisibility;

  /// No description provided for @plagitPremiumUpper.
  ///
  /// In en, this message translates to:
  /// **'PLAGIT PREMIUM'**
  String get plagitPremiumUpper;

  /// No description provided for @premiumOnly.
  ///
  /// In en, this message translates to:
  /// **'Premium Only'**
  String get premiumOnly;

  /// No description provided for @savePercent17.
  ///
  /// In en, this message translates to:
  /// **'Save 17%'**
  String get savePercent17;

  /// No description provided for @registerBusinessCta.
  ///
  /// In en, this message translates to:
  /// **'Register Business'**
  String get registerBusinessCta;

  /// No description provided for @registrationSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Registration Submitted'**
  String get registrationSubmitted;

  /// No description provided for @serviceDescription.
  ///
  /// In en, this message translates to:
  /// **'Service Description'**
  String get serviceDescription;

  /// No description provided for @describeServicesHint.
  ///
  /// In en, this message translates to:
  /// **'Describe your services, experience, and what makes you stand out...'**
  String get describeServicesHint;

  /// No description provided for @websiteOptional.
  ///
  /// In en, this message translates to:
  /// **'Website (optional)'**
  String get websiteOptional;

  /// No description provided for @viewCompanyProfileCta.
  ///
  /// In en, this message translates to:
  /// **'View Company Profile'**
  String get viewCompanyProfileCta;

  /// No description provided for @contactCompany.
  ///
  /// In en, this message translates to:
  /// **'Contact Company'**
  String get contactCompany;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @yourLocation.
  ///
  /// In en, this message translates to:
  /// **'Your location'**
  String get yourLocation;

  /// No description provided for @enterYourCity.
  ///
  /// In en, this message translates to:
  /// **'Enter your city'**
  String get enterYourCity;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// No description provided for @tryDifferentSearchTerm.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get tryDifferentSearchTerm;

  /// No description provided for @tryDifferentOrAdjust.
  ///
  /// In en, this message translates to:
  /// **'Try a different search, category, or adjust your filters.'**
  String get tryDifferentOrAdjust;

  /// No description provided for @noPostsYetCompany.
  ///
  /// In en, this message translates to:
  /// **'No posts yet'**
  String get noPostsYetCompany;

  /// No description provided for @requestQuoteFromCompany.
  ///
  /// In en, this message translates to:
  /// **'Request a Quote from {companyName}'**
  String requestQuoteFromCompany(String companyName);

  /// No description provided for @validUntilDate.
  ///
  /// In en, this message translates to:
  /// **'Valid until {validUntil}'**
  String validUntilDate(String validUntil);

  /// No description provided for @employerCheckingProfile.
  ///
  /// In en, this message translates to:
  /// **'An employer is checking your profile right now'**
  String get employerCheckingProfile;

  /// No description provided for @profileStrengthPercent.
  ///
  /// In en, this message translates to:
  /// **'Your profile is {percent}% complete'**
  String profileStrengthPercent(int percent);

  /// No description provided for @profileGetsMoreViews.
  ///
  /// In en, this message translates to:
  /// **'A complete profile gets 3× more views'**
  String get profileGetsMoreViews;

  /// No description provided for @applicationUpdate.
  ///
  /// In en, this message translates to:
  /// **'Application Update'**
  String get applicationUpdate;

  /// findJobsAndApply
  ///
  /// In en, this message translates to:
  /// **'Find jobs and apply'**
  String get findJobsAndApply;

  /// manageJobsAndHiring
  ///
  /// In en, this message translates to:
  /// **'Manage jobs and hiring'**
  String get manageJobsAndHiring;

  /// managePlatform
  ///
  /// In en, this message translates to:
  /// **'Manage platform'**
  String get managePlatform;

  /// findHospitalityCompanies
  ///
  /// In en, this message translates to:
  /// **'Find hospitality companies'**
  String get findHospitalityCompanies;

  /// candidateMessages
  ///
  /// In en, this message translates to:
  /// **'CANDIDATE MESSAGES'**
  String get candidateMessages;

  /// businessMessages
  ///
  /// In en, this message translates to:
  /// **'BUSINESS MESSAGES'**
  String get businessMessages;

  /// serviceInquiries
  ///
  /// In en, this message translates to:
  /// **'SERVICE INQUIRIES'**
  String get serviceInquiries;

  /// acceptInterview
  ///
  /// In en, this message translates to:
  /// **'Accept Interview'**
  String get acceptInterview;

  /// adminMenuDashboard
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get adminMenuDashboard;

  /// adminMenuUsers
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get adminMenuUsers;

  /// adminMenuCandidates
  ///
  /// In en, this message translates to:
  /// **'Candidates'**
  String get adminMenuCandidates;

  /// adminMenuBusinesses
  ///
  /// In en, this message translates to:
  /// **'Businesses'**
  String get adminMenuBusinesses;

  /// adminMenuJobs
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get adminMenuJobs;

  /// adminMenuApplications
  ///
  /// In en, this message translates to:
  /// **'Applications'**
  String get adminMenuApplications;

  /// adminMenuBookings
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get adminMenuBookings;

  /// adminMenuPayments
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get adminMenuPayments;

  /// adminMenuMessages
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get adminMenuMessages;

  /// adminMenuNotifications
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get adminMenuNotifications;

  /// adminMenuReports
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get adminMenuReports;

  /// adminMenuAnalytics
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get adminMenuAnalytics;

  /// adminMenuSettings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get adminMenuSettings;

  /// adminMenuSupport
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get adminMenuSupport;

  /// adminMenuModeration
  ///
  /// In en, this message translates to:
  /// **'Moderation'**
  String get adminMenuModeration;

  /// adminMenuRoles
  ///
  /// In en, this message translates to:
  /// **'Roles'**
  String get adminMenuRoles;

  /// adminMenuInvoices
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get adminMenuInvoices;

  /// adminMenuLogs
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get adminMenuLogs;

  /// adminMenuIntegrations
  ///
  /// In en, this message translates to:
  /// **'Integrations'**
  String get adminMenuIntegrations;

  /// adminMenuLogout
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get adminMenuLogout;

  /// adminActionApprove
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get adminActionApprove;

  /// adminActionReject
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get adminActionReject;

  /// adminActionSuspend
  ///
  /// In en, this message translates to:
  /// **'Suspend'**
  String get adminActionSuspend;

  /// adminActionActivate
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get adminActionActivate;

  /// adminActionDelete
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get adminActionDelete;

  /// adminActionExport
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get adminActionExport;

  /// adminSectionOverview
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get adminSectionOverview;

  /// adminSectionManagement
  ///
  /// In en, this message translates to:
  /// **'Management'**
  String get adminSectionManagement;

  /// adminSectionFinance
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get adminSectionFinance;

  /// adminSectionOperations
  ///
  /// In en, this message translates to:
  /// **'Operations'**
  String get adminSectionOperations;

  /// adminSectionSystem
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get adminSectionSystem;

  /// adminStatTotalUsers
  ///
  /// In en, this message translates to:
  /// **'Total Users'**
  String get adminStatTotalUsers;

  /// adminStatActiveJobs
  ///
  /// In en, this message translates to:
  /// **'Active Jobs'**
  String get adminStatActiveJobs;

  /// adminStatPendingApprovals
  ///
  /// In en, this message translates to:
  /// **'Pending Approvals'**
  String get adminStatPendingApprovals;

  /// adminStatRevenue
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get adminStatRevenue;

  /// adminStatBookingsToday
  ///
  /// In en, this message translates to:
  /// **'Bookings Today'**
  String get adminStatBookingsToday;

  /// adminStatNewSignups
  ///
  /// In en, this message translates to:
  /// **'New Signups'**
  String get adminStatNewSignups;

  /// adminStatConversionRate
  ///
  /// In en, this message translates to:
  /// **'Conversion Rate'**
  String get adminStatConversionRate;

  /// adminMiscWelcome
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get adminMiscWelcome;

  /// adminMiscLoading
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get adminMiscLoading;

  /// adminMiscNoData
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get adminMiscNoData;

  /// adminMiscSearchPlaceholder
  ///
  /// In en, this message translates to:
  /// **'Search…'**
  String get adminMiscSearchPlaceholder;

  /// adminMenuContent
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get adminMenuContent;

  /// adminMenuMore
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get adminMenuMore;

  /// adminMenuVerifications
  ///
  /// In en, this message translates to:
  /// **'Verifications'**
  String get adminMenuVerifications;

  /// adminMenuSubscriptions
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get adminMenuSubscriptions;

  /// adminMenuCommunity
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get adminMenuCommunity;

  /// adminMenuInterviews
  ///
  /// In en, this message translates to:
  /// **'Interviews'**
  String get adminMenuInterviews;

  /// adminMenuMatches
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get adminMenuMatches;

  /// adminMenuFeaturedContent
  ///
  /// In en, this message translates to:
  /// **'Featured Content'**
  String get adminMenuFeaturedContent;

  /// adminMenuAuditLog
  ///
  /// In en, this message translates to:
  /// **'Audit Log'**
  String get adminMenuAuditLog;

  /// adminMenuChangePassword
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get adminMenuChangePassword;

  /// adminSectionPeople
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get adminSectionPeople;

  /// adminSectionHiring
  ///
  /// In en, this message translates to:
  /// **'Hiring Operations'**
  String get adminSectionHiring;

  /// adminSectionContentComm
  ///
  /// In en, this message translates to:
  /// **'Content & Communication'**
  String get adminSectionContentComm;

  /// adminSectionRevenue
  ///
  /// In en, this message translates to:
  /// **'Business & Revenue'**
  String get adminSectionRevenue;

  /// adminSectionToolsContent
  ///
  /// In en, this message translates to:
  /// **'Tools & Content'**
  String get adminSectionToolsContent;

  /// adminSectionQuickActions
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get adminSectionQuickActions;

  /// adminSectionNeedsAttention
  ///
  /// In en, this message translates to:
  /// **'Needs Attention'**
  String get adminSectionNeedsAttention;

  /// adminStatActiveBusinesses
  ///
  /// In en, this message translates to:
  /// **'Active Businesses'**
  String get adminStatActiveBusinesses;

  /// adminStatApplicationsToday
  ///
  /// In en, this message translates to:
  /// **'Applications Today'**
  String get adminStatApplicationsToday;

  /// adminStatInterviewsToday
  ///
  /// In en, this message translates to:
  /// **'Interviews Today'**
  String get adminStatInterviewsToday;

  /// adminStatFlaggedContent
  ///
  /// In en, this message translates to:
  /// **'Flagged Content'**
  String get adminStatFlaggedContent;

  /// adminStatActiveSubs
  ///
  /// In en, this message translates to:
  /// **'Active Subs'**
  String get adminStatActiveSubs;

  /// adminActionFlagged
  ///
  /// In en, this message translates to:
  /// **'Flagged'**
  String get adminActionFlagged;

  /// adminActionFeatured
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get adminActionFeatured;

  /// adminActionReviewFlagged
  ///
  /// In en, this message translates to:
  /// **'Review Flagged Content'**
  String get adminActionReviewFlagged;

  /// adminActionTodayInterviews
  ///
  /// In en, this message translates to:
  /// **'Today\'s Interviews'**
  String get adminActionTodayInterviews;

  /// adminActionOpenReports
  ///
  /// In en, this message translates to:
  /// **'Open Reports'**
  String get adminActionOpenReports;

  /// adminActionManageSubscriptions
  ///
  /// In en, this message translates to:
  /// **'Manage Subscriptions'**
  String get adminActionManageSubscriptions;

  /// adminActionAnalyticsDashboard
  ///
  /// In en, this message translates to:
  /// **'Analytics Dashboard'**
  String get adminActionAnalyticsDashboard;

  /// adminActionSendNotification
  ///
  /// In en, this message translates to:
  /// **'Send Notification'**
  String get adminActionSendNotification;

  /// adminActionCreateCommunityPost
  ///
  /// In en, this message translates to:
  /// **'Create Community Post'**
  String get adminActionCreateCommunityPost;

  /// adminActionRetry
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get adminActionRetry;

  /// adminMiscGreetingMorning
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get adminMiscGreetingMorning;

  /// adminMiscGreetingAfternoon
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get adminMiscGreetingAfternoon;

  /// adminMiscGreetingEvening
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get adminMiscGreetingEvening;

  /// adminMiscAllClear
  ///
  /// In en, this message translates to:
  /// **'All clear — nothing needs attention.'**
  String get adminMiscAllClear;

  /// adminSubtitleAllUsers
  ///
  /// In en, this message translates to:
  /// **'All platform users'**
  String get adminSubtitleAllUsers;

  /// adminSubtitleCandidates
  ///
  /// In en, this message translates to:
  /// **'Job seeker profiles'**
  String get adminSubtitleCandidates;

  /// adminSubtitleBusinesses
  ///
  /// In en, this message translates to:
  /// **'Employer accounts'**
  String get adminSubtitleBusinesses;

  /// adminSubtitleJobs
  ///
  /// In en, this message translates to:
  /// **'Active job listings'**
  String get adminSubtitleJobs;

  /// adminSubtitleApplications
  ///
  /// In en, this message translates to:
  /// **'Submitted applications'**
  String get adminSubtitleApplications;

  /// adminSubtitleInterviews
  ///
  /// In en, this message translates to:
  /// **'Scheduled interviews'**
  String get adminSubtitleInterviews;

  /// adminSubtitleMatches
  ///
  /// In en, this message translates to:
  /// **'Role and job type matches'**
  String get adminSubtitleMatches;

  /// adminSubtitleVerifications
  ///
  /// In en, this message translates to:
  /// **'Review pending verifications'**
  String get adminSubtitleVerifications;

  /// adminSubtitleReports
  ///
  /// In en, this message translates to:
  /// **'Flags and moderation'**
  String get adminSubtitleReports;

  /// adminSubtitleSupport
  ///
  /// In en, this message translates to:
  /// **'Open support issues'**
  String get adminSubtitleSupport;

  /// adminSubtitleMessages
  ///
  /// In en, this message translates to:
  /// **'User conversations'**
  String get adminSubtitleMessages;

  /// adminSubtitleNotifications
  ///
  /// In en, this message translates to:
  /// **'Push & in-app alerts'**
  String get adminSubtitleNotifications;

  /// adminSubtitleCommunity
  ///
  /// In en, this message translates to:
  /// **'Posts and discussions'**
  String get adminSubtitleCommunity;

  /// adminSubtitleFeaturedContent
  ///
  /// In en, this message translates to:
  /// **'Highlighted content'**
  String get adminSubtitleFeaturedContent;

  /// adminSubtitleSubscriptions
  ///
  /// In en, this message translates to:
  /// **'Plans and billing'**
  String get adminSubtitleSubscriptions;

  /// adminSubtitleAuditLog
  ///
  /// In en, this message translates to:
  /// **'Admin activity logs'**
  String get adminSubtitleAuditLog;

  /// adminSubtitleAnalytics
  ///
  /// In en, this message translates to:
  /// **'Platform metrics'**
  String get adminSubtitleAnalytics;

  /// adminSubtitleSettings
  ///
  /// In en, this message translates to:
  /// **'Platform configuration'**
  String get adminSubtitleSettings;

  /// adminSubtitleUsersPage
  ///
  /// In en, this message translates to:
  /// **'Manage platform accounts'**
  String get adminSubtitleUsersPage;

  /// adminSubtitleContentPage
  ///
  /// In en, this message translates to:
  /// **'Jobs, applications, and interviews'**
  String get adminSubtitleContentPage;

  /// adminSubtitleModerationPage
  ///
  /// In en, this message translates to:
  /// **'Verifications, reports, and support'**
  String get adminSubtitleModerationPage;

  /// adminSubtitleMorePage
  ///
  /// In en, this message translates to:
  /// **'Settings, analytics, and account'**
  String get adminSubtitleMorePage;

  /// adminSubtitleAnalyticsHero
  ///
  /// In en, this message translates to:
  /// **'KPIs, trends, and platform health'**
  String get adminSubtitleAnalyticsHero;

  /// adminBadgeUrgent
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get adminBadgeUrgent;

  /// adminBadgeReview
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get adminBadgeReview;

  /// adminBadgeAction
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get adminBadgeAction;

  /// adminMenuAllUsers
  ///
  /// In en, this message translates to:
  /// **'All Users'**
  String get adminMenuAllUsers;

  /// adminMiscSuperAdmin
  ///
  /// In en, this message translates to:
  /// **'Super Admin'**
  String get adminMiscSuperAdmin;

  /// adminBadgeNToday
  ///
  /// In en, this message translates to:
  /// **'{count} today'**
  String adminBadgeNToday(int count);

  /// adminBadgeNOpen
  ///
  /// In en, this message translates to:
  /// **'{count} open'**
  String adminBadgeNOpen(int count);

  /// adminBadgeNActive
  ///
  /// In en, this message translates to:
  /// **'{count} active'**
  String adminBadgeNActive(int count);

  /// adminBadgeNUnread
  ///
  /// In en, this message translates to:
  /// **'{count} unread'**
  String adminBadgeNUnread(int count);

  /// adminBadgeNPending
  ///
  /// In en, this message translates to:
  /// **'{count} pending'**
  String adminBadgeNPending(int count);

  /// adminBadgeNPosts
  ///
  /// In en, this message translates to:
  /// **'{count} posts'**
  String adminBadgeNPosts(int count);

  /// adminBadgeNFeatured
  ///
  /// In en, this message translates to:
  /// **'{count} featured'**
  String adminBadgeNFeatured(int count);

  /// adminStatusActive
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get adminStatusActive;

  /// adminStatusPaused
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get adminStatusPaused;

  /// adminStatusClosed
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get adminStatusClosed;

  /// adminStatusDraft
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get adminStatusDraft;

  /// adminStatusFlagged
  ///
  /// In en, this message translates to:
  /// **'Flagged'**
  String get adminStatusFlagged;

  /// adminStatusSuspended
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get adminStatusSuspended;

  /// adminStatusPending
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get adminStatusPending;

  /// adminStatusConfirmed
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get adminStatusConfirmed;

  /// adminStatusCompleted
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get adminStatusCompleted;

  /// adminStatusCancelled
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get adminStatusCancelled;

  /// adminStatusAccepted
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get adminStatusAccepted;

  /// adminStatusDenied
  ///
  /// In en, this message translates to:
  /// **'Denied'**
  String get adminStatusDenied;

  /// adminStatusExpired
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get adminStatusExpired;

  /// adminStatusResolved
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get adminStatusResolved;

  /// adminStatusScheduled
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get adminStatusScheduled;

  /// adminStatusBanned
  ///
  /// In en, this message translates to:
  /// **'Banned'**
  String get adminStatusBanned;

  /// adminStatusVerified
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get adminStatusVerified;

  /// adminStatusFailed
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get adminStatusFailed;

  /// adminStatusSuccess
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get adminStatusSuccess;

  /// adminStatusDelivered
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get adminStatusDelivered;

  /// adminFilterAll
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get adminFilterAll;

  /// adminFilterToday
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get adminFilterToday;

  /// adminFilterUnread
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get adminFilterUnread;

  /// adminFilterRead
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get adminFilterRead;

  /// adminFilterCandidates
  ///
  /// In en, this message translates to:
  /// **'Candidates'**
  String get adminFilterCandidates;

  /// adminFilterBusinesses
  ///
  /// In en, this message translates to:
  /// **'Businesses'**
  String get adminFilterBusinesses;

  /// adminFilterAdmins
  ///
  /// In en, this message translates to:
  /// **'Admins'**
  String get adminFilterAdmins;

  /// adminFilterCandidate
  ///
  /// In en, this message translates to:
  /// **'Candidate'**
  String get adminFilterCandidate;

  /// adminFilterBusiness
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get adminFilterBusiness;

  /// adminFilterSystem
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get adminFilterSystem;

  /// adminFilterPinned
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get adminFilterPinned;

  /// adminFilterEmployers
  ///
  /// In en, this message translates to:
  /// **'Employers'**
  String get adminFilterEmployers;

  /// adminFilterBanners
  ///
  /// In en, this message translates to:
  /// **'Banners'**
  String get adminFilterBanners;

  /// adminFilterBilling
  ///
  /// In en, this message translates to:
  /// **'Billing'**
  String get adminFilterBilling;

  /// adminFilterFeaturedEmployer
  ///
  /// In en, this message translates to:
  /// **'Featured Employer'**
  String get adminFilterFeaturedEmployer;

  /// adminFilterFeaturedJob
  ///
  /// In en, this message translates to:
  /// **'Featured Job'**
  String get adminFilterFeaturedJob;

  /// adminFilterHomeBanner
  ///
  /// In en, this message translates to:
  /// **'Home Banner'**
  String get adminFilterHomeBanner;

  /// adminEmptyAdjustFilters
  ///
  /// In en, this message translates to:
  /// **'Try adjusting filters.'**
  String get adminEmptyAdjustFilters;

  /// adminEmptyJobsTitle
  ///
  /// In en, this message translates to:
  /// **'No jobs'**
  String get adminEmptyJobsTitle;

  /// adminEmptyJobsSub
  ///
  /// In en, this message translates to:
  /// **'No jobs match.'**
  String get adminEmptyJobsSub;

  /// adminEmptyUsersTitle
  ///
  /// In en, this message translates to:
  /// **'No users match'**
  String get adminEmptyUsersTitle;

  /// adminEmptyMessagesTitle
  ///
  /// In en, this message translates to:
  /// **'No messages'**
  String get adminEmptyMessagesTitle;

  /// adminEmptyMessagesSub
  ///
  /// In en, this message translates to:
  /// **'No conversations to show.'**
  String get adminEmptyMessagesSub;

  /// adminEmptyReportsTitle
  ///
  /// In en, this message translates to:
  /// **'No reports'**
  String get adminEmptyReportsTitle;

  /// adminEmptyReportsSub
  ///
  /// In en, this message translates to:
  /// **'No user reports to review.'**
  String get adminEmptyReportsSub;

  /// adminEmptyBusinessesTitle
  ///
  /// In en, this message translates to:
  /// **'No businesses'**
  String get adminEmptyBusinessesTitle;

  /// adminEmptyBusinessesSub
  ///
  /// In en, this message translates to:
  /// **'No businesses match.'**
  String get adminEmptyBusinessesSub;

  /// adminEmptyNotifsTitle
  ///
  /// In en, this message translates to:
  /// **'No notifications match'**
  String get adminEmptyNotifsTitle;

  /// adminEmptySubsTitle
  ///
  /// In en, this message translates to:
  /// **'No subscriptions'**
  String get adminEmptySubsTitle;

  /// adminEmptySubsSub
  ///
  /// In en, this message translates to:
  /// **'No subscriptions match.'**
  String get adminEmptySubsSub;

  /// adminEmptyLogsTitle
  ///
  /// In en, this message translates to:
  /// **'No logs match'**
  String get adminEmptyLogsTitle;

  /// adminEmptyContentTitle
  ///
  /// In en, this message translates to:
  /// **'No content matches'**
  String get adminEmptyContentTitle;

  /// adminEmptyInterviewsTitle
  ///
  /// In en, this message translates to:
  /// **'No interviews'**
  String get adminEmptyInterviewsTitle;

  /// adminEmptyInterviewsSub
  ///
  /// In en, this message translates to:
  /// **'No interviews match.'**
  String get adminEmptyInterviewsSub;

  /// adminEmptyFeedback
  ///
  /// In en, this message translates to:
  /// **'Feedback data will appear here'**
  String get adminEmptyFeedback;

  /// adminEmptyMatchNotifs
  ///
  /// In en, this message translates to:
  /// **'Match notifications will appear here'**
  String get adminEmptyMatchNotifs;

  /// adminTitleMatchManagement
  ///
  /// In en, this message translates to:
  /// **'Match Management'**
  String get adminTitleMatchManagement;

  /// adminTitleAdminLogs
  ///
  /// In en, this message translates to:
  /// **'Admin Logs'**
  String get adminTitleAdminLogs;

  /// adminTitleContentFeatured
  ///
  /// In en, this message translates to:
  /// **'Content / Featured'**
  String get adminTitleContentFeatured;

  /// adminTabFeedback
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get adminTabFeedback;

  /// adminTabStats
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get adminTabStats;

  /// adminSortNewest
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get adminSortNewest;

  /// adminSortPriority
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get adminSortPriority;

  /// adminStatTotalMatches
  ///
  /// In en, this message translates to:
  /// **'Total Matches'**
  String get adminStatTotalMatches;

  /// adminStatAccepted
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get adminStatAccepted;

  /// adminStatDenied
  ///
  /// In en, this message translates to:
  /// **'Denied'**
  String get adminStatDenied;

  /// adminStatFeedbackCount
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get adminStatFeedbackCount;

  /// adminStatMatchQuality
  ///
  /// In en, this message translates to:
  /// **'Match Quality Score'**
  String get adminStatMatchQuality;

  /// adminStatTotal
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get adminStatTotal;

  /// adminStatPendingCount
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get adminStatPendingCount;

  /// adminStatNotificationsCount
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get adminStatNotificationsCount;

  /// adminStatActiveCount
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get adminStatActiveCount;

  /// adminSectionPlatformSettings
  ///
  /// In en, this message translates to:
  /// **'Platform Settings'**
  String get adminSectionPlatformSettings;

  /// adminSectionNotificationSettings
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get adminSectionNotificationSettings;

  /// adminSettingMaintenanceTitle
  ///
  /// In en, this message translates to:
  /// **'Maintenance Mode'**
  String get adminSettingMaintenanceTitle;

  /// adminSettingMaintenanceSub
  ///
  /// In en, this message translates to:
  /// **'Disable access for all users'**
  String get adminSettingMaintenanceSub;

  /// adminSettingNewRegsTitle
  ///
  /// In en, this message translates to:
  /// **'New Registrations'**
  String get adminSettingNewRegsTitle;

  /// adminSettingNewRegsSub
  ///
  /// In en, this message translates to:
  /// **'Allow new user sign-ups'**
  String get adminSettingNewRegsSub;

  /// adminSettingFeaturedJobsTitle
  ///
  /// In en, this message translates to:
  /// **'Featured Jobs'**
  String get adminSettingFeaturedJobsTitle;

  /// adminSettingFeaturedJobsSub
  ///
  /// In en, this message translates to:
  /// **'Show featured jobs on home'**
  String get adminSettingFeaturedJobsSub;

  /// adminSettingEmailNotifsTitle
  ///
  /// In en, this message translates to:
  /// **'Email Notifications'**
  String get adminSettingEmailNotifsTitle;

  /// adminSettingEmailNotifsSub
  ///
  /// In en, this message translates to:
  /// **'Send email alerts'**
  String get adminSettingEmailNotifsSub;

  /// adminSettingPushNotifsTitle
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get adminSettingPushNotifsTitle;

  /// adminSettingPushNotifsSub
  ///
  /// In en, this message translates to:
  /// **'Send push notifications'**
  String get adminSettingPushNotifsSub;

  /// adminActionSaveChanges
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get adminActionSaveChanges;

  /// adminToastSettingsSaved
  ///
  /// In en, this message translates to:
  /// **'Settings saved'**
  String get adminToastSettingsSaved;

  /// adminActionResolve
  ///
  /// In en, this message translates to:
  /// **'Resolve'**
  String get adminActionResolve;

  /// adminActionDismiss
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get adminActionDismiss;

  /// adminActionBanUser
  ///
  /// In en, this message translates to:
  /// **'Ban User'**
  String get adminActionBanUser;

  /// adminSearchUsersHint
  ///
  /// In en, this message translates to:
  /// **'Search name, email, role, location...'**
  String get adminSearchUsersHint;

  /// adminMiscPositive
  ///
  /// In en, this message translates to:
  /// **'positive'**
  String get adminMiscPositive;

  /// adminCountUsers
  ///
  /// In en, this message translates to:
  /// **'{count} users'**
  String adminCountUsers(int count);

  /// adminCountNotifs
  ///
  /// In en, this message translates to:
  /// **'{count} notifications'**
  String adminCountNotifs(int count);

  /// adminCountLogs
  ///
  /// In en, this message translates to:
  /// **'{count} log entries'**
  String adminCountLogs(int count);

  /// adminCountItems
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String adminCountItems(int count);

  /// adminBadgeNRetried
  ///
  /// In en, this message translates to:
  /// **'Retried x{count}'**
  String adminBadgeNRetried(int count);

  /// Phase 2 admin key: adminStatusApplied
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get adminStatusApplied;

  /// Phase 2 admin key: adminStatusUnderReview
  ///
  /// In en, this message translates to:
  /// **'Under Review'**
  String get adminStatusUnderReview;

  /// Phase 2 admin key: adminStatusShortlisted
  ///
  /// In en, this message translates to:
  /// **'Shortlisted'**
  String get adminStatusShortlisted;

  /// Phase 2 admin key: adminStatusInterview
  ///
  /// In en, this message translates to:
  /// **'Interview'**
  String get adminStatusInterview;

  /// Phase 2 admin key: adminStatusHired
  ///
  /// In en, this message translates to:
  /// **'Hired'**
  String get adminStatusHired;

  /// Phase 2 admin key: adminStatusRejected
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get adminStatusRejected;

  /// Phase 2 admin key: adminStatusOpen
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get adminStatusOpen;

  /// Phase 2 admin key: adminStatusInReview
  ///
  /// In en, this message translates to:
  /// **'In Review'**
  String get adminStatusInReview;

  /// Phase 2 admin key: adminStatusWaiting
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get adminStatusWaiting;

  /// Phase 2 admin key: adminPriorityHigh
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get adminPriorityHigh;

  /// Phase 2 admin key: adminPriorityMedium
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get adminPriorityMedium;

  /// Phase 2 admin key: adminPriorityLow
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get adminPriorityLow;

  /// Phase 2 admin key: adminActionViewProfile
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get adminActionViewProfile;

  /// Phase 2 admin key: adminActionVerify
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get adminActionVerify;

  /// Phase 2 admin key: adminActionReview
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get adminActionReview;

  /// Phase 2 admin key: adminActionOverride
  ///
  /// In en, this message translates to:
  /// **'Override'**
  String get adminActionOverride;

  /// Phase 2 admin key: adminEmptyCandidatesTitle
  ///
  /// In en, this message translates to:
  /// **'No candidates'**
  String get adminEmptyCandidatesTitle;

  /// Phase 2 admin key: adminEmptyApplicationsTitle
  ///
  /// In en, this message translates to:
  /// **'No applications'**
  String get adminEmptyApplicationsTitle;

  /// Phase 2 admin key: adminEmptyVerificationsTitle
  ///
  /// In en, this message translates to:
  /// **'No pending verifications'**
  String get adminEmptyVerificationsTitle;

  /// Phase 2 admin key: adminEmptyIssuesTitle
  ///
  /// In en, this message translates to:
  /// **'No issues found'**
  String get adminEmptyIssuesTitle;

  /// Phase 2 admin key: adminEmptyAuditTitle
  ///
  /// In en, this message translates to:
  /// **'No audit entries found'**
  String get adminEmptyAuditTitle;

  /// Phase 2 admin key: adminSearchCandidatesTitle
  ///
  /// In en, this message translates to:
  /// **'Search candidates'**
  String get adminSearchCandidatesTitle;

  /// Phase 2 admin key: adminSearchCandidatesHint
  ///
  /// In en, this message translates to:
  /// **'Search by name, email or role…'**
  String get adminSearchCandidatesHint;

  /// Phase 2 admin key: adminSearchAuditHint
  ///
  /// In en, this message translates to:
  /// **'Search audit log…'**
  String get adminSearchAuditHint;

  /// Phase 2 admin key: adminMiscUnknown
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get adminMiscUnknown;

  /// Phase 2 admin ICU: adminCountTotal
  ///
  /// In en, this message translates to:
  /// **'{count} total'**
  String adminCountTotal(int count);

  /// Phase 2 admin ICU: adminBadgeNFlagged
  ///
  /// In en, this message translates to:
  /// **'{count} flagged'**
  String adminBadgeNFlagged(int count);

  /// Phase 2 admin ICU: adminBadgeNDaysWaiting
  ///
  /// In en, this message translates to:
  /// **'{count} days waiting'**
  String adminBadgeNDaysWaiting(int count);

  /// adminPeriodWeek
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get adminPeriodWeek;

  /// adminPeriodMonth
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get adminPeriodMonth;

  /// adminPeriodYear
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get adminPeriodYear;

  /// adminKpiNewCandidates
  ///
  /// In en, this message translates to:
  /// **'New Candidates'**
  String get adminKpiNewCandidates;

  /// adminKpiNewBusinesses
  ///
  /// In en, this message translates to:
  /// **'New Businesses'**
  String get adminKpiNewBusinesses;

  /// adminKpiJobsPosted
  ///
  /// In en, this message translates to:
  /// **'Jobs Posted'**
  String get adminKpiJobsPosted;

  /// adminSectionApplicationFunnel
  ///
  /// In en, this message translates to:
  /// **'Application Funnel'**
  String get adminSectionApplicationFunnel;

  /// adminSectionPlatformGrowth
  ///
  /// In en, this message translates to:
  /// **'Platform Growth'**
  String get adminSectionPlatformGrowth;

  /// adminSectionPremiumConversion
  ///
  /// In en, this message translates to:
  /// **'Premium Conversion'**
  String get adminSectionPremiumConversion;

  /// adminSectionTopLocations
  ///
  /// In en, this message translates to:
  /// **'Top Locations'**
  String get adminSectionTopLocations;

  /// adminStatusViewed
  ///
  /// In en, this message translates to:
  /// **'Viewed'**
  String get adminStatusViewed;

  /// adminWeekdayMon
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get adminWeekdayMon;

  /// adminWeekdayTue
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get adminWeekdayTue;

  /// adminWeekdayWed
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get adminWeekdayWed;

  /// adminWeekdayThu
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get adminWeekdayThu;

  /// adminWeekdayFri
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get adminWeekdayFri;

  /// adminWeekdaySat
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get adminWeekdaySat;

  /// adminWeekdaySun
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get adminWeekdaySun;

  /// adminFilterReported
  ///
  /// In en, this message translates to:
  /// **'Reported'**
  String get adminFilterReported;

  /// adminFilterHidden
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get adminFilterHidden;

  /// adminEmptyPostsTitle
  ///
  /// In en, this message translates to:
  /// **'No posts'**
  String get adminEmptyPostsTitle;

  /// adminEmptyContentFilter
  ///
  /// In en, this message translates to:
  /// **'No content matches this filter.'**
  String get adminEmptyContentFilter;

  /// adminBannerReportedReview
  ///
  /// In en, this message translates to:
  /// **'REPORTED — REVIEW REQUIRED'**
  String get adminBannerReportedReview;

  /// adminBannerHiddenFromFeed
  ///
  /// In en, this message translates to:
  /// **'HIDDEN FROM FEED'**
  String get adminBannerHiddenFromFeed;

  /// adminActionInsights
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get adminActionInsights;

  /// adminActionHide
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get adminActionHide;

  /// adminActionRemove
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get adminActionRemove;

  /// adminActionCancel
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get adminActionCancel;

  /// adminDialogRemovePostTitle
  ///
  /// In en, this message translates to:
  /// **'Remove Post?'**
  String get adminDialogRemovePostTitle;

  /// adminDialogRemovePostBody
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes the post and its comments. This action cannot be undone.'**
  String get adminDialogRemovePostBody;

  /// adminSnackbarReportCleared
  ///
  /// In en, this message translates to:
  /// **'Report cleared'**
  String get adminSnackbarReportCleared;

  /// adminSnackbarPostHidden
  ///
  /// In en, this message translates to:
  /// **'Post hidden from feed'**
  String get adminSnackbarPostHidden;

  /// adminSnackbarPostRemoved
  ///
  /// In en, this message translates to:
  /// **'Post removed'**
  String get adminSnackbarPostRemoved;

  /// adminCountReported
  ///
  /// In en, this message translates to:
  /// **'{count} reported'**
  String adminCountReported(int count);

  /// adminCountHidden
  ///
  /// In en, this message translates to:
  /// **'{count} hidden'**
  String adminCountHidden(int count);

  /// adminMiscPremiumOutOfTotal
  ///
  /// In en, this message translates to:
  /// **'{premium} premium out of {total} total'**
  String adminMiscPremiumOutOfTotal(int premium, int total);

  /// adminActionUnverify
  ///
  /// In en, this message translates to:
  /// **'Unverify'**
  String get adminActionUnverify;

  /// adminActionReactivate
  ///
  /// In en, this message translates to:
  /// **'Reactivate'**
  String get adminActionReactivate;

  /// adminActionFeature
  ///
  /// In en, this message translates to:
  /// **'Feature'**
  String get adminActionFeature;

  /// adminActionUnfeature
  ///
  /// In en, this message translates to:
  /// **'Unfeature'**
  String get adminActionUnfeature;

  /// adminActionFlagAccount
  ///
  /// In en, this message translates to:
  /// **'Flag Account'**
  String get adminActionFlagAccount;

  /// adminActionUnflagAccount
  ///
  /// In en, this message translates to:
  /// **'Unflag Account'**
  String get adminActionUnflagAccount;

  /// adminActionConfirm
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get adminActionConfirm;

  /// adminDialogVerifyBusinessTitle
  ///
  /// In en, this message translates to:
  /// **'Verify Business'**
  String get adminDialogVerifyBusinessTitle;

  /// adminDialogUnverifyBusinessTitle
  ///
  /// In en, this message translates to:
  /// **'Unverify Business'**
  String get adminDialogUnverifyBusinessTitle;

  /// adminDialogSuspendBusinessTitle
  ///
  /// In en, this message translates to:
  /// **'Suspend Business'**
  String get adminDialogSuspendBusinessTitle;

  /// adminDialogReactivateBusinessTitle
  ///
  /// In en, this message translates to:
  /// **'Reactivate Business'**
  String get adminDialogReactivateBusinessTitle;

  /// adminDialogVerifyCandidateTitle
  ///
  /// In en, this message translates to:
  /// **'Verify Candidate'**
  String get adminDialogVerifyCandidateTitle;

  /// adminDialogSuspendCandidateTitle
  ///
  /// In en, this message translates to:
  /// **'Suspend Candidate'**
  String get adminDialogSuspendCandidateTitle;

  /// adminDialogReactivateCandidateTitle
  ///
  /// In en, this message translates to:
  /// **'Reactivate Candidate'**
  String get adminDialogReactivateCandidateTitle;

  /// adminSnackbarBusinessVerified
  ///
  /// In en, this message translates to:
  /// **'Business verified'**
  String get adminSnackbarBusinessVerified;

  /// adminSnackbarVerificationRemoved
  ///
  /// In en, this message translates to:
  /// **'Verification removed'**
  String get adminSnackbarVerificationRemoved;

  /// adminSnackbarBusinessSuspended
  ///
  /// In en, this message translates to:
  /// **'Business suspended'**
  String get adminSnackbarBusinessSuspended;

  /// adminSnackbarBusinessReactivated
  ///
  /// In en, this message translates to:
  /// **'Business reactivated'**
  String get adminSnackbarBusinessReactivated;

  /// adminSnackbarBusinessFeatured
  ///
  /// In en, this message translates to:
  /// **'Business featured'**
  String get adminSnackbarBusinessFeatured;

  /// adminSnackbarBusinessUnfeatured
  ///
  /// In en, this message translates to:
  /// **'Business unfeatured'**
  String get adminSnackbarBusinessUnfeatured;

  /// adminSnackbarUserVerified
  ///
  /// In en, this message translates to:
  /// **'User verified'**
  String get adminSnackbarUserVerified;

  /// adminSnackbarUserSuspended
  ///
  /// In en, this message translates to:
  /// **'User suspended'**
  String get adminSnackbarUserSuspended;

  /// adminSnackbarUserReactivated
  ///
  /// In en, this message translates to:
  /// **'User reactivated'**
  String get adminSnackbarUserReactivated;

  /// adminTabProfile
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get adminTabProfile;

  /// adminTabActivity
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get adminTabActivity;

  /// adminTabNotes
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get adminTabNotes;

  /// adminDialogVerifyBody
  ///
  /// In en, this message translates to:
  /// **'Mark {name} as verified?'**
  String adminDialogVerifyBody(String name);

  /// adminDialogUnverifyBody
  ///
  /// In en, this message translates to:
  /// **'Remove verification from {name}?'**
  String adminDialogUnverifyBody(String name);

  /// adminDialogReactivateBody
  ///
  /// In en, this message translates to:
  /// **'Reactivate {name}?'**
  String adminDialogReactivateBody(String name);

  /// adminDialogSuspendBusinessBody
  ///
  /// In en, this message translates to:
  /// **'Suspend {name}? All jobs will be paused.'**
  String adminDialogSuspendBusinessBody(String name);

  /// adminDialogSuspendCandidateBody
  ///
  /// In en, this message translates to:
  /// **'Suspend {name}? They will lose access.'**
  String adminDialogSuspendCandidateBody(String name);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'it',
    'pt',
    'ru',
    'tr',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'it':
      return AppLocalizationsIt();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
