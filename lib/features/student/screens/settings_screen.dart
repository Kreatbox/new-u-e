import 'package:flutter/material.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/container.dart';
import '../../../shared/widgets/list_item.dart';
import '../../auth/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  final List<Color> gradientColors;
  final Alignment begin;
  final Alignment end;

  const SettingsScreen({
    super.key,
    required this.gradientColors,
    required this.begin,
    required this.end,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isExamNotificationsEnabled = true;
  bool isResultsNotificationsEnabled = false;
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _passwordFormKey = GlobalKey<FormState>();
  bool _isChangingPassword = false;

  void toggleExamNotifications(bool value) {
    setState(() {
      isExamNotificationsEnabled = value;
    });
  }

  void toggleResultsNotifications(bool value) {
    setState(() {
      isResultsNotificationsEnabled = value;
    });
  }

  String? _validateCurrentPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال كلمة المرور الحالية';
    }
    if (value.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }
    return null;
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال كلمة المرور الجديدة';
    }
    if (value.length < 6) {
      return 'كلمة المرور الجديدة يجب أن تكون 6 أحرف على الأقل';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى تأكيد كلمة المرور الجديدة';
    }
    if (value != _newPasswordController.text) {
      return 'كلمة المرور غير متطابقة';
    }
    return null;
  }

  Future<void> _changePassword() async {
    if (!_passwordFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isChangingPassword = true;
    });

    try {
      final result = await AuthService().changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
        context: context,
      );

      if (!mounted) return;

      if (result == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تغيير كلمة المرور بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
        _clearPasswordFields();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء تغيير كلمة المرور'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isChangingPassword = false;
        });
      }
    }
  }

  void _clearPasswordFields() {
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      gradientColors: widget.gradientColors,
      begin: widget.begin,
      end: widget.end,
      padding: EdgeInsets.symmetric(
        vertical: 32,
        horizontal: MediaQuery.of(context).size.width < 700 ? 0 : 32.0,
      ),
      child: ListView(
        children: [
          Text(
            "الإعدادات",
            style: TextStyle(
              fontSize: 32,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ..._buildSettingsItems(),
        ],
      ),
    );
  }

  List<Widget> _buildSettingsItems() {
    return [
      GestureDetector(
        onTap: () {
          _showPasswordChangeDialog(context);
        },
        child: CustomListItem(
          title: "تغيير كلمة المرور",
          description: "تغيير كلمة المرور لتأمين حسابك.",
          gradientColors: widget.gradientColors,
          begin: widget.begin,
          end: widget.end,
          trailingIcon: Icon(
            Icons.arrow_forward_ios,
            color: AppColors.primary,
            size: 18,
          ),
        ),
      ),
    ];
  }

  void _showPasswordChangeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.darkPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.0),
          ),
          title: Text(
            "تغيير كلمة المرور",
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Form(
            key: _passwordFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _currentPasswordController,
                  obscureText: true,
                  validator: _validateCurrentPassword,
                  decoration: InputDecoration(
                    labelText: "كلمة المرور الحالية",
                    hintText: "أدخل كلمة المرور الحالية",
                    border: OutlineInputBorder(),
                    labelStyle: TextStyle(color: Colors.white70),
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: true,
                  validator: _validateNewPassword,
                  decoration: InputDecoration(
                    labelText: "كلمة المرور الجديدة",
                    hintText: "أدخل كلمة المرور الجديدة",
                    border: OutlineInputBorder(),
                    labelStyle: TextStyle(color: Colors.white70),
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  validator: _validateConfirmPassword,
                  decoration: InputDecoration(
                    labelText: "تأكيد كلمة المرور الجديدة",
                    hintText: "تأكيد كلمة المرور الجديدة",
                    border: OutlineInputBorder(),
                    labelStyle: TextStyle(color: Colors.white70),
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          actions: [
            CustomButton(
              onPressed: () => Navigator.pop(context),
              text: "إلغاء",
              gradientColors: [Colors.grey, Colors.grey.shade700],
            ),
            CustomButton(
              onPressed: _isChangingPassword ? null : _changePassword,
              text:
                  _isChangingPassword ? "جاري التغيير..." : "تغيير كلمة المرور",
              gradientColors: widget.gradientColors,
            ),
          ],
        );
      },
    );
  }
}
