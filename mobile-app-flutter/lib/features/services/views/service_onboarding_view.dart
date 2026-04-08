import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/mock/mock_data.dart';

const _orange = Color(0xFFF97316);

class ServiceOnboardingView extends StatefulWidget {
  const ServiceOnboardingView({super.key});

  @override
  State<ServiceOnboardingView> createState() => _ServiceOnboardingViewState();
}

class _ServiceOnboardingViewState extends State<ServiceOnboardingView> {
  final Set<int> _selected = {};
  final _locationCtrl = TextEditingController();

  @override
  void dispose() {
    _locationCtrl.dispose();
    super.dispose();
  }

  IconData _iconForName(String name) {
    switch (name) {
      case 'restaurant':
        return Icons.restaurant;
      case 'celebration':
        return Icons.celebration;
      case 'palette':
        return Icons.palette;
      case 'music_note':
        return Icons.music_note;
      case 'build':
        return Icons.build;
      case 'cleaning_services':
        return Icons.cleaning_services;
      default:
        return Icons.category;
    }
  }

  Color _colorForName(String name) {
    switch (name) {
      case 'orange':
        return _orange;
      case 'purple':
        return AppColors.purple;
      case 'pink':
        return const Color(0xFFEC4899);
      case 'amber':
        return AppColors.amber;
      case 'blue':
        return const Color(0xFF3B82F6);
      case 'teal':
        return AppColors.teal;
      default:
        return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = MockData.serviceCategories;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const Text(
                'What are you looking for?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.charcoal,
                ),
              ),
              const SizedBox(height: 24),

              // Category grid — 2 columns
              Expanded(
                child: GridView.builder(
                  shrinkWrap: true,
                  itemCount: categories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.4,
                  ),
                  itemBuilder: (context, i) {
                    final cat = categories[i];
                    final color = _colorForName(cat['color'] as String);
                    final icon = _iconForName(cat['icon'] as String);
                    final isSelected = _selected.contains(i);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selected.remove(i);
                          } else {
                            _selected.add(i);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: isSelected
                              ? Border.all(color: _orange, width: 2)
                              : Border.all(color: Colors.transparent, width: 2),
                          boxShadow: [AppColors.cardShadow],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(icon, color: color, size: 22),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              cat['name'] as String,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.charcoal,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),
              const Text('Your location',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: TextField(
                  controller: _locationCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Enter your city',
                    hintStyle: TextStyle(color: AppColors.tertiary, fontSize: 14),
                    prefixIcon: Icon(Icons.pin_drop, color: AppColors.secondary, size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => context.go('/services/home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Start Discovering',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
