import '../../domain/repositories/ielts_repository.dart';
import '../datasources/ielts_remote_datasource.dart';

class IeltsRepositoryImpl implements IeltsRepository {
  const IeltsRepositoryImpl(this._remoteDataSource);
  final IeltsRemoteDataSource _remoteDataSource;
}
