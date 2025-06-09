import 'package:pdf/widgets.dart' as pw;
import 'package:pos_farmacia/core/models/cliente_model.dart';
import 'package:pos_farmacia/core/models/venta_detalle_model.dart';
import 'package:pos_farmacia/core/models/venta_model.dart';
import 'package:printing/printing.dart';

Future<void> generarTicketPDF(
  VentaModel venta,
  List<DetalleVentaModel> detalles,
  ClienteModel? cliente,
) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (context) => pw.Column(
        children: [
          pw.Text("Farmacia POS", style: pw.TextStyle(fontSize: 20)),
          pw.Text("Folio: ${venta.folio}"),
          pw.Text("Fecha: ${venta.fecha}"),
          pw.SizedBox(height: 10),
          if (cliente != null) pw.Text("Cliente: ${cliente.nombreCompleto}"),
          pw.SizedBox(height: 10),
          pw.Text("Productos:"),
          ...detalles.map(
            (d) => pw.Text(
              "• ${d.cantidad} x \$${d.precioUnitario} = \$${d.total}",
            ),
          ),
          pw.Divider(),
          pw.Text("Total: \$${venta.total}"),
        ],
      ),
    ),
  );

  await Printing.layoutPdf(onLayout: (format) => pdf.save());
}
