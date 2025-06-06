// lib/models/AdminAppModel.dart
import 'package:cloud_firestore/cloud_firestore.dart'; // Necessário para DocumentSnapshot

class AdminAppModel {
  final String uid; // O UID do usuário (Firebase Auth) que é o ID do documento no Firestore
  final String email;
  final String nome;
  final String senha; // A senha do administrador (Lembre-se: não é seguro armazenar senhas em texto claro no Firestore)

  // Construtor para criar uma instância de AdminAppModel
  AdminAppModel({
    required this.uid,
    required this.email,
    required this.nome,
    required this.senha,
  });

  // Método de fábrica para criar uma instância de AdminAppModel
  // a partir de um DocumentSnapshot do Firestore (ao ler dados)
  factory AdminAppModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>; // Converte os dados do documento para um mapa
    return AdminAppModel(
      uid: doc.id, // O ID do documento do Firestore é usado como o UID do administrador
      email: data['email'] as String,
      nome: data['nome'] as String,
      senha: data['senha'] as String? ?? '', // Garante que a senha não seja nula
    );
  }

  // Método para converter a instância de AdminAppModel para um Map
  // (útil para salvar ou atualizar dados no Firestore)
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'nome': nome,
      'senha': senha, // Lembre-se: não envie senhas em texto claro para o Firestore em produção!
    };
  }
}
