import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pos_farmacia/features/stock/inventario/logic/inventario_provider.dart';
import 'package:pos_farmacia/features/sucursal/logic/sucursal/sucursal_provider.dart';
import '../../../widgets/elevated_button.dart';
import '../../../widgets/text_form_field.dart';
import 'logic/inventario_sucursal_model.dart';
import 'logic/inventario_sucursal_provider.dart';

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

  final TextEditingController _stockMinimoController = TextEditingController();
  final TextEditingController _precioCompraController = TextEditingController();
  final TextEditingController _precioVentaController = TextEditingController();
  final TextEditingController _ubicacionFisicaController =
      TextEditingController();

  DateTime? _fechaEntrada;
  DateTime? _fechaCaducidad;
  bool _loading = false;

  Future<void> _seleccionarFecha(BuildContext context, bool esCaducidad) async {
    final DateTime? seleccionada = await showDatePicker(
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

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate() ||
        _productoId == null ||
        _sucursalId == null)
      return;

    final registro = InventarioSucursalModel(
      idProducto: _productoId!,
      idSucursal: _sucursalId!,
      stock: 0,
      stockMinimo: int.tryParse(_stockMinimoController.text) ?? 0,
      fechaEntrada: _fechaEntrada,
      caducidad: _fechaCaducidad,
      precioCompra: double.tryParse(_precioCompraController.text),
      precioVenta: double.tryParse(_precioVentaController.text),
      ubicacionFisica: _ubicacionFisicaController.text,
    );

    setState(() => _loading = true);
    final provider = Provider.of<InventarioSucursalProvider>(
      context,
      listen: false,
    );
    provider.agregarRegistro(registro);

    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto asignado a sucursal')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final productos = Provider.of<InventarioProvider>(context).productos;
    final sucursales = Provider.of<SucursalProvider>(context).sucursales;

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
                items: productos.map((p) {
                  return DropdownMenuItem(value: p.id, child: Text(p.nombre));
                }).toList(),
                value: _productoId,
                onChanged: (val) => setState(() => _productoId = val),
                validator: (val) =>
                    val == null ? 'Selecciona un producto' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Sucursal'),
                items: sucursales.map((s) {
                  return DropdownMenuItem(value: s.id, child: Text(s.nombre));
                }).toList(),
                value: _sucursalId,
                onChanged: (val) => setState(() => _sucursalId = val),
                validator: (val) =>
                    val == null ? 'Selecciona una sucursal' : null,
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                label: 'Stock mínimo',
                controller: _stockMinimoController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
              CustomTextFormField(
                label: 'Precio de compra',
                controller: _precioCompraController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                label: 'Precio de venta',
                controller: _precioVentaController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                label: 'Ubicación física',
                controller: _ubicacionFisicaController,
              ),
              const SizedBox(height: 20),
              CustomElevatedButton(
                onPressed: _guardar,
                loading: _loading,
                child: const Text('Guardar asignación'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
