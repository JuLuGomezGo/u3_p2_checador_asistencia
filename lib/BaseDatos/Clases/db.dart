import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'materia.dart';
import 'profesor.dart';
import 'horario.dart';
import 'asistencia.dart';

class DB {
  static Future<Database> _conectarDB() async {
    return openDatabase(
      join(await getDatabasesPath(), "asistencia.db"),
      version: 1,
      onConfigure: (db) {
        return db.execute("PRAGMA foreign_keys = ON");
      },
      onCreate: (db, version) async {
        // Crear tabla MATERIA
        await db.execute("CREATE TABLE MATERIA("
            "NMAT TEXT PRIMARY KEY, "
            "DESCRIPCION TEXT"
            ")");

        // Crear tabla PROFESOR
        await db.execute("CREATE TABLE PROFESOR("
            "NPROFESOR TEXT PRIMARY KEY, "
            "NOMBRE TEXT, "
            "CARRERA TEXT"
            ")");

        // Crear tabla HORARIO
        await db.execute("CREATE TABLE HORARIO("
            "NHORARIO INTEGER PRIMARY KEY AUTOINCREMENT, "
            "NPROFESOR TEXT, "
            "NMAT TEXT, "
            "HORA TEXT, "
            "EDIFICIO TEXT, "
            "SALON TEXT, "
            "FOREIGN KEY(NPROFESOR) REFERENCES PROFESOR(NPROFESOR) ON DELETE CASCADE ON UPDATE CASCADE, "
            "FOREIGN KEY(NMAT) REFERENCES MATERIA(NMAT) ON DELETE CASCADE ON UPDATE CASCADE"
            ")");

        // Crear tabla ASISTENCIA
        await db.execute("CREATE TABLE ASISTENCIA("
            "IDASISTENCIA INTEGER PRIMARY KEY AUTOINCREMENT, "
            "NHORARIO INTEGER, "
            "FECHA TEXT, "
            "ASISTENCIA INTEGER, "
            "FOREIGN KEY(NHORARIO) REFERENCES HORARIO(NHORARIO) ON DELETE CASCADE ON UPDATE CASCADE"
            ")");
      },
    );
  }

  // -------------------------------- CRUD MATERIA ----------------------------------
  static Future<int> insertarMateria(Materia m) async {
    Database base = await _conectarDB();
    return base.insert("MATERIA", m.toJSON());
  }

  static Future<List<Materia>> mostrarMaterias() async {
    Database base = await _conectarDB();
    List<Map<String, dynamic>> resultado = await base.query("MATERIA");
    return List.generate(resultado.length, (index) {
      return Materia.fromMap(resultado[index]);
    });
  }

  static Future<int> actualizarMateria(Materia m) async {
    Database base = await _conectarDB();
    return base.update("MATERIA", m.toJSON(),
        where: 'NMAT = ?', whereArgs: [m.nmat]);
  }

  static Future<int> eliminarMateria(String nmat) async {
    Database base = await _conectarDB();
    return base.delete("MATERIA", where: 'NMAT = ?', whereArgs: [nmat]);
  }

  // ---------------------------------- CRUD PROFESOR ---------------------------------
  static Future<int> insertarProfesor(Profesor p) async {
    Database base = await _conectarDB();
    return base.insert("PROFESOR", p.toJSON());
  }

  static Future<List<Profesor>> mostrarProfesores() async {
    Database base = await _conectarDB();
    List<Map<String, dynamic>> resultado = await base.query("PROFESOR");
    return List.generate(resultado.length, (index) {
      return Profesor.fromMap(resultado[index]);
    });
  }

  static Future<int> actualizarProfesor(Profesor p) async {
    Database base = await _conectarDB();
    return base.update("PROFESOR", p.toJSON(),
        where: 'NPROFESOR = ?', whereArgs: [p.nprofesor]);
  }

  static Future<int> eliminarProfesor(String nprofesor) async {
    Database base = await _conectarDB();
    return base
        .delete("PROFESOR", where: 'NPROFESOR = ?', whereArgs: [nprofesor]);
  }

  // ------------------------------------ CRUD HORARIO -------------------------------
  static Future<int> insertarHorario(Horario h) async {
    Database base = await _conectarDB();
    return base.insert("HORARIO", h.toJSON());
  }

  static Future<List<Horario>> mostrarHorarios() async {
    Database base = await _conectarDB();
    List<Map<String, dynamic>> resultado = await base.query("HORARIO");
    return List.generate(resultado.length, (index) {
      return Horario.fromMap(resultado[index]);
    });
  }

