import 'package:flutter/material.dart';
import 'package:pos_farmacia/core/models/cliente_model.dart';
import 'package:pos_farmacia/features/clientes/cliente_form_page.dart';

class ClientesDataTable extends StatefulWidget {
  final List<ClienteModel> clientes;

  const ClientesDataTable({super.key, required this.clientes});

  @override
  State<ClientesDataTable> createState() => _ClientesDataTableState();
}

class _ClientesDataTableState extends State<ClientesDataTable> {
  late List<ClienteModel> _clientesOrdenados;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _clientesOrdenados = [...widget.clientes];
  }

  void _ordenar<T>(
    Comparable<T> Function(ClienteModel c) getField,
    int columnIndex,
  ) {
    setState(() {
      _sortAscending = (_sortColumnIndex == columnIndex)
          ? !_sortAscending
          : true;
      _sortColumnIndex = columnIndex;

      _clientesOrdenados.sort((a, b) {
        final aValue = getField(a);
        final bValue = getField(b);
        return _sortAscending
            ? Comparable.compare(aValue, bValue)
            : Comparable.compare(bValue, aValue);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  sortColumnIndex: _sortColumnIndex,
                  sortAscending: _sortAscending,
                  columnSpacing: 24,
                  columns: [
                    const DataColumn(
                      label: SizedBox(width: 60, child: Text('Editar')),
                    ),
                    DataColumn(
                      label: const SizedBox(width: 160, child: Text('Nombre')),
                      onSort: (_, __) =>
                          _ordenar((c) => c.nombreCompleto.toLowerCase(), 1),
                    ),
                    DataColumn(
                      label: const SizedBox(
                        width: 120,
                        child: Text('Teléfono'),
                      ),
                      onSort: (_, __) =>
                          _ordenar((c) => c.telefono?.toLowerCase() ?? '', 2),
                    ),
                    DataColumn(
                      label: const SizedBox(width: 180, child: Text('Email')),
                      onSort: (_, __) =>
                          _ordenar((c) => c.email?.toLowerCase() ?? '', 3),
                    ),
                    DataColumn(
                      label: const SizedBox(width: 100, child: Text('RFC')),
                      onSort: (_, __) =>
                          _ordenar((c) => c.rfc?.toLowerCase() ?? '', 4),
                    ),
                    DataColumn(
                      label: const SizedBox(width: 80, child: Text('Puntos')),
                      numeric: true,
                      onSort: (_, __) => _ordenar((c) => c.puntosAcumulados, 5),
                    ),
                  ],
                  rows: _clientesOrdenados.map((cliente) {
                    return DataRow(
                      cells: [
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.edit),
                            tooltip: 'Editar cliente',
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.surface,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(24),
                                  ),
                                ),
                                builder: (context) => Padding(
                                  padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(
                                      context,
                                    ).viewInsets.bottom,
                                  ),
                                  child: ClienteFormPage(
                                    clienteExistente: cliente,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        DataCell(Text(cliente.nombreCompleto)),
                        DataCell(Text(cliente.telefono ?? '')),
                        DataCell(Text(cliente.email ?? '')),
                        DataCell(Text(cliente.rfc ?? '')),
                        DataCell(Text(cliente.puntosAcumulados.toString())),
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
