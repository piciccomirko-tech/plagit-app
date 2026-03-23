import 'package:mh/app/enums/user_type.dart';

abstract class RegisterInterface {
  void onTermsAndConditionCheck(bool active);

  void onTermsAndConditionPressed();

  void onLoginPressed();

  void onContinuePressed();

  void onUserTypeClick(UserType userType);

  void onPageChange(int index);

  void  onPositionChange(String? position);
}
