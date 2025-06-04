import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminFarmaciaPage extends StatefulWidget {
  const AdminFarmaciaPage({super.key});

  @override
  State<AdminFarmaciaPage> createState() => _AdminFarmaciaPageState();
}

class _AdminFarmaciaPageState extends State<AdminFarmaciaPage> {
  String adminNome = '';
  String adminEmail = '';
  String idFarmacia = '';

  @override
  void initState() {
    super.initState();
    carregarDadosAdmin();
  }

  Future<void> carregarDadosAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      adminNome = prefs.getString('admin_nome') ?? '';
      adminEmail = prefs.getString('admin_email') ?? '';
      idFarmacia = prefs.getString('admin_idFarmacia') ?? '';
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/loginAdmin');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: const Text("Painel do Administrador"),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Sair',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Bem-vindo, $adminNome",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
            const SizedBox(height: 8),
            Text("Email: $adminEmail", style: const TextStyle(fontSize: 16)),
            Text("ID da Farmácia: $idFarmacia", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 32),

            const Text("Gerenciamento", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),

            _buildOption(
              icon: Icons.medical_services,
              label: 'Ver Medicamentos',
              onTap: () {
                Navigator.pushNamed(context, '/listarMedicamentos');
              },
            ),
            _buildOption(
              icon: Icons.inventory_2,
              label: 'Gerir Stock',
              onTap: () {
                Navigator.pushNamed(context, '/gerirStock');
              },
            ),
            _buildOption(
              icon: Icons.info_outline,
              label: 'Informações da Farmácia',
              onTap: () {
                Navigator.pushNamed(context, '/infoFarmacia');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({required IconData icon, required String label, required VoidCallback onTap}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(label, style: const TextStyle(fontSize: 16)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
