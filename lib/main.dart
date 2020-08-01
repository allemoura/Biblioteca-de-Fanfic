import 'package:fanfic/models/user_model.dart';
import 'package:fanfic/screens/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scoped_model/scoped_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIOverlays([]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModel<UserModel>(
      model: UserModel(),
      child: ScopedModelDescendant<UserModel>(builder: (context, child, model) {
        return MaterialApp(
          theme: ThemeData(
              primarySwatch: Colors.blue, primaryColor: Color(0xfff27bac)),
          debugShowCheckedModeBanner: false,
          home: HomePage(),
        );
      }),
    );
  }
}
