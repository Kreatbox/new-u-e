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

  @override
  Widget build(BuildContext context) {
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
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/login': (context) => LoginScreen(),
        '/sign_up': (context) => SignUpScreen(),
        '/exam': (context) => ExamScreen(),
        '/admin': (context) => AdminScreen(),
        '/student': (context) => StudentScreen(),
        '/teacher': (context) => TeacherScreen(),
      },
    );
  }
}
