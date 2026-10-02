import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/receipt_transaction.dart';
import '../services/heuristic_regex_parser.dart';
import '../database/db_helper.dart';

class ReviewTransactionScreen extends StatefulWidget {
  final ParsedReceipt parsed;
  final String imagePath;

  const ReviewTransactionScreen({super.key, required this.parsed, required this.imagePath});

  @override
  State<ReviewTransactionScreen> createState() => _ReviewTransactionScreenState();
}

class _ReviewTransactionScreenState extends State<ReviewTransactionScreen> {
  late TextEditingController _merchantCtrl;
  late TextEditingController _amountCtrl;
  late DateTime _selectedDate;
  String _selectedCategory = 'Thực phẩm';

  final List<String> _categories = ['Thực phẩm', 'Học tập', 'Du lịch', 'Thiết bị', 'Giải trí'];

  @override
  void initState() {
    super.initState();
    _merchantCtrl = TextEditingController(text: widget.parsed.merchant);
    _amountCtrl = TextEditingController(text: widget.parsed.amount.toStringAsFixed(0));
    _selectedDate = widget.parsed.date;
  }

  Future<void> _save() async {
    final double? amount = double.tryParse(_amountCtrl.text);
    if (amount == null) return;

    final tx = ReceiptTransaction(
      merchant: _merchantCtrl.text.trim(),
      amount: amount,
      date: _selectedDate,
      category: _selectedCategory,
      imagePath: widget.imagePath,
    );

    await DBHelper.instance.insert(tx);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Xác nhận thông tin hóa đơn')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh thu nhỏ của biên lai
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(widget.imagePath),
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _merchantCtrl,
              decoration: InputDecoration(
                labelText: 'Tên người bán / Cửa hàng',
                prefixIcon: const Icon(Icons.store),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Tổng tiền (VND)',
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (d != null) setState(() => _selectedDate = d);
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Ngày giao dịch',
                  prefixIcon: const Icon(Icons.calendar_month),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
              ),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Phân loại danh mục',
                prefixIcon: const Icon(Icons.category),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
            ),
            const SizedBox(height: 28),

            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _save,
              child: const Text('Lưu vào chi tiêu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}