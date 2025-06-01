class UserModel {
  final String uid;
  final String email;
  final String nome;
  final String papel; // 'admin' ou 'farmaceutico'
  final String senha;

  UserModel( {
    required this.uid,
    required this.email,
    required this.nome,
    required this.papel,
    required this.senha
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      nome: map['nome'] ?? '',
      papel: map['papel'] ?? 'farmaceutico',
      senha: map['senha']??''
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'nome': nome,
      'papel': papel,
      'senha': senha
    };
  }
}
