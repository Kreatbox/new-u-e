import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:universal_exam/features/teacher/screens/teacher_screen.dart';
import 'core/providers/user_provider.dart';
import 'features/home/home_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/sign_up_screen.dart';
import 'features/exam/screens/exam_screen.dart';
import 'features/admin/screens/admin_screen.dart';
import 'features/student/screens/student_screen.dart';
import 'shared/theme/theme.dart';
import 'core/config/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Route<dynamic> _generateRoute(
      RouteSettings settings, UserProvider userProvider) {
    final user = userProvider.user;

    final protectedRoutes = {
      '/exam': ['طالب', 'أستاذ', 'مدير'],
      '/admin': ['مدير'],
      '/student': ['طالب', 'أستاذ'],
      '/teacher': ['أستاذ'],
    };
    if (protectedRoutes.containsKey(settings.name)) {
      if (user == null) {
        return MaterialPageRoute(builder: (_) => LoginScreen());
      }
      final allowedRoles = protectedRoutes[settings.name]!;
      if (!allowedRoles.contains(user.role)) {
        return MaterialPageRoute(builder: (_) => HomeScreen());
      }
    }

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case '/sign_up':
        return MaterialPageRoute(builder: (_) => SignUpScreen());
      case '/exam':
        return MaterialPageRoute(
            builder: (_) => ExamScreen(studentUid: user!.id));
      case '/admin':
        return MaterialPageRoute(builder: (_) => AdminScreen());
      case '/student':
        return MaterialPageRoute(builder: (_) => StudentScreen());
      case '/teacher':
        return MaterialPageRoute(builder: (_) => TeacherScreen());
      default:
        return MaterialPageRoute(builder: (_) => HomeScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return MaterialApp(
      title: 'إدارة الامتحان المركزي',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', ''),
      ],
      locale: const Locale('ar', ''),
      onGenerateRoute: (settings) => _generateRoute(settings, userProvider),
    );
  }
}
