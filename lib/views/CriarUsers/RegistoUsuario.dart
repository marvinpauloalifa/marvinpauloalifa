import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegistoUsuario extends StatefulWidget {
  const RegistoUsuario({super.key});

  @override
  State<RegistoUsuario> createState() => _RegistoUsuarioState();
}

class _RegistoUsuarioState extends State<RegistoUsuario> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final TextEditingController confirmarSenhaController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  Future<void> _registrarCliente() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final String nome = nomeController.text.trim();

    try {
      // Registra na autenticação do Firebase
      final UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: senhaController.text.trim(),
      );

      // Grava no Firestore usando o nomedo documento
      await FirebaseFirestore.instance
          .collection('users')
          .doc(nome)
          .set({
        'nome': nome,
        'email': emailController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      Navigator.pushReplacementNamed(context, '/login');
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
                  "Registo de Cliente",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: nomeController,
                  decoration: InputDecoration(
                    hintText: 'Nome',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Informe o nome' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: 'E-mail',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Informe o e-mail' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: senhaController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Senha',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (value) =>
                  value == null || value.length < 6 ? 'Mínimo 6 caracteres' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmarSenhaController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Confirmar Senha',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (value) =>
                  value != senhaController.text ? 'Senhas não coincidem' : null,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _registrarCliente,
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
                if (errorMessage != null)
                  Text(errorMessage!, style: const TextStyle(color: Colors.red)),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text("Já tem conta? Entrar",
                      style: TextStyle(color: Colors.green)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

