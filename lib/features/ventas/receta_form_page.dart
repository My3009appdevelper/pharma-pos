import 'package:flutter/material.dart';
import 'package:pos_farmacia/core/models/product_model.dart';
import 'package:pos_farmacia/core/models/receta_model.dart';
import 'package:pos_farmacia/core/models/receta_detalle_model.dart';
import 'package:pos_farmacia/core/models/venta_detalle_model.dart';
import 'package:pos_farmacia/core/providers/detalle_venta_provider.dart';
import 'package:pos_farmacia/core/providers/inventario_provider.dart';
import 'package:pos_farmacia/core/providers/receta_provider.dart';
import 'package:pos_farmacia/widgets/elevated_button.dart';
import 'package:pos_farmacia/widgets/text_form_field.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class RecetaFormPage extends StatefulWidget {
  final String uuidVenta;
  const RecetaFormPage({Key? key, required this.uuidVenta}) : super(key: key);

  @override
  State<RecetaFormPage> createState() => _RecetaFormPageState();
}

class _RecetaFormPageState extends State<RecetaFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombrePacienteController = TextEditingController();
  final _nombreMedicoController = TextEditingController();
  final _cedulaController = TextEditingController();
  final _observacionesController = TextEditingController();
  final _uuidReceta = const Uuid().v4();

  late List<DetalleVentaModel> productosConReceta;

  final Map<int, TextEditingController> _indicacionesControllers = {};
  final Map<int, TextEditingController> _cantidadControllers = {};
  final Map<int, ProductoModel> _productosMap = {};

  @override
  void initState() {
    super.initState();

    final detalleProvider = context.read<DetalleVentaProvider>();
    final inventarioProvider = context.read<InventarioProvider>();

    productosConReceta = detalleProvider.detalles.where((d) {
      final producto = inventarioProvider.obtenerPorId(d.idProducto);
      if (producto != null && producto.requiereReceta) {
        _productosMap[d.idProducto] = producto;
        return true;
      }
      return false;
    }).toList();

    for (var item in productosConReceta) {
      _indicacionesControllers[item.idProducto] = TextEditingController();
      _cantidadControllers[item.idProducto] = TextEditingController(
        text: item.cantidad.toString(),
      );
    }
  }

  @override
  void dispose() {
    _nombrePacienteController.dispose();
    _nombreMedicoController.dispose();
    _cedulaController.dispose();
    _observacionesController.dispose();
    for (var controller in _indicacionesControllers.values) {
      controller.dispose();
    }
    for (var controller in _cantidadControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final receta = RecetaModel(
      uuid: _uuidReceta,
      uuidVenta: widget.uuidVenta,
      nombrePaciente: _nombrePacienteController.text,
      nombreMedico: _nombreMedicoController.text,
      cedulaProfesional: _cedulaController.text,
      observaciones: _observacionesController.text,
      fechaEmision: DateTime.now(),
      creadoEn: DateTime.now(),
    );

    final detalles = productosConReceta.map((item) {
      return RecetaDetalleModel(
        uuidReceta: _uuidReceta,
        idProducto: item.idProducto,
        cantidad:
            int.tryParse(
              _cantidadControllers[item.idProducto]?.text.trim() ?? '1',
            ) ??
            1,
        indicaciones:
            _indicacionesControllers[item.idProducto]?.text.trim() ?? '',
        creadoEn: DateTime.now(),
      );
    }).toList();

    await context.read<RecetaProvider>().guardarReceta(receta, detalles);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Capturar receta médica"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextFormField(
                label: "Nombre del paciente",
                controller: _nombrePacienteController,

                validator: (value) =>
                    value == null || value.isEmpty ? 'Requerido' : null,
              ),
              CustomTextFormField(
                label: "Nombre del médico",
                controller: _nombreMedicoController,

                validator: (value) =>
                    value == null || value.isEmpty ? 'Requerido' : null,
              ),
              CustomTextFormField(
                label: "Cédula profesional",
                controller: _cedulaController,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              const Text(
                "Productos con receta",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...productosConReceta.map((item) {
                final producto = _productosMap[item.idProducto];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      producto?.nombre ?? "Producto ${item.idProducto}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    CustomTextFormField(
                      label: "Cantidad",
                      controller: _cantidadControllers[item.idProducto]!,
                      keyboardType: TextInputType.number,
                    ),
                    CustomTextFormField(
                      controller: _indicacionesControllers[item.idProducto]!,
                      label: "Indicaciones",
                    ),
                    const Divider(),
                  ],
                );
              }).toList(),
              CustomTextFormField(
                label: "Observaciones",
                controller: _observacionesController,
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              CustomElevatedButton(
                onPressed: _guardar,
                textButtonText: "Guardar receta",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
