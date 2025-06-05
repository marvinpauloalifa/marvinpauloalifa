import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegistoFarmacias extends StatefulWidget {
  const RegistoFarmacias({super.key});

  @override
  State<RegistoFarmacias> createState() => _RegistoFarmaciasState();
}

class _RegistoFarmaciasState extends State<RegistoFarmacias> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController enderecoController = TextEditingController();
  final TextEditingController telefoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final TextEditingController confirmarSenhaController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;
  late String id;

  String gerarId(String nome) {
    final nomeFormatado = nome.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '.');
    final numeroAleatorio = Random().nextInt(100);
    return "$nomeFormatado$numeroAleatorio";
  }

  Future<void> _registrarFarmacia() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final String nome = nomeController.text.trim();
      id = gerarId(nome);

      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: senhaController.text.trim(),
      );

      final double latitude = double.parse(latitudeController.text.trim());
      final double longitude = double.parse(longitudeController.text.trim());

      final farmaciaData = {
        'id': id,
        'nome': nome,
        'endereco': enderecoController.text.trim(),
        'telefone': telefoneController.text.trim(),
        'email': emailController.text.trim(),
        'localizacao': GeoPoint(latitude, longitude),
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('farmacias').doc(id).set(farmaciaData);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('id_farmacia', id);
      await prefs.setString('nome_farmacia', nome);
      await prefs.setString('endereco_farmacia', enderecoController.text.trim());
      await prefs.setString('telefone_farmacia', telefoneController.text.trim());
      await prefs.setString('email_farmacia', emailController.text.trim());

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Farmácia criada com sucesso!'),
          content: Text('ID da farmácia: $id'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/loginAdm');
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message ?? "Erro desconhecido";
      });
    } catch (e) {
      setState(() {
        errorMessage = "Erro: ${e.toString()}";
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  String? validarTelefone(String? value) {
    final pattern = r'^\+258[278][0-9]{7}$'; // Sem espaços
    if (value == null || !RegExp(pattern).hasMatch(value.trim())) {
      return 'Formato inválido. Use +258823921111';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFa8e063), Color(0xFF56ab2f)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text(
                        "Registo de Farmácia",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2e7d32),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _campoTexto("Nome da Farmácia", nomeController, icon: Icons.local_pharmacy),
                      const SizedBox(height: 16),
                      _campoTexto("Endereço", enderecoController, icon: Icons.location_on),
                      const SizedBox(height: 16),
                      _campoTexto("E-mail", emailController,
                          tipo: TextInputType.emailAddress, icon: Icons.email),
                      const SizedBox(height: 16),
                      _campoTexto("Telefone (+258...)",
                          telefoneController,
                          tipo: TextInputType.phone,
                          icon: Icons.phone,
                          validator: validarTelefone),
                      const SizedBox(height: 16),
                      _campoTexto("Latitude", latitudeController,
                          tipo: TextInputType.numberWithOptions(decimal: true),
                          icon: Icons.map),
                      const SizedBox(height: 16),
                      _campoTexto("Longitude", longitudeController,
                          tipo: TextInputType.numberWithOptions(decimal: true),
                          icon: Icons.map_outlined),
                      const SizedBox(height: 16),
                      _campoTexto("Senha", senhaController, senha: true, icon: Icons.lock),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: confirmarSenhaController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Confirmar Senha',
                          prefixIcon: const Icon(Icons.lock),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (value) =>
                        value != senhaController.text ? 'Senhas não coincidem.' : null,
                      ),
                      const SizedBox(height: 16),
                      if (errorMessage != null)
                        Text(errorMessage!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _registrarFarmacia,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF388e3c),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Registrar',
                              style: TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _campoTexto(String texto, TextEditingController controller,
      {TextInputType tipo = TextInputType.text,
        bool senha = false,
        IconData? icon,
        String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      keyboardType: tipo,
      obscureText: senha,
      decoration: InputDecoration(
        hintText: texto,
        prefixIcon: icon != null ? Icon(icon, color: Colors.green[700]) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: validator ?? (value) =>
      value == null || value.isEmpty ? 'Informe $texto' : null,
    );
  }
}
