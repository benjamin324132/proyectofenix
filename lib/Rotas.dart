import 'package:flutter/material.dart';
import 'package:uber_clone/screens/Cadastro.dart';
import 'package:uber_clone/screens/Corrida.dart';
import 'package:uber_clone/screens/Home.dart';
import 'package:uber_clone/screens/PainelMotorista.dart';
import 'package:uber_clone/screens/PainelPassageiro.dart';

class Rotas {
  static Route<dynamic> gerarRotas(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case "/":
        return MaterialPageRoute(builder: (_) => Home());
      case "/cadastro":
        return MaterialPageRoute(builder: (_) => Cadastro());
      case "/painel-driver":
        return MaterialPageRoute(builder: (_) => PainelMotorista());
      case "/painel-passenger":
        return MaterialPageRoute(builder: (_) => PainelPassageiro());
      case "/corrida":
        return MaterialPageRoute(builder: (_) => Corrida(args));
      default:
        _erroRota();
    }
  }

  static Route<dynamic> _erroRota() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Tela não encontrada!"),
        ),
        body: Center(
          child: Text("Tela não encontrada!"),
        ),
      );
    });
  }
}
