import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CustomerInvoiceService {
  // --- Generate Customer Invoice PDF ---
  static Future<void> printInvoice(DocumentSnapshot orderDoc) async {
    final data = orderDoc.data() as Map<String, dynamic>;
    final pdf = pw.Document();

    final orderDate = (data['timestamp'] as Timestamp).toDate();
    final items = data['items'] as List<dynamic>? ?? [];
    final total = _parsePrice(data['total']);
    final subtotal = _parsePrice(data['subtotal'], fallback: total);
    final tax = _parsePrice(data['tax']);

    // Build items table (async)
    final itemsTable = await _buildItemsTable(items);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildHeader(orderDoc.id),
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildCompanyInfo(),
                _buildCustomerInfo(data),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Invoice Date: ${DateFormat('dd/MM/yyyy').format(orderDate)}'),
                pw.Text('Status: ${_formatStatus(data['status'])}'),
              ],
            ),
            pw.SizedBox(height: 20),
            itemsTable,
            pw.SizedBox(height: 20),
            _buildTotals(subtotal, tax, total),
            pw.Spacer(),
            _buildFooter(),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'invoice_${orderDoc.id}.pdf',
    );
  }

  // --- Safe price parser ---
  static double _parsePrice(dynamic rawPrice, {double fallback = 0.0}) {
    if (rawPrice == null) return fallback;
    if (rawPrice is num) return rawPrice.toDouble();
    if (rawPrice is String) return double.tryParse(rawPrice) ?? fallback;
    return fallback;
  }

  // --- Helper: Build Header ---
  static pw.Widget _buildHeader(String docNumber) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: const pw.BoxDecoration(color: PdfColors.blue900),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'INVOICE',
                style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              ),
              pw.Text(
                '#$docNumber',
                style: const pw.TextStyle(fontSize: 12, color: PdfColors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Helper: Build Company Info ---
  static pw.Widget _buildCompanyInfo() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Floorbit', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 5),
        pw.Text('Lot 1101, 4 Miles, Jalan Penrissen, Everbright Park,', style: const pw.TextStyle(fontSize: 10)),
        pw.Text('Kuching, Sarawak, Malaysia', style: const pw.TextStyle(fontSize: 10)),
        pw.Text('Phone: +60 12-851 1678', style: const pw.TextStyle(fontSize: 10)),
      ],
    );
  }

  // --- Helper: Build Customer Info ---
  static pw.Widget _buildCustomerInfo(Map<String, dynamic> data) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('BILL TO:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
          pw.SizedBox(height: 8),
          pw.Text(data['customerName'] ?? 'Customer', style: const pw.TextStyle(fontSize: 12)),
          if (data['customerEmail'] != null) pw.Text(data['customerEmail'], style: const pw.TextStyle(fontSize: 10)),
          if (data['customerPhone'] != null) pw.Text(data['customerPhone'], style: const pw.TextStyle(fontSize: 10)),
          if (data['deliveryAddress'] != null) pw.Text(data['deliveryAddress'], style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  // --- Helper: Build Items Table ---
  static Future<pw.Widget> _buildItemsTable(List<dynamic> items) async {
    List<List<String>> tableData = [
      ['Item', 'Quantity', 'Unit Price (RM)', 'Total (RM)']
    ];

    for (var item in items) {
      final productId = item['productId'];
      final qty = ((item['quantity'] as num?)?.toInt() ?? 1);
      double price = _parsePrice(item['price']); // read from item if present
      double itemTotal = 0;

      String productName = 'Unknown Product';

      try {
        final doc = await FirebaseFirestore.instance.collection('products').doc(productId).get();
        if (doc.exists) {
          final productData = doc.data() as Map<String, dynamic>?;
          productName = productData?['name'] ?? 'Unknown Product';
          price = _parsePrice(productData?['price'], fallback: price);
        }
      } catch (e) {
        productName = 'Product #$productId';
      }

      itemTotal = qty * price;

      tableData.add([
        productName,
        qty.toString(),
        price.toStringAsFixed(2),
        itemTotal.toStringAsFixed(2),
      ]);
    }

    return pw.Table.fromTextArray(
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
      cellAlignment: pw.Alignment.centerLeft,
      cellPadding: const pw.EdgeInsets.all(8),
      data: tableData,
    );
  }

  // --- Helper: Build Totals ---
  static pw.Widget _buildTotals(double subtotal, double tax, double total) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 220,
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey400),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [pw.Text('Subtotal:'), pw.Text('RM ${subtotal.toStringAsFixed(2)}')],
            ),
            pw.SizedBox(height: 5),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [pw.Text('Tax:'), pw.Text('RM ${tax.toStringAsFixed(2)}')],
            ),
            pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('TOTAL:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                pw.Text('RM ${total.toStringAsFixed(2)}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18, color: PdfColors.blue900)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper: Build Footer ---
  static pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.Divider(),
        pw.Text('Thank you for your business!', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 3),
        pw.Text('For questions, contact us at info@floorbit.com',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey)),
      ],
    );
  }

  // --- Helper: Format Status ---
  static String _formatStatus(dynamic status) {
    if (status == null) return 'Pending';
    return status.toString().toUpperCase();
  }
}
