import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fanfic/data/Fanfic.dart';
import 'package:fanfic/models/user_model.dart';
import 'package:fanfic/screens/FanficPage.dart';
import 'package:fanfic/screens/login_screen.dart';
import 'package:fanfic/screens/perfil_screen.dart';
import 'package:fanfic/widgets/top_container.dart';
import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions { orderaz, orderza, orderconsim, onderconbai }

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<FanficData> fanfics = List();
  double tamanho;
  String estado = 'Entrar';
  String saudacao = ' ';
  String uid;
  bool inicio = false;
  double width;

  initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget barra() {
    return Stack(
      children: [
        TextField(
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
              hintText: "Pesquisar",
              hintStyle: TextStyle(color: Colors.white),
              icon: Icon(
                Icons.search,
                color: Colors.white,
              ),
              border: InputBorder.none),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    tamanho = MediaQuery.of(context).size.height * 0.15;

    if (UserModel.of(context).isLoggedIn()) {
      estado = 'Sair';
      //uid = UserModel.of(context).firebaseUser.uid;
    }
    if (UserModel.of(context).isLoggedIn()) {
      if (UserModel.of(context).userData['nome'] == null) {
        saudacao = " ";
      } else {
        saudacao = "Olá, ${UserModel.of(context).userData['nome']}";
      }
    } else {
      saudacao = "Olá, bem vindo!";
    }

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0.0,
          title: barra(),
          actions: [
            PopupMenuButton<OrderOptions>(
              icon: Icon(
                Icons.more_vert,
                size: 30,
                color: Colors.white,
              ),
              itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
                const PopupMenuItem<OrderOptions>(
                  child: Text("Ordenar de A-Z"),
                  value: OrderOptions.orderaz,
                ),
                const PopupMenuItem<OrderOptions>(
                  child: Text("Ordenar de Z-A"),
                  value: OrderOptions.orderza,
                ),
                const PopupMenuItem<OrderOptions>(
                  child: Text("Ordenar por Concluidas"),
                  value: OrderOptions.orderconsim,
                ),
                const PopupMenuItem<OrderOptions>(
                  child: Text("Ordenar por Não Concluidas"),
                  value: OrderOptions.onderconbai,
                )
              ],
              onSelected: _orderList,
            )
          ],
        ),
        backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (UserModel.of(context).isLoggedIn()) {
              _showFanficPage();
            } else {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => LoginScreen(),
              ));
            }
          },
          child: Icon(Icons.add),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: body());
  }

  Widget body() {
    return ScopedModelDescendant<UserModel>(builder: (context, child, model) {
      if (model.isLoding) {
        return Center(
          child: CircularProgressIndicator(
            backgroundColor: Theme.of(context).primaryColor,
          ),
        );
      } else {
        if (model.isLoggedIn()) {
          if (!inicio) {
            uid = model.firebaseUser.uid;
            getProducts(model.firebaseUser.uid);
            inicio = true;
          }
        }
        return Stack(children: <Widget>[
          SafeArea(
              child: TopContainer(
            height: tamanho,
            width: width,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 0, vertical: 0.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        GestureDetector(
                          child: UserModel.of(context).isLoggedIn()
                              ? Container(
                                  width: 80.0,
                                  height: 80.0,
                                  decoration: BoxDecoration(
                                    border: new Border.all(color: Colors.white),
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(
                                            50.0) //                 <--- border radius here
                                        ),
                                    //shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image: model.userData['imagemPerfil'] !=
                                                null
                                            ? NetworkImage(
                                                model.userData['imagemPerfil'])
                                            : AssetImage("images/perfil.png"),
                                        fit: BoxFit.cover),
                                  ),
                                )
                              : Icon(
                                  Icons.account_circle,
                                  size: 60.0,
                                  color: Colors.grey[50],
                                ),
                          onTap: model.isLoggedIn()
                              ? () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => PerfilScreen()));
                                }
                              : null,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              child: Text(
                                saudacao,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontSize: 22.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            GestureDetector(
                              child: Container(
                                child: Text(
                                  estado,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              onTap: () {
                                if (UserModel.of(context).isLoggedIn()) {
                                  UserModel.of(context).signOut();
                                  estado = 'Entrar';
                                } else {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => LoginScreen()));
                                }
                              },
                            )
                          ],
                        )
                      ],
                    ),
                  )
                ]),
          )),
          model.isLoggedIn()
              ? Container(
                  margin: EdgeInsets.only(top: 100),
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.only(top: 10, left: 10.0, right: 10.0),
                    itemCount: fanfics.length,
                    itemBuilder: (context, index) {
                      return _fanficCard(context, fanfics[index]);
                    },
                  ))
              : Container()
        ]);
      }
    });
  }

  Widget _fanficCard(BuildContext context, FanficData fanficData) {
    return GestureDetector(
      child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.74,
          child: Card(
            color: corCard(fanficData.concluido),
            margin: EdgeInsets.only(bottom: 15),
            child: Padding(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 20.0),
                    width: 300.0,
                    height: 200.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      image: DecorationImage(
                          image: fanficData.imagem != ''
                              ? NetworkImage(fanficData.imagem)
                              : AssetImage("images/book.png"),
                          fit: BoxFit.contain),
                    ),
                  ),
                  Padding(
                      padding:
                          EdgeInsets.only(left: 0.0, top: 10.0, bottom: 10),
                      child: Text(
                        fanficData.titulo ?? "",
                        style: TextStyle(
                            fontSize: 22.0, fontWeight: FontWeight.bold),
                      )),
                  Expanded(
                      child: SingleChildScrollView(
                          child: Padding(
                    padding: EdgeInsets.only(left: 0.0, top: 0.0),
                    child: Wrap(
                        alignment: WrapAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            height: 30.0,
                          ),
                          ConstrainedBox(
                              constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width,
                                  maxHeight:
                                      MediaQuery.of(context).size.height * 0.6),
                              child: Text(
                                fanficData.descricao ?? "",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    fontSize: 18.0, color: Colors.grey[800]),
                              ))
                        ]),
                  )))
                ],
              ),
            ),
          )),
      onTap: () {
        _showOptions(context, fanficData);
      },
    );
  }

  void _showOptions(BuildContext context, FanficData fanficData) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
            onClosing: () {},
            builder: (context) {
              return SingleChildScrollView(
                  padding: EdgeInsets.all(10.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.2,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: FlatButton(
                            child: Text(
                              "Abrir Fanfic",
                              style: TextStyle(
                                  color: Colors.purpleAccent, fontSize: 20.0),
                            ),
                            onPressed: () {
                              launch(fanficData.link);
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: FlatButton(
                            child: Text(
                              "Editar",
                              style: TextStyle(
                                  color: Colors.purpleAccent, fontSize: 20.0),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              _showFanficPage(fanfic: fanficData);
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: FlatButton(
                            child: Text(
                              "Excluir",
                              style: TextStyle(
                                  color: Colors.purpleAccent, fontSize: 20.0),
                            ),
                            onPressed: () {
                              setState(() {
                                Firestore.instance
                                    .collection('users')
                                    .document(uid)
                                    .collection('fanfics')
                                    .document(fanficData.id)
                                    .delete();

                                Navigator.pop(context);
                                setState(() {});
                              });
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: FlatButton(
                            child: Text(
                              verificaConcluida(fanficData.concluido),
                              style: TextStyle(
                                  color: Colors.purpleAccent, fontSize: 20.0),
                            ),
                            onPressed: () {
                              if (fanficData.concluido == false) {
                                fanficData.concluido = true;
                              } else {
                                fanficData.concluido = false;
                              }
                              Firestore.instance
                                  .collection('users')
                                  .document(uid)
                                  .collection('fanfics')
                                  .document(fanficData.id)
                                  .updateData(fanficData.fanficToMap());
                              Navigator.pop(context);
                              setState(() {
                                getProducts(uid);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ));
            },
          );
        });
  }

  void _showFanficPage({FanficData fanfic}) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => FanficPage(
                  fanfic: fanfic,
                )));
  }

  void _orderList(OrderOptions result) {
    switch (result) {
      case OrderOptions.orderaz:
        fanfics.sort((a, b) {
          return a.titulo.toLowerCase().compareTo(b.titulo.toLowerCase());
        });
        break;
      case OrderOptions.orderza:
        fanfics.sort((a, b) {
          return b.titulo.toLowerCase().compareTo(a.titulo.toLowerCase());
        });
        break;
      case OrderOptions.onderconbai:
        fanfics.sort((a, b) {
          if (a.concluido && b.concluido == false)
            return 1;
          else if (a.concluido != false && b.concluido)
            return -1;
          else
            return 0;
        });
        break;
      case OrderOptions.orderconsim:
        fanfics.sort((a, b) {
          if (a.concluido == false && b.concluido)
            return 1;
          else if (a.concluido && b.concluido == false)
            return -1;
          else
            return 0;
        });
        break;
    }
    setState(() {});
  }

  String verificaConcluida(bool concluido) {
    if (!concluido) {
      return "Concluida";
    } else {
      return "Desmarcar";
    }
  }

  Color corCard(bool concluido) {
    if (concluido) {
      return Colors.greenAccent;
    } else {
      return Colors.white;
    }
  }

  void getProducts(String uid) async {
    List<FanficData> f = List();
    await Firestore.instance
        .collection('users')
        .document(uid)
        .collection('fanfics')
        .getDocuments()
        .then((value) {
      int i = 0;
      while (i < value.documents.length) {
        FanficData data = FanficData.fromDocument(value.documents[i]);

        f.add(data);
        i++;
      }
    });

    setState(() {
      fanfics = f;
    });
  }
}
