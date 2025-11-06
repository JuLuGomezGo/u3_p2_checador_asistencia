import 'package:flutter/material.dart';
import 'package:u3_p2_checador_asistencia/BaseDatos/Clases/db.dart';

import 'package:u3_p2_checador_asistencia/BaseDatos/Clases/materia.dart';

import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

//MODELO DE LA CLASE "Materia"
// nmat - Texto, Primary Key
//descripcion - Texto
//*********************************

class GestionMaterias extends StatefulWidget {
  const GestionMaterias({super.key});

  @override
  State<GestionMaterias> createState() => _GestionMateriasState();
}



class _GestionMateriasState extends State<GestionMaterias> {

  @override
  void initState() {
    super.initState();
    _cargarMaterias();
  }

  void _cargarMaterias() async {
    List<Materia> listaMaterias = await DB.mostrarMaterias();
    setState(() {
      materias = listaMaterias;
    });
  }



  final _formKey = GlobalKey<FormBuilderState>();
    List<Materia> materias = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(30),
        child: ListView.builder(
          itemCount: materias.length,
          itemBuilder: (context, index) {
            Materia materia = materias[index];
            return Card(
              elevation: 5,
              margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              clipBehavior: Clip.antiAlias,
              child: Slidable(
                key: ValueKey(materia.nmat),
                endActionPane: ActionPane(
                  motion: ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (_) {
                        formularioMaterias(this.context, materia, false);
                      },
                      backgroundColor: Color.fromRGBO(155, 167, 207, 1),
                      foregroundColor: Colors.white,
                      icon: Icons.edit,
                      label: 'Editar',
                    ),
                    SlidableAction(
                      onPressed: (_) {
                        confirmarEliminar(this.context, materia);
                      },
                      backgroundColor: Color.fromRGBO(176, 0, 32, 1),
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
                      tileColor: Colors.white70,
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
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          formularioMaterias(context, Materia(nmat: '', descripcion: ''), true);
        },
      ),
    );
  }

  void formularioMaterias(BuildContext context, Materia materia, bool crear) {
    AwesomeDialog(
      context: context,
      headerAnimationLoop: false,
      dialogType: crear ? DialogType.info : DialogType.question,
      animType: AnimType.scale,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _formKey,
          initialValue: crear ? {} : materia.toJSON(),
          child: Column(
            children: [
              Text(crear ? 'Nueva Materia' : 'Modificar Materia', style: Theme.of(context).textTheme.headlineSmall),
              SizedBox(height: 20),
              FormBuilderTextField(
                name: 'NMAT',
                decoration: InputDecoration(
                  labelText: 'Nombre de la Materia',
                  border: OutlineInputBorder(),
                ),
                enabled: crear,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: "El nombre es obligatorio"),
                ]),
              ),
              SizedBox(height: 20),
              FormBuilderTextField(
                name: 'DESCRIPCION',
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
            ],
          ),
        ),
      ),
      btnOk: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState?.saveAndValidate() ?? false) {
            final formData = _formKey.currentState!.value;
            final materiaNueva = Materia.fromMap(formData);

            if (crear) {
              DB.insertarMateria(materiaNueva).then((value) {
                mostrarResultado('Éxito', 'Materia "${materiaNueva.nmat}" insertada correctamente.', DialogType.success);
              }).catchError((error) {
                mostrarResultado('Error', 'No se pudo insertar la materia: $error', DialogType.error);
              });
            } else {
              DB.actualizarMateria(materiaNueva).then((value) {
                mostrarResultado('Éxito', 'Materia "${materiaNueva.nmat}" actualizada correctamente.', DialogType.success);
              }).catchError((error) {
                mostrarResultado('Error', 'No se pudo actualizar la materia: $error', DialogType.error);
              });
            }

            Navigator.of(context).pop();
          }
        },
        child: Text(crear ? 'Añadir Materia' : 'Guardar Cambios'),
      ),
      btnCancel: TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text('Cancelar'),
      ),
    ).show();
  }
  void confirmarEliminar(BuildContext context, Materia materia) {
    AwesomeDialog(
        context: context,
        headerAnimationLoop: false,
        dialogType: DialogType.warning,
        animType: AnimType.scale,
        title: 'Confirmar Eliminación',
        body: Center(
          child: Text('¿Está seguro de eliminar esta materia ?'),
        ),
        btnOk: ElevatedButton(
          onPressed: () {
            DB.eliminarMateria(materia.nmat).then((value){
              mostrarResultado('Éxito', 'Materia "${materia.nmat}" eliminada.', DialogType.success);
            }).catchError((error){
              mostrarResultado('Error', 'No se pudo eliminar la materia: $error', DialogType.error);
            });
            Navigator.of(context).pop();
          },
          child: Text('Eliminar'),
        ),
        btnCancel: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancelar'),
        )
    ).show();
  }
  void mostrarResultado(String titulo, String desc, DialogType tipo){
    AwesomeDialog(
      autoDismiss: true,
      autoHide: Duration(seconds: 2) ,
      headerAnimationLoop: false,
      context: context,
      dialogType: tipo,
      animType: AnimType.scale,
      title: titulo,
      desc: desc,
      onDismissCallback: (type) {
        _cargarMaterias();
      },
    ).show();
  }
}
