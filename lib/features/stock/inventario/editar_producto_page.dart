import 'package:flutter/material.dart';
import 'dart:io';
import 'package:pos_farmacia/features/stock/inventario/logic/inventario_service.dart';
import 'package:pos_farmacia/widgets/elevated_button.dart';
import 'package:pos_farmacia/widgets/text_form_field.dart';
import 'package:pos_farmacia/widgets/image_picker_field.dart';
import 'package:provider/provider.dart';
import 'package:pos_farmacia/features/stock/inventario/logic/inventario_provider.dart';
import 'package:pos_farmacia/features/stock/inventario/logic/product_model.dart';

class EditarProductoPage extends StatefulWidget {
  final ProductoModel producto;

  const EditarProductoPage({super.key, required this.producto});

  @override
  State<EditarProductoPage> createState() => _EditarProductoPageState();
}

class _EditarProductoPageState extends State<EditarProductoPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _codigoController;
  late final TextEditingController _nombreController;
  late final TextEditingController _descripcionController;
  late final TextEditingController _unidadController;
  late final TextEditingController _precioController;
  late final TextEditingController _costoController;
  late final TextEditingController _nuevaCategoriaController;
  late final TextEditingController _temperaturaMinController;
  late final TextEditingController _temperaturaMaxController;
  late final TextEditingController _humedadMaxController;
  late final TextEditingController _presentacionController;

  String? _imagenUrlCargada;

  bool _requiereRefrigeracion = false;
  bool _requiereReceta = false;
  bool _activo = true;
  bool _loading = false;

  List<String> _categoriasDisponibles = [];
  List<String> _categoriasSeleccionadas = [];

  @override
  void initState() {
    super.initState();
    final p = widget.producto;

    _codigoController = TextEditingController(text: p.codigo);
    _nombreController = TextEditingController(text: p.nombre);
    _descripcionController = TextEditingController(text: p.descripcion);
    _unidadController = TextEditingController(text: p.unidad);
    _precioController = TextEditingController(text: p.precio.toString());
    _costoController = TextEditingController(text: p.costo.toString());
    _presentacionController = TextEditingController(text: p.presentacion);
    _humedadMaxController = TextEditingController(
      text: p.humedadMaxima?.toString() ?? '',
    );
    _temperaturaMinController = TextEditingController(
      text: p.temperaturaMinima?.toString() ?? '',
    );
    _temperaturaMaxController = TextEditingController(
      text: p.temperaturaMaxima?.toString() ?? '',
    );
    _nuevaCategoriaController = TextEditingController();

    _requiereRefrigeracion = p.requiereRefrigeracion;
    _requiereReceta = p.requiereReceta;
    _activo = p.activo;
    _imagenUrlCargada = p.imagenUrl;
    _categoriasSeleccionadas = List.from(p.categorias);

    final productos = Provider.of<InventarioProvider>(
      context,
      listen: false,
    ).productos;
    final categoriasUnicas =
        productos.expand((p) => p.categorias).toSet().toList()..sort();
    _categoriasDisponibles = categoriasUnicas;
  }

  Future<void> _guardarProducto() async {
    if (!_formKey.currentState!.validate()) return;

    final productoEditado = widget.producto.copyWith(
      codigo: _codigoController.text.trim(),
      nombre: _nombreController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      categorias: _categoriasSeleccionadas,
      unidad: _unidadController.text.trim(),
      precio: double.tryParse(_precioController.text) ?? 0,
      costo: double.tryParse(_costoController.text) ?? 0,
      requiereRefrigeracion: _requiereRefrigeracion,
      requiereReceta: _requiereReceta,
      activo: _activo,
      temperaturaMinima: _requiereRefrigeracion
          ? double.tryParse(_temperaturaMinController.text)
          : null,
      temperaturaMaxima: _requiereRefrigeracion
          ? double.tryParse(_temperaturaMaxController.text)
          : null,
      humedadMaxima: double.tryParse(_humedadMaxController.text),
      presentacion: _presentacionController.text.trim(),
      imagenUrl: _imagenUrlCargada,
    );

    setState(() => _loading = true);
    await InventarioService.actualizarProducto(productoEditado);
    await Provider.of<InventarioProvider>(
      context,
      listen: false,
    ).cargarDesdeBD();

    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Producto actualizado')));
    }
  }

  void _actualizarImagen(String imagePath) {
    setState(() {
      _imagenUrlCargada = imagePath;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(title: Center(child: const Text('Editar Producto'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ImagePickerField(
                onImageSelected: _actualizarImagen,
                initialUrl: _imagenUrlCargada,
              ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: isWide ? 280 : double.infinity,
                    child: CustomTextFormField(
                      label: 'Código',
                      controller: _codigoController,
                    ),
                  ),
                  SizedBox(
                    width: isWide ? 280 : double.infinity,
                    child: CustomTextFormField(
                      label: 'Nombre',
                      controller: _nombreController,
                    ),
                  ),
                  SizedBox(
                    width: isWide ? 280 : double.infinity,
                    child: CustomTextFormField(
                      label: 'Descripción',
                      controller: _descripcionController,
                    ),
                  ),
                  SizedBox(
                    width: isWide ? 280 : double.infinity,
                    child: CustomTextFormField(
                      label: 'Unidad',
                      controller: _unidadController,
                    ),
                  ),
                  SizedBox(
                    width: isWide ? 180 : double.infinity,
                    child: CustomTextFormField(
                      label: 'Precio',
                      controller: _precioController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(
                    width: isWide ? 180 : double.infinity,
                    child: CustomTextFormField(
                      label: 'Costo',
                      controller: _costoController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  CustomTextFormField(
                    label: 'Presentación',
                    controller: _presentacionController,
                  ),
                  CustomTextFormField(
                    label: 'Humedad Máxima (%)',
                    controller: _humedadMaxController,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Categorías'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categoriasDisponibles.map((cat) {
                  final selected = _categoriasSeleccionadas.contains(cat);
                  return FilterChip(
                    label: Text(cat),
                    selected: selected,
                    onSelected: (val) {
                      setState(() {
                        if (val) {
                          _categoriasSeleccionadas.add(cat);
                        } else {
                          _categoriasSeleccionadas.remove(cat);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              Row(
                children: [
                  Expanded(
                    child: CustomTextFormField(
                      label: 'Nueva Categoría',
                      controller: _nuevaCategoriaController,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      final nueva = _nuevaCategoriaController.text.trim();
                      if (nueva.isNotEmpty &&
                          !_categoriasDisponibles.contains(nueva)) {
                        setState(() {
                          _categoriasDisponibles.add(nueva);
                          _categoriasSeleccionadas.add(nueva);
                          _nuevaCategoriaController.clear();
                        });
                      }
                    },
                  ),
                ],
              ),
              SwitchListTile(
                title: const Text('¿Requiere Refrigeración?'),
                value: _requiereRefrigeracion,
                onChanged: (v) => setState(() => _requiereRefrigeracion = v),
              ),
              if (_requiereRefrigeracion) ...[
                CustomTextFormField(
                  label: 'Temperatura Mínima (°C)',
                  controller: _temperaturaMinController,
                  keyboardType: TextInputType.number,
                ),
                CustomTextFormField(
                  label: 'Temperatura Máxima (°C)',
                  controller: _temperaturaMaxController,
                  keyboardType: TextInputType.number,
                ),
              ],
              SwitchListTile(
                title: const Text('¿Requiere Receta?'),
                value: _requiereReceta,
                onChanged: (v) => setState(() => _requiereReceta = v),
              ),
              SwitchListTile(
                title: const Text('¿Activo?'),
                value: _activo,
                onChanged: (v) => setState(() => _activo = v),
              ),
              const SizedBox(height: 20),
              CustomElevatedButton(
                onPressed: _guardarProducto,
                loading: _loading,
                child: const Text('Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
