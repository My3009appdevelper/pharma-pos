import 'package:flutter/material.dart';

class CustomScrollDataTable extends StatelessWidget {
  final ScrollController verticalController;
  final ScrollController horizontalController;
  final DataTable dataTable;

  const CustomScrollDataTable({
    super.key,
    required this.verticalController,
    required this.horizontalController,
    required this.dataTable,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        return Stack(
          children: [
            ScrollConfiguration(
              behavior: ScrollConfiguration.of(
                context,
              ).copyWith(scrollbars: false),
              child: Scrollbar(
                controller: verticalController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: verticalController,
                  scrollDirection: Axis.vertical,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: 20,
                    ), // espacio para el scrollbar horizontal
                    child: SingleChildScrollView(
                      controller: horizontalController,
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: 1000),
                        child: dataTable,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Scrollbar horizontal fija en la parte inferior visible
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Scrollbar(
                controller: horizontalController,
                thumbVisibility: true,
                scrollbarOrientation: ScrollbarOrientation.bottom,
                child: SingleChildScrollView(
                  controller: horizontalController,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: 1000,
                    height: 0,
                  ), // solo para activar scrollbar horizontal
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
