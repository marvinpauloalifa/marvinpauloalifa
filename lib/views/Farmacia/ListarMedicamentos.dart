import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListarMedicamentos extends StatefulWidget {
  const ListarMedicamentos({Key? key}) : super(key: key);

  @override
  _ListarMedicamentosState createState() => _ListarMedicamentosState();
}

class _ListarMedicamentosState extends State<ListarMedicamentos> {
  List<Map<String, dynamic>> medicamentos = [];
  String? idFarmacia;

  @override
  void initState() {
    super.initState();
    _carregarIdFarmacia();
  }

  Future<void> _carregarIdFarmacia() async {
    final prefs = await SharedPreferences.getInstance();
    idFarmacia = prefs.getString('id_farmacia');
    if (idFarmacia != null) {
      await _carregarMedicamentos();
    }
  }

  Future<void> _carregarMedicamentos() async {
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore
        .collection('farmacias')
        .doc(idFarmacia)
        .collection('medicamentos')
        .get();

    setState(() {
      medicamentos = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'nome': data['nome'] ?? '',
          'categoria': data['categoria'] ?? '',
          'alcunha': data['alcunha'] ?? '',
          'descricao': data['descricao'] ?? '',
          'quantidade': data['quantidade'] ?? 0,
          'preco': data['preco'] ?? 0.0,
        };
      }).toList();
    });
  }

  Future<void> _salvarMedicamento(Map<String, String> medicamento,
      {String? docId}) async {
    final firestore = FirebaseFirestore.instance;
    final ref = firestore
        .collection('farmacias')
        .doc(idFarmacia)
        .collection('medicamentos');

    final nomeFormatado =
        medicamento['nome']?.toLowerCase().replaceAll(RegExp(r'\s+'), '_') ?? '';

    final dadosCompletos = {
      ...medicamento,
      'quantidade': 0,
      'preco': 0.0,
    };

    await ref.doc(nomeFormatado).set(dadosCompletos);
    _carregarMedicamentos(); // Atualiza a lista
  }

  Future<void> _removerMedicamento(String docId) async {
    final firestore = FirebaseFirestore.instance;
    final ref = firestore
        .collection('farmacias')
        .doc(idFarmacia)
        .collection('medicamentos');

    await ref.doc(docId).delete();
    _carregarMedicamentos();
  }

  void _adicionarEditarMedicamento([Map<String, String>? medExistente]) {
    TextEditingController nomeController =
    TextEditingController(text: medExistente?['nome'] ?? '');
    TextEditingController categoriaController =
    TextEditingController(text: medExistente?['categoria'] ?? '');
    TextEditingController alcunhaController =
    TextEditingController(text: medExistente?['alcunha'] ?? '');
    TextEditingController descricaoController =
    TextEditingController(text: medExistente?['descricao'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
              medExistente == null ? "Adicionar Medicamento" : "Editar Medicamento"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField("Nome", nomeController),
                _buildTextField("Categoria", categoriaController),
                _buildTextField("Alcunha", alcunhaController),
                _buildTextField("Descrição", descricaoController),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text(medExistente == null ? "Adicionar" : "Salvar"),
              onPressed: () {
                final novoMedicamento = {
                  'nome': nomeController.text.trim(),
                  'categoria': categoriaController.text.trim(),
                  'alcunha': alcunhaController.text.trim(),
                  'descricao': descricaoController.text.trim(),
                };

                final docId = medExistente?['id'];
                _salvarMedicamento(novoMedicamento, docId: docId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Medicamentos da Farmácia"),
        foregroundColor: Colors.white,
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
        onPressed: () => _adicionarEditarMedicamento(),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
      body: medicamentos.isEmpty
          ? const Center(child: Text("Nenhum medicamento cadastrado."))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: medicamentos.length,
        itemBuilder: (context, index) {
          final med = medicamentos[index];
          return Card(
            color: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 5,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              title: Text(
                med['nome'] ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              subtitle: Text(
                "${med['categoria']} | ${med['alcunha']}\n${med['descricao']}",
                style: const TextStyle(
                  height: 1.4,
                  color: Colors.white,
                ),
              ),
              isThreeLine: true,
              trailing: Wrap(
                spacing: 10,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    color: Colors.white,
                    onPressed: () => _adicionarEditarMedicamento(
                        med.cast<String, String>()),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    color: Colors.white,
                    onPressed: () => _removerMedicamento(med['id'] ?? ''),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
