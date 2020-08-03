class Usuario {
  String _idUser;
  String _name;
  String _email;
  String _password;
  String _tipoUsuario;

  double _latitude;
  double _longitude;

  Usuario();

  double get latitude => _latitude;

  set latitude(double value) {
    _latitude = value;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "idUsuario": this.idUsuario,
      "name": this.name,
      "email": this.email,
      "tipoUsuario": this.tipoUsuario,
      "latitude": this.latitude,
      "longitude": this.longitude,
    };

    return map;
  }

  String verificaTipoUsuario(bool tipoUsuario) {
    return tipoUsuario ? "driver" : "passenger";
  }

  String get tipoUsuario => _tipoUsuario;

  set tipoUsuario(String value) {
    _tipoUsuario = value;
  }

  String get senha => _password;

  set senha(String value) {
    _password = value;
  }

  String get email => _email;

  set email(String value) {
    _email = value;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  String get idUsuario => _idUser;

  set idUsuario(String value) {
    _idUser = value;
  }

  double get longitude => _longitude;

  set longitude(double value) {
    _longitude = value;
  }
}
