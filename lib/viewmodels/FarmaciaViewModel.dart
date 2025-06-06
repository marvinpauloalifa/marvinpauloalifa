// lib/viewmodels/FarmaciaViewModel.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmacia2pdm/models/FarmaciaModel.dart'; // Importa a FarmaciaModel

class FarmaciaViewModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Método para buscar todas as farmácias do Firestore
  // Equivale ao 'getAllFarmacias' do seu pedido
  Future<List<FarmaciaModel>> buscarFarmacias() async {
    try {
      // Acessa a coleção 'farmacias'
      final snapshot = await _firestore.collection('farmacias').get();
      // Mapeia cada documento do snapshot para uma instância de FarmaciaModel
      // Usando FarmaciaModel.fromFirestore() para mapeamento correto
      return snapshot.docs.map((doc) => FarmaciaModel.fromFirestore(doc)).toList();
    } catch (e) {
      print("Erro ao buscar farmácias: $e");
      rethrow;
    }
  }

  // Método para adicionar uma nova farmácia no Firestore
  // Este é um dos métodos 'saveFarmacia' que você pediu (para criação)
  Future<void> adicionarFarmacia(FarmaciaModel farmacia) async {
    try {
      // Usa o ID da farmácia fornecido como ID do documento
      // Usa toFirestore() para converter o modelo para um mapa para o Firestore
      await _firestore.collection('farmacias').doc(farmacia.id).set(farmacia.toFirestore());
    } catch (e) {
      print("Erro ao adicionar farmácia: $e");
      rethrow;
    }
  }

  // Método para atualizar uma farmácia existente no Firestore
  // Este é o outro método 'saveFarmacia' que você pediu (para atualização)
  Future<void> atualizarFarmacia(String farmaciaId, Map<String, dynamic> dados) async {
    try {
      // Usa .update() para atualizar campos específicos de um documento existente
      await _firestore.collection('farmacias').doc(farmaciaId).update(dados);
    } catch (e) {
      print("Erro ao atualizar farmácia: $e");
      rethrow;
    }
  }

  // Método para remover uma farmácia do Firestore pelo seu ID
  Future<void> removerFarmacia(String farmaciaId) async {
    try {
      await _firestore.collection('farmacias').doc(farmaciaId).delete();
    } catch (e) {
      print("Erro ao remover farmácia: $e");
      rethrow;
    }
  }

  // Os métodos 'saveFarmacia' e 'getAllFarmacias' explicitamente solicitados:
  // Eles já são cobertos por 'adicionarFarmacia'/'atualizarFarmacia' e 'buscarFarmacias'.
  // Se quiser ter nomes idênticos, pode fazer o seguinte redirecionamento:

  Future<void> saveFarmacia(FarmaciaModel farmacia) async {
    // Decide se adiciona ou atualiza com base no ID
    if (farmacia.id.isEmpty) {
      await adicionarFarmacia(farmacia);
    } else {
      // Para 'saveFarmacia', ao atualizar, você precisaria de um mapa completo
      // ou um método que recebe o modelo e o converte para um mapa completo para set.
      // Vou usar .set() para substituir o documento inteiro.
      await _firestore.collection('farmacias').doc(farmacia.id).set(farmacia.toFirestore());
    }
  }

  Future<List<FarmaciaModel>> getAllFarmacias() async {
    return buscarFarmacias(); // Simplesmente redireciona para o método existente
  }
}