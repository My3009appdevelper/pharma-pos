import 'package:flutter/material.dart';
import 'dart:io';
import 'package:pos_farmacia/features/stock/inventario/logic/inventario_service.dart';
import 'package:pos_farmacia/widgets/elevated_button.dart';
import 'package:pos_farmacia/widgets/text_form_field.dart';
import 'package:pos_farmacia/widgets/image_picker_field.dart';
import 'package:provider/provider.dart';
import 'package:pos_farmacia/features/stock/inventario/logic/inventario_provider.dart';
import 'package:pos_farmacia/features/stock/inventario/logic/product_model.dart';

class AgregarProductoPage extends StatefulWidget {
  const AgregarProductoPage({super.key});

  @override
  State<AgregarProductoPage> createState() => _AgregarProductoPageState();
}

class _AgregarProductoPageState extends State<AgregarProductoPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _unidadController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _costoController = TextEditingController();
  final TextEditingController _nuevaCategoriaController =
      TextEditingController();
  final TextEditingController _temperaturaMinController =
      TextEditingController();
  final TextEditingController _temperaturaMaxController =
      TextEditingController();
  final TextEditingController _humedadMaxController = TextEditingController();
  final TextEditingController _presentacionController = TextEditingController();

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

    final nuevoProducto = ProductoModel(
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
      historialPrecios: [],
      historialCostos: [],
      productosRelacionados: [],
      compradosJuntoA: [],
    );

    setState(() => _loading = true);
    await InventarioService.insertarProducto(nuevoProducto);
    await Provider.of<InventarioProvider>(
      context,
      listen: false,
    ).cargarDesdeBD();

    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto agregado exitosamente')),
      );
    }
  }

  void _agregarNuevaCategoria() {
    final nueva = _nuevaCategoriaController.text.trim();
    if (nueva.isNotEmpty && !_categoriasDisponibles.contains(nueva)) {
      setState(() {
        _categoriasDisponibles.add(nueva);
        _categoriasSeleccionadas.add(nueva);
        _nuevaCategoriaController.clear();
      });
    }
  }

  void _actualizarImagen(String imagePath) {
    setState(() {
      _imagenUrlCargada = imagePath;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Producto')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextFormField(
                label: 'Código',
                controller: _codigoController,
              ),
              CustomTextFormField(
                label: 'Nombre',
                controller: _nombreController,
              ),
              CustomTextFormField(
                label: 'Descripción',
                controller: _descripcionController,
              ),
              const SizedBox(height: 10),
              const Text(
                'Categorías',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Wrap(
                spacing: 8,
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
                    onPressed: _agregarNuevaCategoria,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              CustomTextFormField(
                label: 'Unidad',
                controller: _unidadController,
              ),
              CustomTextFormField(
                label: 'Precio Venta',
                controller: _precioController,
                keyboardType: TextInputType.number,
              ),
              CustomTextFormField(
                label: 'Costo',
                controller: _costoController,
                keyboardType: TextInputType.number,
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
              const SizedBox(height: 10),
              ImagePickerField(
                onImageSelected: _actualizarImagen,
                initialUrl: _imagenUrlCargada,
              ),
              const SizedBox(height: 10),
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
                child: const Text('Guardar Producto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
