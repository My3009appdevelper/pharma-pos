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
    if (producto != null) {
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Producto no encontrado')));
    }

    _codigoController.clear();
    _codigoFocus.requestFocus(); // <- vuelve a enfocar automáticamente
  }

  Future<void> procesarPago(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    final ventaProvider = Provider.of<VentaProvider>(context, listen: false);
    final detalleVentaProvider = Provider.of<DetalleVentaProvider>(
      context,
      listen: false,
    );
    final usuarioActual = Provider.of<UserProvider>(
      context,
      listen: false,
    ).usuarioActual;

    try {
      final detalles = detalleVentaProvider.detalles;
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
        idSucursal: usuarioActual?.idSucursal ?? 0,
        idUsuario: usuarioActual?.id ?? 0,
        total: total,
        subtotal: subtotal,
        descuentoTotal: descuentoTotal,
        metodoPago: 'Efectivo',
        observaciones: null,
        creadoEn: now,
        sincronizado: 0,
      );

      await ventaProvider.procesarVenta(venta, detalles);
      detalleVentaProvider.limpiarDetalles();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Venta registrada correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error al registrar la venta: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final detalleProvider = Provider.of<DetalleVentaProvider>(context);
    final inventarioProvider = Provider.of<InventarioProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Center(child: Text('Caja registradora'))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _codigoController,
              focusNode: _codigoFocus,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Escanea o escribe el código...',
                border: OutlineInputBorder(),
              ),
              onFieldSubmitted: (codigo) => _procesarCodigo(context, codigo),
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
                  final producto = inventarioProvider.productos.firstWhere(
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
                Text(
                  'Total: \$${detalleProvider.totalVenta.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
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
    );
  }
}
