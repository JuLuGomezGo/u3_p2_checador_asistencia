class Materia {
  String nmat;
  String descripcion;

  Materia({
    required this.nmat,
    required this.descripcion,
  });


  Map<String, dynamic> toJSON() {
    return {
      'NMAT': nmat,
      'DESCRIPCION': descripcion,
    };
  }


  factory Materia.fromMap(Map<String, dynamic> map) {
    return Materia(
      nmat: map['NMAT'],
      descripcion: map['DESCRIPCION'],
    );
  }
}