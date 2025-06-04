import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditarDadosFarmacia extends StatefulWidget {
  @override
  _EditarDadosFarmaciaState createState() => _EditarDadosFarmaciaState();
}

class _EditarDadosFarmaciaState extends State<EditarDadosFarmacia> {
  final _formKey = GlobalKey<FormState>();
  final nomeController = TextEditingController();
  final enderecoController = TextEditingController();
  final emailController = TextEditingController();

  String? idFarmacia;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarDadosFarmacia();
  }

  Future<void> _carregarDadosFarmacia() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    idFarmacia = prefs.getString('id_farmacia');

    if (idFarmacia != null) {
      final doc = await FirebaseFirestore.instance.collection('farmacias').doc(idFarmacia).get();
      if (doc.exists) {
        final data = doc.data()!;
        nomeController.text = data['nome'] ?? '';
        enderecoController.text = data['endereco'] ?? '';
        emailController.text = data['email'] ?? '';
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _salvarAlteracoes() async {
    if (!_formKey.currentState!.validate() || idFarmacia == null) return;

    await FirebaseFirestore.instance.collection('farmacias').doc(idFarmacia).update({
      'nome': nomeController.text.trim(),
      'endereco': enderecoController.text.trim(),
      'email': emailController.text.trim(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dados atualizados com sucesso!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Editar Dados da Farmácia"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const Text(
                  "Atualize os dados da sua farmácia",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                _buildInputField("Nome da farmácia", nomeController),
                const SizedBox(height: 16),
                _buildInputField("Endereço", enderecoController),
                const SizedBox(height: 16),
                _buildInputField("Email", emailController, TextInputType.emailAddress),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: _salvarAlteracoes,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Salvar Alterações", style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller,
      [TextInputType keyboardType = TextInputType.text]) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.green),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.greenAccent.shade100),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      ),
    );
  }
}
