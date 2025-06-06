// lib/views/AdminApp/ListarFarmacias.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:farmacia2pdm/viewmodels/FarmaciaViewModel.dart'; // Importa o FarmaciaViewModel
import 'package:farmacia2pdm/models/FarmaciaModel.dart';     // Importa o FarmaciaModel
import 'package:farmacia2pdm/views/APP/GerirFarmacias.dart';
import 'package:farmacia2pdm/views/APP/GerirUsuarios.dart';

class ListarFarmacias extends StatefulWidget {
  const ListarFarmacias({super.key});

  @override
  State<ListarFarmacias> createState() => _ListarFarmaciasState();
}

class _ListarFarmaciasState extends State<ListarFarmacias> {
  final FarmaciaViewModel viewModel = FarmaciaViewModel();

  List<FarmaciaModel> _allFarmacias = []; // Armazena a lista completa do Firestore
  List<FarmaciaModel> _filteredFarmacias = []; // Armazena a lista filtrada pela pesquisa
  TextEditingController _searchController = TextEditingController();
  FarmaciaModel? farmaciaSelecionada;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _carregarTodasFarmacias(); // Carrega todas as farmácias inicialmente
    _searchController.addListener(_onSearchChanged); // Ouve mudanças no campo de pesquisa
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Busca todas as farmácias do Firestore
  Future<void> _carregarTodasFarmacias() async {
    setState(() {
      isLoading = true;
      farmaciaSelecionada = null; // Limpa a seleção ao recarregar
    });
    try {
      // ✅ Chama o método buscarFarmacias do FarmaciaViewModel
      _allFarmacias = await viewModel.buscarFarmacias();
      _filtrarFarmacias(); // Aplica o filtro inicial (que pode ser vazio)
    } catch (e) {
      _mostrarMensagem("Erro ao carregar farmácias: ${e.toString()}", Colors.red);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Este método é chamado sempre que o texto de pesquisa muda
  void _onSearchChanged() {
    _filtrarFarmacias();
  }

  // Filtra a lista _allFarmacias com base na consulta de pesquisa
  void _filtrarFarmacias() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredFarmacias = List.from(_allFarmacias); // Mostra tudo se a consulta estiver vazia
      } else {
        _filteredFarmacias = _allFarmacias.where((farmacia) {
          // Realiza pesquisa que não diferencia maiúsculas de minúsculas no 'nome', 'email' ou 'enderecoTexto'
          return farmacia.nome.toLowerCase().contains(query) ||
              (farmacia.email?.toLowerCase().contains(query) ?? false) ||
              (farmacia.enderecoTexto?.toLowerCase().contains(query) ?? false);
        }).toList();
      }
      farmaciaSelecionada = null; // Limpa a seleção após filtrar
    });
  }

  Future<void> _removerFarmacia() async {
    if (farmaciaSelecionada == null) {
      _mostrarMensagem("Nenhuma farmácia selecionada para remover.", Colors.orange);
      return;
    }

    // Usando showDialog para confirmação (boa prática)
    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmar Remoção"),
          content: Text("Tem certeza que deseja remover a farmácia '${farmaciaSelecionada!.nome}'?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text("Remover", style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    ) ?? false; // Retorna false se o diálogo for descartado

    if (!confirm) {
      _mostrarMensagem("Remoção cancelada.", Colors.grey);
      return;
    }

    setState(() {
      isLoading = true;
    });
    try {
      // ✅ Chama o método removerFarmacia do FarmaciaViewModel
      await viewModel.removerFarmacia(farmaciaSelecionada!.id);
      _mostrarMensagem("Farmácia removida com sucesso!", Colors.green);
      await _carregarTodasFarmacias(); // Recarrega todas as farmácias após a remoção
    } catch (e) {
      _mostrarMensagem("Erro ao remover farmácia: ${e.toString()}", Colors.red);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _editarFarmacia() {
    if (farmaciaSelecionada == null) {
      _mostrarMensagem("Nenhuma farmácia selecionada para editar.", Colors.orange);
      return;
    }
    // Navega para a tela GerirFarmacias para edição, passando a farmácia selecionada
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GerirFarmacias(farmacia: farmaciaSelecionada!),
      ),
    ).then((result) {
      // Se a edição foi bem-sucedida (o GerirFarmacias retornou 'true'), recarrega a lista
      if (result == true) {
        _carregarTodasFarmacias();
      }
    });
  }

  void _criarFarmacia() {
    // Navega para a tela GerirFarmacias para criação (sem passar um objeto de farmácia)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GerirFarmacias(),
      ),
    ).then((result) {
      // Se a criação foi bem-sucedida, recarrega a lista
      if (result == true) {
        _carregarTodasFarmacias();
      }
    });
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
        title: const Text('Gestão de Farmácias'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Pesquisar pelo nome, email ou endereço...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredFarmacias.isEmpty && _searchController.text.isNotEmpty
                  ? const Center(child: Text('Nenhuma farmácia encontrada para a pesquisa.'))
                  : _filteredFarmacias.isEmpty && _searchController.text.isEmpty
                  ? const Center(child: Text('Nenhuma farmácia cadastrada.'))
                  : ListView.builder(
                itemCount: _filteredFarmacias.length,
                itemBuilder: (context, index) {
                  final farmacia = _filteredFarmacias[index];
                  final selecionada = farmaciaSelecionada == farmacia;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        farmaciaSelecionada = selecionada ? null : farmacia;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: selecionada ? Colors.green[700]! : Colors.grey,
                            width: 2),
                        borderRadius: BorderRadius.circular(8),
                        color: selecionada ? Colors.green[100] : Colors.white,
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            farmacia.nome,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text('Telefone: ${farmacia.telefone ?? 'N/A'}'),
                          if (farmacia.email != null && farmacia.email!.isNotEmpty)
                            Text('Email: ${farmacia.email}'),
                          if (farmacia.enderecoTexto != null && farmacia.enderecoTexto!.isNotEmpty)
                            Text('Endereço: ${farmacia.enderecoTexto}'),
                          if (farmacia.localizacao != null)
                            Text('Latitude: ${farmacia.localizacao!.latitude.toStringAsFixed(4)}, Longitude: ${farmacia.localizacao!.longitude.toStringAsFixed(4)}'),
                          if (farmacia.createdAt != null)
                            Text('Criado em: ${_formatTimestamp(farmacia.createdAt!)}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  label: 'Criar',
                  icon: Icons.add,
                  onPressed: _criarFarmacia,
                  color: Colors.green,
                ),
                _buildActionButton(
                  label: 'Remover',
                  icon: Icons.delete,
                  onPressed: farmaciaSelecionada == null ? null : _removerFarmacia,
                  color: Colors.red,
                ),
                _buildActionButton(
                  label: 'Editar',
                  icon: Icons.edit,
                  onPressed: farmaciaSelecionada == null ? null : _editarFarmacia,
                  color: Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}";
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: onPressed == null ? Colors.grey : color,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}