  static Future<int> actualizarHorario(Horario h) async {
    Database base = await _conectarDB();
    return base.update("HORARIO", h.toJSON(),
        where: 'NHORARIO = ?', whereArgs: [h.nhorario]);
  }

  static Future<int> eliminarHorario(int nhorario) async {
    Database base = await _conectarDB();
    return base.delete("HORARIO", where: 'NHORARIO = ?', whereArgs: [nhorario]);
  }

  // ---------------------------------- CRUD ASISTENCIA ------------------------------
  static Future<int> insertarAsistencia(Asistencia a) async {
    Database base = await _conectarDB();
    return base.insert("ASISTENCIA", a.toJSON());
  }

  static Future<List<Asistencia>> mostrarAsistencias() async {
    Database base = await _conectarDB();
    List<Map<String, dynamic>> resultado = await base.query("ASISTENCIA");
    return List.generate(resultado.length, (index) {
      return Asistencia.fromMap(resultado[index]);
    });
  }

  static Future<int> actualizarAsistencia(Asistencia a) async {
    Database base = await _conectarDB();
    return base.update("ASISTENCIA", a.toJSON(),
        where: 'IDASISTENCIA = ?', whereArgs: [a.idasistencia]);
  }

  static Future<int> eliminarAsistencia(int idasistencia) async {
    Database base = await _conectarDB();
    return base.delete("ASISTENCIA",
        where: 'IDASISTENCIA = ?', whereArgs: [idasistencia]);
  }

  // --------------------------------- CONSULTAS AVANZADAS ----------------------

  /**
     Consulta 1: "todos los profesores que tienen clase a las 8am en el edificio UD."
     Se asume que la hora se guarda como '8am' (ajustar si es otro formato)
     y el edificio como 'UD'.
   */
  static Future<List<Profesor>> getProfesoresPorHorarioYEdificio(
      String hora, String edificio) async {
    Database base = await _conectarDB();
    final List<Map<String, dynamic>> maps = await base.rawQuery('''
      SELECT DISTINCT P.* FROM PROFESOR P
      JOIN HORARIO H ON P.NPROFESOR = H.NPROFESOR
      WHERE H.HORA = ? AND H.EDIFICIO = ?
    ''', [hora, edificio]);

    // Convertir la lista de Maps a una lista de Profesores
    return List.generate(maps.length, (i) {
      return Profesor.fromMap(maps[i]);
    });
  }

  /**
     Consulta 2: "mostrar todos los profesores (nombres) que asistieron
     el día 8/02/2022 a clase."
      Se asume que la fecha se guarda como '8/02/2022'.
   */
  static Future<List<String>> getNombresProfesoresAsistieron(String fecha) async {
    Database base = await _conectarDB();
    final List<Map<String, dynamic>> maps = await base.rawQuery('''
      SELECT DISTINCT P.NOMBRE 
      FROM PROFESOR P
      JOIN HORARIO H ON P.NPROFESOR = H.NPROFESOR
      JOIN ASISTENCIA A ON H.NHORARIO = A.NHORARIO
      WHERE A.FECHA = ? AND A.ASISTENCIA = 1
    ''', [fecha]);


    return List.generate(maps.length, (i) {
      return maps[i]['NOMBRE'] as String;
    });
  }

  /**
     Consulta 3 (Adicional): Obtener todas las asistencias
     detalles del horario o materia de un profesor específico.

   */
  static Future<List<Map<String, dynamic>>> getHistorialAsistenciaProfesor(
      String nprofesor) async {
    Database base = await _conectarDB();
    // Esta consulta devuelve un JSON combinado con información de las 4 tablas
    final List<Map<String, dynamic>> maps = await base.rawQuery('''
      SELECT 
        P.NOMBRE,
        M.DESCRIPCION AS MATERIA,
        H.HORA,
        H.SALON,
        A.FECHA,
        A.ASISTENCIA
      FROM ASISTENCIA A
      JOIN HORARIO H ON A.NHORARIO = H.NHORARIO
      JOIN PROFESOR P ON H.NPROFESOR = P.NPROFESOR
      JOIN MATERIA M ON H.NMAT = M.NMAT
      WHERE P.NPROFESOR = ?
      ORDER BY A.FECHA DESC
    ''', [nprofesor]);

    return maps;
  }
}