abstract class IeltsRemoteDataSource {}

class IeltsRemoteDataSourceImpl implements IeltsRemoteDataSource {
  const IeltsRemoteDataSourceImpl(this._dioClient);
  final dynamic _dioClient;
}
