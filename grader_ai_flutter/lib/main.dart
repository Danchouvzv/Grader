import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/di/injection.dart';
import 'features/career/presentation/bloc/career_bloc.dart';
import 'features/ielts/presentation/bloc/ielts_bloc.dart';
import 'presentation/pages/welcome_page.dart';
import 'shared/themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: ThemeMode.system,
            home: const WelcomePage(),
          ),
        );
      },
    );
  }
}