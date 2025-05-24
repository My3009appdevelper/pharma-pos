import 'package:flutter/material.dart';

class NavigationRailCategorias extends StatelessWidget {
  final String categoriaSeleccionada;
  final Function(String) onCategoriaSeleccionada;
  final List<String> categorias;

  const NavigationRailCategorias({
    super.key,
    required this.categoriaSeleccionada,
    required this.onCategoriaSeleccionada,
    required this.categorias,
  });

  IconData _obtenerIcono(String nombre) {
    final mapaIconos = {
      'Medicamentos': Icons.medication,
      'Cuidado Personal': Icons.spa,
      'Bebés y Maternidad': Icons.child_friendly,
      'Hogar y Limpieza': Icons.cleaning_services,
      'Alimentos y Bebidas': Icons.fastfood,
      'Vitaminas': Icons.local_pharmacy,
      'Otros': Icons.category,
    };
    return mapaIconos[nombre] ?? Icons.label_outline;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return NavigationRail(
      indicatorColor: colorScheme.primary,
      selectedIndex: categoriaSeleccionada == 'Todas'
          ? 0
          : categorias.indexOf(categoriaSeleccionada) + 1,
      onDestinationSelected: (index) {
        final nombre = index == 0 ? 'Todas' : categorias[index - 1];
        onCategoriaSeleccionada(nombre);
      },
      labelType: NavigationRailLabelType.all,
      backgroundColor: colorScheme.surface,
      selectedIconTheme: IconThemeData(color: colorScheme.onPrimary),
      unselectedIconTheme: IconThemeData(color: colorScheme.primary),
      selectedLabelTextStyle: TextStyle(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelTextStyle: TextStyle(color: colorScheme.onSurface),
      destinations: [
        const NavigationRailDestination(
          icon: Icon(Icons.dashboard),
          label: Text('Todas'),
        ),
        ...categorias.map(
          (c) => NavigationRailDestination(
            icon: Icon(_obtenerIcono(c)),
            label: Text(c),
          ),
        ),
      ],
    );
  }
}
