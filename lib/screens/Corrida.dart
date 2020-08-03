import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:uber_clone/model/Usuario.dart';
import 'package:uber_clone/util/StatusRequisicao.dart';
import 'package:uber_clone/util/UsuarioFirebase.dart';

class Corrida extends StatefulWidget {
  String idRequisicao;

  Corrida(this.idRequisicao);

  @override
  _CorridaState createState() => _CorridaState();
}

class _CorridaState extends State<Corrida> {
  Completer<GoogleMapController> _controller = Completer();
  CameraPosition _posicaoCamera =
      CameraPosition(target: LatLng(-23.563999, -46.653256));
  Set<Marker> _marcadores = {};
  Map<String, dynamic> _dadosRequisicao;
  String _idRequisicao;
  Position _localMotorista;
  String _statusRequisicao = StatusRequisicao.WAITING;

  //Controles para exibição na tela
  String _textoBotao = "Aceptar";
  Color _corBotao = Colors.black;
  Function _funcaoBotao;
  String _mensagemStatus = "";

  _alterarBotaoPrincipal(String texto, Color cor, Function funcao) {
    setState(() {
      _textoBotao = texto;
      _corBotao = cor;
      _funcaoBotao = funcao;
    });
  }

  _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  _adicionarListenerLocalizacao() {
    var geolocator = Geolocator();
    var locationOptions =
        LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);

