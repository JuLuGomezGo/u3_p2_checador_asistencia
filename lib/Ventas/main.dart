import 'package:flutter/material.dart';
import 'package:u3_p2_checador_asistencia/Diseño/app_estilos.dart';

import 'package:u3_p2_checador_asistencia/Ventas/gestion_horarios.dart';
import 'package:u3_p2_checador_asistencia/Ventas/gestion_profesores.dart';
import 'package:u3_p2_checador_asistencia/Ventas/gestion_materias.dart';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:google_nav_bar/google_nav_bar.dart';


//MODELO DE LA CLASE "asistencia"
//  idasistencia - Int, Primary Key, AutoIncrement
//  nhorario - Int, Foreign Key
//  fecha - Text
//  Asistencia - Boolean



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Checador(), debugShowCheckedModeBanner: false);
  }
}

class Checador extends StatefulWidget {
  const Checador({super.key});

  @override
  State<Checador> createState() => _ChecadorState();
}

class _ChecadorState extends State<Checador> {
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  String titulo = 'Control de Asistencia';
  String subtitulo = '';
  int _index = 0;
  int _indexnavbar = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(title: Text('$titulo\n$subtitulo'), centerTitle: true),
      body: ventanas(),
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: _index,
        backgroundColor: Colors.transparent, //COLOR DE FONDO
        buttonBackgroundColor: AppEstilos
            .curvedNavBarButtonBackgroundColor, //COLOR CIRCULAR DEL ICONO
        color: AppEstilos.curvedNavBarColor, //COLOR DE LA BARRA
        animationCurve: Curves.linear,
        animationDuration: Duration(milliseconds: 300),
        height: 50,
        items: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.book, color: AppEstilos.curvedNavBarIconColor),
              Text('Asistencia', style: TextStyle(color: AppEstilos.curvedNavBarIconColor, fontSize: 9)),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart_outlined, color: AppEstilos.curvedNavBarIconColor),
              Text('Reportes', style: TextStyle(color: AppEstilos.curvedNavBarIconColor, fontSize: 10)),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_outline, color: AppEstilos.curvedNavBarIconColor),
              Text('Gestión', style: TextStyle(color: AppEstilos.curvedNavBarIconColor, fontSize: 10)),
            ],
          ),
        ],
        onTap: (idx) {
          setState(() {
            _index = idx;
            if (idx<2) {
              subtitulo = '';
            }
            else {
              switch (_indexnavbar) {
                case 0:
                  subtitulo = ' Gestión de Materias';
                case 1:
                  subtitulo = ' Gestión de Maestros';
                case 2:
                  subtitulo = ' Gestión de Horarios';
              };
            }
          });
        },
      ),
    );
  }

  Widget ventanas() {
    switch (_index) {
      case 1:
        return Card();
      case 2:
        return ventanasGestion();
    }
    return Card();
  }

  Widget ventanasGestion() {
    final _ventanasGestion = [
      GestionMaterias(),
      GestionProfesores(),
      GestionHorarios(),
    ];

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: _ventanasGestion[_indexnavbar],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: AppEstilos.gNavBarBackgroundColor,
            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                color: Colors.black.withOpacity(.1),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 15.0,
                vertical: 8.0,
              ),
              child: GNav(
                backgroundColor: AppEstilos.gNavBarBackgroundColor,
                activeColor: AppEstilos.gNavBarActiveColor,
                color: AppEstilos.gNavBarInactiveColor,

                tabBackgroundColor: AppEstilos.gNavBarTabBackgroundColor,

                rippleColor: Colors.grey[300]!,
                hoverColor: Colors.grey[100]!,
                gap: 8,
                iconSize: 24,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                duration: Duration(milliseconds: 400),
                tabs: [
                  GButton(icon: Icons.school_outlined, text: 'Materias'),
                  GButton(icon: Icons.person_outline, text: 'Maestros'),
                  GButton(icon: Icons.schedule_outlined, text: 'Horarios'),
                ],
                selectedIndex: _indexnavbar,
                onTabChange: (index) {

                  setState(() {
                    _indexnavbar = index;
                    switch (index) {
                      case 0:
                        subtitulo = ' Gestión de Materias';
                      case 1:
                        subtitulo = ' Gestión de Maestros';
                      case 2:
                        subtitulo = ' Gestión de Horarios';
                    }
                  });
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
