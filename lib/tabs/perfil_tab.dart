import 'dart:io';

import 'package:fanfic/models/user_model.dart';
import 'package:fanfic/screens/HomePage.dart';
import 'package:fanfic/screens/reset_screen.dart';
import 'package:fanfic/widgets/image_source_sheet.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scoped_model/scoped_model.dart';

class PerfilTab extends StatefulWidget {
  @override
  _PerfilTabState createState() => _PerfilTabState();
}

class _PerfilTabState extends State<PerfilTab> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String imagem;
  File _imageController;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    _nameController.text = UserModel.of(context).userData['nome'];
    _emailController.text = UserModel.of(context).userData['email'];
    imagem = UserModel.of(context).userData['imagemPerfil'];
    return Form(
        key: _formKey,
        child: ListView(padding: EdgeInsets.all(16.0), children: <Widget>[
          GestureDetector(
            child: CircleAvatar(
              radius: 80.0,
              child: ClipOval(
                  child: imagem.isEmpty
                      ? Image.asset('images/perfil.png')
                      : _imageController == null
                          ? Image.network(imagem)
                          : Image.file(_imageController)),
              backgroundColor: Colors.transparent,
            ),
            onTap: () {
              showModalBottomSheet(
                  context: context,
                  builder: (context) => ImageSourceSheet(
                        onImageSelected: (image) {
                          Navigator.of(context).pop();
                          _imageController = image;
                          setState(() {});
                        },
                      ));
            },
          ),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: "Nome",
            ),
            validator: (text) {
              if (text.isEmpty) return "Nome inválido!";
            },
          ),
          SizedBox(height: 16.0),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              hintText: "Seu E-mail",
            ),
            validator: (text) {
              if (text.isEmpty) return "E-mail inválido!";
            },
          ),
          SizedBox(height: 16.0),
          SizedBox(height: 16.0),
          SizedBox(
            height: 44.0,
            child: RaisedButton(
              child: Text(
                "Alterar Cadastro",
                style: TextStyle(fontSize: 18.0),
              ),
              textColor: Colors.white,
              color: Theme.of(context).primaryColor,
              onPressed: () async {
                if (_formKey.currentState.validate()) {
                  if (_emailController.text !=
                      UserModel.of(context).userData['email']) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ResetScreen(
                            _emailController.text,
                            _nameController.text,
                            _imageController == null
                                ? imagem
                                : _imageController.path)));
                  } else {
                    if (_imageController.path != null ||
                        _nameController.text !=
                            UserModel.of(context).userData['nome']) {
                      if (_nameController !=
                          UserModel.of(context).userData['nome']) {
                        UserModel.of(context).userData['nome'] =
                            _nameController.text;
                      }
                      if (_imageController != null) {
                        String url;

                        StorageUploadTask task = FirebaseStorage.instance
                            .ref()
                            .child(DateTime.now()
                                .millisecondsSinceEpoch
                                .toString())
                            .putFile(_imageController);

                        StorageTaskSnapshot taskSnapshot =
                            await task.onComplete;
                        url = await taskSnapshot.ref.getDownloadURL();

                        UserModel.of(context).userData['imagemPerfil'] = url;
                      }
                      UserModel.of(context).updateUserLocal();
                      Future.delayed(Duration(seconds: 1), () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => HomePage(),
                        ));
                      });
                      showColoredToast('Seu perfil foi atualizado!');
                    }
                  }
                }
              },
            ),
          ),
        ]));
  }

  void showColoredToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_LONG,
      backgroundColor: Theme.of(context).primaryColor,
      textColor: Colors.white,
    );
  }

  void onSuccess() {
    showDialog(
        context: context,
        builder: (context) {
          Widget okButton = FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'ok',
                style: TextStyle(color: Colors.white),
              ));

          AlertDialog alert = AlertDialog(
            content: Text(
              'Usuário atualizado com sucesso!!',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            backgroundColor: Theme.of(context).primaryColor,
            actions: [
              okButton,
            ],
          );

          return alert;
        });
  }

  void onFail() {
    showDialog(
        context: context,
        builder: (context) {
          Widget okButton = FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'ok',
                style: TextStyle(color: Colors.white),
              ));

          AlertDialog alert = AlertDialog(
            content: Text(
              'Falha ao atualizar usuário, tente novamente!!',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            backgroundColor: Theme.of(context).primaryColor,
            actions: [
              okButton,
            ],
          );
          return alert;
        });
  }
}
