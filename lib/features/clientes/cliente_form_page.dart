import 'package:flutter/material.dart';
import 'package:pos_farmacia/widgets/elevated_button.dart';
import 'package:pos_farmacia/widgets/text_form_field.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:pos_farmacia/core/models/cliente_model.dart';
import 'package:pos_farmacia/core/providers/cliente_provider.dart';

class ClienteFormPage extends StatefulWidget {
  final ClienteModel? clienteExistente;
  const ClienteFormPage({Key? key, this.clienteExistente}) : super(key: key);

  @override
  State<ClienteFormPage> createState() => _ClienteFormPageState();
}

class _ClienteFormPageState extends State<ClienteFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController nombreController;
  late final TextEditingController apellidoController;
  late final TextEditingController telefonoController;
  late final TextEditingController emailController;
  late final TextEditingController direccionController;
  late final TextEditingController ciudadController;
  late final TextEditingController estadoController;
  late final TextEditingController cpController;
  late final TextEditingController rfcController;
  late final TextEditingController razonSocialController;
  late final TextEditingController usoCfdiController;
  late final TextEditingController regimenFiscalController;

  @override
  void initState() {
    final c = widget.clienteExistente;
    nombreController = TextEditingController(text: c?.nombreCompleto ?? '');
    apellidoController = TextEditingController(text: c?.apellido ?? '');
    telefonoController = TextEditingController(text: c?.telefono ?? '');
    emailController = TextEditingController(text: c?.email ?? '');
    direccionController = TextEditingController(text: c?.direccion ?? '');
    ciudadController = TextEditingController(text: c?.ciudad ?? '');
    estadoController = TextEditingController(text: c?.estado ?? '');
    cpController = TextEditingController(text: c?.codigoPostal ?? '');
    rfcController = TextEditingController(text: c?.rfc ?? '');
    razonSocialController = TextEditingController(text: c?.razonSocial ?? '');
    usoCfdiController = TextEditingController(text: c?.usoCfdi ?? '');
    regimenFiscalController = TextEditingController(
      text: c?.regimenFiscal ?? '',
    );
    super.initState();
  }

  @override
  void dispose() {
    nombreController.dispose();
    apellidoController.dispose();
    telefonoController.dispose();
    emailController.dispose();
    direccionController.dispose();
    ciudadController.dispose();
    estadoController.dispose();
    cpController.dispose();
    rfcController.dispose();
    razonSocialController.dispose();
    usoCfdiController.dispose();
    regimenFiscalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.clienteExistente != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Editar Cliente' : 'Nuevo Cliente')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                CustomTextFormField(
                  label: 'Nombre',
                  controller: nombreController,
                  validator: _required,
                ),
                CustomTextFormField(
                  label: 'Apellido',
                  controller: apellidoController,
                ),
                CustomTextFormField(
                  label: 'Teléfono',
                  controller: telefonoController,
                ),
                CustomTextFormField(
                  label: 'Email',
                  controller: emailController,
                ),
                CustomTextFormField(
                  label: 'Dirección',
                  controller: direccionController,
                ),
                CustomTextFormField(
                  label: 'Ciudad',
                  controller: ciudadController,
                ),
                CustomTextFormField(
                  label: 'Estado',
                  controller: estadoController,
                ),
                CustomTextFormField(
                  label: 'Código Postal',
                  controller: cpController,
                ),
                CustomTextFormField(label: 'RFC', controller: rfcController),
                CustomTextFormField(
                  label: 'Razón Social',
                  controller: razonSocialController,
                ),
                CustomTextFormField(
                  label: 'Uso CFDI',
                  controller: usoCfdiController,
                ),
                CustomTextFormField(
                  label: 'Régimen Fiscal',
                  controller: regimenFiscalController,
                ),
                const SizedBox(height: 20),
                CustomElevatedButton(
                  textButtonText: isEdit ? 'Actualizar' : 'Guardar',
                  onPressed: _guardarCliente,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }
    return null;
  }

  void _guardarCliente() async {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final nuevoCliente = ClienteModel(
      id: widget.clienteExistente?.id,
      uuid_cliente: widget.clienteExistente?.uuid_cliente ?? const Uuid().v4(),
      nombreCompleto: nombreController.text.trim(),
      apellido: apellidoController.text.trim(),
      telefono: telefonoController.text.trim(),
      email: emailController.text.trim(),
      direccion: direccionController.text.trim(),
      ciudad: ciudadController.text.trim(),
      estado: estadoController.text.trim(),
      codigoPostal: cpController.text.trim(),
      rfc: rfcController.text.trim(),
      razonSocial: razonSocialController.text.trim(),
      usoCfdi: usoCfdiController.text.trim(),
      regimenFiscal: regimenFiscalController.text.trim(),
      puntosAcumulados: widget.clienteExistente?.puntosAcumulados ?? 0,
      creadoEn: widget.clienteExistente?.creadoEn ?? now,
      modificadoEn: now,
    );

    final clienteProvider = Provider.of<ClienteProvider>(
      context,
      listen: false,
    );
    if (widget.clienteExistente == null) {
      await clienteProvider.agregarCliente(nuevoCliente);
    } else {
      await clienteProvider.actualizarCliente(nuevoCliente);
    }

    if (context.mounted) Navigator.pop(context);
  }
}
