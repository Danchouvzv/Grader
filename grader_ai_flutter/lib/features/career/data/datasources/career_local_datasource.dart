abstract class CareerLocalDataSource {}

class CareerLocalDataSourceImpl implements CareerLocalDataSource {
  const CareerLocalDataSourceImpl(this._sharedPreferences);
  final dynamic _sharedPreferences;
}
