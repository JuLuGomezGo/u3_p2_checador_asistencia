import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Checador(), debugShowCheckedModeBanner: false,);
  }
}

class Checador extends StatefulWidget {
  const Checador({super.key});

  @override
  State<Checador> createState() => _ChecadorState();
}

class _ChecadorState extends State<Checador> {
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

      ),
      body: ventanas(),
      bottomNavigationBar: CurvedNavigationBar(
          key: _bottomNavigationKey,
          index: _index,
          animationCurve: Curves.bounceIn,
          animationDuration: Duration(milliseconds: 350),
          height: 50,
          items: [
            Icon(Icons.book),
            Icon(Icons.schedule),
            Icon(Icons.person_outline),
          ],
        onTap: (idx){
            setState(() {
              _index = idx;
            });
        },
      ),
    );
  }

  Widget ventanas() {
    switch(_index){
      case 1:return Card();
      case 2:return Card();
    }
    return Card();
  }
}
