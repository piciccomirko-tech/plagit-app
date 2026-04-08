import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/theme/app_colors.dart';

const _orange = Color(0xFFF97316);

class ServiceEntryView extends StatelessWidget {
  const ServiceEntryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.charcoal),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Looking for Companies',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.charcoal,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              // Orange circle with grid icon
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: _orange,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.grid_view, color: Colors.white, size: 36),
              ),
              const SizedBox(height: 24),
              const Text(
                'Hospitality Services',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.charcoal,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Register your service company or find hospitality providers near you',
                style: TextStyle(fontSize: 14, color: AppColors.secondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Card 1 — Register as a Business
              GestureDetector(
                onTap: () => context.push('/services/register'),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [AppColors.cardShadow],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _orange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.store, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Register as a Business',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.charcoal,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'List your hospitality service and get discovered by clients',
                              style: TextStyle(fontSize: 12, color: AppColors.secondary),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward, color: _orange, size: 20),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Card 2 — I'm Looking for a Business
              GestureDetector(
                onTap: () => context.push('/services/discover'),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [AppColors.cardShadow],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.teal,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.search, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "I'm Looking for a Business",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.charcoal,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Find hospitality service providers near you',
                              style: TextStyle(fontSize: 12, color: AppColors.secondary),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward, color: AppColors.teal, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
