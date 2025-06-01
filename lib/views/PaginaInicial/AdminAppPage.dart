import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:farmacia2pdm/views/CriarUsers/CriarAdminFarmacia.dart';

class AdminAppPage extends StatelessWidget {
  const AdminAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Administração da Aplicação")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ListTile(
            title: const Text('Gerir Farmácias'),
            subtitle: const Text('Editar ou apagar farmácias'),
            trailing: const Icon(Icons.local_pharmacy),
            onTap: () => Navigator.pushNamed(context, '/gerirFarmacias'),
          ),
          ListTile(
            title: const Text('Gerir Medicamentos'),
            subtitle: const Text('Adicionar, remover, ajustar estoque'),
            trailing: const Icon(Icons.medical_services),
            onTap: () => Navigator.pushNamed(context, '/gerirMedicamentos'),
          ),
          ListTile(
            title: const Text('Gerir Usuários'),
            subtitle: const Text('Editar, adicionar ou apagar usuários'),
            trailing: const Icon(Icons.group),
            onTap: () => Navigator.pushNamed(context, '/gerirUsuarios'),
          ),
        ],
      ),
    );
  }
}