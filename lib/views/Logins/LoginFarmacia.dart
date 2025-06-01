import 'package:farmacia2pdm/views/Farmacia/AdminFarmaciaPage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginFarmacia extends StatefulWidget {
  const LoginFarmacia({super.key});

  @override
  State<LoginFarmacia> createState() => _LoginFarmaciaState();
}

class _LoginFarmaciaState extends State<LoginFarmacia> {
  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final idFarmaciaController = TextEditingController();
  final senhaController = TextEditingController();
  bool isLoading = false;

  Future<void> _loginAdminFarmacia() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    final username = usernameController.text.trim();
    final idFarmacia = idFarmaciaController.text.trim();
    final senha = senhaController.text.trim();

    try {
      final doc = await FirebaseFirestore.instance
          .collection('admin_farmacia')
          .doc(username)
          .get();

      if (!doc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário não encontrado.')),
        );
        return;
      }

      final email = doc.get('email');
      final idFarmaciaArmazenado = doc.get('idFarmacia');

      if (idFarmacia != idFarmaciaArmazenado) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ID da farmácia incorreto.')),
        );
        return;
      }

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('admin_username', username);
      await prefs.setString('admin_email', email);
      await prefs.setString('admin_idFarmacia', idFarmacia);

      Navigator.pushReplacementNamed(context, '/adminFarmacia');
    } on FirebaseAuthException catch (e) {
      String mensagemErro;
      if (e.code == 'user-not-found') {
        mensagemErro = 'Usuário não encontrado.';
      } else if (e.code == 'wrong-password') {
        mensagemErro = 'Senha incorreta.';
      } else if (e.code == 'invalid-email') {
        mensagemErro = 'Email inválido.';
      } else {
        mensagemErro = 'Erro ao fazer login. Tente novamente.';
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(mensagemErro)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tente novamente.')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _irParaCriarConta() {
    Navigator.pushNamed(context, '/criarAdmin').then((_) => setState(() {}));
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
                "Login  - Administrador",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: usernameController,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Informe o username'
                          : null,
                      decoration: InputDecoration(
                        hintText: 'Username do Administrador',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: idFarmaciaController,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Insira o ID da farmácia'
                          : null,
                      decoration: InputDecoration(
                        hintText: 'ID da Farmácia',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: senhaController,
                      obscureText: true,
                      validator: (value) =>
                      value == null || value.isEmpty ? 'Insira a senha' : null,
                      decoration: InputDecoration(
                        hintText: 'Senha',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _loginAdminFarmacia,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent.shade400,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                          'Login',
                          style:
                          TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Ainda não tem conta? "),
                        GestureDetector(
                          onTap: _irParaCriarConta,
                          child: const Text(
                            "Registe-se",
                            style: TextStyle(color: Colors.green),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
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
