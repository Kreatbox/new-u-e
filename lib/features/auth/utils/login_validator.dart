class LoginValidator {
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال اسم المستخدم';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال كلمة المرور';
    } else if (value.length < 6) {
      return 'كلمة المرور يجب أن تحتوي على 6 حروف على الأقل';
    }
    return null;
  }
}
