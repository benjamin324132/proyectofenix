class StatusRequisicao {
  /*
  passenger:
    1) parado: -23.562006, -46.656009 (-23,562006, -46,656009)
    2) andou: -23.562408, -46.655518 (-23,562408, -46,655518)

  Motorista:
    1) longe do passenger: -23.563068, -46.650550
    2) intermediário: -23.564924, -46.652460
    3) próximo ao passenger: -23.562542, -46.655393

    4) a caminho do destination: -23.553442, -46.672161

  Destino:
    1) Destino final -23.547813, -46.686385
    2) Próximo ao destination -23.547791, -46.686474
  * */

  static const String WAITING = "waiting";
  static const String ON_WAY = "on_way";
  static const String TRAVEL = "travel";
  static const String FINISHED = "finished";
  static const String CONFIRMED = "confirmed";
  static const String CANCELED = "canceled";
}
