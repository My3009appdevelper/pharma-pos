import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_farmacia/core/models/venta_model.dart';
import 'package:pos_farmacia/core/providers/venta_provider.dart';
import 'package:pos_farmacia/features/ventas/historial_ventas/detalle_venta_page.dart';
import 'package:provider/provider.dart';

class HistorialVentasDataTable extends StatefulWidget {
  const HistorialVentasDataTable({super.key});

  @override
  State<HistorialVentasDataTable> createState() =>
      _HistorialVentasDataTableState();
}

class _HistorialVentasDataTableState extends State<HistorialVentasDataTable> {
  late List<VentaModel> _ventasOrdenadas;
  int? _sortColumnIndex;
  bool _isAscending = true;

  @override
  void initState() {
    super.initState();
    final ventaProvider = Provider.of<VentaProvider>(context, listen: false);
    _ventasOrdenadas = [...ventaProvider.ventas]; // Copia editable
  }

  void _sort<T>(
    Comparable<T> Function(VentaModel venta) getField,
    int columnIndex,
  ) {
    setState(() {
      _isAscending = (_sortColumnIndex == columnIndex) ? !_isAscending : true;
      _sortColumnIndex = columnIndex;

      _ventasOrdenadas.sort((a, b) {
        final aValue = getField(a);
        final bValue = getField(b);
        return _isAscending
            ? Comparable.compare(aValue, bValue)
            : Comparable.compare(bValue, aValue);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final ventaProvider = Provider.of<VentaProvider>(context);
    final verticalController = ScrollController();
    final horizontalController = ScrollController();

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: true),
      child: Scrollbar(
        controller: verticalController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: verticalController,
          scrollDirection: Axis.vertical,
          child: Scrollbar(
            controller: horizontalController,
            thumbVisibility: true,
            scrollbarOrientation: ScrollbarOrientation.top,
            child: SingleChildScrollView(
              controller: horizontalController,
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 800),
                child: DataTable(
                  sortAscending: _isAscending,
                  sortColumnIndex: _sortColumnIndex,
                  columnSpacing: 24,
                  columns: [
                    DataColumn(
                      label: const Text('Sucursal'),
                      onSort: (index, _) => _sort((v) => v.folio, index),
                    ),
                    DataColumn(
                      label: const Text('Fecha'),
                      onSort: (index, _) => _sort((v) => v.fecha, index),
                    ),
                    DataColumn(
                      label: const Text('Método'),
                      onSort: (index, _) => _sort((v) => v.metodoPago, index),
                    ),
                    DataColumn(
                      label: const Text('Total'),
                      numeric: true,
                      onSort: (index, _) => _sort((v) => v.total, index),
                    ),
                    DataColumn(
                      label: const Text('Cliente'),
                      onSort: (index, _) => _sort(
                        (v) =>
                            ventaProvider
                                .clientesMap[v.uuid_cliente]
                                ?.nombreCompleto ??
                            '',
                        index,
                      ),
                    ),
                    const DataColumn(label: Text('Ver')),
                  ],
                  rows: _ventasOrdenadas.map((venta) {
                    final clienteNombre =
                        ventaProvider
                            .clientesMap[venta.uuid_cliente]
                            ?.nombreCompleto ??
                        '—';
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            ventaProvider
                                    .sucursalesMap[venta.idSucursal]
                                    ?.nombre ??
                                '—',
                          ),
                        ),
                        DataCell(
                          Text(DateFormat.yMMMd().add_jm().format(venta.fecha)),
                        ),
                        DataCell(Text(venta.metodoPago)),
                        DataCell(Text('\$${venta.total.toStringAsFixed(2)}')),
                        DataCell(Text(clienteNombre)),
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.visibility),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      DetalleVentaPage(venta: venta),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
