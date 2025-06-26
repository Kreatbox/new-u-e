class Validator {
  static String? validateName(String value) {
    if (value.isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    if (value.length < 2) {
      return 'يجب أن يكون الاسم مكونًا من حرفين على الأقل';
    }
    return null;
  }

  static String? validateFullname(String value) {
    if (value.isEmpty) {
      return 'اسم الأم وكنيتها مطلوب';
    }
    if (value.length < 6 && value.contains(" ")) {
      return 'يجب أن يكون الاسم مكونًا من حرفين على الأقل';
    }
    return null;
  }

  static String? validateDateOfBirth(String value) {
    if (value.isEmpty) {
      return 'تاريخ الميلاد مطلوب';
    }
    return null;
  }

  static String? validateEmail(String value) {
    const emailPattern = r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$";
    final regExp = RegExp(emailPattern);
    if (value.isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }
    if (!regExp.hasMatch(value)) {
      return 'البريد الإلكتروني غير صالح';
    }
    return null;
  }

  static String? validatePassword(String value) {
    if (value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    if (value.length < 6) {
      return 'كلمة المرور يجب أن تحتوي على 6 حروف على الأقل';
    }
    return null;
  }
}
