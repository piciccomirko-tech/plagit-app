import 'package:get/get.dart';

class PolicyController extends GetxController {
  List<String> policyLabels = <String>['Delivery Policy', 'Refund Policy', 'Cancellation Policy', 'Address Details'];
  List<int> policyValue = <int>[1, 2, 3, 4];
  RxString policyText = '''
  
Scope of Delivery

Plagit is committed to complying with international trade regulations and laws, including those about the United Arab Emirates (UAE). In alignment with our commitment to corporate responsibility and legal compliance, the following policy applies to our delivery and shipping services:

OFAC Sanctioned Countries

- Compliance Statement: Plagit will NOT deal with or provide any services or products to any OFAC (Office of Foreign Assets Control) sanctioned countries by the law of the UAE.

Product and Service Availability

- Website Listings: Our website lists all products and services available for purchase and shipping. Each product or service's availability and delivery options are subject to compliance with our Delivery & Shipping Policy.

Shipping Restrictions

- Transparent Communication: Any shipping restrictions related to specific products or regions will be clearly communicated on our product pages and during checkout.

Legal Framework

- UAE Law: We operate under the strict legal framework of the UAE and ensure that all our shipping and delivery practices comply fully with the relevant laws and regulations.

Customer Support

• Queries and Clarifications: Customers are encouraged to contact our customer support team with any questions or clarifications related to our Delivery and Shipping policy.

Plagit endeavours to provide efficient delivery services while upholding legal and ethical standards. We appreciate our customers' trust and strive to meet their expectations responsibly.

'''
      .obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void onButtonTapped(int value) {
    if (value == 2) {
      policyText.value = '''
      
- Policy Statement: Plagit's policy is to handle refunds with integrity and transparency. If refunds are applicable based on our terms and conditions, they will be processed in the following manner:
- "Refunds will be done only through the Original Mode of Payment."
- This ensures that the funds are returned securely to the source from which they originated, maintaining a clear financial trail and protecting against fraud.

No Refund Statement

- Clear Communication: If Plagit does not offer refunds for its products or services, this will be clearly articulated on our company's website to prevent misunderstandings. The statement to be provided on the website will read:
  - "Plagit does not provide refunds for any products or services. Please ensure you review your purchase carefully before proceeding with payment."

Return Policy

- Conditions for Return: If Plagit allows returns, conditions for returns will be detailed, including timelines, product condition requirements, and the process for initiating a return.

Customer Support

- Assistance and Queries: Customers can contact our customer service team for guidance and support regarding our refund/return policy.

Plagit is committed to ensuring our customers are well-informed about their purchases and the policies that govern transactions on our website. We strive to provide clarity and convenience to enhance our customers' experience.

      ''';
    } else if (value == 3) {
      policyText.value = '''
      
1. Cancellation Policy

a. Time Frame: You can cancel your order within 24 hours of purchase. Please note that once the 24-hour window has passed, your order will be processed for shipment and cannot be cancelled.

b. Process: To cancel your order, please follow these steps:
   - Log in to your account.
   - Go to the 'Orders' section.
   - Select the order you wish to cancel.
   - Click on 'Cancel Order' button.
   - Confirm your cancellation.

c. Refunds: After cancellation, a full refund will be issued to your original method of payment within 7-10 business days.

d. Exceptions: Certain products may not be eligible for cancellation due to their nature. This includes perishable goods, custom-made items, or services that have commenced execution with your agreement before the end of the 24-hour cancellation period.

2. Replacement Policy

a. Conditions for Replacement:
   - Incorrect Product: If the product delivered is not what was ordered.
   - Damaged or Defective Product: If the product arrives damaged or has a manufacturing defect.
   - Expiry Date: If the product received is expired or near its expiration date.

b. Time Frame: Replacement requests must be made within 7 days from the date of delivery.

c. Process:
   - Contact our Customer Service to initiate a replacement request.
   - Provide a detailed description of the issue and attach photographic evidence if applicable.
   - Once the replacement request is validated, the incorrect/damaged product must be returned in its original packaging.
   - Replacement will be processed only after the received item has been inspected and deemed eligible.

d. Non-replaceable Products: Some products may be non-replaceable due to their nature. This includes products that are consumable, personalized, or part of a promotion.

3. General Terms

a. Shipping Cost: For both cancelled orders and replacements, shipping costs will be borne by us if the error is ours (incorrect or defective item). In all other cases, the customer may be responsible for shipping costs.

b. Policy Amendments: We reserve the right to modify any provisions of the cancellation and replacement policy without any prior notification. Any changes will be reflected in the terms of the policy here.

c. Applicability: This policy applies to all products purchased via our website, subject to specific product/service exceptions noted within the policy.

This cancellation and replacement policy ensures that our customers receive products in their best condition and as per their expectations. If you have any questions or require further assistance, please contact our customer service team.
       
       ''';
    } else if (value == 4) {
      policyText.value = '''
      
      Phone: +971524033856.
      
      Email: support@plagit.com.
      
      Office Address: Souk Al Bahar Saaha C,
      Downtown Dubai.
      
      ''';
    } else {
      policyText.value = '''
      
Scope of Delivery

Plagit is committed to complying with international trade regulations and laws, including those about the United Arab Emirates (UAE). In alignment with our commitment to corporate responsibility and legal compliance, the following policy applies to our delivery and shipping services:

OFAC Sanctioned Countries

- Compliance Statement: Plagit will NOT deal with or provide any services or products to any OFAC (Office of Foreign Assets Control) sanctioned countries by the law of the UAE.

Product and Service Availability

- Website Listings: Our website lists all products and services available for purchase and shipping. Each product or service's availability and delivery options are subject to compliance with our Delivery & Shipping Policy.

Shipping Restrictions

- Transparent Communication: Any shipping restrictions related to specific products or regions will be clearly communicated on our product pages and during checkout.

Legal Framework

- UAE Law: We operate under the strict legal framework of the UAE and ensure that all our shipping and delivery practices comply fully with the relevant laws and regulations.

Customer Support

• Queries and Clarifications: Customers are encouraged to contact our customer support team with any questions or clarifications related to our Delivery and Shipping policy.

Plagit endeavours to provide efficient delivery services while upholding legal and ethical standards. We appreciate our customers' trust and strive to meet their expectations responsibly.

''';
    }
  }
}
