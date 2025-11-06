import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:u3_p2_checador_asistencia/BaseDatos/Clases/db.dart';
import 'package:u3_p2_checador_asistencia/BaseDatos/Clases/horario.dart';
import 'package:u3_p2_checador_asistencia/BaseDatos/Clases/materia.dart';
import 'package:u3_p2_checador_asistencia/BaseDatos/Clases/profesor.dart';

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
  final _formKey = GlobalKey<FormBuilderState>();
  List<Horario> horarios = [];
  List<Profesor> profesoresDrop = [];
  List<Materia> materiasDrop = [];


  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  void _cargarDatos() async {
    List<Horario> listaHorarios = await DB.mostrarHorarios();
    List<Profesor> listaProfesores = await DB.mostrarProfesores();
    List<Materia> listaMaterias = await DB.mostrarMaterias();

    setState(() {
      horarios = listaHorarios;
      profesoresDrop = listaProfesores;
      materiasDrop = listaMaterias;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(30),
        child: ListView.builder(
          itemCount: horarios.length,
          itemBuilder: (context, index) {
            Horario horario = horarios[index];
            return Card(
              elevation: 5,
              margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              clipBehavior: Clip.antiAlias,
              child: Slidable(
                key: ValueKey(horario.nhorario),
                endActionPane: ActionPane(
                  motion: ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (_) {
                        formularioHorarios(this.context, horario, false);
                      },
                      backgroundColor: Color.fromRGBO(155, 167, 207, 1),
                      foregroundColor: Colors.white,
                      icon: Icons.edit,
                      label: 'Editar',
                    ),
                    SlidableAction(
                      onPressed: (_) {
                        confirmarEliminar(this.context, horario);
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
                      leading: Icon(Icons.schedule, size: 20),
                      title: Text(
                        'Materia: ${horario.nmat}\nProfesor: ${horario.nprofesor}',
                      ),
                      subtitle: Text(
                        'Hora: ${horario.hora} - Lugar: ${horario.edificio} - ${horario.salon}',
                      ),
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
          formularioHorarios(
            context,
            Horario(
              nhorario: null,
              nprofesor: '',
              nmat: '',
              hora: '',
              edificio: '',
              salon: '',
            ),
            true,
          );
        },
      ),
    );
  }

  void formularioHorarios(BuildContext context, Horario horario, bool crear) {
    final initialValues = crear
        ? {'NPROFESOR': null, 'NMAT': null}
        : horario.toJSON();

    AwesomeDialog(
      context: context,
      headerAnimationLoop: false,
      dialogType: crear ? DialogType.info : DialogType.question,
      animType: AnimType.scale,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _formKey,
          initialValue: initialValues,
          child: Column(
            children: [
              Text(
                crear ? 'Nuevo Horario' : 'Modificar Horario',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 20),
              FormBuilderDropdown<String>(
                name: 'NPROFESOR',
                decoration: InputDecoration(
                  labelText: 'Numero de Profesor',
                  border: OutlineInputBorder(),
                  hintText: 'Seleccione un profesor',
                ),
                initialValue: crear ? null : horario.nprofesor,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: "El número de profesor es obligatorio",
                  ),
                ]),
                items: profesoresDrop.map((profesor) {
                  return DropdownMenuItem(
                    value: profesor.nprofesor,
                    child: Text('${profesor.nprofesor} - ${profesor.nombre}'),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              FormBuilderDropdown<String>(
                name: 'NMAT',
                decoration: InputDecoration(
                  labelText: 'Clave de Materia',
                  border: OutlineInputBorder(),
                  hintText: 'Seleccione una materia',
                ),
                initialValue: crear ? null : horario.nmat,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: "La clave de la materia es obligatoria",
                  ),
                ]),
                items: materiasDrop.map((materia) {
                  return DropdownMenuItem(
                    value: materia.nmat,
                    child: Text('${materia.nmat} - ${materia.descripcion}'),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              FormBuilderDateTimePicker(
                name: 'HORA',
                inputType: InputType.time,
                decoration: InputDecoration(
                  labelText: 'Hora',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.access_time),
                ),
                initialTime: TimeOfDay.now(),
                initialValue: crear || horario.hora.isEmpty
                    ? null
                    : DateTime(0,0,0,
                    int.parse(horario.hora.split(":")[0]),
                    int.parse(horario.hora.split(":")[1])),
                format: DateFormat.Hm(),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: "La hora es obligatoria"),
                ]),
              ),

              SizedBox(height: 20),
              FormBuilderTextField(
                name: 'EDIFICIO',
                decoration: InputDecoration(
                  labelText: 'Edificio',
                  border: OutlineInputBorder(),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: "El edificio es obligatorio",
                  ),
                ]),
              ),
              SizedBox(height: 20),
              FormBuilderTextField(
                name: 'SALON',
                decoration: InputDecoration(
                  labelText: 'Salón',
                  border: OutlineInputBorder(),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: "El salón es obligatorio",
                  ),
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
            final horaSeleccionada = formData['HORA'] as DateTime?;
            final horaFormateada = horaSeleccionada != null
                ? TimeOfDay.fromDateTime(horaSeleccionada).format(context)
                : '';

            final nuevoHorario = Horario.fromMap({
              'NHORARIO': horario.nhorario,
              'NPROFESOR': formData['NPROFESOR'],
              'NMAT': formData['NMAT'],
              'HORA': horaFormateada,
              'EDIFICIO': formData['EDIFICIO'],
              'SALON': formData['SALON'],
            });

            if (crear) {
              DB
                  .insertarHorario(nuevoHorario)
                  .then((value) {
                    mostrarResultado(
                      'Éxito',
                      'Horario para "${nuevoHorario.nmat}" agregado correctamente.',
                      DialogType.success,
                    );
                  })
                  .catchError((error) {
                    mostrarResultado(
                      'Error',
                      'No se pudo agregar el horario: $error',
                      DialogType.error,
                    );
                  });
            } else {
              DB
                  .actualizarHorario(nuevoHorario)
                  .then((value) {
                    mostrarResultado(
                      'Éxito',
                      'Horario para "${nuevoHorario.nmat}" actualizado correctamente.',
                      DialogType.success,
                    );
                  })
                  .catchError((error) {
                    mostrarResultado(
                      'Error',
                      'No se pudo actualizar el horario: $error',
                      DialogType.error,
                    );
                  });
            }

            Navigator.of(context).pop();
          }
        },
        child: Text(crear ? 'Añadir Horario' : 'Guardar Cambios'),
      ),
      btnCancel: TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text('Cancelar'),
      ),
    ).show();
  }

  void confirmarEliminar(BuildContext context, Horario horario) {
    AwesomeDialog(
      context: context,
      headerAnimationLoop: false,
      dialogType: DialogType.warning,
      animType: AnimType.scale,
      title: 'Confirmar Eliminación',
      showCloseIcon: true,
      body: Center(child: Text('¿Está seguro de eliminar este horario?')),
      btnOk: ElevatedButton(
        onPressed: () {
          DB
              .eliminarHorario(horario.nhorario!)
              .then((value) {
                mostrarResultado(
                  'Éxito',
                  'Horario para "${horario.nmat}" eliminado.',
                  DialogType.success,
                );
              })
              .catchError((error) {
                mostrarResultado(
                  'Error',
                  'No se pudo eliminar el profesor: $error',
                  DialogType.error,
                );
              });
          Navigator.of(context).pop();
        },
        child: Text('Eliminar'),
      ),
      btnCancel: TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text('Cancelar'),
      ),
    ).show();
  }

  void mostrarResultado(String titulo, String desc, DialogType tipo) {
    AwesomeDialog(
      autoDismiss: true,
      autoHide: Duration(seconds: 2),
      headerAnimationLoop: false,
      context: context,
      dialogType: tipo,
      animType: AnimType.scale,
      title: titulo,
      desc: desc,
      onDismissCallback: (type) {
        _cargarDatos();
      },
    ).show();
  }
}
