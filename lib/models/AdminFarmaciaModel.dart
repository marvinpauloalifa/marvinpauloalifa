// lib/models/AdminFarmaciaModel.dart
import 'package:cloud_firestore/cloud_firestore.dart'; // Necessário para Timestamp, se aplicável, mas aqui para DocumentSnapshot

class AdminFarmaciaModel {
  final String uid; // O UID do usuário (Firebase Auth) que é o ID do documento no Firestore
  final String email;
  final String idFarmacia; // O ID da farmácia que este administrador gerencia
  final String nome;
  final String username;
  final String senha; // A senha do administrador (Lembre-se: não é seguro armazenar senhas em texto claro no Firestore)

  // Construtor para criar uma instância de AdminFarmaciaModel
  AdminFarmaciaModel({
    required this.uid,
    required this.email,
    required this.idFarmacia,
    required this.nome,
    required this.username,
    required this.senha,
  });

  // Método de fábrica para criar uma instância de AdminFarmaciaModel
  // a partir de um DocumentSnapshot do Firestore (ao ler dados)
  factory AdminFarmaciaModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>; // Converte os dados do documento para um mapa
    return AdminFarmaciaModel(
      uid: doc.id, // O ID do documento do Firestore é usado como o UID do administrador
      email: data['email'] as String,
      idFarmacia: data['idFarmacia'] as String,
      nome: data['nome'] as String,
      username: data['username'] as String,
      senha: data['senha'] as String? ?? '', // Garante que a senha não seja nula
    );
  }

  // Método para converter a instância de AdminFarmaciaModel para um Map
  // (útil para salvar ou atualizar dados no Firestore)
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'idFarmacia': idFarmacia,
      'nome': nome,
      'username': username,
      'senha': senha, // Lembre-se: não envie senhas em texto claro para o Firestore em produção!
    };
  }
}
