import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'viewmodels/UserViewModel.dart'; // ✅ Importa o ViewModel
import 'views/Farmacia/EditarDadosFarmacia.dart';
import 'views/Farmacia/AdminFarmaciaPage.dart';
import 'views/CriarUsers/CriarAdminFarmacia.dart';
import 'views/Farmacia/GerirStock.dart';
import 'views/PaginaInicial/AdminAppPage.dart';
import 'views/Logins/LoginFarmacia.dart';
import 'views/Logins/LoginPage.dart';
import 'views/CriarUsers/RegistoFarmacias.dart';
import 'views/PaginaInicial/UserPage.dart';
import 'views/PaginaInicial/InicioPage.dart';
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

  runApp(
    /// ✅ Envolve o app com `ChangeNotifierProvider` para o `UserViewModel`
    ChangeNotifierProvider(
      create: (_) => UserViewModel(),
      child: const MainApp(),
    ),
  );
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
        '/registerFarmacia': (context) => const RegistoFarmacias(),
        '/gerirMedicamentos': (context) => const ListarMedicamentos(),
        '/adminFarmacia': (context) => const AdminFarmaciaPage(),
        '/adminApp': (context) => const AdminAppPage(),
        '/registeruser': (context) => const RegistoUsuario(),
        '/loginAdm': (context) => const LoginFarmacia(),
        '/loginAdmApp': (context) => const LoginAdminApp(),
        '/gerirStock': (context) => GerirStock(),
        '/EditarMed': (context) => EditarDadosFarmacia(),
      },
    );
  }
}
