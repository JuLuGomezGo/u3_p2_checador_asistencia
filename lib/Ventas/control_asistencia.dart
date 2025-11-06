import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:u3_p2_checador_asistencia/BaseDatos/Clases/asistencia.dart';
import 'package:u3_p2_checador_asistencia/BaseDatos/Clases/db.dart';


//MODELO DE LA CLASE "asistencia"
//  idasistencia - Int, Primary Key, AutoIncrement
//  nhorario - Int, Foreign Key
//  fecha - Text
//  Asistencia - Boolean



class ControlAsistencia extends StatefulWidget {
  const ControlAsistencia({super.key});

  @override
  State<ControlAsistencia> createState() => _ControlAsistenciaState();
}

class _ControlAsistenciaState extends State<ControlAsistencia> {
  final _formKey = GlobalKey<FormBuilderState>();
  List<Map<String, dynamic>> asistenciasDetalladas = [];
  List<Map<String, dynamic>> horariosDropdown = [];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  void _cargarDatos() async {
    final List<Map<String, dynamic>> listaAsistencias = await DB.mostrarAsistenciasDetalladas();
    final List<Map<String, dynamic>> listaHorarios = await DB.mostrarHorariosDetallados();

    setState(() {
      asistenciasDetalladas = listaAsistencias;
      horariosDropdown = listaHorarios;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: asistenciasDetalladas.isEmpty
          ? Center(child: Text("No hay registros de asistencia."))
          : ListView.builder(
        itemCount: asistenciasDetalladas.length,
        itemBuilder: (context, index) {
          final asistencia = asistenciasDetalladas[index];
          final esPresente = asistencia['ASISTENCIA'] == 1;

          return Slidable(
            key: ValueKey(asistencia['IDASISTENCIA']),
            endActionPane: ActionPane(
              motion: ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (_) {
                    formularioAsistencia(this.context, asistencia, false);
                  },
                  backgroundColor: Color.fromRGBO(155, 167, 207, 1),
                  foregroundColor: Colors.white,
                  icon: Icons.edit,
                  label: 'Editar',
                ),
                SlidableAction(
                  onPressed: (_) {
                    confirmarEliminar(this.context, asistencia);
                  },
                  backgroundColor: Color.fromRGBO(176, 0, 32, 1),
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: 'Eliminar',
                ),
              ],
            ),
            child: Card(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
              elevation: 3,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        esPresente ? Icons.check_circle_outline : Icons.cancel_outlined,
                        color: esPresente ? Colors.green : Colors.red,
                        size: 30,
                      ),
                      title: Text(
                        '${asistencia['NOMBRE_PROFESOR']} - ${asistencia['DESCRIPCION_MATERIA']}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Fecha: ${asistencia['FECHA']} - ${asistencia['HORA']}',
                        style: TextStyle(fontSize: 14),
                      ),
                      trailing: Text(
                        esPresente ? 'Presente' : 'Ausente',
                        style: TextStyle(
                          color: esPresente ? Colors.green.shade700 : Colors.red.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                      child: Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                          SizedBox(width: 5),
                          Text(
                            'Edificio: ${asistencia['EDIFICIO']} - Salón: ${asistencia['SALON']}',
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          formularioAsistencia(context, null, true);
        },
      ),
    );
  }

  void formularioAsistencia(BuildContext context, Map<String, dynamic>? data, bool crear) {

    final asistenciaObj = crear ? null : Asistencia.fromMap(data!);

    DateTime? initialDate;
    if (!crear && data!['FECHA'] != null) {
      try {
        initialDate = DateFormat('dd-MM-yyyy').parse(data['FECHA']);
      } catch (e) {
        initialDate = DateTime.tryParse(data['FECHA']);
      }
    }

    AwesomeDialog(
      context: context,
      headerAnimationLoop: false,
      dialogType: crear ? DialogType.info : DialogType.question,
      animType: AnimType.scale,
      showCloseIcon: true,
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: FormBuilder(
            key: _formKey,
            initialValue: {
              'NHORARIO': crear ? null : data!['NHORARIO'],
              'FECHA': initialDate,
              'ASISTENCIA': crear ? true : (data!['ASISTENCIA'] == 1),
            },
            child: Column(
              children: [
                Text(crear ? 'Registrar Asistencia' : 'Modificar Asistencia', style: Theme.of(context).textTheme.headlineSmall),
                SizedBox(height: 20),

                FormBuilderDropdown<int>(
                  name: 'NHORARIO',
                  decoration: InputDecoration(
                    labelText: 'Horario (Profesor - Materia - Hora)',
                    border: OutlineInputBorder(),
                    hintText: 'Seleccione el horario',
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: "El horario es obligatorio"),
                  ]),
                  items: horariosDropdown.map((horario) {
                    return DropdownMenuItem<int>(
                      value: horario['NHORARIO'] as int,
                      child: Text(
                          '${horario['NOMBRE_PROFESOR']} - ${horario['DESCRIPCION_MATERIA']} (${horario['HORA']})'
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: 20,),

                FormBuilderDateTimePicker(
                  name: 'FECHA',
                  decoration: InputDecoration(
                    labelText: 'Fecha de la Asistencia',
                    border: OutlineInputBorder(),
                  ),
                  inputType: InputType.date,
                  format: DateFormat('yyyy-MM-dd'),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: "La fecha es obligatoria"),
                  ]),
                ),

                SizedBox(height: 20,),

                FormBuilderDropdown<bool>(
                  name: 'ASISTENCIA',
                  decoration: InputDecoration(
                    labelText: 'Estado de Asistencia',
                    border: OutlineInputBorder(),
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: "El estado es obligatorio"),
                  ]),
                  items: [
                    DropdownMenuItem(value: true, child: Text('Presente')),
                    DropdownMenuItem(value: false, child: Text('Ausente')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      btnOk: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState?.saveAndValidate() ?? false) {
            final formData = _formKey.currentState!.value;

            final fechaString = DateFormat('dd-MM-yyyy').format(formData['FECHA'] as DateTime);

            final nuevaAsistencia = Asistencia(
              idasistencia: asistenciaObj?.idasistencia,
              nhorario: formData['NHORARIO'] as int,
              fecha: fechaString,
              asistencia: formData['ASISTENCIA'] as bool,
            );

            if (crear) {
              DB.insertarAsistencia(nuevaAsistencia).then((value) {
                mostrarResultado('Éxito', 'Asistencia registrada correctamente.', DialogType.success);
              }).catchError((error) {
                mostrarResultado('Error', 'No se pudo registrar la asistencia: $error', DialogType.error);
              });
            } else {
              DB.actualizarAsistencia(nuevaAsistencia).then((value) {
                mostrarResultado('Éxito', 'Asistencia actualizada correctamente.', DialogType.success);
              }).catchError((error) {
                mostrarResultado('Error', 'No se pudo actualizar la asistencia: $error', DialogType.error);
              });
            }

            Navigator.of(context).pop();
          }
        },
        child: Text(crear ? 'Añadir Asistencia' : 'Guardar Cambios'),
      ),
      btnCancel: TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text('Cancelar'),
      ),
    ).show();
  }

  void confirmarEliminar(BuildContext context, Map<String, dynamic> asistencia) {
    AwesomeDialog(
        context: context,
        headerAnimationLoop: false,
        dialogType: DialogType.warning,
        animType: AnimType.scale,
        title: 'Confirmar Eliminación',
        showCloseIcon: true,
        body: Center(
          child: Text('¿Está seguro de eliminar el registro de asistencia del ${asistencia['FECHA']} para ${asistencia['NOMBRE_PROFESOR']}?'),
        ),
        btnOk: ElevatedButton(
          onPressed: () {
            DB.eliminarAsistencia(asistencia['IDASISTENCIA'] as int).then((value){
              mostrarResultado('Éxito', 'Registro de asistencia eliminado.', DialogType.success);
            }).catchError((error){
              mostrarResultado('Error', 'No se pudo eliminar el registro: $error', DialogType.error);
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
        _cargarDatos();
      },
    ).show();
  }
}
