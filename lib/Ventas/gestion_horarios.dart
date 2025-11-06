import 'package:flutter/material.dart';


//MODELO DE LA CLASE "Horario"
// nhorario - Int, Primary Key, AutoIncrement
// nprofesor - Text,Foreign Key
// nmat - Text, Foreign Key
// hora - Text
// edificio - Text
// salon - Text

class GestionHorarios extends StatefulWidget {
  const GestionHorarios({super.key});

  @override
  State<GestionHorarios> createState() => _GestionHorariosState();
}

class _GestionHorariosState extends State<GestionHorarios> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Gestion de Horarios"),
      ),
    );
  }
}
