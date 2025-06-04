import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginFarmacia extends StatefulWidget {
  const LoginFarmacia({super.key});

  @override
  State<LoginFarmacia> createState() => _LoginFarmaciaState();
}

class _LoginFarmaciaState extends State<LoginFarmacia> {
  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final senhaController = TextEditingController();

  bool isLoading = false;

  Future<void> _loginFarmacia() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final username = usernameController.text.trim();
    final senha = senhaController.text.trim();

    try {
      final doc = await FirebaseFirestore.instance
          .collection('farmacias')
          .doc(username)
          .get();

      if (!doc.exists) {
        _mostrarMensagem('Farmácia não encontrada.');
        return;
      }

      final email = doc.get('email');
      final idFarmacia = doc.id;

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('id_farmacia', idFarmacia);
      await prefs.setString('nome_farmacia', doc.get('nome'));
      await prefs.setString('email_farmacia', email);

      Navigator.pushReplacementNamed(context, '/adminFarmacia');
    } on FirebaseAuthException catch (e) {
      String erro = switch (e.code) {
        'user-not-found' => 'Email não encontrado.',
        'wrong-password' => 'Senha incorreta.',
        'invalid-email' => 'Email inválido.',
        _ => 'Erro ao fazer login.',
      };
      _mostrarMensagem(erro);
    } catch (e) {
      _mostrarMensagem('Erro inesperado. Verifique sua conexão.');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _mostrarMensagem(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  void _irParaCriarConta() {
    Navigator.pushNamed(context, '/criarFarmacia');
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
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 10,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Login da Farmácia',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: usernameController,
                        decoration: const InputDecoration(
                          labelText: 'ID/Nome da Farmácia',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                        value == null || value.isEmpty ? 'Informe o ID' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: senhaController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Senha',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                        value == null || value.isEmpty ? 'Informe a senha' : null,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _loginFarmacia,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                            'Entrar',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: _irParaCriarConta,
                        child: const Text(
                          'Não tem uma conta? Registre-se aqui.',
                          style: TextStyle(color: Colors.green),
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
}
