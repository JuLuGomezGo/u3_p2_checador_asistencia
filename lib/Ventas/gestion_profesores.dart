import 'package:flutter/material.dart';


//MODELO DE LA CLASE "Profesor"
// nprofesor - Text
// nombre - Text
// carrera - Text

class GestionProfesores extends StatefulWidget {
  const GestionProfesores({super.key});

  @override
  State<GestionProfesores> createState() => _GestionProfesoresState();
}

class _GestionProfesoresState extends State<GestionProfesores> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Gestion de Profesores"),
      ),
    );
  }
}
