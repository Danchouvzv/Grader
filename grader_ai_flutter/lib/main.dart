import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/di/injection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io' show Platform;
import 'features/career/presentation/bloc/career_bloc.dart';
import 'features/ielts/presentation/bloc/ielts_bloc.dart';
import 'presentation/pages/splash_screen.dart';
import 'presentation/pages/main_page.dart';
import 'shared/themes/app_theme.dart';
import 'core/services/firestore_service.dart';
import 'core/services/iap_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize IAP
  await IAPService().initialize();

  // Initialize dependencies
  await configureDependencies();
  
  runApp(const GraderAIApp());
}

class GraderAIApp extends StatelessWidget {
  const GraderAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone 12/13/14 design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<IeltsBloc>(
              create: (context) => getIt<IeltsBloc>(),
            ),
            BlocProvider<CareerBloc>(
              create: (context) => getIt<CareerBloc>(),
            ),
          ],
          child: MaterialApp(
            title: 'Grader.AI',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.lightTheme, // Using light theme for now
            themeMode: ThemeMode.system,
            home: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                // Show loading while checking auth state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                
                // If user is signed in, go to main page
                if (snapshot.hasData && snapshot.data != null) {
                  return const MainPage();
                }
                
                // If user is not signed in, show splash screen
                return const SplashScreen();
              },
            ),
          ),
        );
      },
    );
  }
}