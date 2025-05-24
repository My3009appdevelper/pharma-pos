import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class ImagePickerField extends StatelessWidget {
  final String? initialUrl;
  final void Function(String imagePath) onImageSelected;

  const ImagePickerField({
    super.key,
    required this.onImageSelected,
    this.initialUrl,
  });

  Future<void> _pickImage(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: false,
    );

    if (result != null && result.files.single.path != null) {
      onImageSelected(result.files.single.path!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se seleccionó ninguna imagen.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = initialUrl != null && File(initialUrl!).existsSync()
        ? Image.file(File(initialUrl!), height: 100)
        : const Icon(Icons.image, size: 100, color: Colors.grey);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('Imagen del producto'),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _pickImage(context),
          child: Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: image),
          ),
        ),
      ],
    );
  }
}
