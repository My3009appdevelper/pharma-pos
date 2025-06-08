import 'package:flutter/material.dart';
import 'package:pos_farmacia/core/providers/cliente_provider.dart';
import 'package:pos_farmacia/features/clientes/cliente_form_page.dart';
import 'package:pos_farmacia/widgets/elevated_button.dart';
import 'package:provider/provider.dart';

class SeleccionarClienteSheet extends StatefulWidget {
  const SeleccionarClienteSheet({super.key});

  @override
  State<SeleccionarClienteSheet> createState() =>
      _SeleccionarClienteSheetState();
}

class _SeleccionarClienteSheetState extends State<SeleccionarClienteSheet> {
  String _filtro = '';

  @override
  Widget build(BuildContext context) {
    final clientes = context.watch<ClienteProvider>().clientes;
    final filtrados = clientes
        .where(
          (c) =>
              c.nombreCompleto.toLowerCase().contains(_filtro.toLowerCase()) ||
              (c.telefono ?? '').contains(_filtro) ||
              (c.email ?? '').contains(_filtro),
        )
        .toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: const InputDecoration(labelText: 'Buscar cliente...'),
            onChanged: (value) => setState(() => _filtro = value),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 300,
            child: ListView.builder(
              itemCount: filtrados.length,
              itemBuilder: (_, index) {
                final cliente = filtrados[index];
                return ListTile(
                  title: Text(cliente.nombreCompleto),
                  subtitle: Text(cliente.telefono ?? ''),
                  trailing: Icon(Icons.person),
                  onTap: () {
                    Navigator.pop(context, cliente);
                  },
                );
              },
            ),
          ),
          const Divider(),
          CustomElevatedButton(
            textButtonText: "Registrar nuevo cliente",

            onPressed: () async {
              Navigator.pop(context); // cerrar modal
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => const ClienteFormPage(),
              );
            },
          ),
        ],
      ),
    );
  }
}
