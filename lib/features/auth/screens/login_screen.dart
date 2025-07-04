import 'package:flutter/material.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/constrained_box.dart';
import '../../../shared/widgets/app_bar.dart';
import '../utils/login_validator.dart';
import '../auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  void _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => isLoading = true);

      String result = await AuthService().loginUser(
        email: usernameController.text.trim(),
        password: passwordController.text,
        context: context,
      );

      setState(() => isLoading = false);

      if (result == "success") {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, '/');
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: ('تسجيل الدخول')),
      body: CustomConstrainedBox(
        title: 'مرحبًا بك!',
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'اسم المستخدم',
                  border: OutlineInputBorder(),
                ),
                validator: LoginValidator.validateUsername,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور',
                  border: OutlineInputBorder(),
                ),
                validator: LoginValidator.validatePassword,
              ),
              const SizedBox(height: 24),
              CustomButton(
                onPressed: isLoading ? () {} : _login,
                text: isLoading ? 'جاري الدخول...' : 'تسجيل الدخول',
              ),
            ],
          ),
        ),
      ),
      backgroundColor: AppColors.primary,
    );
  }
}
