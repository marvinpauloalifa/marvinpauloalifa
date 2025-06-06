import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:farmacia2pdm/models/AdminFarmaciaModel.dart';
import 'package:farmacia2pdm/models/UserModel.dart';
import 'package:farmacia2pdm/models/AdminAppModel.dart';

class EditarUser extends StatefulWidget {
  final String selectedType;
  final dynamic selectedUser; // Pode ser AdminFarmaciaModel, UserModel, AdminAppModel

  const EditarUser({
    super.key,
    required this.selectedType,
    required this.selectedUser,
  });

  @override
  State<EditarUser> createState() => _EditarUserState();
}

class _EditarUserState extends State<EditarUser> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto para campos comuns
  late TextEditingController _nomeController;
  late TextEditingController _emailController;
  late TextEditingController _senhaController; // Cuidado com senhas em texto claro

  // Controladores de texto para campos específicos (nullable)
  TextEditingController? _idFarmaciaController;
  TextEditingController? _usernameController;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    // Inicializa controladores básicos
    _nomeController = TextEditingController();
    _emailController = TextEditingController();
    _senhaController = TextEditingController();

    // Preenche controladores com dados do utilizador selecionado e inicializa específicos
    if (widget.selectedType == 'farmácias' && widget.selectedUser is AdminFarmaciaModel) {
      final admin = widget.selectedUser as AdminFarmaciaModel;
      _nomeController.text = admin.nome;
      _emailController.text = admin.email;
      _senhaController.text = admin.senha;
      _idFarmaciaController = TextEditingController(text: admin.idFarmacia);
      _usernameController = TextEditingController(text: admin.username);
    } else if (widget.selectedType == 'users' && widget.selectedUser is UserModel) {
      final user = widget.selectedUser as UserModel;
      _nomeController.text = user.nome;
      _emailController.text = user.email;
      // _senhaController.text = user.senha;
      // UserModel não tem idFarmacia ou username
    } else if (widget.selectedType == 'app' && widget.selectedUser is AdminAppModel) {
      final adminApp = widget.selectedUser as AdminAppModel;
      _nomeController.text = adminApp.nome;
      _emailController.text = adminApp.email;
      _senhaController.text = adminApp.senha;
      // AdminAppModel não tem idFarmacia ou username
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _idFarmaciaController?.dispose(); // Dispor se foi inicializado
    _usernameController?.dispose(); // Dispor se foi inicializado
    super.dispose();
  }

  String? _validarTexto(String? value, String label) {
    if (value == null || value.isEmpty) return 'Por favor, informe $label';
    return null;
  }

  // Widget para campo de texto genérico
  Widget _campoTexto(String label, TextEditingController controller,
      {TextInputType tipo = TextInputType.text, bool senha = false, IconData? icon, String? Function(String?)? validator, bool readOnly = false}) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly, // Adicionado readOnly
      keyboardType: tipo,
      obscureText: senha,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: Colors.green) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: validator ?? (value) => _validarTexto(value, label),
    );
  }

  Future<void> _atualizarInformacoes() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      Map<String, dynamic> updatedData = {
        'nome': _nomeController.text.trim(),
        'email': _emailController.text.trim(),
        'senha': _senhaController.text.trim(), // Cuidado com senhas em texto claro!
      };

      String documentId = '';
      CollectionReference? collectionRef;

      if (widget.selectedType == 'farmácias' && widget.selectedUser is AdminFarmaciaModel) {
        final admin = widget.selectedUser as AdminFarmaciaModel;
        documentId = admin.uid; // Usar o UID do modelo como ID do documento
        collectionRef = FirebaseFirestore.instance.collection('admin_farmacia');
        updatedData['idFarmacia'] = _idFarmaciaController?.text.trim() ?? '';
        updatedData['username'] = _usernameController?.text.trim() ?? '';
      } else if (widget.selectedType == 'users' && widget.selectedUser is UserModel) {
        final user = widget.selectedUser as UserModel;
        documentId = user.uid; // Usar o ID do modelo como ID do documento
        collectionRef = FirebaseFirestore.instance.collection('users');
        // Para UserModel, createdAt não deve ser atualizado. Ele é setado na criação.
      } else if (widget.selectedType == 'app' && widget.selectedUser is AdminAppModel) {
        final adminApp = widget.selectedUser as AdminAppModel;
        documentId = adminApp.uid; // Usar o UID do modelo como ID do documento
        collectionRef = FirebaseFirestore.instance.collection('admin_app');
      }

      if (collectionRef == null || documentId.isEmpty) {
        throw Exception("Tipo de utilizador ou ID do documento inválido.");
      }

      await collectionRef.doc(documentId).update(updatedData);

      if (!mounted) return;
      _mostrarMensagem("Informações atualizadas com sucesso!", Colors.green);

      Navigator.pop(context, true); // Voltar e indicar sucesso
    } catch (e) {
      setState(() => _errorMessage = 'Erro ao atualizar: ${e.toString()}');
      _mostrarMensagem("Erro ao atualizar: ${e.toString()}", Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _mostrarMensagem(String mensagem, Color cor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: cor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String title = '';
    if (widget.selectedType == 'farmácias') {
      title = 'Editar Admin Farmácia';
    } else if (widget.selectedType == 'users') {
      title = 'Editar Utilizador Comum';
    } else if (widget.selectedType == 'app') {
      title = 'Editar Admin App';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _campoTexto("Nome", _nomeController, icon: Icons.person),
                const SizedBox(height: 16),
                _campoTexto("E-mail", _emailController, tipo: TextInputType.emailAddress, icon: Icons.email,
                  readOnly: (widget.selectedType == 'users' && widget.selectedUser is UserModel) || // Email de UserModel pode ser o ID do documento
                      (widget.selectedType == 'farmácias' && widget.selectedUser is AdminFarmaciaModel), // Email de AdminFarmacia também
                ),
                const SizedBox(height: 16),
                _campoTexto("Senha", _senhaController, senha: true, icon: Icons.lock, validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a senha';
                  }
                  return null;
                }),
                const SizedBox(height: 16),

                // Campos específicos para AdminFarmaciaModel
                if (widget.selectedType == 'farmácias') ...[
                  _campoTexto("ID da Farmácia", _idFarmaciaController!, icon: Icons.numbers),
                  const SizedBox(height: 16),
                  _campoTexto("Username", _usernameController!, icon: Icons.account_circle),
                  const SizedBox(height: 16),
                ],

                if (_errorMessage != null)
                  Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _atualizarInformacoes,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent[400],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Atualizar', style: TextStyle(color: Colors.white)),
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
