import 'package:flutter/material.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/features/admin/views/admin_shared_widgets.dart';

class AdminSettingsView extends StatefulWidget {
  const AdminSettingsView({super.key});
  @override State<AdminSettingsView> createState() => _S();
}

class _S extends State<AdminSettingsView> {
  bool _maintenanceMode = false;
  bool _onboarding = true;
  bool _push = true;
  bool _email = true;
  bool _sms = false;
  bool _inApp = true;
  bool _mapEnabled = true;
  bool _autoFlag = true;
  bool _abuseFilter = true;
  bool _community = true;
  bool _homePreview = true;
  bool _nearMe = true;
  bool _mapMode = true;
  bool _offerFlow = false;
  bool _experimental = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: AppColors.background, body: SafeArea(child: Column(children: [
      AdminTopBar(title: 'Settings', onBack: () => Navigator.pop(context)),
      Expanded(child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xxxl),
        child: Column(children: [
          _card('General', Icons.settings, [
            _row('App Name', 'Plagit'), _row('Support Email', 'support@plagit.com'), _row('Support Phone', '+971 800 PLAGIT'),
            _tog('Maintenance Mode', _maintenanceMode, (v) => setState(() => _maintenanceMode = v), danger: true),
            _tog('Onboarding Enabled', _onboarding, (v) => setState(() => _onboarding = v)),
          ]),
          const SizedBox(height: AppSpacing.sectionGap),
          _card('Notifications', Icons.notifications, [
            _tog('Push', _push, (v) => setState(() => _push = v)),
            _tog('Email', _email, (v) => setState(() => _email = v)),
            _tog('SMS', _sms, (v) => setState(() => _sms = v)),
            _tog('In-App', _inApp, (v) => setState(() => _inApp = v)),
            _row('Reminder', '24h before interview'), _row('Retry', '3 retries, 1h apart'),
          ]),
          const SizedBox(height: AppSpacing.sectionGap),
          _card('Map & Location', Icons.map, [
            _tog('Map Enabled', _mapEnabled, (v) => setState(() => _mapEnabled = v)),
            _row('Default Radius', '5 km'), _row('Max Radius', '20 km'), _row('Location Prompt', 'On first launch'),
          ]),
          const SizedBox(height: AppSpacing.sectionGap),
          _card('Moderation', Icons.shield, [
            _tog('Auto-Flag Suspicious', _autoFlag, (v) => setState(() => _autoFlag = v)),
            _tog('Abuse Filter', _abuseFilter, (v) => setState(() => _abuseFilter = v)),
            _row('Report Types', 'Spam, Fake, Scam, Harassment'), _row('Auto-Suspend', '3 confirmed reports'),
          ]),
          const SizedBox(height: AppSpacing.sectionGap),
          _card('Community', Icons.chat_bubble, [
            _tog('Community Enabled', _community, (v) => setState(() => _community = v)),
            _tog('Home Preview', _homePreview, (v) => setState(() => _homePreview = v)),
            _row('Max Home Cards', '2'), _row('Featured Limit', '3 employers'),
          ]),
          const SizedBox(height: AppSpacing.sectionGap),
          _card('Billing', Icons.credit_card, [
            _row('Plans', 'Basic \$99 · Premium \$299 · Enterprise \$4,999'), _row('Trial', '14 days'), _row('Grace Period', '7 days'), _row('Failed Payment', 'Retry 3x then suspend'),
          ]),
          const SizedBox(height: AppSpacing.sectionGap),
          _card('Feature Flags', Icons.flag, [
            _tog('Near Me Jobs', _nearMe, (v) => setState(() => _nearMe = v)),
            _tog('Map Mode', _mapMode, (v) => setState(() => _mapMode = v)),
            _tog('Offer Flow', _offerFlow, (v) => setState(() => _offerFlow = v)),
            _tog('Experimental Onboarding', _experimental, (v) => setState(() => _experimental = v)),
          ]),
          const SizedBox(height: AppSpacing.sectionGap),
          _card('Localization', Icons.language, [_row('Default', 'English'), _row('Supported', 'English, Arabic, French'), _row('Regions', 'UAE, UK, EU')]),
          const SizedBox(height: AppSpacing.sectionGap),
          _card('Support', Icons.help, [_row('Help Center', 'help.plagit.com'), _row('Terms', 'plagit.com/terms'), _row('Privacy', 'plagit.com/privacy')]),
          const SizedBox(height: AppSpacing.sectionGap),
          _card('Account Security', Icons.lock, [
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/admin/change-password'),
              child: Padding(padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs), child: Row(children: [
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Change Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.charcoal)), Text('Update your admin login password', style: TextStyle(fontSize: 10, color: AppColors.tertiary))])),
                const Icon(Icons.chevron_right, size: 14, color: AppColors.tertiary),
              ])),
            ),
          ]),
          const SizedBox(height: AppSpacing.sectionGap),
          _dangerZone(),
          const SizedBox(height: AppSpacing.lg),
          const Center(child: Column(children: [Text('Plagit Admin v1.0.0', style: TextStyle(fontSize: 13, color: AppColors.tertiary)), SizedBox(height: AppSpacing.xs), Text('Build 2026.03.30', style: TextStyle(fontSize: 10, color: AppColors.tertiary))])),
        ]),
      )),
    ])));
  }

  Widget _card(String title, IconData icon, List<Widget> children) {
    return AdminCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      AdminSectionTitle(title: title, icon: icon),
      const SizedBox(height: AppSpacing.lg),
      ...children,
    ]));
  }

  Widget _row(String l, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs), child: Row(children: [Expanded(child: Text(l, style: const TextStyle(fontSize: 14, color: AppColors.secondary))), Flexible(child: Text(v, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.charcoal), textAlign: TextAlign.end, maxLines: 1, overflow: TextOverflow.ellipsis))]));

  Widget _tog(String l, bool v, ValueChanged<bool> onChanged, {bool danger = false}) => Padding(padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs), child: Row(children: [Expanded(child: Text(l, style: TextStyle(fontSize: 14, color: danger ? AppColors.urgent : AppColors.secondary))), Switch(value: v, onChanged: onChanged, activeColor: danger ? AppColors.urgent : AppColors.teal)]));

  Widget _dangerZone() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(AppRadius.xl), border: Border.all(color: AppColors.urgent.withValues(alpha: 0.12)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [const Icon(Icons.warning, size: 14, color: AppColors.urgent), const SizedBox(width: AppSpacing.sm), const Text('Danger Zone', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.charcoal))]),
        const SizedBox(height: AppSpacing.lg),
        _dangerRow('Clear Platform Cache', 'Remove all cached data'),
        _dangerRow('Maintenance Mode', 'Take platform offline'),
        _dangerRow('Purge Inactive Accounts', 'Remove accounts inactive >6 months'),
      ]),
    );
  }

  Widget _dangerRow(String t, String s) => Padding(padding: const EdgeInsets.only(bottom: AppSpacing.sm), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.urgent)), Text(s, style: const TextStyle(fontSize: 10, color: AppColors.tertiary))])), const Icon(Icons.chevron_right, size: 14, color: AppColors.tertiary)]));
}
