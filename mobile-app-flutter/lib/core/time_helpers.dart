/// Short, locale-aware time-ago formatting helpers.
///
/// The community feed stores `timeAgo` as a short English literal (e.g.
/// `"45m"`, `"2h"`, `"1d"`, `"now"`) inside the mock seed data. On non-English
/// devices these letters look out of place — English "h" next to an Italian
/// feed, or Latin "d" inside an Arabic RTL card.
///
/// [shortTimeAgo] parses the short format and re-emits it localized using
/// the `timeAgoMinutesShort` / `timeAgoHoursShort` / `timeAgoDaysShort` /
/// `timeAgoNow` ARB keys. If the input isn't a recognised short format it
/// passes through untouched so user-typed / backend values still render.
library;

import 'package:flutter/widgets.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';

/// Localize a short time-ago literal such as `"45m"`, `"2h"`, `"1d"`,
/// `"now"`. Falls back to [raw] when the input doesn't match the expected
/// short pattern.
String shortTimeAgo(BuildContext context, String raw) {
  final l = AppLocalizations.of(context);
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return raw;

  final lower = trimmed.toLowerCase();
  if (lower == 'now') return l.timeAgoNow;

  final match = RegExp(r'^(\d+)\s*([mhd])$').firstMatch(lower);
  if (match == null) return raw;

  final count = int.tryParse(match.group(1)!);
  if (count == null) return raw;

  return switch (match.group(2)!) {
    'm' => l.timeAgoMinutesShort(count),
    'h' => l.timeAgoHoursShort(count),
    'd' => l.timeAgoDaysShort(count),
    _ => raw,
  };
}
