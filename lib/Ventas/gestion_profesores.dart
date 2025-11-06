import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:u3_p2_checador_asistencia/BaseDatos/Clases/db.dart';
import 'package:u3_p2_checador_asistencia/BaseDatos/Clases/profesor.dart';


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

  final _formKey = GlobalKey<FormBuilderState>();
  List<Profesor> profesores = [];


  @override
  void initState() {
    super.initState();
    _cargarProfesores();
  }

  void _cargarProfesores() async {
    List<Profesor> listaProfesores = await DB.mostrarProfesores();
    setState(() {
      profesores = listaProfesores;
    });
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(30),
        child: ListView.builder(
          itemCount: profesores.length,
          itemBuilder: (context, index) {
            Profesor profesor = profesores[index];
            return Card(
              elevation: 5,
              margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              clipBehavior: Clip.antiAlias,
              child: Slidable(
                key: ValueKey(profesor.nprofesor),
                endActionPane: ActionPane(
                  motion: ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (_) {
                        formularioProfesores(this.context, profesor, false);
                      },
                      backgroundColor: Color.fromRGBO(155, 167, 207, 1),
                      foregroundColor: Colors.white,
                      icon: Icons.edit,
                      label: 'Editar',
                    ),
                    SlidableAction(
                      onPressed: (_) {
                        confirmarEliminar(this.context, profesor);
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
                      leading: Icon(Icons.people, size: 20),
                      title: Text(profesor.nombre),
                      subtitle: Text('Carrera: ${profesor.carrera}'),
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
          formularioProfesores(context, Profesor(nprofesor: '', nombre: '', carrera: ''), true);
        },
      ),
    );
  }

  void formularioProfesores(BuildContext context, Profesor profesor, bool crear) {
    AwesomeDialog(
      context: context,
      headerAnimationLoop: false,
      dialogType: crear ? DialogType.info : DialogType.question,
      animType: AnimType.scale,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _formKey,
          initialValue: crear ? {} : profesor.toJSON(),
          child: Column(
            children: [
              Text(crear ? 'Nuevo Profesor' : 'Modificar Profesor', style: Theme.of(context).textTheme.headlineSmall),
              SizedBox(height: 20),
              FormBuilderTextField(
                name: 'NPROFESOR',
                decoration: InputDecoration(
                  labelText: 'Numero de Profesor',
                  border: OutlineInputBorder(),
                ),
                enabled: crear,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: "El numero de profesor es obligatorio"),
                ]),
              ),
              SizedBox(height: 20,),
              FormBuilderTextField(
                name: 'NOMBRE',
                decoration: InputDecoration(
                  labelText: 'Nombre del Profesor',
                  border: OutlineInputBorder(),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: "El nombre es obligatorio"),
                ]),
              ),
              SizedBox(height: 20,),
              FormBuilderTextField(
                name: 'CARRERA',
                decoration: InputDecoration(
                  labelText: 'Carrera donde imparte',
                  border: OutlineInputBorder(),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: "La carrera es obligatoria"),
                ]),
              ),
            ],
          ),
        ),
      ),
      btnOk: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState?.saveAndValidate() ?? false) {
            final formData = _formKey.currentState!.value;
            final nuevoProfesor = Profesor.fromMap(formData);

            if (crear) {
              DB.insertarProfesor(nuevoProfesor).then((value) {
                mostrarResultado('Éxito', 'Profesor "${nuevoProfesor.nombre}" agregado correctamente.', DialogType.success);
              }).catchError((error) {
                mostrarResultado('Error', 'No se pudo agregar el profesor: $error', DialogType.error);
              });
            } else {
              DB.actualizarProfesor(nuevoProfesor).then((value) {
                mostrarResultado('Éxito', 'profesor "${nuevoProfesor.nombre}" actualizado correctamente.', DialogType.success);
              }).catchError((error) {
                mostrarResultado('Error', 'No se pudo actualizar el profesor: $error', DialogType.error);
              });
            }

            Navigator.of(context).pop();
          }
        },
        child: Text(crear ? 'Añadir profesor' : 'Guardar Cambios'),
      ),
      btnCancel: TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text('Cancelar'),
      ),
    ).show();
  }
  void confirmarEliminar(BuildContext context, Profesor profesor) {
    AwesomeDialog(
        context: context,
        headerAnimationLoop: false,
        dialogType: DialogType.warning,
        animType: AnimType.scale,
        title: 'Confirmar Eliminación',
        body: Center(
          child: Text('¿Está seguro de eliminar a este profesor ?'),
        ),
        btnOk: ElevatedButton(
          onPressed: () {
            DB.eliminarProfesor(profesor.nprofesor).then((value){
              mostrarResultado('Éxito', 'Profesor "${profesor.nombre}" eliminado.', DialogType.success);
            }).catchError((error){
              mostrarResultado('Error', 'No se pudo eliminar el profesor: $error', DialogType.error);
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
        _cargarProfesores();
      },
    ).show();
  }

}
