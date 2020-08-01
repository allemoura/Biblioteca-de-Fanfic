import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter/material.dart';

class UserModel extends Model {
  FirebaseAuth _auth = FirebaseAuth.instance;

  FirebaseUser firebaseUser;
  Map<String, dynamic> userData = Map();

  bool isLoding = false;

  static UserModel of(BuildContext context) =>
      ScopedModel.of<UserModel>(context);

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);

    _loadCurrentUser();
  }

  //fazer cadastro
  void signUp(
      {@required Map<String, dynamic> userData,
      @required String pass,
      @required VoidCallback onSuccess,
      @required VoidCallback onFail}) {
    isLoding = true;
    notifyListeners();

    _auth
        .createUserWithEmailAndPassword(
            email: userData['email'], password: pass)
        .then((user) async {
      firebaseUser = user;

      await _saveUserData(userData);

      onSuccess();
      isLoding = false;
      notifyListeners();
    }).catchError((e) {
      onFail();
      isLoding = false;
      notifyListeners();
    });
  }

  //fazer login
  void signIn(
      {@required String email,
      @required String pass,
      @required VoidCallback onSuccess,
      @required VoidCallback onFail}) async {
    isLoding = true;
    notifyListeners();

    _auth.signInWithEmailAndPassword(email: email, password: pass).then((user) {
      firebaseUser = user;
      _loadCurrentUser();

      onSuccess();
      isLoding = false;
      notifyListeners();
    }).catchError((e) {
      onFail();

      isLoding = false;
      notifyListeners();
    });
  }

  void signOut() async {
    await _auth.signOut();

    userData = Map();
    firebaseUser = null;

    notifyListeners();
  }

  //recuperar senha
  void recoverPass(String email) {
    _auth.sendPasswordResetEmail(email: email);
  }

  void updateEmail(String email) {
    firebaseUser.updateEmail(email).catchError((onError) => print(onError));
  }

  Future<Null> _loadCurrentUser() async {
    if (firebaseUser == null) firebaseUser = await _auth.currentUser();
    if (firebaseUser != null) {
      if (userData["nome"] == null) {
        DocumentSnapshot docUser = await Firestore.instance
            .collection("users")
            .document(firebaseUser.uid)
            .get();
        userData = docUser.data;
      }
    }
    notifyListeners();
  }

  //saber se esta logado
  bool isLoggedIn() {
    return firebaseUser != null;
  }

  Future<Null> _saveUserData(Map<String, dynamic> userData) async {
    this.userData = userData;
    await Firestore.instance
        .collection("users")
        .document(firebaseUser.uid)
        .setData(userData);
  }

  double getPontos() {
    if (isLoggedIn() || isLoding) {
      if (userData['pontos'] != null) {
        return userData['pontos'] + 0.0;
      } else {
        return 0.01;
      }
    } else {
      return 0.00;
    }
  }

  Future updateUserDate(Map<String, dynamic> userDate) async {
    isLoding = true;
    notifyListeners();

    try {
      await _saveUserData(userDate);

      isLoding = false;
      notifyListeners();
    } catch (e) {
      isLoding = false;
      notifyListeners();
    }
  }

  Future<void> updateUserLocal() async {
    isLoding = true;
    notifyListeners();

    try {
      await _saveUserData(this.userData);

      isLoding = false;
      notifyListeners();
    } catch (e) {
      isLoding = false;
      notifyListeners();
    }
  }

  Future<void> updateUser(
      {@required Map<String, dynamic> userData,
      @required VoidCallback onSuccess,
      @required VoidCallback onFail}) async {
    isLoding = true;
    notifyListeners();

    try {
      await _saveUserData(userData);

      onSuccess();
      isLoding = false;
      notifyListeners();
    } catch (e) {
      onFail();
      isLoding = false;
      notifyListeners();
    }
  }
}
