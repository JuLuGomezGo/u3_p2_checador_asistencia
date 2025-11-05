class Asistencia {
  int? idasistencia;
  int nhorario;
  String fecha;
  bool asistencia;

  Asistencia({
    this.idasistencia,
    required this.nhorario,
    required this.fecha,
    required this.asistencia,
  });

  Map<String, dynamic> toJSON() {
    return {
      'NHORARIO': nhorario,
      'FECHA': fecha,
      'ASISTENCIA': asistencia ? 1 : 0,
    };
  }

  factory Asistencia.fromMap(Map<String, dynamic> map) {
    return Asistencia(
      idasistencia: map['IDASISTENCIA'],
      nhorario: map['NHORARIO'],
      fecha: map['FECHA'],
      asistencia: map['ASISTENCIA'] == 1,
    );
  }
}