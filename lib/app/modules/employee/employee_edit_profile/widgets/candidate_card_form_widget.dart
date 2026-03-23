import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../../common/widgets/custom_buttons.dart';
import '../../../../common/widgets/custom_text_input_field.dart';
import '../../../../enums/custom_button_style.dart';
import '../controllers/employee_edit_profile_controller.dart';


class CandidateCardFormWidget extends GetWidget<EmployeeEditProfileController> {

  final TextEditingController _holderNameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  CandidateCardFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Toggle between form and carousel based on the showForm flag
      return controller.showForm.value ? _cardForm() : _cardCarousel();
    });
  }

  // Card Form for Adding New Cards
  Widget _cardForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Add New Card'),
        CustomTextInputField(
          controller: _holderNameController,
          label: 'Card Holder Name',
          prefixIcon: Icons.person,
        ),
        const SizedBox(height: 20),
        CustomTextInputField(
          controller: _cardNumberController,
          label: 'Card Number',
          prefixIcon: Icons.credit_card,
        ),
        const SizedBox(height: 20),
        CustomTextInputField(
          controller: _expiryDateController,
          label: 'Expiry Date',
          prefixIcon: Icons.calendar_today,
        ),
        const SizedBox(height: 20),
        CustomTextInputField(
          controller: _cvvController,
          label: 'CVV',
          prefixIcon: Icons.lock,
        ),
        const SizedBox(height: 20),
        CustomButtons.button(
          height: 48,
          text: "Save Card",
          fontSize: 16,
          margin: EdgeInsets.zero,
          customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
          onTap: _saveCard,
        ),
      ],
    );
  }

  // Save card data and switch to carousel view
  void _saveCard() {
    // Collect card data
    final card = {
      'holder': _holderNameController.text,
      'number': _cardNumberController.text,
      'expiry': _expiryDateController.text,
      'cvv': _cvvController.text,
      'type': 'Credit',
    };

    // Add the card to the observable list
    controller.addCard2(card);

    // Clear the form after saving
    _holderNameController.clear();
    _cardNumberController.clear();
    _expiryDateController.clear();
    _cvvController.clear();

    // Switch to carousel view
    controller.showForm.value = false;
  }

  // Card Carousel to Show Existing Cards
  Widget _cardCarousel() {
    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: controller.cards.length,
          itemBuilder: (context, index, realIndex) {
            return _buildCardItem(controller.cards[index]);
          },
          options: CarouselOptions(
            height: 200,
            enlargeCenterPage: true,
            enableInfiniteScroll: false,
            viewportFraction: 0.9,
            
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: 250.w,
          child: CustomButtons.button(
            height: 48,
            text: "Add Another Card",
            fontSize: 16,
            margin: EdgeInsets.zero,
            customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
            onTap: () {
              // Show the form to add another card
              controller.showForm.value = true;
            },
          ),
        ),
      ],
    );
  }

  // Individual Card Item
 Widget _buildCardItem(Map<String, String> card) {
  return Stack(
    children: [
      // Card background image
      Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: AssetImage('assets/images/card.png'), // Use the uploaded card image
            fit: BoxFit.cover,
          ),
        ),
      ),

      // Overlay card details on top of the image
      Positioned.fill(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Card Type
              Text(
                card['type'] ?? 'Credit',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Spacer
              const Spacer(),

              // Card Holder Name
              Text(
                card['holder'] ?? 'Card Holder',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 8),

              // Card Number
              Text(
                card['number'] ?? 'XXXX - XXXX - XXXX - XXXX',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 16),

              // Bottom Row: Expiry Date & Delete Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Expiry Date
                  Text(
                    'Expiry: ${card['expiry'] ?? 'MM/YY'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),

                  // Delete Button
                  IconButton(
                    onPressed: () {
                      controller.deleteCard(card);
                    },
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

  // Helper to build section titles
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
