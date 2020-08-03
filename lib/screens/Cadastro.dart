import 'package:flutter/material.dart';
import 'package:uber_clone/model/Usuario.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Cadastro extends StatefulWidget {
  @override
  _CadastroState createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  TextEditingController _controllerNome = TextEditingController();
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();
  bool _tipoUsuario = false;
  String _mensagemErro = "";

  _validarCampos() {
    //Recuperar dados dos campos
    String name = _controllerNome.text;
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;

    //validar campos
    if (name.isNotEmpty) {
      if (email.isNotEmpty && email.contains("@")) {
        if (senha.isNotEmpty && senha.length > 6) {
          Usuario usuario = Usuario();
          usuario.name = name;
          usuario.email = email;
          usuario.senha = senha;
          usuario.tipoUsuario = usuario.verificaTipoUsuario(_tipoUsuario);

          _cadastrarUsuario(usuario);
        } else {
          setState(() {
            _mensagemErro = "Ingrese una contraseña de más de 6 caracteres";
          });
        }
      } else {
        setState(() {
          _mensagemErro = "Digite un E-mail válido";
        });
      }
    } else {
      setState(() {
        _mensagemErro = "Escriba su nombre";
      });
    }
  }

  _cadastrarUsuario(Usuario usuario) {
    FirebaseAuth auth = FirebaseAuth.instance;
    Firestore db = Firestore.instance;

    auth
        .createUserWithEmailAndPassword(
            email: usuario.email, password: usuario.senha)
        .then((firebaseUser) {
      db
          .collection("users")
          .document(firebaseUser.user.uid)
          .setData(usuario.toMap());

      //redireciona para o painel, de acordo com o tipoUsuario
      switch (usuario.tipoUsuario) {
        case "driver":
          Navigator.pushNamedAndRemoveUntil(
              context, "/painel-driver", (_) => false);
          break;
        case "passenger":
          Navigator.pushNamedAndRemoveUntil(
              context, "/painel-passenger", (_) => false);
          break;
      }
    }).catchError((error) {
      _mensagemErro =
          "¡Error al registrar usuario, verifique los campos e intente nuevamente!";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Registrarse"),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextField(
                  controller: _controllerNome,
                  autofocus: true,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "Nombre completo",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6))),
                ),
                TextField(
                  controller: _controllerEmail,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "E-mail",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6))),
                ),
                TextField(
                  controller: _controllerSenha,
                  obscureText: true,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "contraseña",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6))),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: <Widget>[
                      Text("Pasajero"),
                      Switch(
                          value: _tipoUsuario,
                          onChanged: (bool valor) {
                            setState(() {
                              _tipoUsuario = valor;
                            });
                          }),
                      Text("Conductor"),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 10),
                  child: RaisedButton(
                      child: Text(
                        "Registrar",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      color: Colors.black,
                      padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      onPressed: () {
                        _validarCampos();
                      }),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Center(
                    child: Text(
                      _mensagemErro,
                      style: TextStyle(color: Colors.red, fontSize: 20),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
