import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:universal_exam/core/providers/app_provider.dart';
import 'package:universal_exam/features/teacher/screens/teacher_screen.dart';
import 'package:universal_exam/splash_screen.dart';
import 'core/providers/user_provider.dart';
import 'features/home/home_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/sign_up_screen.dart';
import 'features/exam/screens/exam_screen.dart';
import 'features/admin/screens/admin_screen.dart';
import 'features/student/student_screen.dart';
import 'shared/theme/theme.dart';
import 'core/config/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final appProvider = AppProvider();
  await appProvider.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appProvider),
        ChangeNotifierProvider(create: (context) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<void> _initializationFuture;

  @override
  void initState() {
    super.initState();
    _initializationFuture = _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

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
        return MaterialPageRoute(builder: (_) => const HomeScreen());
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
        return MaterialPageRoute(builder: (_) => UserScreen());
      case '/teacher':
        return MaterialPageRoute(builder: (_) => TeacherScreen());
      default:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            home: SplashScreen(),
            debugShowCheckedModeBanner: false,
          );
        }

        final userProvider = Provider.of<UserProvider>(context);
        
        if (!userProvider.isInitialized) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            userProvider.loadUserFromPrefs();
          });
          
          return const MaterialApp(
            home: SplashScreen(),
            debugShowCheckedModeBanner: false,
          );
        }

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
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SplashScreen();
              }

              final firebaseUser = snapshot.data;

              if (firebaseUser != null) {
                if (userProvider.user == null || userProvider.user!.id != firebaseUser.uid) {
                  debugPrint("Logged In User");
                  debugPrint("UID: ${firebaseUser.uid}");
                  debugPrint("Email: ${firebaseUser.email}");

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    userProvider.fetchUserData(firebaseUser.uid);
                  });

                  return const SplashScreen();
                } else {
                  return const HomeScreen();
                }
              } else {
                if (userProvider.user != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    userProvider.clearUserData();
                  });
                }
                return const HomeScreen();
              }
            },
          ),
        );
      },
    );
  }
}
