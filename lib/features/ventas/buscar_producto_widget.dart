import 'package:flutter/material.dart';
import 'package:pos_farmacia/core/models/product_model.dart';

class BuscarProductoWidget extends StatefulWidget {
  final List<ProductoModel> productos;
  final Function(ProductoModel) onSeleccionar;

  const BuscarProductoWidget({
    required this.productos,
    required this.onSeleccionar,
  });

  @override
  State<BuscarProductoWidget> createState() => BuscarProductoWidgetState();
}

class BuscarProductoWidgetState extends State<BuscarProductoWidget> {
  String _busqueda = '';

  @override
  Widget build(BuildContext context) {
    final resultados = widget.productos.where((p) {
      final texto = _busqueda.toLowerCase();
      return p.nombre.toLowerCase().contains(texto) ||
          p.codigo.toLowerCase().contains(texto);
    }).toList();

    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(
            labelText: 'Buscar por nombre o código',
            border: OutlineInputBorder(),
          ),
          onChanged: (valor) => setState(() => _busqueda = valor),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: resultados.length,
            itemBuilder: (context, index) {
              final p = resultados[index];
              return ListTile(
                title: Text(p.nombre),
                subtitle: Text('Precio: \$${p.precio.toStringAsFixed(2)}'),
                trailing: const Icon(Icons.add),
                onTap: () => widget.onSeleccionar(p),
              );
            },
          ),
        ),
      ],
    );
  }
}
