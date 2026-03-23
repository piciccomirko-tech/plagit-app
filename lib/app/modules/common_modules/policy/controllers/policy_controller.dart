import 'package:mh/app/common/utils/exports.dart';

class PolicyController extends GetxController {
  List<String> policyLabels = <String>[
    MyStrings.privacyPolicy.tr,
    MyStrings.deliveryPolicy.tr,
    MyStrings.refundPolicy.tr,
    MyStrings.cancellationPolicy.tr,
    MyStrings.addressDetails.tr,
    MyStrings.pricingPolicy.tr,
    MyStrings.goodsAndServicesDescription.tr,
    MyStrings.paymentMethods.tr,
    MyStrings.governingLaw.tr
  ];
  List<int> policyValue = <int>[1, 2, 3, 4, 5, 6, 7, 8, 9];
  RxString policyText = '''
<h2>Introduction</h2>
<p>At Plagit, we value our customers' privacy and are committed to protecting their personal information. This Privacy Policy outlines the types of information we collect, how it is used, and the measures we take to ensure your personal data is treated with the highest standards of security and confidentiality.</p>

<h2>Information Collection and Use</h2>
<p>We may collect information from you when you use our website, including but not limited to your name, email address, contact information, and payment details when you make a purchase or register on our site. The information collected is used to process transactions, provide the requested services, and enhance your experience with our services.</p>

<h2>Payment Information</h2>
<p>Plagit takes the following approach regarding the security of payment information:</p>
<p>- Credit/Debit Card Details: Plagit confirms that all credit/debit card details and personally identifiable information will NOT be stored, sold, shared, rented, or leased to any third parties.</p>

<h2>Third-Party Disclosure</h2>
<p>We do not sell, trade, or transfer your personally identifiable information to outside parties. This does not include trusted third parties who assist us in operating our website, conducting our business, or serving you, so long as those parties agree to keep this information confidential.</p>

<h2>Cookies and Tracking Technology</h2>
<p>Our website may use cookies and tracking technology depending on the features offered. Cookies and tracking technology are functional for gathering information such as browser type and operating system, tracking the number of visitors to the site, and understanding how visitors use the site.</p>

<h2>Policy Changes and Updates</h2>
<p>The following applies to our policy changes:</p>
<p>- Updates to Policies: The Website Policies and Terms and Conditions may be changed or updated occasionally to meet the requirements and standards. Therefore, customers are encouraged to frequently visit these sections to be updated on the changes on the website.</p>
<p>- Effective Date: Modifications will be effective on the day they are posted.</p>

<h2>Your Consent</h2>
<p>By using our site, you consent to our Privacy Policy.</p>

<h2>Contacting Us</h2>
<p>If you have any questions regarding this Privacy Policy, you may contact us using the information below:</p>
<p>info@plagit.com</p>

'''
      .obs;

