import 'package:farmacia2pdm/views/Farmacia/EditarMed.dart';
import 'package:farmacia2pdm/views/Farmacia/AdminFarmaciaPage.dart';
import 'package:farmacia2pdm/views/CriarUsers/CriarAdminFarmacia.dart';
import 'package:farmacia2pdm/views/Farmacia/GerirStock.dart';
import 'package:farmacia2pdm/views/PaginaInicial/AdminAppPage.dart';
import 'package:farmacia2pdm/views/Logins/LoginFarmacia.dart';
import 'package:farmacia2pdm/views/Logins/LoginPage.dart';
import 'package:farmacia2pdm/views/CriarUsers/RegistoFarmacias.dart';
import 'package:farmacia2pdm/views/PaginaInicial/UserPage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:farmacia2pdm/views/PaginaInicial/InicioPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'views/CriarUsers/RegistoUsuario.dart';
import 'views/Farmacia/ListarMedicamentos.dart';
import 'views/Logins/LoginAdminApp.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
            apiKey: "AIzaSyDY_kFitAPLjNFc9TRmVuwz4UoB7Gr_fKU",
            authDomain: "farmaciamedifinder.firebaseapp.com",
            projectId: "farmaciamedifinder",
            storageBucket: "farmaciamedifinder.firebasestorage.app",
            messagingSenderId: "288810801599",
            appId: "1:288810801599:web:630e87a3d994a056a2a90a"
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
    return MaterialApp(
      title: 'MediFinder',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => InicioPage(),
        '/login': (context) => const LoginPage(),
        '/criarAdmin': (context) => const CriarAdminFarmacia(),
        '/user': (context) => const UserPage(),
       // '/registar': (context) => const RegistoPage(),
        '/registerFarmacia': (context) => const RegistoFarmacias(),
        //'/listfarmacias': (context) => const ListagemFarmacias(),
        //'/addMedication': (context) => AdicaoMedicamentos(),
        '/gerirMedicamentos': (context) => const ListarMedicamentos(),
        '/adminFarmacia': (context) => const AdminFarmaciaPage(),
        '/adminApp': (context) => const AdminAppPage(),
        '/registeruser':(context)=>const RegistoUsuario(),
        '/loginAdm': (context) => const LoginFarmacia(),
        '/loginAdmApp': (context) => const LoginAdminApp(),
        '/gerirStock': (context) => const GerirStock(),

      },
    );
  }
}



