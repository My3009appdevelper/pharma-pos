import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pos_farmacia/core/models/cliente_model.dart';
import 'package:pos_farmacia/core/models/product_model.dart';
import 'package:pos_farmacia/core/models/venta_model.dart';
import 'package:pos_farmacia/core/providers/user_provider.dart';
import 'package:pos_farmacia/core/providers/venta_provider.dart';
import 'package:pos_farmacia/features/ventas/buscar_producto_widget.dart';
import 'package:pos_farmacia/features/ventas/receta_form_page.dart';
import 'package:pos_farmacia/features/ventas/seleccionar_cliente_sheet.dart';
import 'package:pos_farmacia/widgets/custom_snackbar.dart';
import 'package:pos_farmacia/widgets/elevated_button.dart';
import 'package:provider/provider.dart';
import 'package:pos_farmacia/core/models/venta_detalle_model.dart';
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
  String? _uuidVenta;
  ClienteModel? _clienteSeleccionado;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DetalleVentaProvider>(
        context,
        listen: false,
      ).limpiarDetalles();
    });
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _codigoFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

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

    final compradosJuntoA = detalleProvider.detalles.isNotEmpty
        ? inventarioProvider.obtenerCompradosJuntoA(
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CustomElevatedButton(
                                textButtonText: "Seleccionar cliente",
                                onPressed: () async {
                                  final cliente =
                                      await showModalBottomSheet<ClienteModel>(
                                        context: context,
                                        isScrollControlled: true,
                                        builder: (_) =>
                                            const SeleccionarClienteSheet(),
                                      );

                                  if (cliente != null) {
                                    setState(() {
                                      _clienteSeleccionado = cliente;
                                    });
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.clear),
                                tooltip: 'Limpiar cliente',
                                onPressed: () {
                                  setState(() {
                                    _clienteSeleccionado = null;
                                  });
                                },
                              ),
                            ],
                          ),

                          if (_clienteSeleccionado != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '👤 Cliente seleccionado:',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  Text(
                                    'Nombre: ${_clienteSeleccionado!.nombreCompleto}',
                                  ),
                                  if (_clienteSeleccionado!.telefono != null)
                                    Text(
                                      'Teléfono: ${_clienteSeleccionado!.telefono}',
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

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
                    'Productos en la caja:',
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
                          leading:
                              producto.imagenUrl != null &&
                                  File(producto.imagenUrl!).existsSync()
                              ? Image.file(
                                  File(producto.imagenUrl!),
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(
                                  Icons.image,
                                  size: 30,
                                  color: Colors.grey,
                                ),
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
                  SingleChildScrollView(
                    child: Row(
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
                  ),
                ],
              ),
            ),
          ),
          const VerticalDivider(),
          Expanded(
            flex: 1,
            child: DefaultTabController(
              length: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TabBar(
                    labelColor: colorScheme.primary,
                    unselectedLabelColor: colorScheme.primary.withOpacity(0.6),
                    tabs: [
                      Tab(text: 'Relacionados'),
                      Tab(text: 'Comprados junto a'),
                      Tab(text: 'Buscar'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: TabBarView(
                      children: [
                        ListView.builder(
                          itemCount: relacionados.length,
                          itemBuilder: (context, index) {
                            final p = relacionados[index];
                            return ListTile(
                              leading:
                                  p.imagenUrl != null &&
                                      File(p.imagenUrl!).existsSync()
                                  ? Image.file(
                                      File(p.imagenUrl!),
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(
                                      Icons.image,
                                      size: 30,
                                      color: Colors.grey,
                                    ),
                              title: Text(p.nombre),
                              subtitle: Text(
                                'Precio: \$${p.precio.toStringAsFixed(2)}',
                              ),
                              onTap: () => _procesarCodigo(context, p.codigo),
                            );
                          },
                        ),
                        ListView.builder(
                          itemCount: compradosJuntoA.length,
                          itemBuilder: (context, index) {
                            final p = compradosJuntoA[index];
                            return ListTile(
                              leading:
                                  p.imagenUrl != null &&
                                      File(p.imagenUrl!).existsSync()
                                  ? Image.file(
                                      File(p.imagenUrl!),
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(
                                      Icons.image,
                                      size: 30,
                                      color: Colors.grey,
                                    ),
                              title: Text(p.nombre),
                              subtitle: Text(
                                'Precio: \$${p.precio.toStringAsFixed(2)}',
                              ),
                              onTap: () => _procesarCodigo(context, p.codigo),
                            );
                          },
                        ),
                        // Tab 3: Buscar Producto
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: BuscarProductoWidget(
                            productos: inventarioProvider.productos,
                            onSeleccionar: (p) =>
                                _procesarCodigo(context, p.codigo),
                          ),
                        ),
                      ],
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

  bool _hayProductosConReceta(BuildContext context) {
    final detalleProvider = Provider.of<DetalleVentaProvider>(
      context,
      listen: false,
    );
    return detalleProvider.detalles.any(
      (d) => Provider.of<InventarioProvider>(
        context,
        listen: false,
      ).productos.firstWhere((p) => p.id == d.idProducto).requiereReceta,
    );
  }

  Future<void> _mostrarDialogoCapturaReceta(BuildContext context) async {
    final uuidVenta = const Uuid().v4(); // Genera uuid
    _uuidVenta = uuidVenta; // Guarda en el estado

    final continuar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("📋 Receta médica requerida"),
        content: const Text(
          "Algunos productos requieren receta médica. ¿Deseas capturarla antes de continuar con el pago?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancelar"),
          ),
          CustomElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            textButtonText: "Capturar receta",
          ),
        ],
      ),
    );

    if (continuar == true) {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.9,
            child: RecetaFormPage(uuidVenta: uuidVenta),
          ),
        ),
      );
    }
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
      SnackBarUtils.show(
        context,
        message: 'Producto no encontrado o sin stock',
        type: SnackBarType.warning,
      );
    }

    _codigoController.clear();
    _codigoFocus.requestFocus();
  }

  Future<void> procesarPago(BuildContext context) async {
    setState(() => _isLoading = true);

    if (_hayProductosConReceta(context)) {
      await _mostrarDialogoCapturaReceta(context);
      return; // Detener flujo hasta que regrese
    }

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
      final uuid =
          _uuidVenta ?? const Uuid().v4(); // Usa receta o crea uno nuevo
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
        uuid_cliente: _clienteSeleccionado?.uuid_cliente,
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
      _uuidVenta = null; // Limpia después de usarla
      _clienteSeleccionado = null;
      SnackBarUtils.show(
        context,
        message: '✅ Venta registrada correctamente',
        type: SnackBarType.success,
      );
    } catch (e) {
      SnackBarUtils.show(context, message: '❌ $e', type: SnackBarType.error);
      print(e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _mostrarSeleccionCliente(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const SeleccionarClienteSheet(),
    );
  }
}
