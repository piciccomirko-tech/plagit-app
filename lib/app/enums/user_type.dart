import '../routes/app_pages.dart';

enum UserType {
  admin(Routes.adminRoot),
  client(Routes.clientPremiumRoot),
  employee(Routes.employeeRoot),
  premiumClient(Routes.clientPremiumRoot),
  guest(Routes.loginRegisterHints);

  final String homeRoute;

  const UserType(this.homeRoute);
}
