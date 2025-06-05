
import 'package:farmacia2pdm/viewmodels/UserViewModel.dart';
import 'package:farmacia2pdm/views/CriarUsers/CriarAdminFarmacia.dart';
import 'package:farmacia2pdm/views/CriarUsers/RegistoFarmacias.dart';
import 'package:farmacia2pdm/views/Farmacia/GerirStock.dart';
import 'package:farmacia2pdm/views/Logins/LoginFarmacia.dart';
import 'package:farmacia2pdm/views/Logins/LoginPage.dart';
import 'package:farmacia2pdm/views/PaginaInicial/AdminAppPage.dart';
import 'package:farmacia2pdm/views/PaginaInicial/InicioPage.dart';
import 'package:farmacia2pdm/views/PaginaInicial/UserPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'views/CriarUsers/RegistoUsuario.dart';
import 'views/Farmacia/ListarMedicamentos.dart';
import 'views/Logins/LoginAdminApp.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyD3Iiunay3kJR5Xn_Dp_4uTGsWOyBHwtCU",
        authDomain: "farmaciapdm-4bab9.firebaseapp.com",
        projectId: "farmaciapdm-4bab9",
        storageBucket: "farmaciapdm-4bab9.appspot.com",
        messagingSenderId: "948651031691",
        appId: "1:948651031691:web:ff27995d3dbb7c678ba88e",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserViewModel()),
        // Adicione outros providers aqui se necessário
      ],
      child: MaterialApp(
        title: 'MediFinder',
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => InicioPage(),
          '/login': (context) => const LoginPage(),
          '/criarAdmin': (context) => const CriarAdminFarmacia(),
          '/user': (context) => const UserPage(),
          '/registerFarmacia': (context) => const RegistoFarmacias(),
          //'/listfarmacias': (context) => const ListarFarmacias(),
          '/gerirMedicamentos': (context) => const ListarMedicamentos(),
          '/adminApp': (context) => const AdminAppPage(),
          '/registeruser': (context) => const RegistoUsuario(),
          '/loginAdm': (context) => const LoginFarmacia(),
          '/loginAdmApp': (context) => const LoginAdminApp(),
          '/gerirStock': (context) => const GerirStock(),
          '/geriruser': (context) => GerirStock(),
        },
      ),
    );
  }
}