import '../enums/user_type.dart';
import 'admin.dart';
import 'client.dart';
import 'employee.dart';

class User {
  UserType? userType;

  Client? client;
  Employee? employee;
  Admin? admin;

  User({
    this.userType,
    this.client,
    this.employee,
  });

  bool get isClient => userType == UserType.client;
  bool get isEmployee => userType == UserType.employee;
  bool get isAdmin => userType == UserType.admin;
  bool get isGuest => userType == UserType.guest;

  String get userId => _getUserIdAndNameAndOtherInfo[0];
  String get userName => _getUserIdAndNameAndOtherInfo[1];
  String get userRole => _getUserIdAndNameAndOtherInfo[2];

  List<String> get _getUserIdAndNameAndOtherInfo {
    String id = '';
    String name = '';
    String role = '';

    if(isClient) {
      id = client?.id ?? "Client id get failed";
      name = client?.restaurantName ?? "Restaurant Owner";
      role = client?.role ?? "CLIENT";
    } else if(isEmployee) {
      id = employee?.id ?? "Employee id get failed";
      name = employee?.name ?? "Employee";
      role = employee?.role ?? "EMPLOYEE";
    } else if(isAdmin) {
      id = admin?.id ?? "Admin id get failed";
      name = admin?.name ?? "Admin";
      role = admin?.role ?? "ADMIN";
    }

    return [id, name, role];
  }
}
