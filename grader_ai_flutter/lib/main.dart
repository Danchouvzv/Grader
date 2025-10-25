import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/di/injection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io' show Platform;
import 'features/ielts/presentation/bloc/ielts_bloc.dart';
import 'presentation/pages/splash_screen.dart';
import 'presentation/pages/main_page.dart';
import 'shared/themes/app_theme.dart';
import 'core/services/firestore_service.dart';
import 'core/services/iap_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase only once
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      print('✅ Firebase initialized successfully');
    } else {
      print('ℹ️ Firebase already initialized, skipping');
    }
  } catch (e) {
    if (e.toString().contains('duplicate-app')) {
      print('ℹ️ Firebase already initialized (duplicate-app error is normal)');
    } else {
      print('❌ Firebase initialization failed: $e');
    }
    // Continue without Firebase for now
  }

  try {
    // Initialize IAP
    await IAPService().initialize();
    print('✅ IAP initialized successfully');
  } catch (e) {
    print('❌ IAP initialization failed: $e');
    // Continue without IAP for now
  }

  try {
    // Initialize dependencies
    await configureDependencies();
    print('✅ Dependencies configured successfully');
  } catch (e) {
    print('❌ Dependencies configuration failed: $e');
    // Continue without some dependencies
  }
  
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