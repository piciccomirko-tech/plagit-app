import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/mock/mock_data.dart';

class NearbyMapView extends StatelessWidget {
  const NearbyMapView({super.key});

  @override
  Widget build(BuildContext context) {
    final londonJobs = MockData.londonJobs;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Nearby Jobs',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.charcoal,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text(
              'List',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.teal,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map placeholder background
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFFE8E8E8),
          ),

          // Center placeholder text
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.map, size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(
                  'Map view',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),

          // Mock pins (teal dots)
          Positioned(
            top: 120,
            left: 80,
            child: _buildPin(),
          ),
          Positioned(
            top: 200,
            right: 100,
            child: _buildPin(),
          ),
          Positioned(
            top: 300,
            left: 160,
            child: _buildPin(),
          ),
          Positioned(
            top: 180,
            left: 240,
            child: _buildPin(),
          ),
          Positioned(
            top: 350,
            right: 60,
            child: _buildPin(),
          ),

          // Bottom floating sheet with job cards
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 8),
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Horizontal scrolling job cards
                  SizedBox(
                    height: 140,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: londonJobs.length,
                      itemBuilder: (context, index) {
                        final job = londonJobs[index];
                        return _buildCompactJobCard(context, job);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPin() {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: AppColors.teal,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactJobCard(BuildContext context, Map<String, dynamic> job) {
    final company = job['company'] as String? ?? '';
    final title = job['title'] as String? ?? '';
    final salary = job['salary'] as String? ?? '';
    final location = job['location'] as String? ?? '';

    return GestureDetector(
      onTap: () => context.push('/candidate/job/${job['id']}'),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              company,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.charcoal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.secondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              salary,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.teal,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 12,
                  color: AppColors.tertiary,
                ),
                const SizedBox(width: 2),
                Text(
                  location,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.tertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
