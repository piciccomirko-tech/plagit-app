import 'package:get/get.dart';

class PolicyController extends GetxController {
  List<String> policyLabels = <String>[
    'Privacy Policy',
    'Delivery Policy',
    'Refund Policy',
    'Cancellation Policy',
    'Address Details',
    "Pricing Policy",
    "Goods and Services Description",
    "Payment Methods",
    "Governing Law"
  ];
  List<int> policyValue = <int>[1, 2, 3, 4, 5, 6, 7, 8, 9];
  RxString policyText = '''
  
Introduction

At Plagit, we value our customers' privacy and are committed to protecting their personal information. This Privacy Policy outlines the types of information we collect, how it is used, and the measures we take to ensure your personal data is treated with the highest standards of security and confidentiality.

Information Collection and Use

We may collect information from you when you use our website, including but not limited to your name, email address, contact information, and payment details when you make a purchase or register on our site. The information collected is used to process transactions, provide the requested services, and enhance your experience with our services.

Payment Information

Plagit takes the following approach regarding the security of payment information:

- Credit/Debit Card Details: Plagit confirms that all credit/debit card details and personally identifiable information will NOT be stored, sold, shared, rented, or leased to any third parties.

Third-Party Disclosure

We do not sell, trade, or transfer your personally identifiable information to outside parties. This does not include trusted third parties who assist us in operating our website, conducting our business, or serving you, so long as those parties agree to keep this information confidential.

Cookies and Tracking Technology

Our website may use cookies and tracking technology depending on the features offered. Cookies and tracking technology are functional for gathering information such as browser type and operating system, tracking the number of visitors to the site, and understanding how visitors use the site.

Policy Changes and Updates

The following applies to our policy changes:

- Updates to Policies: The Website Policies and Terms and Conditions may be changed or updated occasionally to meet the requirements and standards. Therefore, customers are encouraged to frequently visit these sections to be updated on the changes on the website.

- Effective Date: Modifications will be effective on the day they are posted.

Your Consent

By using our site, you consent to our Privacy Policy.

Contacting Us

If you have any questions regarding this Privacy Policy, you may contact us using the information below:

Support@plagit.com

'''
      .obs;

