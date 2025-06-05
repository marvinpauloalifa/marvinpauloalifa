import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GerirStock extends StatefulWidget {
  @override
  _GerirStockState createState() => _GerirStockState();
}

class _GerirStockState extends State<GerirStock> {
  List<Map<String, dynamic>> medicamentos = [];
  String? farmaciaId;

  @override
  void initState() {
    super.initState();
    _carregarIdFarmacia();
  }

  Future<void> _carregarIdFarmacia() async {
    final prefs = await SharedPreferences.getInstance();
    farmaciaId = prefs.getString('id_farmacia');
    if (farmaciaId != null) {
      await _carregarMedicamentosFirestore();
    }
  }

  Future<void> _carregarMedicamentosFirestore() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('farmacias')
        .doc(farmaciaId)
        .collection('medicamentos')
        .get();

    final dados = snapshot.docs.map((doc) {
      final data = doc.data();
      data['nome'] = doc.id;
      return data;
    }).toList();

    setState(() {
      medicamentos = dados
          .where((m) =>
      m.containsKey('preco') &&
          m.containsKey('quantidade') &&
          m['preco'] > 0 &&
          m['quantidade'] > 0)
          .cast<Map<String, dynamic>>()
          .toList();
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('medicamentos', jsonEncode(medicamentos));
  }

  Future<void> _salvarMedicamento(Map<String, dynamic> medicamento) async {
    if (farmaciaId == null) return;

    final nome = medicamento['nome'];
    if (nome == null || nome is! String) return;

    final docRef = FirebaseFirestore.instance
        .collection('farmacias')
        .doc(farmaciaId)
        .collection('medicamentos')
        .doc(nome);

    await docRef.update({
      'preco': medicamento['preco'],
      'quantidade': medicamento['quantidade'],
      'estado': medicamento['quantidade'] > 0 ? 'disponível' : 'indisponível',
    });

    await _carregarMedicamentosFirestore();
  }

  void _abrirSelecaoMedicamento() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('farmacias')
        .doc(farmaciaId)
        .collection('medicamentos')
        .get();

    final todos = snapshot.docs.map((doc) {
      final data = doc.data();
      data['nome'] = doc.id;
      return data;
    }).toList();

    String? nomeSelecionado;
    double quantidade = 0;
    double preco = 0;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: StatefulBuilder(
              builder: (context, setState) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Selecionar Medicamento',
                          style: TextStyle(
                              color: Colors.green.shade800,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: "Escolha o medicamento",
                          labelStyle: TextStyle(color: Colors.green),
                          border: OutlineInputBorder(),
                        ),
                        value: nomeSelecionado,
                        items: todos.map<DropdownMenuItem<String>>((med) {
                          return DropdownMenuItem<String>(
                            value: med['nome'],
                            child: Text(med['nome']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => nomeSelecionado = value);
                        },
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Quantidade',
                          labelStyle: TextStyle(color: Colors.green),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) =>
                        quantidade = double.tryParse(value) ?? 0,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Preço',
                          labelStyle: TextStyle(color: Colors.green),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) =>
                        preco = double.tryParse(value) ?? 0,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            child: Text('Cancelar',
                                style: TextStyle(color: Colors.green)),
                            onPressed: () => Navigator.pop(context),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green),
                            onPressed: () {
                              if (nomeSelecionado != null &&
                                  quantidade > 0 &&
                                  preco > 0) {
                                final med = todos.firstWhere(
                                        (m) => m['nome'] == nomeSelecionado);
                                final atualizado = {
                                  ...med,
                                  'quantidade': quantidade,
                                  'preco': preco,
                                  'estado': quantidade > 0
                                      ? 'disponível'
                                      : 'indisponível',
                                };
                                _salvarMedicamento(atualizado);
                                Navigator.pop(context);
                              }
                            },
                            child: Text('Salvar',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _editarMedicamento(int index) {
    final med = medicamentos[index];
    final quantidadeController =
    TextEditingController(text: med['quantidade'].toString());
    final precoController =
    TextEditingController(text: med['preco'].toString());

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Editar Medicamento',
                    style: TextStyle(
                        color: Colors.green.shade800,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(med['nome'], style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(
                  controller: quantidadeController,
                  decoration: InputDecoration(labelText: 'Quantidade'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: precoController,
                  decoration: InputDecoration(labelText: 'Preço'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      child:
                      Text('Cancelar', style: TextStyle(color: Colors.green)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      onPressed: () {
                        final novaQtd =
                            double.tryParse(quantidadeController.text) ?? 0;
                        final novoPreco =
                            double.tryParse(precoController.text) ?? 0;
                        final atualizado = {
                          ...med,
                          'quantidade': novaQtd,
                          'preco': novoPreco,
                          'estado':
                          novaQtd > 0 ? 'disponível' : 'indisponível',
                        };
                        _salvarMedicamento(atualizado);
                        Navigator.pop(context);
                      },
                      child:
                      Text('Salvar', style: TextStyle(color: Colors.white)),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _removerMedicamento(int index) async {
    final med = medicamentos[index];
    final nome = med['nome'];
    if (nome == null || nome is! String) return;

    await FirebaseFirestore.instance
        .collection('farmacias')
        .doc(farmaciaId)
        .collection('medicamentos')
        .doc(nome)
        .update({
      'quantidade': 0,
      'preco': 0,
      'estado': 'indisponível',
    });

    await _carregarMedicamentosFirestore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Gerir Stock', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: medicamentos.isEmpty
          ? Center(
          child: Text('Nenhum medicamento disponível',
              style: TextStyle(color: Colors.green)))
          : ListView.builder(
        itemCount: medicamentos.length,
        itemBuilder: (context, index) {
          final med = medicamentos[index];

          // Condição: medicamento válido (com quantidade e preço > 0)
          final bool ativo = (med['quantidade'] > 0 && med['preco'] > 0);

          final Color backgroundColor = ativo ? Colors.green : Colors.white;
          final Color foregroundColor = ativo ? Colors.white : Colors.green;

          return Card(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            color: backgroundColor,
            child: ListTile(
              title: Text(
                med['nome'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: foregroundColor,
                ),
              ),
              subtitle: Text(
                "Quantidade: ${med['quantidade']} | Preço: ${med['preco']} MZN",
                style: TextStyle(color: foregroundColor),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: foregroundColor),
                    onPressed: () => _editarMedicamento(index),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: foregroundColor),
                    onPressed: () => _removerMedicamento(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _abrirSelecaoMedicamento,
        backgroundColor: Colors.green,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
