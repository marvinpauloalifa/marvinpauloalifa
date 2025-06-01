import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../CriarUsers/CriarAdminFarmacia.dart';


class AdminFarmaciaPage extends StatefulWidget {
  const AdminFarmaciaPage({super.key});

  @override
  State<AdminFarmaciaPage> createState() => _AdminFarmaciaPageState();
}

class _AdminFarmaciaPageState extends State<AdminFarmaciaPage> {
  String nomeFarmacia = "Administração da Farmácia";

  @override
  void initState() {
    super.initState();
    _carregarNomeFarmacia();
  }

  Future<void> _carregarNomeFarmacia() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nomeFarmacia = prefs.getString('nomeFarmacia') ?? "Administração da Farmácia";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(nomeFarmacia),
        backgroundColor: Colors.green[400],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/registerFarmacia'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[400],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.edit, color: Colors.white),
              label: const Text(
                'Editar Informações da Farmácia',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/gerirMedicamentos'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[400],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.medical_services, color: Colors.white),
              label: const Text(
                'Listar Medicamentos da Farmácia',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/gerirStock'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[400],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.storage, color: Colors.white),
              label: const Text(
                'Gerir Stock de Medicamentos',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
