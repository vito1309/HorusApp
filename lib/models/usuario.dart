class Usuario {
  int? id;
  String email;
  String senha;

  Usuario({this.id, required this.email, required this.senha});

  Map<String, dynamic> toMap() => {'id': id, 'email': email, 'senha': senha};

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(id: map['id'], email: map['email'], senha: map['senha']);
  }
}