  void onButtonTapped(int value) {
    if (value == 2) {
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
    } else if (value == 3) {
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
    } else if (value == 4) {
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
    } else if (value == 5) {
      policyText.value = '''
      
      Phone: +971524033856.
      
      Email: support@plagit.com.
      
      Office Address: Souk Al Bahar Saaha C,
      Downtown Dubai.
      
      ''';
    } else if (value == 6) {
      policyText.value = '''
      
Introduction

At Plagit, we believe in transparency and straightforwardness when pricing our services and products. Our pricing structure is designed to reflect our offerings' value and quality while being competitive and fair.

Hourly Service Rates

Our services are priced on an hourly basis. This ensures that you only pay for the time you need and the services you use. Here are the key points about our hourly service rates:

- We staff our services to provide efficient and high-quality results, ensuring the best value for the time you pay for.
- Our hourly rates are determined by the service's complexity and nature.
- We provide detailed breakdowns of our hourly rates upon request to ensure complete transparency.

Pricing for Items and Products

The pricing for items and products offered by Plagit is as follows:

- All product pricing will be clearly listed on our website or provided at the point of inquiry.
- Our products are priced competitively, reflecting their quality and value.
- Discounts and promotions may be offered at our discretion and will be clearly communicated when available.

Mandatory Inclusion

- The inclusion of pricing for all items, products, and services is mandatory and will always be presented clearly to our customers before any commitment is made.
- We are committed to providing complete pricing information without hidden fees or charges.

Review and Adjustments

- Plagit reserves the right to review and adjust pricing to remain competitive and reflect market changes.
- Any pricing adjustments will be communicated to our customers with adequate notice.

Inquiries

If you have any inquiries or need further clarification on our pricing, please do not hesitate to contact us. Our customer service team is always ready to provide the information you need to make an informed decision.


Plagit aims to maintain trust and ensure customer satisfaction by outlining our pricing policy. We are dedicated to providing our customers with the highest level of service at the best possible price.

       ''';
    } else if (value == 7) {
      policyText.value = '''
    
Plagit ensures that a complete and detailed description of all the goods or services offered is available and easily accessible to all visitors, including the Acquiring RISK & Fraud team conducting reviews:

1. Accessibility of Information: Detailed descriptions of our goods or services can be accessed directly on our website. This includes comprehensive information regarding each product or service's features, benefits, and specifications.

2. Transparency in Descriptions: We ensure that all descriptions are honest and accurate, giving our customers a true representation of what they can expect.

3. Review by RISK & Fraud Team: As our website undergoes review by the Acquiring RISK & Fraud team, we guarantee full cooperation by maintaining open access to all necessary documentation and descriptions that facilitate a thorough assessment.

4. Availability: Our descriptions are kept up-to-date and always present on the website, immediately reflecting any changes or updates to our goods or services.

5. Customer Support: If you have additional inquiries or need further explanation regarding our goods and services, our customer support team is available to provide assistance and clarify any information.

Plagit is committed to upholding the highest standards of transparency and accuracy in presenting our goods and services, ensuring our customers and partners can always rely on the information provided.

       ''';
    } else if (value == 8) {
      policyText.value = '''
      
We at Plagit value your security and convenience. To ensure a seamless transaction process, we have established the following payment methods:

- Online Payments: Customers can complete their purchases online, utilizing a secure and reliable payment system.

Accepted Card Types

- Visa and MasterCard: We accept Visa and MasterCard credit/debit cards to accommodate many customers. We understand the importance of flexibility in payment options and have integrated these widely accepted card types into our payment system.

Currency

- AED and Other Currencies: Transactions can be processed in AED, the currency of the United Arab Emirates. We are also open to processing payments in other agreed-upon currencies to accommodate our international customers.

Secure Transactions

- Security Measures: The security of your financial information is paramount. Our website employs robust encryption and security protocols to protect all online transactions against fraud and unauthorized access.

We would like to encourage our customers to review their payment options and contact our customer support for any assistance or clarification regarding payment methods and currency options.

       ''';
    } else if (value == 9) {
      policyText.value = '''
      
1. Governing Law

Any purchase, dispute, or claim arising out of or in connection with this website shall be governed and construed in accordance with the laws of the United Arab Emirates (UAE).

2. Jurisdiction

a. Exclusive Jurisdiction: All disputes or claims that arise under or relate to this website, its usability, or any transactions conducted through it, will be resolved exclusively in the competent courts of the United Arab Emirates. By using this website, you consent to the jurisdiction and venue of these courts in any such legal action or proceeding.

b. Legal Compliance: Users are responsible for compliance with local laws, if and to the extent local laws are applicable. You agree not to access this website in any jurisdiction where doing so would be prohibited or illegal.

c. Binding Agreement: This provision acts as a binding agreement between you and PLAGIT, determining the legal environment under which transactions and disputes are managed.

This governing law and jurisdiction clause ensures that both the customer and the company adhere to the legal standards and practices upheld in the UAE, promoting a secure and reliable environment for online transactions. For any further clarification or legal assistance, please consult with a legal advisor who specializes in UAE law.

       ''';
    } else {
      policyText.value = '''
      
Introduction

At Plagit, we value our customers' privacy and are committed to protecting their personal information. This Privacy Policy outlines the types of information we collect, how it is used, and the measures we take to ensure your personal data is treated with the highest standards of security and confidentiality.

Information Collection and Use

We may collect information from you when you use our website, including but not limited to your name, email address, contact information, and payment details when you make a purchase or register on our site. The information collected is used to process transactions, provide the requested services, and enhance your experience with our services.

Payment Information

Plagit takes the following approach regarding the security of payment information:

- Credit/Debit Card Details: Plagit confirms that all credit/debit card details and personally identifiable information will NOT be stored, sold, shared, rented, or leased to any third parties.

Third-Party Disclosure

We do not sell, trade, or transfer your personally identifiable information to outside parties. This does not include trusted third parties who assist us in operating our website, conducting our business, or serving you, so long as those parties agree to keep this information confidential.

Cookies and Tracking Technology

Our website may use cookies and tracking technology depending on the features offered. Cookies and tracking technology are functional for gathering information such as browser type and operating system, tracking the number of visitors to the site, and understanding how visitors use the site.

Policy Changes and Updates

The following applies to our policy changes:

- Updates to Policies: The Website Policies and Terms and Conditions may be changed or updated occasionally to meet the requirements and standards. Therefore, customers are encouraged to frequently visit these sections to be updated on the changes on the website.

- Effective Date: Modifications will be effective on the day they are posted.

Your Consent

By using our site, you consent to our Privacy Policy.

Contacting Us

If you have any questions regarding this Privacy Policy, you may contact us using the information below:

Support@plagit.com

''';
    }
  }
}
