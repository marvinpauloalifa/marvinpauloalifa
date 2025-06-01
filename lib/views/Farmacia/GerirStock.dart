import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GerirStock extends StatefulWidget {
  const GerirStock({Key? key}) : super(key: key);

  @override
  _GerirStockState createState() => _GerirStockState();
}

class _GerirStockState extends State<GerirStock> {
  List<Map<String, dynamic>> estoque = [];
  List<Map<String, String>> medicamentosCadastrados = [];

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    await _carregarMedicamentos();
    await _carregarEstoque();
  }

  Future<void> _carregarMedicamentos() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? medicamentosSalvos = prefs.getStringList('medicamentos');

    if (medicamentosSalvos == null || medicamentosSalvos.isEmpty) {
      medicamentosCadastrados = [
        {'nome': 'Paracetamol', 'categoria': 'Analgesico', 'alcunha': 'Panadol', 'descricao': 'Alivia dor e febre'},
        {'nome': 'Ibuprofeno', 'categoria': 'Anti-inflamatório', 'alcunha': 'Advil', 'descricao': 'Reduz inflamação e dor'},
        {'nome': 'Amoxicilina', 'categoria': 'Antibiótico', 'alcunha': 'Amoxil', 'descricao': 'Tratamento de infecções bacterianas'},
        {'nome': 'Dipirona', 'categoria': 'Analgesico', 'alcunha': 'Novalgina', 'descricao': 'Alivia dor e febre'},
        {'nome': 'Omeprazol', 'categoria': 'Antiácido', 'alcunha': 'Losec', 'descricao': 'Tratamento de refluxo e úlceras gástricas'},
      ];

      List<String> medicamentosString = medicamentosCadastrados.map((med) {
        return '${med['nome']}|${med['categoria']}|${med['alcunha']}|${med['descricao']}';
      }).toList();

      await prefs.setStringList('medicamentos', medicamentosString);
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
            'estado': int.parse(parts[2]),
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
            onPressed: () {
              final quantidade = int.tryParse(quantidadeController.text) ?? 0;
              final preco = precoController.text.trim();

              if (selectedNome == null || selectedNome!.isEmpty || preco.isEmpty || quantidade < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Preencha todos os campos corretamente!')),
                );
                return;
              }

              final estado = quantidade > 0 ? 1 : -1;

              setState(() {
                estoque.add({
                  'nome': selectedNome,
                  'dataAtualizacao': DateFormat('dd/MM/yyyy').format(DateTime.now()),
                  'estado': estado,
                  'preco': preco,
                  'quantidade': quantidade,
                });
              });

              _salvarEstoque();
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Stock de "$selectedNome" adicionado com sucesso!')),
              );
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
            onPressed: () {
              final novaQuantidade = int.tryParse(quantidadeController.text) ?? -1;
              final novoPreco = precoController.text.trim();

              if (novaQuantidade < 0 || novoPreco.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Campos inválidos!')),
                );
                return;
              }

              final novoEstado = novaQuantidade > 0 ? 1 : -1;

              setState(() {
                estoque[index] = {
                  'nome': medicamento['nome'],
                  'dataAtualizacao': DateFormat('dd/MM/yyyy').format(DateTime.now()),
                  'estado': novoEstado,
                  'preco': novoPreco,
                  'quantidade': novaQuantidade,
                };
              });

              _salvarEstoque();
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
            onPressed: () {
              setState(() {
                estoque.removeAt(index);
              });
              _salvarEstoque();
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
        backgroundColor: Colors.green[400],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _adicionarNovoStock,
        child: const Icon(Icons.add),
        backgroundColor: Colors.green[400],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: estoque.isEmpty
            ? const Center(child: Text('Nenhum medicamento em stock.'))
            : ListView.builder(
          itemCount: estoque.length,
          itemBuilder: (context, index) {
            final medicamento = estoque[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(medicamento['nome']),
                subtitle: Text(
                  'Estado: ${medicamento['estado'] == 1 ? "Disponível" : "Indisponível"}\n'
                      'Preço: ${medicamento['preco']} MZN | Quantidade: ${medicamento['quantidade']}\n'
                      'Última atualização: ${medicamento['dataAtualizacao']}',
                ),
                leading: Icon(
                  medicamento['estado'] == 1 ? Icons.check_circle : Icons.cancel,
                  color: medicamento['estado'] == 1 ? Colors.green : Colors.red,
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
                      onPressed: () => _removerStock(index),
                      color: Colors.red,
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
