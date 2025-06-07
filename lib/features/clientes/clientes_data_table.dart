import 'package:flutter/material.dart';
import 'package:pos_farmacia/core/models/cliente_model.dart';
import 'package:pos_farmacia/features/clientes/cliente_form_page.dart';

class ClientesDataTable extends StatelessWidget {
  final List<ClienteModel> clientes;

  const ClientesDataTable({super.key, required this.clientes});

  @override
  Widget build(BuildContext context) {
    final ScrollController verticalController = ScrollController();
    final ScrollController horizontalController = ScrollController();

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
                  columnSpacing: 24,
                  columns: const [
                    DataColumn(
                      label: SizedBox(width: 60, child: Text('Editar')),
                    ),
                    DataColumn(
                      label: SizedBox(width: 160, child: Text('Nombre')),
                    ),
                    DataColumn(
                      label: SizedBox(width: 120, child: Text('Teléfono')),
                    ),
                    DataColumn(
                      label: SizedBox(width: 180, child: Text('Email')),
                    ),
                    DataColumn(label: SizedBox(width: 100, child: Text('RFC'))),
                    DataColumn(
                      label: SizedBox(width: 80, child: Text('Puntos')),
                    ),
                  ],
                  rows: clientes.map((cliente) {
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
