import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fanfic/data/Fanfic.dart';
import 'package:fanfic/models/user_model.dart';
import 'package:fanfic/screens/HomePage.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FanficPage extends StatefulWidget {
  final FanficData fanfic;

  FanficPage({this.fanfic});

  @override
  _FanficPageState createState() => _FanficPageState();
}

class _FanficPageState extends State<FanficPage> {
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _linkController = TextEditingController();

  final _tituloFocus = FocusNode();

  bool _userEdited = false;

  String _imageController;
  bool estadoImagem = false;
  bool iniciado = false;
  @override
  void initState() {
    super.initState();

    if (widget.fanfic != null) {
      iniciado = true;

      _tituloController.text = widget.fanfic.titulo;
      _descricaoController.text = widget.fanfic.descricao;
      _linkController.text = widget.fanfic.link;
      if (widget.fanfic.imagem != '') {
        estadoImagem = true;
        _imageController = widget.fanfic.imagem;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              iniciado ? widget.fanfic.titulo : "Nova Fanfic",
            ),
            backgroundColor: Theme.of(context).primaryColor,
            centerTitle: true,
          ),
          floatingActionButton: FloatingActionButton(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onPressed: () async {
              if (_tituloController.text != null &&
                  _tituloController.text.isNotEmpty) {
                String uid = UserModel.of(context).firebaseUser.uid;
                String url;
                if (_imageController != null && !estadoImagem) {
                  StorageUploadTask task = FirebaseStorage.instance
                      .ref()
                      .child(DateTime.now().millisecondsSinceEpoch.toString())
                      .putFile(File(_imageController));

                  StorageTaskSnapshot taskSnapshot = await task.onComplete;
                  url = await taskSnapshot.ref.getDownloadURL();
                }

                Map<String, dynamic> data = {
                  "titulo": _tituloController.text,
                  "descricao": _descricaoController.text,
                  "link": _linkController.text,
                  "concluido": iniciado ? widget.fanfic.concluido : false,
                  "imagem": estadoImagem
                      ? _imageController
                      : _imageController == null ? '' : url
                };
                print(data["imagem"]);
                if (iniciado) {
                  Firestore.instance
                      .collection('users')
                      .document(uid)
                      .collection('fanfics')
                      .document(widget.fanfic.id)
                      .updateData(data);
                } else {
                  Firestore.instance
                      .collection('users')
                      .document(uid)
                      .collection('fanfics')
                      .add(data);
                }

                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => HomePage()));
              } else {
                FocusScope.of(context).requestFocus(_tituloFocus);
              }
            },
            child: Icon(Icons.save),
            backgroundColor: Theme.of(context).primaryColor,
          ),
          body: SingleChildScrollView(
              padding: EdgeInsets.all(10.0),
              child: Column(children: <Widget>[
                GestureDetector(
                  child: Container(
                    width: 300.0,
                    height: 200.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      image: DecorationImage(
                          image: _imageController != null
                              ? estadoImagem
                                  ? NetworkImage(_imageController)
                                  : FileImage(File(_imageController))
                              : AssetImage("images/book.png"),
                          fit: BoxFit.cover),
                    ),
                  ),
                  onTap: () {
                    ImagePicker.pickImage(
                      source: ImageSource.gallery,
                    ).then((file) {
                      if (file == null) return;
                      setState(() {
                        _imageController = file.path;
                        estadoImagem = false;
                      });
                    });
                  },
                ),
                TextField(
                  controller: _tituloController,
                  focusNode: _tituloFocus,
                  decoration: InputDecoration(labelText: "Titulo"),
                ),
                TextField(
                  maxLines:
                      /*_descricaoController.text != null
                      ? (_descricaoController.text.length / 30).round()
                      :*/
                      8,
                  controller: _descricaoController,
                  decoration: InputDecoration(labelText: "Descricao"),
                  keyboardType: TextInputType.multiline,
                ),
                TextField(
                  controller: _linkController,
                  decoration: InputDecoration(labelText: "Link"),
                  keyboardType: TextInputType.url,
                ),
              ]))),
      onWillPop: _requestPop,
    );
  }

  Future<bool> _requestPop() {
    if (_userEdited) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Descartar Alterações?"),
              content: Text("Se sair as alterações serão perdidas."),
              actions: <Widget>[
                FlatButton(
                  child: Text("Cancelar"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text("Sim"),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          });
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}
