import 'package:fanfic/models/user_model.dart';
import 'package:fanfic/screens/cadastro_Screen.dart';
import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool mostrarSenha = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar:
            AppBar(title: Text("Entrar"), centerTitle: true, actions: <Widget>[
          FlatButton(
            child: Text("CRIAR CONTA", style: TextStyle(fontSize: 15.0)),
            textColor: Colors.white,
            onPressed: () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => CadastroScreen()));
            },
          )
        ]),
        body: ScopedModelDescendant<UserModel>(
          builder: (context, child, model) {
            if (model.isLoding) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return Form(
                  key: _formKey,
                  child: ListView(
                      padding: EdgeInsets.all(16.0),
                      children: <Widget>[
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: "E-mail",
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (text) {
                            if (text.isEmpty || !text.contains('@'))
                              return "E-mail inválido!";
                          },
                        ),
                        TextFormField(
                          controller: _senhaController,
                          decoration: InputDecoration(
                            hintText: "Senha",
                          ),
                          obscureText: mostrarSenha,
                          validator: (text) {
                            if (text.isEmpty || text.length < 8)
                              return "Senha inválida!";
                          },
                        ),
                        SizedBox(height: 20.0),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              height: 16.0,
                              child: Checkbox(
                                  activeColor: Theme.of(context).primaryColor,
                                  value: !mostrarSenha,
                                  onChanged: (bool value) {
                                    mostrarSenha = !mostrarSenha == true;
                                    setState(() {});
                                  }),
                            ),
                            Text(
                              "Mostrar Senha",
                              style: TextStyle(
                                  color: Colors.grey[900],
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 16.0,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: FlatButton(
                                  onPressed: () {
                                    if (_emailController.text.isEmpty) {
                                      _scaffoldKey.currentState
                                          .showSnackBar(SnackBar(
                                        content: Text(
                                            "Insira seu e-mail para recuperação!"),
                                        backgroundColor: Colors.redAccent,
                                        duration: Duration(seconds: 2),
                                      ));
                                    } else {
                                      model.recoverPass(_emailController.text);
                                      _scaffoldKey.currentState
                                          .showSnackBar(SnackBar(
                                        content: Text("Confira seu e-mail!"),
                                        backgroundColor:
                                            Theme.of(context).primaryColor,
                                        duration: Duration(seconds: 2),
                                      ));
                                    }
                                  },
                                  child: Text(
                                    "Esqueci minha senha",
                                    style: TextStyle(
                                        color: Colors.grey[900],
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.right,
                                  ),
                                  padding: EdgeInsets.only(left: 35.0),
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 20.0),
                        SizedBox(
                          height: 44.0,
                          child: RaisedButton(
                            child: Text(
                              "Entrar",
                              style: TextStyle(fontSize: 18.0),
                            ),
                            textColor: Colors.white,
                            color: Theme.of(context).primaryColor,
                            onPressed: () {
                              if (_formKey.currentState.validate()) {
                                model.signIn(
                                  email: _emailController.text,
                                  pass: _senhaController.text,
                                  onFail: _onFail,
                                  onSuccess: _onSuccess,
                                );
                              }
                            },
                          ),
                        ),
                      ]));
            }
          },
        ));
  }

  void _onSuccess() {
    Navigator.of(context).pop();
  }

  void _onFail() {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text("Falha ao Entrar!"),
      backgroundColor: Colors.redAccent,
      duration: Duration(seconds: 2),
    ));
  }
}
