import 'package:flutter/material.dart';
import 'package:plagit/features/admin/views/admin_shared_widgets.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';

class AdminSettingsView extends StatefulWidget {
  const AdminSettingsView({super.key});
  @override
  State<AdminSettingsView> createState() => _AdminSettingsViewState();
}

class _AdminSettingsViewState extends State<AdminSettingsView> {
  bool _maintenance = false, _newRegistrations = true, _featuredJobs = true;
  bool _emailNotifs = true, _pushNotifs = true;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(backgroundColor: aBg, body: SafeArea(child: Column(children: [
      aTopBar(context, l.adminMenuSettings),
      Expanded(child: SingleChildScrollView(padding: const EdgeInsets.only(bottom: 48), child: Column(children: [
        // PLATFORM SETTINGS
        Container(margin: const EdgeInsets.fromLTRB(20, 16, 20, 0), padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: aCard, borderRadius: BorderRadius.circular(20), boxShadow: [aSubtleShadow]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.adminSectionPlatformSettings, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: aCharcoal)), const SizedBox(height: 16),
            _toggle(l.adminSettingMaintenanceTitle, l.adminSettingMaintenanceSub, _maintenance, (v) => setState(() => _maintenance = v)),
            _toggle(l.adminSettingNewRegsTitle, l.adminSettingNewRegsSub, _newRegistrations, (v) => setState(() => _newRegistrations = v)),
            _toggle(l.adminSettingFeaturedJobsTitle, l.adminSettingFeaturedJobsSub, _featuredJobs, (v) => setState(() => _featuredJobs = v)),
          ])),

        // NOTIFICATION SETTINGS
        Container(margin: const EdgeInsets.fromLTRB(20, 16, 20, 0), padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: aCard, borderRadius: BorderRadius.circular(20), boxShadow: [aSubtleShadow]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.adminSectionNotificationSettings, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: aCharcoal)), const SizedBox(height: 16),
            _toggle(l.adminSettingEmailNotifsTitle, l.adminSettingEmailNotifsSub, _emailNotifs, (v) => setState(() => _emailNotifs = v)),
            _toggle(l.adminSettingPushNotifsTitle, l.adminSettingPushNotifsSub, _pushNotifs, (v) => setState(() => _pushNotifs = v)),
          ])),

        // SAVE BUTTON
        Padding(padding: const EdgeInsets.fromLTRB(20, 24, 20, 0), child: GestureDetector(onTap: () { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.adminToastSettingsSaved), behavior: SnackBarBehavior.floating)); },
          child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 16), decoration: BoxDecoration(gradient: const LinearGradient(colors: [aTeal, Color(0xFF009490)]), borderRadius: BorderRadius.circular(100)),
            child: Center(child: Text(l.adminActionSaveChanges, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white)))))),
      ]))),
    ])));
  }

  Widget _toggle(String title, String sub, bool value, ValueChanged<bool> onChanged) {
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: aCharcoal)),
        Text(sub, style: const TextStyle(fontSize: 13, color: aSecondary)),
      ])),
      Switch(value: value, activeTrackColor: aTeal, onChanged: onChanged),
    ]));
  }
}
