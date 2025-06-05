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
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Sair',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Seja bem-vindo, $adminNome",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildDashboardCard(
                    icon: Icons.add_box_rounded,
                    label: 'Adicionar Medicamentos',
                    onTap: () => Navigator.pushNamed(context, '/gerirMedicamentos'),
                    color: Colors.green.shade300,
                  ),
                  _buildDashboardCard(
                    icon: Icons.inventory_2,
                    label: 'Gerir Stock',
                    onTap: () => Navigator.pushNamed(context, '/gerirStock'),
                    color: Colors.green.shade400,
                  ),
                  _buildDashboardCard(
                    icon: Icons.info_outline,
                    label: 'Editar Farmácia',
                    onTap: () => Navigator.pushNamed(context, '/EditarMed'),
                    color: Colors.green.shade500,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, Colors.green.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.green.shade200, blurRadius: 6, offset: const Offset(0, 4)),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
