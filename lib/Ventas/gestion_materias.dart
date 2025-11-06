import 'package:flutter/material.dart';

import 'package:u3_p2_checador_asistencia/BaseDatos/Clases/materia.dart';

import 'package:flutter_slidable/flutter_slidable.dart';

//MODELO DE LA CLASE "Materia"
// nmat - Texto, Primary Key
//descripcion - Texto
//*********************************

class GestionMaterias extends StatefulWidget {
  const GestionMaterias({super.key});

  @override
  State<GestionMaterias> createState() => _GestionMateriasState();
}

List<Materia> materias = [];

class _GestionMateriasState extends State<GestionMaterias> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(30),
      child: ListView.builder(
        itemCount: materias.length,
        itemBuilder: (context, index) {
          Materia materia = materias[index];
          return Slidable(
            key: ValueKey(materia.nmat),
            endActionPane: ActionPane(
              motion: ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) {
                    /* Acción de editar */
                  },
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  icon: Icons.edit,
                  label: 'Editar',
                ),
                SlidableAction(
                  onPressed: (context) {
                    /*   ELIMINAR  */
                  },
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: 'Eliminar',
                ),
              ],
            ),
            child: Builder(
              builder: (context) {
                final controller = Slidable.of(context)!;
                final isSlidableOpen =
                    controller.animation.status == AnimationStatus.completed;

                return ListTile(
                  leading: Icon(Icons.book_sharp, size: 20),
                  title: Text(materia.nmat),
                  subtitle: Text(materia.descripcion),
                  trailing: Icon(
                    isSlidableOpen
                        ? Icons.arrow_forward_ios
                        : Icons.arrow_back_ios,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
