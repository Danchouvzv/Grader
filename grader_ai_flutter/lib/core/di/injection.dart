import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/career/data/datasources/career_local_datasource.dart';
import '../../features/career/data/datasources/career_remote_datasource.dart';
import '../../features/career/data/repositories/career_repository_impl.dart';
import '../../features/career/domain/repositories/career_repository.dart';
import '../../features/career/domain/usecases/get_assessment_questions.dart';
import '../../features/career/domain/usecases/get_career_guidance.dart';
import '../../features/career/domain/usecases/manage_career_sessions.dart';
import '../../features/career/presentation/bloc/career_bloc.dart';
import '../../features/ielts/data/datasources/ielts_remote_datasource.dart';
import '../../features/ielts/data/repositories/ielts_repository_impl.dart';
import '../../features/ielts/domain/repositories/ielts_repository.dart';
import '../../features/ielts/domain/usecases/assess_audio.dart';
import '../../features/ielts/domain/usecases/get_random_task.dart';
import '../../features/ielts/presentation/bloc/ielts_bloc.dart';
import '../network/dio_client.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Core
  getIt.registerLazySingleton<DioClient>(() => DioClient());

  // IELTS
  getIt.registerLazySingleton<IeltsRemoteDataSource>(
    () => IeltsRemoteDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<IeltsRepository>(
    () => IeltsRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<GetRandomTask>(
    () => GetRandomTask(getIt()),
  );
  getIt.registerLazySingleton<AssessAudio>(
    () => AssessAudio(getIt()),
  );
  getIt.registerFactory<IeltsBloc>(
    () => IeltsBloc(getIt(), getIt()),
  );

  // Career
  getIt.registerLazySingleton<CareerRemoteDataSource>(
    () => CareerRemoteDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<CareerLocalDataSource>(
    () => CareerLocalDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<CareerRepository>(
    () => CareerRepositoryImpl(getIt(), getIt()),
  );
  getIt.registerLazySingleton<GetAssessmentQuestions>(
    () => GetAssessmentQuestions(getIt()),
  );
  getIt.registerLazySingleton<GetCareerGuidance>(
    () => GetCareerGuidance(getIt()),
  );
  getIt.registerLazySingleton<SaveCareerSession>(
    () => SaveCareerSession(getIt()),
  );
  getIt.registerLazySingleton<LoadCareerSession>(
    () => LoadCareerSession(getIt()),
  );
  getIt.registerLazySingleton<GetAvailableSessions>(
    () => GetAvailableSessions(getIt()),
  );
  getIt.registerLazySingleton<DeleteCareerSession>(
    () => DeleteCareerSession(getIt()),
  );
  getIt.registerFactory<CareerBloc>(
    () => CareerBloc(
      getIt(),
      getIt(),
      getIt(),
      getIt(),
      getIt(),
      getIt(),
    ),
  );
}
