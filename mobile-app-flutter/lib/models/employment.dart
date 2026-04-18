/// Typed models for a job's employment type and compensation structure.
library;

import 'package:flutter/widgets.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';

enum EmploymentType {
  fullTime,
  partTime,
  fixedTerm,
  hourly;

  String get label => switch (this) {
        fullTime => 'Full-time',
        partTime => 'Part-time',
        fixedTerm => 'Temporary',
        hourly => 'Casual',
      };

  static EmploymentType fromString(String raw) {
    final s = raw.toLowerCase().replaceAll(RegExp(r'[\s_-]'), '');
    return switch (s) {
      'fulltime' || 'full' => EmploymentType.fullTime,
      'parttime' || 'part' => EmploymentType.partTime,
      'fixedterm' ||
      'temporary' ||
      'temp' ||
      'contract' =>
        EmploymentType.fixedTerm,
      'hourly' ||
      'casual' ||
      'zerohours' ||
      'zerohour' =>
        EmploymentType.hourly,
      _ => EmploymentType.fullTime,
    };
  }
}

class Compensation {
  final EmploymentType employmentType;
  final String currency;
  final double? annualSalary;
  final double? annualSalaryMin;
  final double? annualSalaryMax;
  final double? monthlyPay;
  final int? contractDurationMonths;
  final double? hourlyRate;
  final double? weeklyHours;
  final String? bonus;
  final String? shiftPattern;
  final bool housingIncluded;
  final bool travelIncluded;
  final bool overtimeAvailable;
  final bool flexibleSchedule;
  final bool weekendShifts;

  const Compensation({
    required this.employmentType,
    this.currency = '£',
    this.annualSalary,
    this.annualSalaryMin,
    this.annualSalaryMax,
    this.monthlyPay,
    this.contractDurationMonths,
    this.hourlyRate,
    this.weeklyHours,
    this.bonus,
    this.shiftPattern,
    this.housingIncluded = false,
    this.travelIncluded = false,
    this.overtimeAvailable = false,
    this.flexibleSchedule = false,
    this.weekendShifts = false,
  });

  /// Short single-line summary for list rows and pills.
  String get display => _buildDisplay(
        perYear: '/year',
        perMonth: '/month',
        perHour: '/hr',
      );

  /// Localized variant of [display] — same structure but the
  /// `/year` · `/month` · `/hr` suffixes come from ARB.
  String displayLocalized(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _buildDisplay(
      perYear: l.perYear,
      perMonth: l.perMonth,
      perHour: l.perHour,
    );
  }

  String _buildDisplay({
    required String perYear,
    required String perMonth,
    required String perHour,
  }) {
    String money(double v) => '$currency${v.toStringAsFixed(0)}';
    return switch (employmentType) {
      EmploymentType.fullTime => switch ((annualSalaryMin, annualSalaryMax, annualSalary)) {
          (final lo?, final hi?, _) => '${money(lo)}–${money(hi)}$perYear',
          (_, _, final s?) => '${money(s)}$perYear',
          _ => '—',
        },
      EmploymentType.fixedTerm => monthlyPay != null
          ? '${money(monthlyPay!)}$perMonth'
          : '—',
      EmploymentType.partTime ||
      EmploymentType.hourly =>
        hourlyRate != null ? '${money(hourlyRate!)}$perHour' : '—',
    };
  }

  factory Compensation.fromJson(
      Map<String, dynamic> json, EmploymentType empType) {
    double? asDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    int? asInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v);
      return null;
    }

    return Compensation(
      employmentType: empType,
      currency: json['currency'] as String? ?? '£',
      annualSalary: asDouble(json['annualSalary'] ?? json['annual_salary']),
      annualSalaryMin:
          asDouble(json['annualSalaryMin'] ?? json['annual_salary_min']),
      annualSalaryMax:
          asDouble(json['annualSalaryMax'] ?? json['annual_salary_max']),
      monthlyPay: asDouble(json['monthlyPay'] ?? json['monthly_pay']),
      contractDurationMonths: asInt(
          json['contractDurationMonths'] ?? json['contract_duration_months']),
      hourlyRate: asDouble(json['hourlyRate'] ?? json['hourly_rate']),
      weeklyHours: asDouble(json['weeklyHours'] ?? json['weekly_hours']),
      bonus: json['bonus'] as String?,
      shiftPattern:
          json['shiftPattern'] as String? ?? json['shift_pattern'] as String?,
      housingIncluded: json['housingIncluded'] as bool? ??
          json['housing_included'] as bool? ??
          false,
      travelIncluded: json['travelIncluded'] as bool? ??
          json['travel_included'] as bool? ??
          false,
      overtimeAvailable: json['overtimeAvailable'] as bool? ??
          json['overtime_available'] as bool? ??
          false,
      flexibleSchedule: json['flexibleSchedule'] as bool? ??
          json['flexible_schedule'] as bool? ??
          false,
      weekendShifts: json['weekendShifts'] as bool? ??
          json['weekend_shifts'] as bool? ??
          false,
    );
  }

  /// Best-effort parser for legacy plain-string salary fields like "£25,000/year"
  /// or "£12/hr". Extracts currency symbol and the first number; everything
  /// else stays null.
  factory Compensation.fromLegacy(String raw, EmploymentType empType) {
    final currencyMatch = RegExp(r'[£$€]').firstMatch(raw);
    final currency = currencyMatch?.group(0) ?? '£';
    final numbers = RegExp(r'\d[\d,\.]*')
        .allMatches(raw)
        .map((m) => double.tryParse(m.group(0)!.replaceAll(',', '')))
        .whereType<double>()
        .toList();

    final lower = raw.toLowerCase();
    final isHourly = lower.contains('/hr') || lower.contains('hour');
    final isMonthly = lower.contains('/mo') || lower.contains('month');

    double? annual, annualMin, annualMax, monthly, hourly;
    if (isHourly && numbers.isNotEmpty) {
      hourly = numbers.first;
    } else if (isMonthly && numbers.isNotEmpty) {
      monthly = numbers.first;
    } else if (numbers.length >= 2) {
      annualMin = numbers[0];
      annualMax = numbers[1];
    } else if (numbers.length == 1) {
      annual = numbers.first;
    }

    return Compensation(
      employmentType: empType,
      currency: currency,
      annualSalary: annual,
      annualSalaryMin: annualMin,
      annualSalaryMax: annualMax,
      monthlyPay: monthly,
      hourlyRate: hourly,
    );
  }
}
