import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/UserModel.dart';
import '../models/FarmaciaModel.dart';
import '../models/MedicamentoModel.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------- USERS ----------
  Future<void> saveUserData(UserModel user) async {
    await _db.collection('usuarios').doc(user.uid).set(user.toMap());
  }

  Future<UserModel> getUserData(String uid) async {
    final doc = await _db.collection('usuarios').doc(uid).get();
    return UserModel.fromMap(doc.data()!, doc.id);
  }

  // ---------- FARMÁCIAS ----------
  Future<void> saveFarmacia(FarmaciaModel farmacia) async {
    await _db.collection('farmacias').doc(farmacia.id).set(farmacia.toMap());
  }

  Future<List<FarmaciaModel>> getAllFarmacias() async {
    final snapshot = await _db.collection('farmacias').get();
    return snapshot.docs.map((doc) => FarmaciaModel.fromMap(doc.data(), doc.id)).toList();
  }

  // ---------- MEDICAMENTOS ----------
  Future<void> saveMedicamento(String farmaciaId, MedicamentoModel medicamento) async {
    await _db
        .collection('farmacias')
        .doc(farmaciaId)
        .collection('medicamentos')
        .doc(medicamento.id)
        .set(medicamento.toMap());
  }

  Future<List<MedicamentoModel>> getMedicamentos(String farmaciaId) async {
    final snapshot = await _db
        .collection('farmacias')
        .doc(farmaciaId)
        .collection('medicamentos')
        .get();

    return snapshot.docs.map((doc) => MedicamentoModel.fromMap(doc.data(), doc.id)).toList();
  }

  // ---------- PESQUISA ----------
  Future<List<FarmaciaModel>> buscarFarmaciasComMedicamento(String nomeMedicamento) async {
    final farmacias = await getAllFarmacias();
    List<FarmaciaModel> resultado = [];

    for (final farmacia in farmacias) {
      final medicamentos = await getMedicamentos(farmacia.id);
      final temMedicamento = medicamentos.any((m) =>
      m.nome.toLowerCase().contains(nomeMedicamento.toLowerCase()) &&
          m.quantidade > 0);
      if (temMedicamento) {
        resultado.add(farmacia);
      }
    }

    return resultado;
  }
}
