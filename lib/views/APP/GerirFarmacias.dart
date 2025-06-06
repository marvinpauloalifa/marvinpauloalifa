import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmacia2pdm/models/FarmaciaModel.dart'; // Importa o FarmaciaModel
import 'package:farmacia2pdm/viewmodels/FarmaciaViewModel.dart'; // Importa o FarmaciaViewModel

class GerirFarmacias extends StatefulWidget {
  final FarmaciaModel? farmacia; // Nullable para criação, non-null para edição

  const GerirFarmacias({super.key, this.farmacia});

  @override
  State<GerirFarmacias> createState() => _GerirFarmaciasState();
}

class _GerirFarmaciasState extends State<GerirFarmacias> {
  final _formKey = GlobalKey<FormState>();
  final FarmaciaViewModel _viewModel = FarmaciaViewModel();

  late TextEditingController _idController;
  late TextEditingController _nomeController;
  late TextEditingController _telefoneController;
  late TextEditingController _emailController;
  late TextEditingController _enderecoTextoController; // ✨ NOVO: Para o endereço textual
  late TextEditingController _localizacaoLatController; // ✨ NOVO: Para a latitude da localização
  late TextEditingController _localizacaoLongController; // ✨ NOVO: Para a longitude da localização

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Inicializa controladores com dados da farmácia existente ou vazio para nova
    _idController = TextEditingController(text: widget.farmacia?.id ?? '');
    _nomeController = TextEditingController(text: widget.farmacia?.nome ?? '');
    _telefoneController = TextEditingController(text: widget.farmacia?.telefone ?? '');
    _emailController = TextEditingController(text: widget.farmacia?.email ?? '');
    _enderecoTextoController = TextEditingController(text: widget.farmacia?.enderecoTexto ?? ''); // Usa enderecoTexto
    _localizacaoLatController = TextEditingController(text: widget.farmacia?.localizacao?.latitude.toString() ?? ''); // Usa localizacao.latitude
    _localizacaoLongController = TextEditingController(text: widget.farmacia?.localizacao?.longitude.toString() ?? ''); // Usa localizacao.longitude
  }

  @override
  void dispose() {
    _idController.dispose();
    _nomeController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _enderecoTextoController.dispose(); // Dispose do novo controlador
    _localizacaoLatController.dispose(); // Dispose do novo controlador
    _localizacaoLongController.dispose(); // Dispose do novo controlador
    super.dispose();
  }

  Future<void> _salvarFarmacia() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final String id = _idController.text.trim();
        final String nome = _nomeController.text.trim();
        final String telefone = _telefoneController.text.trim();
        final String? email = _emailController.text.trim().isEmpty ? null : _emailController.text.trim();
        final String? enderecoTexto = _enderecoTextoController.text.trim().isEmpty ? null : _enderecoTextoController.text.trim(); // Pega o endereço textual
        final double? lat = double.tryParse(_localizacaoLatController.text.trim()); // Pega a latitude
        final double? long = double.tryParse(_localizacaoLongController.text.trim()); // Pega a longitude
        final GeoPoint? localizacao = (lat != null && long != null) ? GeoPoint(lat, long) : null; // Cria o GeoPoint

        if (widget.farmacia == null) {
          // Criar nova farmácia
          final newFarmacia = FarmaciaModel(
            id: id,
            createdAt: Timestamp.now(), // Define o timestamp de criação
            nome: nome,
            telefone: telefone,
            email: email,
            enderecoTexto: enderecoTexto, // Atribui o endereço textual
            localizacao: localizacao, // Atribui o GeoPoint
          );
          await _viewModel.adicionarFarmacia(newFarmacia); // Chama o método de adicionar
          _mostrarMensagem("Farmácia criada com sucesso!", Colors.green);
        } else {
          // Atualizar farmácia existente
          final Map<String, dynamic> dadosAtualizados = {
            'nome': nome,
            'telefone': telefone,
            'email': email,
            'endereco': enderecoTexto, // Atualiza o campo 'endereco' no Firestore com o texto
            'localizacao': localizacao, // Atualiza o campo 'localizacao' no Firestore com o GeoPoint
            // 'createdAt' não deve ser atualizado aqui
          };
          await _viewModel.atualizarFarmacia(widget.farmacia!.id, dadosAtualizados); // Chama o método de atualizar
          _mostrarMensagem("Farmácia atualizada com sucesso!", Colors.green);
        }
        Navigator.pop(context, true); // Retorna 'true' para indicar sucesso
      } catch (e) {
        _mostrarMensagem("Erro ao salvar farmácia: ${e.toString()}", Colors.red);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
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
        title: Text(widget.farmacia == null ? 'Nova Farmácia' : 'Editar Farmácia'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _idController,
                readOnly: widget.farmacia != null, // ID é somente leitura em edição
                decoration: InputDecoration( // Atualizado para InputDecoration
                  labelText: 'ID da Farmácia',
                  border: OutlineInputBorder( // Usa OutlineInputBorder
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor insira o ID da farmácia';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration( // Atualizado para InputDecoration
                  labelText: 'Nome da Farmácia',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor insira o nome da farmácia';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telefoneController,
                decoration: InputDecoration( // Atualizado para InputDecoration
                  labelText: 'Telefone',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor insira o telefone';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration( // Atualizado para InputDecoration
                  labelText: 'Email (Opcional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextFormField( // ✨ NOVO: Campo para o endereço textual
                controller: _enderecoTextoController,
                decoration: InputDecoration(
                  labelText: 'Endereço (Texto)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _localizacaoLatController, // Usa _localizacaoLatController
                      decoration: InputDecoration( // Atualizado para InputDecoration
                        labelText: 'Latitude (Opcional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _localizacaoLongController, // Usa _localizacaoLongController
                      decoration: InputDecoration( // Atualizado para InputDecoration
                        labelText: 'Longitude (Opcional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _salvarFarmacia,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  widget.farmacia == null ? 'Adicionar Farmácia' : 'Atualizar Farmácia',
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
