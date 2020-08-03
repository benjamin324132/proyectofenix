import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uber_clone/model/Usuario.dart';

class UsuarioFirebase {
  static Future<FirebaseUser> getUsuarioAtual() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    return await auth.currentUser();
  }

  static Future<Usuario> getDadosUsuarioLogado() async {
    FirebaseUser firebaseUser = await getUsuarioAtual();
    String idUsuario = firebaseUser.uid;

    Firestore db = Firestore.instance;

    DocumentSnapshot snapshot =
        await db.collection("users").document(idUsuario).get();

    Map<String, dynamic> dados = snapshot.data;
    String tipoUsuario = dados["tipoUsuario"];
    String email = dados["email"];
    String name = dados["name"];

    Usuario usuario = Usuario();
    usuario.idUsuario = idUsuario;
    usuario.tipoUsuario = tipoUsuario;
    usuario.email = email;
    usuario.name = name;

    return usuario;
  }

  static atualizarDadosLocalizacao(
      String idRequisicao, double lat, double lon) async {
    Firestore db = Firestore.instance;

    Usuario driver = await getDadosUsuarioLogado();
    driver.latitude = lat;
    driver.longitude = lon;

    db
        .collection("requests")
        .document(idRequisicao)
        .updateData({"driver": driver.toMap()});
  }
}