    geolocator.getPositionStream(locationOptions).listen((Position position) {
      if (position != null) {
        if (_idRequisicao != null && _idRequisicao.isNotEmpty) {
          if (_statusRequisicao != StatusRequisicao.WAITING) {
            //Atualiza local do passenger
            UsuarioFirebase.atualizarDadosLocalizacao(
                _idRequisicao, position.latitude, position.longitude);
          } else {
            //waiting
            setState(() {
              _localMotorista = position;
            });
            _statusAguardando();
          }
        }
      }
    });
  }

  _recuperaUltimaLocalizacaoConhecida() async {
    Position position = await Geolocator()
        .getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);

    if (position != null) {
      //Atualizar localização em tempo real do driver

    }
  }

  _movimentarCamera(CameraPosition cameraPosition) async {
    GoogleMapController googleMapController = await _controller.future;
    googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  _exibirMarcador(Position local, String icone, String infoWindow) async {
    double pixelRatio = MediaQuery.of(context).devicePixelRatio;

    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(devicePixelRatio: pixelRatio), icone)
        .then((BitmapDescriptor bitmapDescriptor) {
      Marker marcador = Marker(
          markerId: MarkerId(icone),
          position: LatLng(local.latitude, local.longitude),
          infoWindow: InfoWindow(title: infoWindow),
          icon: bitmapDescriptor);

      setState(() {
        _marcadores.add(marcador);
      });
    });
  }

  _recuperarRequisicao() async {
    String idRequisicao = widget.idRequisicao;

    Firestore db = Firestore.instance;
    DocumentSnapshot documentSnapshot =
        await db.collection("requests").document(idRequisicao).get();
  }

  _adicionarListenerRequisicao() async {
    Firestore db = Firestore.instance;

    await db
        .collection("requests")
        .document(_idRequisicao)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.data != null) {
        _dadosRequisicao = snapshot.data;

        Map<String, dynamic> dados = snapshot.data;
        _statusRequisicao = dados["status"];

        switch (_statusRequisicao) {
          case StatusRequisicao.WAITING:
            _statusAguardando();
            break;
          case StatusRequisicao.ON_WAY:
            _statusACaminho();
            break;
          case StatusRequisicao.TRAVEL:
            _statusEmViagem();
            break;
          case StatusRequisicao.FINISHED:
            _statusFinalizada();
            break;
          case StatusRequisicao.CONFIRMED:
            _statusConfirmada();
            break;
        }
      }
    });
  }

  _statusAguardando() {
    _alterarBotaoPrincipal("Aceitar corrida", Colors.black, () {
      _aceitarCorrida();
    });

    if (_localMotorista != null) {
      double driverLat = _localMotorista.latitude;
      double driverLon = _localMotorista.longitude;

      Position position = Position(latitude: driverLat, longitude: driverLon);
      _exibirMarcador(position, "images/driver.png", "Motorista");

      CameraPosition cameraPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude), zoom: 19);

      _movimentarCamera(cameraPosition);
    }
  }

  _statusACaminho() {
    _mensagemStatus = "Camino al pasajero";
    _alterarBotaoPrincipal("Iniciar corrida", Colors.black, () {
      _iniciarCorrida();
    });

    double latitudePassageiro = _dadosRequisicao["passenger"]["latitude"];
    double longitudePassageiro = _dadosRequisicao["passenger"]["longitude"];

    double latitudeMotorista = _dadosRequisicao["driver"]["latitude"];
    double longitudeMotorista = _dadosRequisicao["driver"]["longitude"];

    //Exibir dois marcadores
    _exibirDoisMarcadores(LatLng(latitudeMotorista, longitudeMotorista),
        LatLng(latitudePassageiro, longitudePassageiro));

    //'southwest.latitude <= northeast.latitude': is not true
    var nLat, nLon, sLat, sLon;

    if (latitudeMotorista <= latitudePassageiro) {
      sLat = latitudeMotorista;
      nLat = latitudePassageiro;
    } else {
      sLat = latitudePassageiro;
      nLat = latitudeMotorista;
    }

    if (longitudeMotorista <= longitudePassageiro) {
      sLon = longitudeMotorista;
      nLon = longitudePassageiro;
    } else {
      sLon = longitudePassageiro;
      nLon = longitudeMotorista;
    }

    _movimentarCameraBounds(LatLngBounds(
        northeast: LatLng(nLat, nLon), //nordeste
        southwest: LatLng(sLat, sLon) //sudoeste
        ));
  }

  _finalizarCorrida() {
    Firestore db = Firestore.instance;
    db
        .collection("requests")
        .document(_idRequisicao)
        .updateData({"status": StatusRequisicao.FINISHED});

    String idPassageiro = _dadosRequisicao["passenger"]["idUsuario"];
    db
        .collection("active_request")
        .document(idPassageiro)
        .updateData({"status": StatusRequisicao.FINISHED});

    String idMotorista = _dadosRequisicao["driver"]["idUsuario"];
    db
        .collection("active_driver_request")
        .document(idMotorista)
        .updateData({"status": StatusRequisicao.FINISHED});
  }

  _statusFinalizada() async {
    //Calcula valor da corrida
    double latitudeDestino = _dadosRequisicao["destination"]["latitude"];
    double longitudeDestino = _dadosRequisicao["destination"]["longitude"];

    double latitudeOrigem = _dadosRequisicao["origin"]["latitude"];
    double longitudeOrigem = _dadosRequisicao["origin"]["longitude"];

    double distanciaEmMetros = await Geolocator().distanceBetween(
        latitudeOrigem, longitudeOrigem, latitudeDestino, longitudeDestino);

    //Converte para KM
    double distanciaKm = distanciaEmMetros / 1000;

    //8 é o valor cobrado por KM
    double valorViagem = distanciaKm * 10;

    //Formatar valor travel
    var f = new NumberFormat("###.00", "dl_US");
    var valorViagemFormatado = f.format(valorViagem);

    _mensagemStatus = "Viaje completado";
    _alterarBotaoPrincipal(
        "Confirmar - \$ ${valorViagemFormatado}", Colors.black, () {
      _confirmarCorrida();
    });

    _marcadores = {};
    Position position =
        Position(latitude: latitudeDestino, longitude: longitudeDestino);
    _exibirMarcador(position, "images/destination.png", "Destino");

    CameraPosition cameraPosition = CameraPosition(
        target: LatLng(position.latitude, position.longitude), zoom: 19);

    _movimentarCamera(cameraPosition);
  }

  _statusConfirmada() {
    Navigator.pushReplacementNamed(context, "/painel-driver");
  }

  _confirmarCorrida() {
    Firestore db = Firestore.instance;
    db
        .collection("requests")
        .document(_idRequisicao)
        .updateData({"status": StatusRequisicao.CONFIRMED});

    String idPassageiro = _dadosRequisicao["passenger"]["idUsuario"];
    db.collection("active_request").document(idPassageiro).delete();

    String idMotorista = _dadosRequisicao["driver"]["idUsuario"];
    db.collection("active_driver_request").document(idMotorista).delete();
  }

  _statusEmViagem() {
    _mensagemStatus = "De viaje";
    _alterarBotaoPrincipal("Finalizar corrida", Colors.black, () {
      _finalizarCorrida();
    });

    double latitudeDestino = _dadosRequisicao["destination"]["latitude"];
    double longitudeDestino = _dadosRequisicao["destination"]["longitude"];

    double latitudeOrigem = _dadosRequisicao["driver"]["latitude"];
    double longitudeOrigem = _dadosRequisicao["driver"]["longitude"];

    //Exibir dois marcadores
    _exibirDoisMarcadores(LatLng(latitudeOrigem, longitudeOrigem),
        LatLng(latitudeDestino, longitudeDestino));

    //'southwest.latitude <= northeast.latitude': is not true
    var nLat, nLon, sLat, sLon;

    if (latitudeOrigem <= latitudeDestino) {
      sLat = latitudeOrigem;
      nLat = latitudeDestino;
    } else {
      sLat = latitudeDestino;
      nLat = latitudeOrigem;
    }

    if (longitudeOrigem <= longitudeDestino) {
      sLon = longitudeOrigem;
      nLon = longitudeDestino;
    } else {
      sLon = longitudeDestino;
      nLon = longitudeOrigem;
    }

    _movimentarCameraBounds(LatLngBounds(
        northeast: LatLng(nLat, nLon), //nordeste
        southwest: LatLng(sLat, sLon) //sudoeste
        ));
  }

  _iniciarCorrida() {
    Firestore db = Firestore.instance;
    db.collection("requests").document(_idRequisicao).updateData({
      "origin": {
        "latitude": _dadosRequisicao["driver"]["latitude"],
        "longitude": _dadosRequisicao["driver"]["longitude"]
      },
      "status": StatusRequisicao.TRAVEL
    });

    String idPassageiro = _dadosRequisicao["passenger"]["idUsuario"];
    db
        .collection("active_request")
        .document(idPassageiro)
        .updateData({"status": StatusRequisicao.TRAVEL});

    String idMotorista = _dadosRequisicao["driver"]["idUsuario"];
    db
        .collection("active_driver_request")
        .document(idMotorista)
        .updateData({"status": StatusRequisicao.TRAVEL});
  }

  _movimentarCameraBounds(LatLngBounds latLngBounds) async {
    GoogleMapController googleMapController = await _controller.future;
    googleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 100));
  }

  _exibirDoisMarcadores(LatLng latLngMotorista, LatLng latLngPassageiro) {
    double pixelRatio = MediaQuery.of(context).devicePixelRatio;

    Set<Marker> _listaMarcadores = {};
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(devicePixelRatio: pixelRatio),
            "images/driver.png")
        .then((BitmapDescriptor icone) {
      Marker marcador1 = Marker(
          markerId: MarkerId("marcador-driver"),
          position: LatLng(latLngMotorista.latitude, latLngMotorista.longitude),
          infoWindow: InfoWindow(title: "Local driver"),
          icon: icone);
      _listaMarcadores.add(marcador1);
    });

    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(devicePixelRatio: pixelRatio),
            "images/passenger.png")
        .then((BitmapDescriptor icone) {
      Marker marcador2 = Marker(
          markerId: MarkerId("marcador-passenger"),
          position:
              LatLng(latLngPassageiro.latitude, latLngPassageiro.longitude),
          infoWindow: InfoWindow(title: "Local passenger"),
          icon: icone);
      _listaMarcadores.add(marcador2);
    });

    setState(() {
      _marcadores = _listaMarcadores;
    });
  }

  _aceitarCorrida() async {
    //Recuperar dados do driver
    Usuario driver = await UsuarioFirebase.getDadosUsuarioLogado();
    driver.latitude = _localMotorista.latitude;
    driver.longitude = _localMotorista.longitude;

    Firestore db = Firestore.instance;
    String idRequisicao = _dadosRequisicao["id"];

    db.collection("requests").document(idRequisicao).updateData({
      "driver": driver.toMap(),
      "status": StatusRequisicao.ON_WAY,
    }).then((_) {
      //atualiza requisicao ativa
      String idPassageiro = _dadosRequisicao["passenger"]["idUsuario"];
      db.collection("active_request").document(idPassageiro).updateData({
        "status": StatusRequisicao.ON_WAY,
      });

      //Salvar requisicao ativa para driver
      String idMotorista = driver.idUsuario;
      db.collection("active_driver_request").document(idMotorista).setData({
        "id_request": idRequisicao,
        "id_usuario": idMotorista,
        "status": StatusRequisicao.ON_WAY,
      });
    });
  }

  @override
  void initState() {
    super.initState();

    _idRequisicao = widget.idRequisicao;

    // adicionar listener para mudanças na requisicao
    _adicionarListenerRequisicao();

    //_recuperaUltimaLocalizacaoConhecida();
    _adicionarListenerLocalizacao();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Panel de carrera - " + _mensagemStatus),
      ),
      body: Container(
        child: Stack(
          children: <Widget>[
            GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _posicaoCamera,
              onMapCreated: _onMapCreated,
              //myLocationEnabled: true,
              myLocationButtonEnabled: false,
              markers: _marcadores,
              //-23,559200, -46,658878
            ),
            Positioned(
              right: 0,
              left: 0,
              bottom: 0,
              child: Padding(
                padding: Platform.isIOS
                    ? EdgeInsets.fromLTRB(20, 10, 20, 25)
                    : EdgeInsets.all(10),
                child: RaisedButton(
                    child: Text(
                      _textoBotao,
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    color: _corBotao,
                    padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                    onPressed: _funcaoBotao),
              ),
            )
          ],
        ),
      ),
    );
  }
}
