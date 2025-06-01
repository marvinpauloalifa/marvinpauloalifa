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

  bool isLoading = false;
  String? errorMessage;

  late String id; // Variável para armazenar o id gerado

  String gerarId(String nome) {
    final nomeFormatado = nome.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '.');
    final numeroAleatorio = Random().nextInt(100); // Ex: 0 a 99
    return "$nomeFormatado$numeroAleatorio";
  }

  Future<void> _registrarFarmacia() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final String nome = nomeController.text.trim();
    id = gerarId(nome);

    try {
      // Registra na autenticação do Firebase
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: senhaController.text.trim(),
      );

      final farmaciaData = {
        'id': id,
        'nome': nome,
        'endereco': enderecoController.text.trim(),
        'telefone': telefoneController.text.trim(),
        'email': emailController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Salva no Firestore
      await FirebaseFirestore.instance.collection('farmacias').doc(id).set(farmaciaData);

      // Salva localmente
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('id_farmacia', id);
      await prefs.setString('nome_farmacia', nome);
      await prefs.setString('endereco_farmacia', enderecoController.text.trim());
      await prefs.setString('telefone_farmacia', telefoneController.text.trim());
      await prefs.setString('email_farmacia', emailController.text.trim());

      // Pop-up sucesso com o ID da farmácia
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Farmacia criada com sucesso!'),
          content: Text('ID da farmácia: $id'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // fecha o diálogo
                Navigator.pushReplacementNamed(context, '/loginAdm'); // vai para login da farmacia
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
        errorMessage = "Erro inesperado: ${e.toString()}";
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text(
                  "Registo de Farmácia",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 40),
                _campoTexto("Nome da Farmácia", nomeController, icon: Icons.local_pharmacy),
                const SizedBox(height: 16),
                _campoTexto("Endereço", enderecoController, icon: Icons.location_on),
                const SizedBox(height: 16),
                _campoTexto("Telefone", telefoneController,
                    tipo: TextInputType.phone, icon: Icons.phone),
                const SizedBox(height: 16),
                _campoTexto("E-mail", emailController,
                    tipo: TextInputType.emailAddress, icon: Icons.email),
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
                  value != senhaController.text ? 'Senhas não são iguais.' : null,
                ),
                const SizedBox(height: 16),
                if (errorMessage != null)
                  Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _registrarFarmacia,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Registrar', style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _campoTexto(String texto, TextEditingController controller,
      {TextInputType tipo = TextInputType.text, bool senha = false, IconData? icon}) {
    return TextFormField(
      controller: controller,
      keyboardType: tipo,
      obscureText: senha,
      decoration: InputDecoration(
        hintText: texto,
        prefixIcon: icon != null ? Icon(icon, color: Colors.green) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Informe $texto' : null,
    );
  }
}
