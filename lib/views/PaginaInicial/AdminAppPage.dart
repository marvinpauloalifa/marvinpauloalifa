import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Importa as páginas de destino diretamente
//import 'package:farmacia2pdm/views/AdminApp/ListarFarmacias.dart'; // Para gerir farmácias
import 'package:farmacia2pdm/views/Farmacia/ListarMedicamentos.dart'; // Para gerir medicamentos
//import 'package:farmacia2pdm/views/GerirUsuarios.dart';
import 'package:farmacia2pdm/views/APP/GerirUsuarios.dart';
import '../APP/ListarFarmacias.dart'; // Para gerir usuários
// O import abaixo pode ser removido se CriarAdminFarmacia não for chamada diretamente desta página
// import 'package:farmacia2pdm/views/CriarUsers/CriarAdminFarmacia.dart';


class AdminAppPage extends StatelessWidget {
  const AdminAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Administração da Aplicação"),
        backgroundColor: Colors.green[700], // Adicionado cor para o AppBar
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // --- Gerir Farmácias ---
          Card( // Adicionado Card para melhor visual
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: const Text('Gerir Farmácias', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Visualizar, editar e apagar farmácias cadastradas'),
              trailing: Icon(Icons.local_pharmacy, color: Colors.green[700], size: 30),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ListarFarmacias()), // Navegação direta
              ),
            ),
          ),
          // --- Gerir Medicamentos ---
          Card( // Adicionado Card para melhor visual
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: const Text('Gerir Medicamentos', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Adicionar, remover e ajustar estoque de medicamentos'),
              trailing: Icon(Icons.medical_services, color: Colors.green[700], size: 30),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ListarMedicamentos()), // Navegação direta
              ),
            ),
          ),
          // --- Gerir Usuários ---
          Card( // Adicionado Card para melhor visual
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: const Text('Gerir Usuários', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Visualizar, editar, adicionar e apagar contas de usuários e administradores'),
              trailing: Icon(Icons.group, color: Colors.green[700], size: 30),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GerirUsuarios()), // Navegação direta
              ),
            ),
          ),
        ],
      ),
    );
  }
}
