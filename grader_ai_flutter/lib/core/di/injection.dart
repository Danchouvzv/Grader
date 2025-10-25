import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
}
