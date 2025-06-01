import 'package:flutter/material.dart';

class AdicaoMedicamentos extends StatefulWidget {
  @override
  _AdicaoMedicamentosState createState() => _AdicaoMedicamentosState();
}

class _AdicaoMedicamentosState extends State<AdicaoMedicamentos> {
  final _formKey = GlobalKey<FormState>();
  final nomeController = TextEditingController();
  final descricaoController = TextEditingController();
  final quantidadeController = TextEditingController();
  final precoController = TextEditingController(); // Novo controlador

  void adicionarMedicamento() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Medicamento adicionado com sucesso!")),
      );
      nomeController.clear();
      descricaoController.clear();
      quantidadeController.clear();
      precoController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Adicionar Medicamento"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const Text(
                  "Adicione um\nmedicamento ao stock",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                _buildInputField("Nome", nomeController),
                const SizedBox(height: 16),
                _buildInputField("Descrição", descricaoController),
                const SizedBox(height: 16),
                _buildInputField("Quantidade", quantidadeController, TextInputType.number),
                const SizedBox(height: 16),
                _buildInputField("Preço (MT)", precoController, TextInputType.number),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: adicionarMedicamento,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                    ),
                    child: const Text("Adicionar"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ESTE MÉTODO DEVE ESTAR DENTRO DA CLASSE _AdicaoMedicamentosState
  Widget _buildInputField(String label, TextEditingController controller,
      [TextInputType keyboardType = TextInputType.text]) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.green),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.greenAccent.shade100),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      ),
    );
  }
}
