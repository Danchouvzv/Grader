abstract class CareerRemoteDataSource {}

class CareerRemoteDataSourceImpl implements CareerRemoteDataSource {
  const CareerRemoteDataSourceImpl(this._dioClient);
  final dynamic _dioClient;
}
