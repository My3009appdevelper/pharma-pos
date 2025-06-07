import 'package:flutter/material.dart';
import 'package:pos_farmacia/widgets/custom_snackbar.dart';
import 'package:provider/provider.dart';
import 'package:pos_farmacia/core/providers/inventario_provider.dart';
import 'package:pos_farmacia/core/providers/sucursal_provider.dart';
import 'package:pos_farmacia/widgets/elevated_button.dart';
import 'package:pos_farmacia/widgets/text_form_field.dart';
import 'package:pos_farmacia/core/models/inventario_sucursal_model.dart';
import 'package:pos_farmacia/core/providers/inventario_sucursal_provider.dart';

class AgregarProductoSucursalPage extends StatefulWidget {
  const AgregarProductoSucursalPage({super.key});

  @override
  State<AgregarProductoSucursalPage> createState() =>
      _AgregarProductoSucursalPageState();
}

class _AgregarProductoSucursalPageState
    extends State<AgregarProductoSucursalPage> {
  final _formKey = GlobalKey<FormState>();
  int? _productoId;
  int? _sucursalId;

  final _stockController = TextEditingController();
  final _stockMinimoController = TextEditingController();
  final _precioCompraController = TextEditingController();
  final _precioVentaController = TextEditingController();
  final _ubicacionFisicaController = TextEditingController();
  final _presentacionController = TextEditingController();
  final _nuevoLoteController = TextEditingController();

  DateTime? _fechaEntrada;
  DateTime? _fechaCaducidad;
  bool _loading = false;
  bool _activo = true;

  List<String> _lotesDisponibles = [];
  String? _loteSeleccionado;

  @override
  void initState() {
    super.initState();
    final inventarios = Provider.of<InventarioSucursalProvider>(
      context,
      listen: false,
    ).inventario;

    _lotesDisponibles =
        inventarios
            .map((e) => e.lote)
            .where((l) => l != null && l.trim().isNotEmpty)
            .cast<String>()
            .toSet()
            .toList()
          ..sort();
  }

  Future<void> _seleccionarFecha(BuildContext context, bool esCaducidad) async {
    final seleccionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (seleccionada != null) {
      setState(() {
        if (esCaducidad) {
          _fechaCaducidad = seleccionada;
        } else {
          _fechaEntrada = seleccionada;
        }
      });
    }
  }

  void _agregarLote() {
    final nuevo = _nuevoLoteController.text.trim();
    if (nuevo.isNotEmpty && !_lotesDisponibles.contains(nuevo)) {
      setState(() {
        _lotesDisponibles.add(nuevo);
        _loteSeleccionado = nuevo;
        _nuevoLoteController.clear();
      });
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate() ||
        _productoId == null ||
        _sucursalId == null)
      return;

    final registro = InventarioSucursalModel(
      idProducto: _productoId!,
      idSucursal: _sucursalId!,
      stock: int.tryParse(_stockController.text) ?? 0,
      stockMinimo: int.tryParse(_stockMinimoController.text) ?? 0,
      fechaEntrada: _fechaEntrada,
      caducidad: _fechaCaducidad,
      precioCompra: double.tryParse(_precioCompraController.text),
      precioVenta: double.tryParse(_precioVentaController.text),
      ubicacionFisica: _ubicacionFisicaController.text,
      presentacion: _presentacionController.text,
      lote: _loteSeleccionado,
      activo: _activo,
    );

    setState(() => _loading = true);
    await Provider.of<InventarioSucursalProvider>(
      context,
      listen: false,
    ).agregarRegistro(registro);

    setState(() => _loading = false);

    if (context.mounted) {
      Navigator.pop(context);
      SnackBarUtils.show(
        context,
        message: 'Producto asignado a sucursal',
        type: SnackBarType.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final productos = Provider.of<InventarioProvider>(context).productos;
    final sucursales = Provider.of<SucursalProvider>(context).sucursales;
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(title: const Text('Asignar Producto a Sucursal')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Producto'),
                items: productos
                    .map(
                      (p) =>
                          DropdownMenuItem(value: p.id, child: Text(p.nombre)),
                    )
                    .toList(),
                value: _productoId,
                onChanged: (val) => setState(() => _productoId = val),
                validator: (val) =>
                    val == null ? 'Selecciona un producto' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Sucursal'),
                items: sucursales
                    .map(
                      (s) =>
                          DropdownMenuItem(value: s.id, child: Text(s.nombre)),
                    )
                    .toList(),
                value: _sucursalId,
                onChanged: (val) => setState(() => _sucursalId = val),
                validator: (val) =>
                    val == null ? 'Selecciona una sucursal' : null,
              ),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: isWide ? 200 : double.infinity,
                    child: CustomTextFormField(
                      label: 'Stock',
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(
                    width: isWide ? 200 : double.infinity,
                    child: CustomTextFormField(
                      label: 'Stock mínimo',
                      controller: _stockMinimoController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(
                    width: isWide ? 200 : double.infinity,
                    child: CustomTextFormField(
                      label: 'Precio de compra',
                      controller: _precioCompraController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: isWide ? 200 : double.infinity,
                    child: CustomTextFormField(
                      label: 'Precio de venta',
                      controller: _precioVentaController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                  CustomTextFormField(
                    label: 'Presentación',
                    controller: _presentacionController,
                  ),
                  CustomTextFormField(
                    label: 'Ubicación física',
                    controller: _ubicacionFisicaController,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Lote',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              Wrap(
                spacing: 8,
                children: _lotesDisponibles.map((l) {
                  return ChoiceChip(
                    label: Text(l),
                    selected: _loteSeleccionado == l,
                    onSelected: (val) {
                      setState(() {
                        _loteSeleccionado = val ? l : null;
                      });
                    },
                  );
                }).toList(),
              ),
              Row(
                children: [
                  Expanded(
                    child: CustomTextFormField(
                      label: 'Nuevo lote',
                      controller: _nuevoLoteController,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _agregarLote,
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Fecha de entrada: ${_fechaEntrada != null ? _fechaEntrada!.toLocal().toString().split(' ')[0] : 'No seleccionada'}',
                    ),
                  ),
                  TextButton(
                    onPressed: () => _seleccionarFecha(context, false),
                    child: const Text('Seleccionar'),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Fecha de caducidad: ${_fechaCaducidad != null ? _fechaCaducidad!.toLocal().toString().split(' ')[0] : 'No seleccionada'}',
                    ),
                  ),
                  TextButton(
                    onPressed: () => _seleccionarFecha(context, true),
                    child: const Text('Seleccionar'),
                  ),
                ],
              ),
              SwitchListTile(
                title: const Text('¿Activo?'),
                value: _activo,
                onChanged: (v) => setState(() => _activo = v),
              ),
              const SizedBox(height: 20),
              CustomElevatedButton(
                onPressed: _guardar,
                loading: _loading,
                textButtonText: 'Guardar asignación',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
