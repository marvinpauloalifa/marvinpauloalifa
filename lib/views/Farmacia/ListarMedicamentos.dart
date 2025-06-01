import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ListarMedicamentos extends StatefulWidget {
  const ListarMedicamentos({Key? key}) : super(key: key);

  @override
  _ListarMedicamentosState createState() => _ListarMedicamentosState();
}

class _ListarMedicamentosState extends State<ListarMedicamentos> {
  List<Map<String, String>> medicamentos = [];

  @override
  void initState() {
    super.initState();
    _carregarMedicamentos();
  }

  Future<void> _carregarMedicamentos() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? medicamentosSalvos = prefs.getStringList('medicamentos');

    if (medicamentosSalvos != null) {
      setState(() {
        medicamentos = medicamentosSalvos
            .map((e) => Map<String, String>.from({
          'nome': e.split('|')[0],
          'categoria': e.split('|')[1],
          'alcunha': e.split('|')[2],
          'descricao': e.split('|')[3],
        }))
            .toList();
      });
    } else {
      // Adicionando 5 medicamentos de exemplo
      setState(() {
        medicamentos = [
          {'nome': 'Paracetamol', 'categoria': 'Analgesico', 'alcunha': 'Panadol', 'descricao': 'Alivia dor e febre'},
          {'nome': 'Ibuprofeno', 'categoria': 'Anti-inflamatório', 'alcunha': 'Advil', 'descricao': 'Reduz inflamação e dor'},
          {'nome': 'Amoxicilina', 'categoria': 'Antibiótico', 'alcunha': 'Amoxil', 'descricao': 'Tratamento de infecções bacterianas'},
          {'nome': 'Dipirona', 'categoria': 'Analgesico', 'alcunha': 'Novalgina', 'descricao': 'Alivia dor e febre'},
          {'nome': 'Omeprazol', 'categoria': 'Antiácido', 'alcunha': 'Losec', 'descricao': 'Tratamento de refluxo e úlceras gástricas'},
        ];
      });
      _salvarMedicamentos();
    }
  }

  Future<void> _salvarMedicamentos() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> medicamentosString = medicamentos
        .map((med) =>
    '${med['nome']}|${med['categoria']}|${med['alcunha']}|${med['descricao']}')
        .toList();
    await prefs.setStringList('medicamentos', medicamentosString);
  }

  void _adicionarEditarMedicamento([int? index]) {
    TextEditingController nomeController = TextEditingController();
    TextEditingController categoriaController = TextEditingController();
    TextEditingController alcunhaController = TextEditingController();
    TextEditingController descricaoController = TextEditingController();

    // Preenche os campos caso seja edição
    if (index != null) {
      nomeController.text = medicamentos[index]['nome']!;
      categoriaController.text = medicamentos[index]['categoria']!;
      alcunhaController.text = medicamentos[index]['alcunha']!;
      descricaoController.text = medicamentos[index]['descricao']!;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(index == null ? "Adicionar Medicamento" : "Editar Medicamento"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField("Nome", nomeController),
              _buildTextField("Categoria", categoriaController),
              _buildTextField("Alcunha", alcunhaController),
              _buildTextField("Descrição", descricaoController),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                final novoMedicamento = {
                  'nome': nomeController.text,
                  'categoria': categoriaController.text,
                  'alcunha': alcunhaController.text,
                  'descricao': descricaoController.text,
                };

                setState(() {
                  if (index == null) {
                    // Adiciona o novo medicamento
                    medicamentos.add(novoMedicamento);
                  } else {
                    // Edita o medicamento existente
                    medicamentos[index] = novoMedicamento;
                  }
                });

                _salvarMedicamentos();
                Navigator.of(context).pop();
              },
              child: Text(index == null ? "Adicionar" : "Salvar Alterações"),
            ),
          ],
        );
      },
    );
  }

  void _removerMedicamento(int index) {
    setState(() {
      medicamentos.removeAt(index);
    });
    _salvarMedicamentos();
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lista de Medicamentos"),
        backgroundColor: Colors.green[400],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => _adicionarEditarMedicamento(),
              child: const Text("Adicionar Medicamento"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: medicamentos.length,
                itemBuilder: (context, index) {
                  final medicamento = medicamentos[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(medicamento['nome']!),
                      subtitle: Text('${medicamento['categoria']} - ${medicamento['alcunha']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _adicionarEditarMedicamento(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _removerMedicamento(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
