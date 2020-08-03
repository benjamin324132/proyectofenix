import 'package:cloud_firestore/cloud_firestore.dart';
import 'Destino.dart';
import 'Usuario.dart';

class Requisicao {
  String _id;
  String _status;
  Usuario _passageiro;
  Usuario _driver;
  Destino _destino;

  Requisicao() {
    Firestore db = Firestore.instance;

    DocumentReference ref = db.collection("requests").document();
    this.id = ref.documentID;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> dadosPassageiro = {
      "name": this.passenger.name,
      "email": this.passenger.email,
      "tipoUsuario": this.passenger.tipoUsuario,
      "idUsuario": this.passenger.idUsuario,
      "latitude": this.passenger.latitude,
      "longitude": this.passenger.longitude,
    };

    Map<String, dynamic> dadosDestino = {
      "street": this.destination.street,
      "number": this.destination.number,
      "neighborhood": this.destination.neighborhood,
      "zip": this.destination.zip,
      "latitude": this.destination.latitude,
      "longitude": this.destination.longitude,
    };

    Map<String, dynamic> dadosRequisicao = {
      "id": this.id,
      "status": this.status,
      "passenger": dadosPassageiro,
      "driver": null,
      "destination": dadosDestino,
    };

    return dadosRequisicao;
  }

  Destino get destination => _destino;

  set destination(Destino value) {
    _destino = value;
  }

  Usuario get driver => _driver;

  set driver(Usuario value) {
    _driver = value;
  }

  Usuario get passenger => _passageiro;

  set passenger(Usuario value) {
    _passageiro = value;
  }

  String get status => _status;

  set status(String value) {
    _status = value;
  }

  String get id => _id;

  set id(String value) {
    _id = value;
  }
}