  void onButtonTapped(int? value) {
    if (value == 2) {
      policyText.value = '''
      
<h2>Scope of Delivery</h2>
<p>Plagit is committed to complying with international trade regulations and laws, including those about the United Arab Emirates (UAE). In alignment with our commitment to corporate responsibility and legal compliance, the following policy applies to our delivery and shipping services:</p>

<h2>OFAC Sanctioned Countries</h2>
<p>- Compliance Statement: Plagit will NOT deal with or provide any services or products to any OFAC (Office of Foreign Assets Control) sanctioned countries by the law of the UAE.</p>

<h2>Product and Service Availability</h2>
<p>- Website Listings: Our website lists all products and services available for purchase and shipping. Each product or service's availability and delivery options are subject to compliance with our Delivery & Shipping Policy.</p>

<h2>Shipping Restrictions</h2>
<p>- Transparent Communication: Any shipping restrictions related to specific products or regions will be clearly communicated on our product pages and during checkout.</p>

<h2>Legal Framework</h2>
<p>- UAE Law: We operate under the strict legal framework of the UAE and ensure that all our shipping and delivery practices comply fully with the relevant laws and regulations.</p>

<h2>Customer Support</h2>
<p>• Queries and Clarifications: Customers are encouraged to contact our customer support team with any questions or clarifications related to our Delivery and Shipping policy.</p>

<p>Plagit endeavours to provide efficient delivery services while upholding legal and ethical standards. We appreciate our customers' trust and strive to meet their expectations responsibly.</p>
     
       ''';
    } else if (value == 3) {
      policyText.value = '''
      
<h2>Policy Statement</h2>
<p>Plagit's policy is to handle refunds with integrity and transparency. If refunds are applicable based on our terms and conditions, they will be processed in the following manner:</p>
<ul>
  <li>"Refunds will be done only through the Original Mode of Payment."</li>
  <li>This ensures that the funds are returned securely to the source from which they originated, maintaining a clear financial trail and protecting against fraud.</li>
</ul>

<h2>No Refund Statement</h2>
<p>- Clear Communication: If Plagit does not offer refunds for its products or services, this will be clearly articulated on our company's website to prevent misunderstandings. The statement to be provided on the website will read:</p>
<blockquote>
  <p>"Plagit does not provide refunds for any products or services. Please ensure you review your purchase carefully before proceeding with payment."</p>
</blockquote>

<h2>Return Policy</h2>
<ul>
  <li>Conditions for Return: If Plagit allows returns, conditions for returns will be detailed, including timelines, product condition requirements, and the process for initiating a return.</li>
</ul>

<h2>Customer Support</h2>
<ul>
  <li>Assistance and Queries: Customers can contact our customer service team for guidance and support regarding our refund/return policy.</li>
</ul>

<p>Plagit is committed to ensuring our customers are well-informed about their purchases and the policies that govern transactions on our website. We strive to provide clarity and convenience to enhance our customers' experience.</p>

      ''';
    } else if (value == 4) {
      policyText.value = '''
      
<h2>1. Cancellation Policy</h2>

<h3>a. Time Frame:</h3>
<p>You can cancel your order within 24 hours of purchase. Please note that once the 24-hour window has passed, your order will be processed for shipment and cannot be cancelled.</p>

<h3>b. Process:</h3>
<p>To cancel your order, please follow these steps:</p>
<ul>
  <li>Log in to your account.</li>
  <li>Go to the 'Orders' section.</li>
  <li>Select the order you wish to cancel.</li>
  <li>Click on 'Cancel Order' button.</li>
  <li>Confirm your cancellation.</li>
</ul>

<h3>c. Refunds:</h3>
<p>After cancellation, a full refund will be issued to your original method of payment within 7-10 business days.</p>

<h3>d. Exceptions:</h3>
<p>Certain products may not be eligible for cancellation due to their nature. This includes perishable goods, custom-made items, or services that have commenced execution with your agreement before the end of the 24-hour cancellation period.</p>

<h2>2. Replacement Policy</h2>

<h3>a. Conditions for Replacement:</h3>
<ul>
  <li>Incorrect Product: If the product delivered is not what was ordered.</li>
  <li>Damaged or Defective Product: If the product arrives damaged or has a manufacturing defect.</li>
  <li>Expiry Date: If the product received is expired or near its expiration date.</li>
</ul>

<h3>b. Time Frame:</h3>
<p>Replacement requests must be made within 7 days from the date of delivery.</p>

<h3>c. Process:</h3>
<ul>
  <li>Contact our Customer Service to initiate a replacement request.</li>
  <li>Provide a detailed description of the issue and attach photographic evidence if applicable.</li>
  <li>Once the replacement request is validated, the incorrect/damaged product must be returned in its original packaging.</li>
  <li>Replacement will be processed only after the received item has been inspected and deemed eligible.</li>
</ul>

<h3>d. Non-replaceable Products:</h3>
<p>Some products may be non-replaceable due to their nature. This includes products that are consumable, personalized, or part of a promotion.</p>

<h2>3. General Terms</h2>

<h3>a. Shipping Cost:</h3>
<p>For both cancelled orders and replacements, shipping costs will be borne by us if the error is ours (incorrect or defective item). In all other cases, the customer may be responsible for shipping costs.</p>

<h3>b. Policy Amendments:</h3>
<p>We reserve the right to modify any provisions of the cancellation and replacement policy without any prior notification. Any changes will be reflected in the terms of the policy here.</p>

<h3>c. Applicability:</h3>
<p>This policy applies to all products purchased via our website, subject to specific product/service exceptions noted within the policy.</p>

<p>This cancellation and replacement policy ensures that our customers receive products in their best condition and as per their expectations. If you have any questions or require further assistance, please contact our customer service team.</p>

       ''';
    } else if (value == 5) {
      policyText.value = '''
  <h2>Contact Information</h2>
<p><strong>Email:</strong> info@plagit.com</p>

      ''';
    } else if (value == 6) {
      policyText.value = '''
      
<h2>Introduction</h2>
<p>At Plagit, we believe in transparency and straightforwardness when pricing our services and products. Our pricing structure is designed to reflect our offerings' value and quality while being competitive and fair.</p>

<h2>Hourly Service Rates</h2>
<p>Our services are priced on an hourly basis. This ensures that you only pay for the time you need and the services you use. Here are the key points about our hourly service rates:</p>
<ul>
  <li>We staff our services to provide efficient and high-quality results, ensuring the best value for the time you pay for.</li>
  <li>Our hourly rates are determined by the service's complexity and nature.</li>
  <li>We provide detailed breakdowns of our hourly rates upon request to ensure complete transparency.</li>
</ul>

<h2>Pricing for Items and Products</h2>
<p>The pricing for items and products offered by Plagit is as follows:</p>
<ul>
  <li>All product pricing will be clearly listed on our website or provided at the point of inquiry.</li>
  <li>Our products are priced competitively, reflecting their quality and value.</li>
  <li>Discounts and promotions may be offered at our discretion and will be clearly communicated when available.</li>
</ul>

<h2>Mandatory Inclusion</h2>
<ul>
  <li>The inclusion of pricing for all items, products, and services is mandatory and will always be presented clearly to our customers before any commitment is made.</li>
  <li>We are committed to providing complete pricing information without hidden fees or charges.</li>
</ul>

<h2>Review and Adjustments</h2>
<ul>
  <li>Plagit reserves the right to review and adjust pricing to remain competitive and reflect market changes.</li>
  <li>Any pricing adjustments will be communicated to our customers with adequate notice.</li>
</ul>

<h2>Inquiries</h2>
<p>If you have any inquiries or need further clarification on our pricing, please do not hesitate to contact us. Our customer service team is always ready to provide the information you need to make an informed decision.</p>

<p>Plagit aims to maintain trust and ensure customer satisfaction by outlining our pricing policy. We are dedicated to providing our customers with the highest level of service at the best possible price.</p>

       ''';
    } else if (value == 7) {
      policyText.value = '''
    
<h2>Goods and Services Description</h2>
<p>Plagit ensures that a complete and detailed description of all the goods or services offered is available and easily accessible to all visitors, including the Acquiring RISK & Fraud team conducting reviews:</p>

<ol>
  <li><strong>Accessibility of Information:</strong> Detailed descriptions of our goods or services can be accessed directly on our website. This includes comprehensive information regarding each product or service's features, benefits, and specifications.</li>

  <li><strong>Transparency in Descriptions:</strong> We ensure that all descriptions are honest and accurate, giving our customers a true representation of what they can expect.</li>

  <li><strong>Review by RISK & Fraud Team:</strong> As our website undergoes review by the Acquiring RISK & Fraud team, we guarantee full cooperation by maintaining open access to all necessary documentation and descriptions that facilitate a thorough assessment.</li>

  <li><strong>Availability:</strong> Our descriptions are kept up-to-date and always present on the website, immediately reflecting any changes or updates to our goods or services.</li>

  <li><strong>Customer Support:</strong> If you have additional inquiries or need further explanation regarding our goods and services, our customer support team is available to provide assistance and clarify any information.</li>
</ol>

<p>Plagit is committed to upholding the highest standards of transparency and accuracy in presenting our goods and services, ensuring our customers and partners can always rely on the information provided.</p>

       ''';
    } else if (value == 8) {
      policyText.value = '''
      
<h2>Payment Methods</h2>
<p>We at Plagit value your security and convenience. To ensure a seamless transaction process, we have established the following payment methods:</p>

<ul>
  <li><strong>Online Payments:</strong> Customers can complete their purchases online, utilizing a secure and reliable payment system.</li>
</ul>

<h3>Accepted Card Types</h3>
<ul>
  <li><strong>Visa and MasterCard:</strong> We accept Visa and MasterCard credit/debit cards to accommodate many customers. We understand the importance of flexibility in payment options and have integrated these widely accepted card types into our payment system.</li>
</ul>

<h3>Currency</h3>
<ul>
  <li><strong>AED and Other Currencies:</strong> Transactions can be processed in AED, the currency of the United Arab Emirates. We are also open to processing payments in other agreed-upon currencies to accommodate our international customers.</li>
</ul>

<h3>Secure Transactions</h3>
<ul>
  <li><strong>Security Measures:</strong> The security of your financial information is paramount. Our website employs robust encryption and security protocols to protect all online transactions against fraud and unauthorized access.</li>
</ul>

<p>We encourage our customers to review their payment options and contact our customer support for any assistance or clarification regarding payment methods and currency options.</p>

       ''';
    } else if (value == 9) {
      policyText.value = '''
      
<h2>1. Governing Law</h2>
<p>Any purchase, dispute, or claim arising out of or in connection with this website shall be governed and construed in accordance with the laws of the United Arab Emirates (UAE).</p>

<h2>2. Jurisdiction</h2>

<h3>a. Exclusive Jurisdiction:</h3>
<p>All disputes or claims that arise under or relate to this website, its usability, or any transactions conducted through it, will be resolved exclusively in the competent courts of the United Arab Emirates. By using this website, you consent to the jurisdiction and venue of these courts in any such legal action or proceeding.</p>

<h3>b. Legal Compliance:</h3>
<p>Users are responsible for compliance with local laws, if and to the extent local laws are applicable. You agree not to access this website in any jurisdiction where doing so would be prohibited or illegal.</p>

<h3>c. Binding Agreement:</h3>
<p>This provision acts as a binding agreement between you and PLAGIT, determining the legal environment under which transactions and disputes are managed.</p>

<p>This governing law and jurisdiction clause ensures that both the customer and the company adhere to the legal standards and practices upheld in the UAE, promoting a secure and reliable environment for online transactions. For any further clarification or legal assistance, please consult with a legal advisor who specializes in UAE law.</p>

       ''';
    } else {
      policyText.value = '''
      
<h2>Introduction</h2>
<p>At Plagit, we value our customers' privacy and are committed to protecting their personal information. This Privacy Policy outlines the types of information we collect, how it is used, and the measures we take to ensure your personal data is treated with the highest standards of security and confidentiality.</p>

<h2>Information Collection and Use</h2>
<p>We may collect information from you when you use our website, including but not limited to your name, email address, contact information, and payment details when you make a purchase or register on our site. The information collected is used to process transactions, provide the requested services, and enhance your experience with our services.</p>

<h2>Payment Information</h2>
<p>Plagit takes the following approach regarding the security of payment information:</p>
<ul>
  <li><strong>Credit/Debit Card Details:</strong> Plagit confirms that all credit/debit card details and personally identifiable information will NOT be stored, sold, shared, rented, or leased to any third parties.</li>
</ul>

<h2>Third-Party Disclosure</h2>
<p>We do not sell, trade, or transfer your personally identifiable information to outside parties. This does not include trusted third parties who assist us in operating our website, conducting our business, or serving you, so long as those parties agree to keep this information confidential.</p>

<h2>Cookies and Tracking Technology</h2>
<p>Our website may use cookies and tracking technology depending on the features offered. Cookies and tracking technology are functional for gathering information such as browser type and operating system, tracking the number of visitors to the site, and understanding how visitors use the site.</p>

<h2>Policy Changes and Updates</h2>
<p>The following applies to our policy changes:</p>
<ul>
  <li><strong>Updates to Policies:</strong> The Website Policies and Terms and Conditions may be changed or updated occasionally to meet the requirements and standards. Therefore, customers are encouraged to frequently visit these sections to be updated on the changes on the website.</li>
  <li><strong>Effective Date:</strong> Modifications will be effective on the day they are posted.</li>
</ul>

<h2>Your Consent</h2>
<p>By using our site, you consent to our Privacy Policy.</p>

<h2>Contacting Us</h2>
<p>If you have any questions regarding this Privacy Policy, you may contact us using the information below:</p>
<p>Email: <a href="mailto:info@plagit.com">info@plagit.com</a></p>

''';
    }
  }
}
