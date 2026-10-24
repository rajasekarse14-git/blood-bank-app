/// Centralized form validation utilities for HemoLife 2.0.
class Validators {
  Validators._();

  /// Validates a non-empty name.
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a name.';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters.';
    }
    return null;
  }

  /// Validates donor age between 18 and 65 (WHO blood donor guidelines).
  static String? validateAge(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter donor age.';
    }
    final age = int.tryParse(value.trim());
    if (age == null) {
      return 'Please enter a valid number.';
    }
    if (age < 18) {
      return 'Donors must be at least 18 years old.';
    }
    if (age > 65) {
      return 'Donors must be 65 years or younger.';
    }
    return null;
  }

  /// Validates 10-digit phone number.
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a contact phone number.';
    }
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (!RegExp(r'^\d{10}$').hasMatch(cleaned)) {
      return 'Please enter a valid 10-digit phone number.';
    }
    return null;
  }

  /// Validates hospital name.
  static String? validateHospital(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter the hospital name.';
    }
    if (value.trim().length < 3) {
      return 'Hospital name must be at least 3 characters.';
    }
    return null;
  }

  /// Validates address.
  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter an address or location.';
    }
    if (value.trim().length < 4) {
      return 'Address must be at least 4 characters.';
    }
    return null;
  }

  /// Validates blood group is non-empty and valid.
  static String? validateBloodGroup(String? value) {
    const validGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
    if (value == null || value.trim().isEmpty) {
      return 'Please select a blood group.';
    }
    if (!validGroups.contains(value.trim())) {
      return 'Invalid blood group selected.';
    }
    return null;
  }

  /// Validates quantity is between 1 and 20 units.
  static String? validateQuantity(int quantity) {
    if (quantity < 1) {
      return 'Quantity must be at least 1 unit.';
    }
    if (quantity > 20) {
      return 'Maximum request is 20 units at a time.';
    }
    return null;
  }
}
