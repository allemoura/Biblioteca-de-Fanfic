import 'package:cloud_firestore/cloud_firestore.dart';

class FanficData {
  bool concluido;
  String id;

  String titulo;
  String descricao;

  String imagem;

  String link;
  FanficData();
  FanficData.fromDocument(DocumentSnapshot snapshot) {
    id = snapshot.documentID;
    titulo = snapshot.data['titulo'];
    descricao = snapshot.data['descricao'];
    imagem = snapshot.data['imagem'];

    concluido = snapshot.data['concluido'];
    link = snapshot.data['link'];
  }

  Map<String, dynamic> fanficToMap() {
    return {
      'titulo': titulo,
      'descricao': descricao,
      'imagem': imagem,
      'link': link,
      'concluido': concluido,
    };
  }
}
