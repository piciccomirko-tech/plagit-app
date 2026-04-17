import 'package:flutter/material.dart';

/// Hardcoded mock data for the employer/business side.
/// Used directly by employer views — no API calls needed.
class MockEmployerData {
  MockEmployerData._();

  // ══════════════════════════════════════
  // Dashboard stats
  // ══════════════════════════════════════
  static const int activeJobs = 2;
  static const int newApplicants = 3;
  static const int interviewsCount = 1;

  // ══════════════════════════════════════
  // Jobs
  // ══════════════════════════════════════
  static final List<Map<String, dynamic>> jobs = [
    {
      'id': 'job_1',
      'title': 'Waiter',
      'status': 'active',
      'location': 'Milan, Italy',
      'salary': '€12/hr',
      'employmentType': 'Full-time',
      'views': 89,
      'saved': 12,
      'applicants': 5,
    },
    {
      'id': 'job_2',
      'title': 'Bartender',
      'status': 'active',
      'location': 'Milan, Italy',
      'salary': '€14/hr',
      'employmentType': 'Full-time',
      'views': 134,
      'saved': 20,
      'applicants': 3,
    },
  ];

  // ══════════════════════════════════════
  // Next interview (dashboard card)
  // ══════════════════════════════════════
  static final Map<String, dynamic> nextInterview = {
    'id': 'int_1',
    'candidateName': 'Marco Rossi',
    'initials': 'MR',
    'avatarHue': 0.35,
    'jobTitle': 'Waiter',
    'status': 'confirmed',
    'scheduledDay': '11',
    'scheduledMonth': 'APR',
    'scheduledTime': '3:51 PM',
    'interviewType': 'in_person',
    'location': 'Test Restaurant, Milan',
  };

  // ══════════════════════════════════════
  // Interviews list
  // ══════════════════════════════════════
  static final List<Map<String, dynamic>> interviewsList = [
    {
      'id': 'int_1',
      'candidateName': 'Marco Rossi',
      'initials': 'MR',
      'avatarHue': 0.35,
      'jobTitle': 'Waiter',
      'status': 'confirmed',
      'date': 'Apr 11, 2026 at 4:26 pm',
      'interviewType': 'in_person',
      'location': 'Test Restaurant, Milan',
      'timezone': 'Europe/Rome',
    },
    {
      'id': 'int_2',
      'candidateName': 'Sara Bianchi',
      'initials': 'SB',
      'avatarHue': 0.55,
      'jobTitle': 'Bartender',
      'status': 'pending',
      'date': 'Apr 14, 2026 at 4:26 pm',
      'interviewType': 'video',
      'location': null,
      'timezone': 'Europe/Rome',
    },
  ];

  // ══════════════════════════════════════
  // Applicants
  // ══════════════════════════════════════
  static final List<Map<String, dynamic>> applicants = [
    {
      'id': 'a1',
      'name': 'Alex Chen',
      'initials': 'AC',
      'avatarHue': 0.33,
      'role': 'Waiter',
      'jobTitle': 'Waiter',
      'experience': '3yr exp',
      'location': 'Camden, London',
      'status': 'applied',
      'appliedAgo': '1 day ago',
    },
    {
      'id': 'a2',
      'name': 'Maria Santos',
      'initials': 'MS',
      'avatarHue': 0.75,
      'role': 'Waiter',
      'jobTitle': 'Waiter',
      'experience': '5yr exp',
      'location': 'Kensington, London',
      'status': 'shortlisted',
      'appliedAgo': '2 days ago',
      'verified': true,
    },
    {
      'id': 'a3',
      'name': 'James Wilson',
      'initials': 'JW',
      'avatarHue': 0.65,
      'role': 'Bartender',
      'jobTitle': 'Bartender',
      'experience': '2yr exp',
      'location': 'Soho, London',
      'status': 'under_review',
      'appliedAgo': '1 day ago',
    },
    {
      'id': 'a4',
      'name': 'Sofia Rossi',
      'initials': 'SR',
      'avatarHue': 0.85,
      'role': 'Bartender',
      'jobTitle': 'Bartender',
      'experience': '4yr exp',
      'location': 'Chelsea, London',
      'status': 'applied',
      'appliedAgo': '3 days ago',
    },
  ];

  // ══════════════════════════════════════
  // Quick Actions menu items
  // ══════════════════════════════════════
  static const List<Map<String, dynamic>> quickActions = [
    {'icon': Icons.work, 'title': 'Post Job', 'subtitle': 'Reach top candidates', 'route': '/business/post-job'},
    {'icon': Icons.edit, 'title': 'Create Update', 'subtitle': 'Share company news', 'route': null},
    {'icon': Icons.camera_alt, 'title': 'Add Story', 'subtitle': 'Show your workplace', 'route': null},
    {'icon': Icons.star, 'title': 'View Shortlist', 'subtitle': 'Your saved candidates', 'route': '/business/shortlist'},
    {'icon': Icons.person_add, 'title': 'Invite Candidate', 'subtitle': 'Reach out directly', 'route': null},
  ];

  // ── Colori avatar da hue ──
  static Color avatarColor(double hue) {
    return HSLColor.fromAHSL(1.0, hue * 360, 0.55, 0.50).toColor();
  }

  // ── Colore badge status intervista ──
  static Color interviewStatusColor(String status) {
    switch (status) {
      case 'confirmed': return const Color(0xFF34C759);
      case 'pending': return const Color(0xFFFF9500);
      case 'completed': return const Color(0xFF2BB8B0);
      case 'cancelled': return const Color(0xFFFF3B30);
      default: return const Color(0xFF8E8E93);
    }
  }

  // ── Colore badge status applicant ──
  static Color applicantStatusColor(String status) {
    switch (status) {
      case 'applied': return const Color(0xFF2BB8B0);
      case 'shortlisted': return const Color(0xFFFF9500);
      case 'under_review': return const Color(0xFFFF9500);
      case 'interview': return const Color(0xFF5856D6);
      case 'offer': return const Color(0xFF34C759);
      default: return const Color(0xFF8E8E93);
    }
  }
}
