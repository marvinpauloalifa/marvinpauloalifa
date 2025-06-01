import 'package:flutter/material.dart';
import 'package:farmacia2pdm/views/CriarUsers/RegistoUsuario.dart';
import 'package:farmacia2pdm/views/PaginaInicial/UserPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  bool isLoading = false;

  Future<void> _loginCliente() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    final email = emailController.text.trim();
    final senha = senhaController.text.trim();

    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: senha);

      final user = userCredential.user;

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const UserPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String mensagemErro;
      if (e.code == 'user-not-found') {
        mensagemErro = 'Este utilizador não está registrado.';
      } else if (e.code == 'wrong-password') {
        mensagemErro = 'Senha incorreta.';
      } else if (e.code == 'invalid-email') {
        mensagemErro = 'Email inválido.';
      } else {
        mensagemErro = 'Erro ao fazer login. Tente novamente.';
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensagemErro)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tente novamente.")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _irParaCriarConta() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegistoUsuario()),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Login",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green),
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: emailController,
                      validator: (value) =>
                      value == null || value.isEmpty ? 'Informe o e-mail' : null,
                      decoration: InputDecoration(
                        hintText: 'E-mail',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: senhaController,
                      obscureText: true,
                      validator: (value) =>
                      value == null || value.isEmpty ? 'Informe a senha' : null,
                      decoration: InputDecoration(
                        hintText: 'Senha',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _loginCliente,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent.shade400,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Login', style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Ainda não tem conta? "),
                        GestureDetector(
                          onTap: _irParaCriarConta,
                          child: const Text("Registe-se", style: TextStyle(color: Colors.green)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("É administrador? "),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(context, '/loginAdm');
                          },
                          child: const Text("Login", style: TextStyle(color: Colors.green)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
