enum UserRole {
  customer,
  petugas;

  String get displayName {
    switch (this) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.petugas:
        return 'Petugas';
    }
  }

  String get description {
    switch (this) {
      case UserRole.customer:
        return 'Pengguna yang ingin membuang sampah';
      case UserRole.petugas:
        return 'Petugas pengambil sampah';
    }
  }

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'customer':
        return UserRole.customer;
      case 'petugas':
        return UserRole.petugas;
      default:
        return UserRole.customer;
    }
  }
}