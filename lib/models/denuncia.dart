class Denuncia {
  int? id;
  String nome;
  String localizacao;
  String? foto;
  int usuarioId;

  Denuncia({
    this.id,
    required this.nome,
    required this.localizacao,
    this.foto,
    required this.usuarioId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'localizacao': localizacao,
      'foto': foto,
      'usuario_id': usuarioId,
    };
  }

  factory Denuncia.fromMap(Map<String, dynamic> map) {
    return Denuncia(
      id: map['id'],
      nome: map['nome'],
      localizacao: map['localizacao'],
      foto: map['foto'],
      usuarioId: map['usuario_id'],
    );
  }
}