import '../../domain/repositories/career_repository.dart';

class CareerRepositoryImpl implements CareerRepository {
  const CareerRepositoryImpl(this._remoteDataSource, this._localDataSource);
  final dynamic _remoteDataSource;
  final dynamic _localDataSource;
}
