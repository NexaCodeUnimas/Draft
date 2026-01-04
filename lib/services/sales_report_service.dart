import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SalesReportService {
  // --- PDF Export ---
  static Future<void> exportPdf(List<QueryDocumentSnapshot> orders, DateTimeRange range) async {
    final pdf = pw.Document();
    double totalSum = orders.fold(0, (prev, doc) => prev + ((doc.data() as Map)['total'] ?? 0));

    pdf.addPage(pw.Page(
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Header(level: 0, text: "Floorbit Sales Summary"),
          pw.Text("Period: ${DateFormat('yyyy-MM-dd').format(range.start)} to ${DateFormat('yyyy-MM-dd').format(range.end)}"),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            data: <List<String>>[
              ['Order ID', 'Date', 'Amount (RM)'],
              ...orders.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final date = (data['timestamp'] as Timestamp).toDate();
                return [doc.id, DateFormat('yyyy-MM-dd HH:mm').format(date), data['total'].toString()];
              }),
              ['', 'TOTAL REVENUE:', 'RM ${totalSum.toStringAsFixed(2)}']
            ],
          ),
        ],
      ),
    ));
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  // --- CSV Export ---
  static Future<void> exportCsv(List<QueryDocumentSnapshot> orders) async {
    List<List<dynamic>> rows = [["Order ID", "Timestamp", "Total Amount"]];

    for (var doc in orders) {
      final data = doc.data() as Map<String, dynamic>;
      rows.add([doc.id, (data['timestamp'] as Timestamp).toDate().toString(), data['total']]);
    }

    String csvData = const ListToCsvConverter().convert(rows);
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/sales_report_${DateTime.now().millisecondsSinceEpoch}.csv');

    await file.writeAsString(csvData);
    await Share.shareXFiles([XFile(file.path)], text: 'Exported Sales Data');
  }
}