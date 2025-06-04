import 'package:flutter/material.dart';
import 'package:farmacia2pdm/views/CriarUsers/RegistoUsuario.dart';
import 'package:farmacia2pdm/views/PaginaInicial/UserPage.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: senhaController.text.trim(),
      );

      if (userCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const UserPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String mensagemErro;
      switch (e.code) {
        case 'user-not-found':
          mensagemErro = 'Este utilizador não está registrado.';
          break;
        case 'wrong-password':
          mensagemErro = 'Senha incorreta.';
          break;
        case 'invalid-email':
          mensagemErro = 'Email inválido.';
          break;
        default:
          mensagemErro = 'Erro ao fazer login. Tente novamente.';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensagemErro)));
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _irParaCriarConta() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegistoUsuario()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 8,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Entrar como Cliente",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => value == null || value.isEmpty ? 'Informe o e-mail' : null,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email, color: Colors.green),
                          hintText: 'E-mail',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: senhaController,
                        obscureText: true,
                        validator: (value) => value == null || value.isEmpty ? 'Informe a senha' : null,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock, color: Colors.green),
                          hintText: 'Senha',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _loginCliente,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                            'Entrar',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Não tem conta? "),
                          GestureDetector(
                            onTap: _irParaCriarConta,
                            child: const Text(
                              "Registe-se",
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("É administrador? "),
                          GestureDetector(
                            onTap: () => Navigator.pushReplacementNamed(context, '/loginAdm'),
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
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
