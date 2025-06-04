import 'package:flutter/material.dart';
import 'package:pos_farmacia/core/models/product_model.dart';
import 'package:pos_farmacia/core/models/venta_model.dart';
import 'package:pos_farmacia/core/providers/user_provider.dart';
import 'package:pos_farmacia/core/providers/venta_provider.dart';
import 'package:pos_farmacia/widgets/elevated_button.dart';
import 'package:provider/provider.dart';
import 'package:pos_farmacia/core/models/detalle_venta_model.dart';
import 'package:pos_farmacia/core/providers/detalle_venta_provider.dart';
import 'package:pos_farmacia/core/providers/inventario_provider.dart';
import 'package:uuid/uuid.dart';

class VentasPage extends StatefulWidget {
  const VentasPage({super.key});

  @override
  State<VentasPage> createState() => _VentasPageState();
}

class _VentasPageState extends State<VentasPage> {
  final TextEditingController _codigoController = TextEditingController();
  final FocusNode _codigoFocus = FocusNode();
  bool _isLoading = false;
  ProductoModel? _productoSeleccionado;
  String _metodoPagoSeleccionado = 'Efectivo';

  @override
  void dispose() {
    _codigoController.dispose();
    _codigoFocus.dispose();
    super.dispose();
  }

  void _procesarCodigo(BuildContext context, String codigo) {
    final detalleProvider = Provider.of<DetalleVentaProvider>(
      context,
      listen: false,
    );
    final inventarioProvider = Provider.of<InventarioProvider>(
      context,
      listen: false,
    );

    final producto = inventarioProvider.obtenerPorCodigo(codigo.trim());
    setState(() => _productoSeleccionado = producto);

    if (producto != null && producto.stock > 0) {
      detalleProvider.agregarDetalle(
        DetalleVentaModel(
          uuidVenta: '',
          idProducto: producto.id!,
          cantidad: 1,
          precioUnitario: producto.precio,
          descuento: 0.0,
          total: producto.precio,
          idSucursal: 1,
          creadoEn: DateTime.now(),
          sincronizado: false,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto no encontrado o sin stock')),
      );
    }

    _codigoController.clear();
    _codigoFocus.requestFocus();
  }

  Future<void> procesarPago(BuildContext context) async {
    setState(() => _isLoading = true);
    final ventaProvider = Provider.of<VentaProvider>(context, listen: false);
    final detalleProvider = Provider.of<DetalleVentaProvider>(
      context,
      listen: false,
    );
    final usuario = Provider.of<UserProvider>(
      context,
      listen: false,
    ).usuarioActual;

    try {
      final detalles = detalleProvider.detalles;
      if (detalles.isEmpty) throw Exception("No hay productos en la venta.");

      final now = DateTime.now();
      final uuid = const Uuid().v4();
      final folio = 'FOLIO-${now.microsecondsSinceEpoch}';
      final subtotal = detalles.fold(
        0.0,
        (s, d) => s + d.precioUnitario * d.cantidad,
      );
      final descuentoTotal = detalles.fold(0.0, (s, d) => s + d.descuento);
      final total = subtotal - descuentoTotal;

      final venta = VentaModel(
        uuid: uuid,
        folio: folio,
        fecha: now,
        idSucursal: usuario?.idSucursal ?? 0,
        idUsuario: usuario?.id ?? 0,
        total: total,
        subtotal: subtotal,
        descuentoTotal: descuentoTotal,
        metodoPago: _metodoPagoSeleccionado,
        observaciones: null,
        creadoEn: now,
        sincronizado: 0,
      );

      await ventaProvider.procesarVenta(venta, detalles);
      detalleProvider.limpiarDetalles();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Venta registrada correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error al registrar la venta: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detalleProvider = Provider.of<DetalleVentaProvider>(context);
    final inventarioProvider = Provider.of<InventarioProvider>(context);
    final relacionados = detalleProvider.detalles.isNotEmpty
        ? inventarioProvider.obtenerRelacionados(
            inventarioProvider.productos.firstWhere(
              (p) => p.id == detalleProvider.detalles.last.idProducto,
              orElse: () => ProductoModel.empty(),
            ),
          )
        : inventarioProvider.productos.take(5).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Caja registradora'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Limpiar venta',
            onPressed: () {
              Provider.of<DetalleVentaProvider>(
                context,
                listen: false,
              ).limpiarDetalles();
            },
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _codigoController,
                    focusNode: _codigoFocus,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Escanea o escribe el código...',
                      border: OutlineInputBorder(),
                    ),
                    onFieldSubmitted: (codigo) =>
                        _procesarCodigo(context, codigo),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Productos en la venta:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: detalleProvider.detalles.length,
                      itemBuilder: (context, index) {
                        final d = detalleProvider.detalles[index];
                        final producto = inventarioProvider.productos
                            .firstWhere(
                              (p) => p.id == d.idProducto,
                              orElse: () => ProductoModel.empty(),
                            );
                        return ListTile(
                          title: Text(producto.nombre),
                          subtitle: Text(
                            'Cantidad: ${d.cantidad}  Total: \$${d.total.toStringAsFixed(2)}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => detalleProvider.eliminarDetalle(d),
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text(
                            'Artículos: ${detalleProvider.totalArticulos}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Total: \$${detalleProvider.totalVenta.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      DropdownButton<String>(
                        value: _metodoPagoSeleccionado,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _metodoPagoSeleccionado = value);
                          }
                        },
                        items: ['Efectivo', 'Tarjeta', 'Transferencia'].map((
                          m,
                        ) {
                          return DropdownMenuItem<String>(
                            value: m,
                            child: Text(m),
                          );
                        }).toList(),
                      ),
                      CustomElevatedButton(
                        onPressed: () => procesarPago(context),
                        textButtonText: 'Pagar',
                        loading: _isLoading,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const VerticalDivider(),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Productos relacionados:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: relacionados.length,
                      itemBuilder: (context, index) {
                        final p = relacionados[index];
                        return ListTile(
                          title: Text(p.nombre),
                          subtitle: Text(
                            'Precio: \$${p.precio.toStringAsFixed(2)}',
                          ),
                          onTap: () => _procesarCodigo(context, p.codigo),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
