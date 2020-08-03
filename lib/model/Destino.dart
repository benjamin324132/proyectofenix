class Destino {
  String _street;
  String _numero;
  String _city;
  String _neighborhood;
  String _zip;

  double _latitude;
  double _longitude;

  Destino();

  double get longitude => _longitude;

  set longitude(double value) {
    _longitude = value;
  }

  double get latitude => _latitude;

  set latitude(double value) {
    _latitude = value;
  }

  String get zip => _zip;

  set zip(String value) {
    _zip = value;
  }

  String get neighborhood => _neighborhood;

  set neighborhood(String value) {
    _neighborhood = value;
  }

  String get city => _city;

  set city(String value) {
    _city = value;
  }

  String get number => _numero;

  set number(String value) {
    _numero = value;
  }

  String get street => _street;

  set street(String value) {
    _street = value;
  }
}
