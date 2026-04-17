/// Localization helpers for service-provider / company categories used in
/// the "Looking for Companies" flow. Backend and mock data store the
/// canonical English label (e.g. `Food & Beverage Suppliers`) — we keep
/// those values intact for filtering/routing and translate them only at
/// display time.
///
/// Unknown category strings pass through untouched so custom/backend
/// categories still render.
library;

import 'package:flutter/widgets.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';

/// Canonical list of service provider category keys used in mock data.
const _canonicalFoodBeverage = 'Food & Beverage Suppliers';
const _canonicalEventServices = 'Event Services';
const _canonicalDecorDesign = 'Decor & Design';
const _canonicalEntertainment = 'Entertainment';
const _canonicalEquipmentOps = 'Equipment & Operations';
const _canonicalCleaningMaintenance = 'Cleaning & Maintenance';

/// Returns the localized display name for a canonical service category.
/// Unknown categories pass through untouched.
String localizedServiceCategory(BuildContext context, String raw) {
  final l = AppLocalizations.of(context);
  switch (raw) {
    case _canonicalFoodBeverage:
      return l.serviceCategoryFoodBeverage;
    case _canonicalEventServices:
      return l.serviceCategoryEventServices;
    case _canonicalDecorDesign:
      return l.serviceCategoryDecorDesign;
    case _canonicalEntertainment:
      return l.serviceCategoryEntertainment;
    case _canonicalEquipmentOps:
      return l.serviceCategoryEquipmentOps;
    case _canonicalCleaningMaintenance:
      return l.serviceCategoryCleaningMaintenance;
    default:
      return raw;
  }
}
