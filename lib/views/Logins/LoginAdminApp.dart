import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:farmacia2pdm/views/CriarUsers/CriarAdminApp.dart';
import 'package:farmacia2pdm/views/PaginaInicial/AdminAppPage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginAdminApp extends StatefulWidget {
  const LoginAdminApp({super.key});

  @override
  State<LoginAdminApp> createState() => _LoginAdminAppState();
}

class _LoginAdminAppState extends State<LoginAdminApp> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  bool isLoading = false;

  Future<void> _loginAdmin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: senhaController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Logado com sucesso!")),
      );

      // Redireciona após login bem-sucedido
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AdminAppPage()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email ou senha inválidos.")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text("Login Administrador", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) => value == null || value.isEmpty ? 'Informe o email' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: senhaController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Senha'),
                  validator: (value) => value == null || value.isEmpty ? 'Informe a senha' : null,
                ),
                const SizedBox(height: 20),
                isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: _loginAdmin,
                  child: const Text('Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
