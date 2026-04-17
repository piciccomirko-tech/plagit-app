/// Canonical user roles — single source of truth.
///
/// The backend returns a role string in the auth response. This enum
/// normalizes it so the rest of the app never compares raw strings.
/// Admin/super-admin separation allows future permission granularity
/// (e.g. super_admin can delete accounts, admin can only moderate).
enum UserRole {
  candidate,
  business,
  admin,
  superAdmin;

  /// Parse a role string from the backend into a [UserRole].
  /// Unknown values default to [candidate] to avoid crashes, but
  /// the login flow will reject mismatched roles before this matters.
  static UserRole fromString(String? value) {
    return switch (value?.toLowerCase().replaceAll('-', '_')) {
      'candidate' => UserRole.candidate,
      'business' => UserRole.business,
      'admin' => UserRole.admin,
      'super_admin' || 'superadmin' => UserRole.superAdmin,
      _ => UserRole.candidate,
    };
  }

  /// The string stored in [TokenStorage] and sent to/from the backend.
  String get storedValue => switch (this) {
    UserRole.candidate => 'candidate',
    UserRole.business => 'business',
    UserRole.admin => 'admin',
    UserRole.superAdmin => 'super_admin',
  };

  /// Whether this role has admin-level access (admin or super_admin).
  bool get isAdmin => this == UserRole.admin || this == UserRole.superAdmin;

  /// Display label for UI.
  String get displayName => switch (this) {
    UserRole.candidate => 'Candidate',
    UserRole.business => 'Business',
    UserRole.admin => 'Admin',
    UserRole.superAdmin => 'Super Admin',
  };
}
