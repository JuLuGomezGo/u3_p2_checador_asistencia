// widgets/asistencia_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:u3_p2_checador_asistencia/BaseDatos/Clases/db.dart';
import 'package:u3_p2_checador_asistencia/BaseDatos/Clases/profesor.dart';

class AsistenciaPorProfesorChart extends StatefulWidget {
  // si quieres, puedes pasar rango inicial aquí (opcional)
  const AsistenciaPorProfesorChart({Key? key}) : super(key: key);

  @override
  State<AsistenciaPorProfesorChart> createState() =>
      _AsistenciaPorProfesorChartState();
}

class _AsistenciaPorProfesorChartState
    extends State<AsistenciaPorProfesorChart> {
  bool loading = true;
  List<Profesor> profesores = [];
  // porcentaje por profesor en el mismo orden que 'profesores'
  List<double> porcentajes = [];
  String? error;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final listaProf = await DB.mostrarProfesores();
      List<double> listaPorc = [];

      // Para cada profesor, obtén el historial y calcula porcentaje
      for (var prof in listaProf) {
        final historial = await DB.getHistorialAsistenciaProfesor(prof.nprofesor);
        // historial es List<Map<String,dynamic>> con campo 'ASISTENCIA' (0/1)
        int total = historial.length;
        int presencias = historial.fold<int>(0, (acc, row) {
          final val = row['ASISTENCIA'];
          if (val is int) return acc + (val == 1 ? 1 : 0);
          if (val is String) return acc + (val == '1' ? 1 : 0);
          return acc;
        });
        double pct = total == 0 ? 0.0 : (presencias / total) * 100.0;
        listaPorc.add(pct);
      }

      if (!mounted) return;
      setState(() {
        profesores = listaProf;
        porcentajes = listaPorc;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(child: Text('Error: $error'));
    }
    if (profesores.isEmpty) {
      return const Center(child: Text('No hay profesores registrados.'));
    }

    // Preparar datos para fl_chart
    final maxY = (porcentajes.isEmpty) ? 100.0 : (porcentajes.reduce((a, b) => a > b ? a : b) + 10).clamp(10.0, 100.0);

    final groups = List.generate(porcentajes.length, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: porcentajes[i],
            width: 18,
            borderRadius: BorderRadius.circular(6),
            // color dejar que el theme decida (o personalizar)
          ),
        ],
      );
    });

    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                    child: Text('Porcentaje de asistencia por profesor',
                        style: Theme.of(context).textTheme.titleMedium)),
                IconButton(
                  tooltip: 'Actualizar',
                  icon: const Icon(Icons.refresh),
                  onPressed: _cargarDatos,
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 320,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  minY: 0,
                  barGroups: groups,
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: AxisTitles(),
                    rightTitles: AxisTitles(),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}%',
                              style: const TextStyle(fontSize: 12));
                        },
                        interval: 20,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 64,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= profesores.length) return const SizedBox.shrink();
                          final name = profesores[idx].nprofesor;
                          // Puedes devolver nombre corto o iniciales si es muy largo
                          final label = name.length > 8 ? '${name.substring(0, 8)}...' : name;
                          return SideTitleWidget(
                            meta: meta,
                            child: Transform.rotate(
                              angle: -0.6,
                              child: Text(label, style: const TextStyle(fontSize: 11)),
                            ),
                          );
                        },
                        interval: 1,
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                  ),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final profesor = profesores[group.x.toInt()];
                        final pct = porcentajes[group.x.toInt()];
                        return BarTooltipItem(
                          '${profesor.nprofesor}\n${pct.toStringAsFixed(1)}%',
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _cargarDatos,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refrescar'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Por ejemplo: exportar CSV o abrir pantalla detalle
                  },
                  icon: const Icon(Icons.bar_chart),
                  label: const Text('Detalles'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
