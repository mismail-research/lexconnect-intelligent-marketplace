class LawyerProfileValidator {
  static String? validateName(String value) {
    if (value.trim().isEmpty) return "Name is required";
    return null;
  }

  static String? validateLocation(String value) {
    if (value.trim().length > 16) {
      return "Office location max 16 characters";
    }
    return null;
  }

  static String? validateWhatsapp(String value) {
    if (!RegExp(r'^03\d{9}$').hasMatch(value)) {
      return "Enter valid WhatsApp number (03XXXXXXXXX)";
    }
    return null;
  }

  static String? validateExperience(String value) {
    final exp = int.tryParse(value.trim()) ?? 0;
    if (exp > 50) {
      return "Experience cannot be more than 50 years";
    }
    return null;
  }

  static String? validateCases(String value) {
    final cases = int.tryParse(value.trim()) ?? 0;
    if (cases > 9999) {
      return "Case won cannot exceed 9999";
    }
    return null;
  }
}