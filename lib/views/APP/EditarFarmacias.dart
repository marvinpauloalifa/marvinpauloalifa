import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmacia2pdm/models/FarmaciaModel.dart'; // Importa FarmaciaModel
import 'package:farmacia2pdm/viewmodels/FarmaciaViewModel.dart'; // Importa FarmaciaViewModel

class EditarFarmacia extends StatefulWidget {
  final FarmaciaModel farmacia;

  const EditarFarmacia({super.key, required this.farmacia});

  @override
  State<EditarFarmacia> createState() => _EditarFarmaciaState();
}

class _EditarFarmaciaState extends State<EditarFarmacia> {
  final _formKey = GlobalKey<FormState>();
  final FarmaciaViewModel _viewModel = FarmaciaViewModel(); // Instancia o ViewModel

  late TextEditingController _nomeController;
  late TextEditingController _telefoneController;
  late TextEditingController _emailController;
  late TextEditingController _enderecoTextoController; // Controlador para o endereço textual
  late TextEditingController _localizacaoLatController; // Controlador para a latitude da localização
  late TextEditingController _localizacaoLongController; // Controlador para a longitude da localização

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _nomeController = TextEditingController(text: widget.farmacia.nome);
    _telefoneController = TextEditingController(text: widget.farmacia.telefone);
    _emailController = TextEditingController(text: widget.farmacia.email);

    // Inicializa o controlador do endereço textual
    _enderecoTextoController = TextEditingController(text: widget.farmacia.enderecoTexto);

    // Inicializa os controladores de latitude e longitude a partir do GeoPoint 'localizacao'
    _localizacaoLatController = TextEditingController(
      text: widget.farmacia.localizacao?.latitude.toString() ?? '',
    );
    _localizacaoLongController = TextEditingController(
      text: widget.farmacia.localizacao?.longitude.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _enderecoTextoController.dispose(); // Dispose do controlador do endereço textual
    _localizacaoLatController.dispose(); // Dispose do controlador de latitude
    _localizacaoLongController.dispose(); // Dispose do controlador de longitude
    super.dispose();
  }

  // Validador genérico para campos de texto
  String? _validarTexto(String? value, String label) {
    if (value == null || value.isEmpty) return 'Por favor, informe $label';
    return null;
  }

  // Validador genérico para campos numéricos
  String? _validarNumero(String? value, String label) {
    if (value == null || value.isEmpty) return 'Por favor, informe $label';
    if (double.tryParse(value) == null) return '$label inválido';
    return null;
  }

  // Widget de campo de texto reutilizável
  Widget _campoTexto(String label, TextEditingController controller,
      {TextInputType tipo = TextInputType.text, bool senha = false, IconData? icon, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
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

  // Widget de campo numérico reutilizável
  Widget _campoNumero(String label, TextEditingController controller, {IconData? icon}) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: Colors.green) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) => _validarNumero(value, label),
    );
  }

  Future<void> _atualizarFarmacia() async {
    if (!_formKey.currentState!.validate()) return; // Valida o formulário

    setState(() {
      _isLoading = true;
      _errorMessage = null; // Limpa mensagens de erro anteriores
    });

    try {
      // Pega os valores de latitude e longitude dos controladores
      final double? lat = double.tryParse(_localizacaoLatController.text.trim());
      final double? long = double.tryParse(_localizacaoLongController.text.trim());
      GeoPoint? localizacaoGeoPoint;

      // Cria o GeoPoint se ambos os valores forem válidos, caso contrário, verifica se há erro
      if (lat != null && long != null) {
        localizacaoGeoPoint = GeoPoint(lat, long);
      } else if (_localizacaoLatController.text.isNotEmpty || _localizacaoLongController.text.isNotEmpty) {
        // Se um dos campos de lat/long foi preenchido, mas não formou um GeoPoint válido
        _mostrarMensagem("Por favor, insira valores válidos para Latitude e Longitude.", Colors.red);
        setState(() => _isLoading = false);
        return;
      }

      // Prepara os dados atualizados para o Firestore
      final updatedData = {
        'nome': _nomeController.text.trim(),
        'telefone': _telefoneController.text.trim(),
        'email': _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        'endereco': _enderecoTextoController.text.trim().isEmpty ? null : _enderecoTextoController.text.trim(), // Salva o endereço textual
        'localizacao': localizacaoGeoPoint, // Salva o GeoPoint
      };

      // Chama o método atualizarFarmacia do ViewModel
      await _viewModel.atualizarFarmacia(widget.farmacia.id, updatedData);

      if (!mounted) return; // Verifica se o widget ainda está montado
      _mostrarMensagem("Farmácia atualizada com sucesso!", Colors.green);

      Navigator.pop(context, true); // Retorna 'true' para indicar sucesso
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Farmácia'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _campoTexto("Nome da Farmácia", _nomeController, icon: Icons.local_pharmacy),
                const SizedBox(height: 16),
                _campoTexto("Telefone", _telefoneController,
                    tipo: TextInputType.phone, icon: Icons.phone),
                const SizedBox(height: 16),
                _campoTexto("E-mail", _emailController,
                    tipo: TextInputType.emailAddress, icon: Icons.email, validator: (value) {
                      if (value != null && value.isNotEmpty && !value.contains('@')) {
                        return 'Email inválido';
                      }
                      return null;
                    }),
                const SizedBox(height: 16),
                _campoTexto("Endereço (Texto)", _enderecoTextoController, icon: Icons.location_on), // Novo campo para endereço textual
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _campoNumero("Latitude", _localizacaoLatController, icon: Icons.map),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _campoNumero("Longitude", _localizacaoLongController, icon: Icons.map),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_errorMessage != null) // Usa _errorMessage agora
                  Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _atualizarFarmacia, // Usa _isLoading agora
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent[400],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: _isLoading // Usa _isLoading agora
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
