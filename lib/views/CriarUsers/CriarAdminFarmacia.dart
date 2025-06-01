import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CriarAdminFarmacia extends StatefulWidget {
  const CriarAdminFarmacia({super.key});

  @override
  State<CriarAdminFarmacia> createState() => _CriarAdminFarmaciaState();
}

class _CriarAdminFarmaciaState extends State<CriarAdminFarmacia> {
  final _formKey = GlobalKey<FormState>();
  final nomeCompletoController = TextEditingController();
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final idFarmaciaController = TextEditingController();
  final senhaController = TextEditingController();
  final confirmarSenhaController = TextEditingController();
  bool isLoading = false;

  Future<void> _criarConta() async {
    if (!_formKey.currentState!.validate()) return;

    final nomeCompleto = nomeCompletoController.text.trim();
    final email = emailController.text.trim();
    final username = usernameController.text.trim();
    final idFarmacia = idFarmaciaController.text.trim();
    final senha = senhaController.text.trim();
    final confirmarSenha = confirmarSenhaController.text.trim();

    if (senha != confirmarSenha) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('As senhas não coincidem.')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final credenciais = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: senha);

      await FirebaseFirestore.instance
          .collection('admin_farmacia')
          .doc(username)
          .set({
        'nome': nomeCompleto,
        'email': email,
        'username': username,
        'idFarmacia': idFarmacia,
        'senha': senha,
        'uid': credenciais.user!.uid,
      });

      // Salvar no SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('admin_nome', nomeCompleto);
      await prefs.setString('admin_email', email);
      await prefs.setString('admin_username', username);
      await prefs.setString('admin_idFarmacia', idFarmacia);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Administrador criado com sucesso!')),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: ${e.message}')),
      );
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
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Criar Conta - Admin",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 24),

                // Nome Completo
                TextFormField(
                  controller: nomeCompletoController,
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Informe o nome completo' : null,
                  decoration: InputDecoration(
                    hintText: 'Nome completo',
                    prefixIcon: const Icon(Icons.person, color: Colors.green),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: emailController,
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Informe o email' : null,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    prefixIcon: const Icon(Icons.email, color: Colors.green),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Username
                TextFormField(
                  controller: usernameController,
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Informe o username' : null,
                  decoration: InputDecoration(
                    hintText: 'Username',
                    prefixIcon: const Icon(Icons.account_circle, color: Colors.green),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ID Farmácia
                TextFormField(
                  controller: idFarmaciaController,
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Informe o ID da farmácia' : null,
                  decoration: InputDecoration(
                    hintText: 'ID da Farmácia',
                    prefixIcon: const Icon(Icons.local_hospital, color: Colors.green),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Senha
                TextFormField(
                  controller: senhaController,
                  obscureText: true,
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Informe a senha' : null,
                  decoration: InputDecoration(
                    hintText: 'Senha',
                    prefixIcon: const Icon(Icons.lock, color: Colors.green),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Confirmar Senha
                TextFormField(
                  controller: confirmarSenhaController,
                  obscureText: true,
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Confirme a senha' : null,
                  decoration: InputDecoration(
                    hintText: 'Confirmar Senha',
                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.green),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Botão Criar Conta
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _criarConta,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      'Criar Conta',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
