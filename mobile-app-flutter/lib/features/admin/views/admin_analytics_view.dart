import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/theme/app_colors.dart';

class AdminAnalyticsView extends StatefulWidget {
  const AdminAnalyticsView({super.key});
  @override
  State<AdminAnalyticsView> createState() => _AdminAnalyticsViewState();
}

class _AdminAnalyticsViewState extends State<AdminAnalyticsView> {
  String _period = 'Month';
  final _periods = ['Today', 'Week', 'Month', 'Year'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.charcoal),
          onPressed: () => context.pop(),
        ),
        title: const Text('Analytics',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.charcoal)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period selector chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _periods.map((p) {
                  final sel = _period == p;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _period = p),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: sel
                              ? AppColors.teal
                              : AppColors.teal.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(p,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color:
                                    sel ? Colors.white : AppColors.teal)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // KPI cards 2x2
            Row(
              children: [
                Expanded(
                    child: _kpiCard(
                        '47', 'New Candidates', '+12%', AppColors.teal)),
                const SizedBox(width: 10),
                Expanded(
                    child: _kpiCard(
                        '8', 'New Businesses', '+5%', AppColors.purple)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                    child: _kpiCard(
                        '23', 'Jobs Posted', '+8%', AppColors.amber)),
                const SizedBox(width: 10),
                Expanded(
                    child: _kpiCard(
                        '156', 'Applications', '+15%', AppColors.green)),
              ],
            ),
            const SizedBox(height: 16),

            // Application Funnel
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Application Funnel',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.charcoal)),
                  const SizedBox(height: 14),
                  _funnelBar('Applied', 156, 100, AppColors.teal),
                  _funnelBar('Viewed', 134, 86,
                      AppColors.teal.withValues(alpha: 0.7)),
                  _funnelBar('Shortlisted', 67, 43,
                      AppColors.teal.withValues(alpha: 0.55)),
                  _funnelBar('Interview', 23, 15,
                      AppColors.teal.withValues(alpha: 0.4)),
                  _funnelBar('Hired', 8, 5,
                      AppColors.teal.withValues(alpha: 0.3)),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Platform Growth
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Platform Growth',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.charcoal)),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 140,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _barGroup('Mon', 0.6, 0.3),
                        _barGroup('Tue', 0.8, 0.4),
                        _barGroup('Wed', 0.5, 0.5),
                        _barGroup('Thu', 0.9, 0.35),
                        _barGroup('Fri', 0.7, 0.6),
                        _barGroup('Sat', 0.4, 0.2),
                        _barGroup('Sun', 0.3, 0.15),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _legendDot(AppColors.teal, 'Candidates'),
                      const SizedBox(width: 16),
                      _legendDot(AppColors.purple, 'Businesses'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Premium Conversion
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Premium Conversion',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.charcoal)),
                  const SizedBox(height: 12),
                  const Text('11.7%',
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: AppColors.teal)),
                  const SizedBox(height: 4),
                  const Text('156 premium out of 1,336 total',
                      style: TextStyle(
                          fontSize: 13, color: AppColors.secondary)),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: 0.117,
                      minHeight: 8,
                      backgroundColor:
                          AppColors.teal.withValues(alpha: 0.12),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.teal),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Top Locations
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Top Locations',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.charcoal)),
                  const SizedBox(height: 14),
                  _locationRow('London', 0.67, '67%'),
                  const SizedBox(height: 10),
                  _locationRow('Dubai', 0.28, '28%'),
                  const SizedBox(height: 10),
                  _locationRow('Milan', 0.05, '5%'),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _kpiCard(String value, String label, String change, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: color)),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(change,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.secondary)),
        ],
      ),
    );
  }

  Widget _funnelBar(String label, int count, int percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$label: $count',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.charcoal)),
              Text('$percentage%',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.secondary)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 16,
              backgroundColor: AppColors.divider,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _barGroup(String day, double candidateH, double businessH) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 10,
                height: 100 * candidateH,
                decoration: BoxDecoration(
                  color: AppColors.teal,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 2),
              Container(
                width: 10,
                height: 100 * businessH,
                decoration: BoxDecoration(
                  color: AppColors.purple,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(day,
              style: const TextStyle(
                  fontSize: 10, color: AppColors.tertiary)),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AppColors.secondary)),
      ],
    );
  }

  Widget _locationRow(String city, double value, String percentage) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(city,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.charcoal)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: AppColors.teal.withValues(alpha: 0.12),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.teal),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 36,
          child: Text(percentage,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.charcoal)),
        ),
      ],
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.cardShadow],
      ),
      child: child,
    );
  }
}
