import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GerirStock extends StatefulWidget {
  const GerirStock({Key? key}) : super(key: key);

  @override
  _GerirStockState createState() => _GerirStockState();
}

class _GerirStockState extends State<GerirStock> {
  List<Map<String, dynamic>> estoque = [];
  List<Map<String, String>> medicamentosCadastrados = [];

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String farmaciaId = '';

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final prefs = await SharedPreferences.getInstance();
    farmaciaId = prefs.getString('id_farmacia') ?? '';
    await _carregarMedicamentos();
    await _carregarEstoque();
  }

  Future<void> _carregarMedicamentos() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? medicamentosSalvos = prefs.getStringList('medicamentos');

    if (medicamentosSalvos == null || medicamentosSalvos.isEmpty) {
      medicamentosCadastrados = [];
    } else {
      medicamentosCadastrados = medicamentosSalvos.map((e) {
        final parts = e.split('|');
        return {
          'nome': parts[0],
          'categoria': parts[1],
          'alcunha': parts[2],
          'descricao': parts[3],
        };
      }).toList();
    }
  }

  Future<void> _carregarEstoque() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? estoqueSalvo = prefs.getStringList('estoque');

    if (estoqueSalvo != null) {
      setState(() {
        estoque = estoqueSalvo.map((e) {
          final parts = e.split('|');
          return {
            'nome': parts[0],
            'dataAtualizacao': parts[1],
            'estado': parts[2],
            'preco': parts[3],
            'quantidade': int.parse(parts[4]),
          };
        }).toList();
      });
    }
  }

  Future<void> _salvarEstoque() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> estoqueString = estoque.map((item) {
      return '${item['nome']}|${item['dataAtualizacao']}|${item['estado']}|${item['preco']}|${item['quantidade']}';
    }).toList();
    await prefs.setStringList('estoque', estoqueString);
  }

  Future<void> _atualizarFirebase(String nome, String preco, int quantidade) async {
    final estado = quantidade > 0 ? 'disponível' : 'indisponível';
    final data = {
      'preco': preco,
      'quantidade': quantidade,
      'estado': estado,
      'dataAtualizacao': DateFormat('dd/MM/yyyy').format(DateTime.now()),
    };

    await firestore
        .collection('farmacias')
        .doc(farmaciaId)
        .collection('medicamentos')
        .doc(nome.toLowerCase().replaceAll(' ', '_'))
        .set(data, SetOptions(merge: true));
  }

  void _adicionarNovoStock() {
    final medicamentosSemStock = medicamentosCadastrados.where((med) {
      return !estoque.any((item) => item['nome'] == med['nome']);
    }).toList();

    if (medicamentosSemStock.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todos os medicamentos já têm stock!')),
      );
      return;
    }

    String? selectedNome;
    TextEditingController quantidadeController = TextEditingController();
    TextEditingController precoController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Adicionar Novo Stock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              hint: const Text('Selecione o medicamento'),
              items: medicamentosSemStock.map((med) {
                return DropdownMenuItem<String>(
                  value: med['nome'],
                  child: Text(med['nome']!),
                );
              }).toList(),
              onChanged: (value) => selectedNome = value,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: quantidadeController,
              decoration: const InputDecoration(labelText: 'Quantidade'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: precoController,
              decoration: const InputDecoration(labelText: 'Preço (MZN)'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final quantidade = int.tryParse(quantidadeController.text) ?? 0;
              final preco = precoController.text.trim();

              if (selectedNome == null || preco.isEmpty || quantidade < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Preencha todos os campos corretamente!')),
                );
                return;
              }

              final estado = quantidade > 0 ? 'disponível' : 'indisponível';

              setState(() {
                estoque.add({
                  'nome': selectedNome,
                  'dataAtualizacao': DateFormat('dd/MM/yyyy').format(DateTime.now()),
                  'estado': estado,
                  'preco': preco,
                  'quantidade': quantidade,
                });
              });

              await _salvarEstoque();
              await _atualizarFirebase(selectedNome!, preco, quantidade);
              Navigator.pop(context);
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  void _editarStock(int index) {
    final medicamento = estoque[index];
    TextEditingController quantidadeController = TextEditingController(text: medicamento['quantidade'].toString());
    TextEditingController precoController = TextEditingController(text: medicamento['preco']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Editar Stock - ${medicamento['nome']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: quantidadeController,
              decoration: const InputDecoration(labelText: 'Quantidade'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: precoController,
              decoration: const InputDecoration(labelText: 'Preço (MZN)'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final novaQuantidade = int.tryParse(quantidadeController.text) ?? -1;
              final novoPreco = precoController.text.trim();

              if (novaQuantidade < 0 || novoPreco.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Campos inválidos!')),
                );
                return;
              }

              final novoEstado = novaQuantidade > 0 ? 'disponível' : 'indisponível';

              setState(() {
                estoque[index] = {
                  'nome': medicamento['nome'],
                  'dataAtualizacao': DateFormat('dd/MM/yyyy').format(DateTime.now()),
                  'estado': novoEstado,
                  'preco': novoPreco,
                  'quantidade': novaQuantidade,
                };
              });

              await _salvarEstoque();
              await _atualizarFirebase(medicamento['nome'], novoPreco, novaQuantidade);
              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _removerStock(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Remover ${estoque[index]['nome']} do stock?'),
        content: const Text('Essa ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              String nome = estoque[index]['nome'];
              setState(() {
                estoque.removeAt(index);
              });
              await _salvarEstoque();
              await firestore
                  .collection('farmacias')
                  .doc(farmaciaId)
                  .collection('medicamentos')
                  .doc(nome.toLowerCase().replaceAll(' ', '_'))
                  .delete();
              Navigator.pop(context);
            },
            child: const Text('Remover', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerir Estoque de Medicamentos'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green, Colors.lightGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _adicionarNovoStock,
        child: const Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: estoque.isEmpty
            ? const Center(child: Text('Nenhum medicamento em stock.'))
            : ListView.builder(
          itemCount: estoque.length,
          itemBuilder: (context, index) {
            final medicamento = estoque[index];
            return Card(
              color: Colors.white,
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(medicamento['nome'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  'Estado: ${medicamento['estado']}\n'
                      'Preço: ${medicamento['preco']} MZN | Quantidade: ${medicamento['quantidade']}\n'
                      'Última atualização: ${medicamento['dataAtualizacao']}',
                ),
                leading: Icon(
                  medicamento['estado'] == 'disponível' ? Icons.check_circle : Icons.cancel,
                  color: medicamento['estado'] == 'disponível' ? Colors.green : Colors.red,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editarStock(index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      color: Colors.red,
                      onPressed: () => _removerStock(index),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
