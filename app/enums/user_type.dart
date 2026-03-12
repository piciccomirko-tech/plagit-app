import '../routes/app_pages.dart';

enum UserType {
  admin(Routes.adminHome),
  client(Routes.clientHome),
  employee(Routes.employeeHome),
  guest(Routes.loginRegisterHints);

  final String homeRoute;

  const UserType(this.homeRoute);
}
