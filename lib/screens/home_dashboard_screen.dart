import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:camera/camera.dart';
import '../models/receipt_transaction.dart';
import '../database/db_helper.dart';
import '../widgets/donut_chart_painter.dart';
import '../widgets/weekly_bar_chart_painter.dart';
import 'receipt_scanner_screen.dart';

class HomeDashboardScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const HomeDashboardScreen({super.key, required this.cameras});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  List<ReceiptTransaction> _txs = [];

  final Map<String, Color> _categoryColors = {
    'Thực phẩm': const Color(0xFFEF5350),
    'Học tập': const Color(0xFF42A5F5),
    'Du lịch': const Color(0xFF66BB6A),
    'Thiết bị': const Color(0xFFFFA726),
    'Giải trí': const Color(0xFFAB47BC),
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final list = await DBHelper.instance.getAllTransactions();
    setState(() => _txs = list);
  }

  Map<String, double> _getCategoryTotals() {
    final map = {'Thực phẩm': 0.0, 'Học tập': 0.0, 'Du lịch': 0.0, 'Thiết bị': 0.0, 'Giải trí': 0.0};
    for (var tx in _txs) {
      if (map.containsKey(tx.category)) {
        map[tx.category] = map[tx.category]! + tx.amount;
      }
    }
    return map;
  }

  List<double> _getWeeklySpending() {
    List<double> weekly = List.filled(7, 0.0);
    final now = DateTime.now();
    for (var tx in _txs) {
      final diff = now.difference(tx.date).inDays;
      if (diff >= 0 && diff < 7) {
        int index = tx.date.weekday - 1; // 0 = T2, 6 = CN
        weekly[index] += tx.amount;
      }
    }
    return weekly;
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final totalSpent = _txs.fold(0.0, (sum, item) => sum + item.amount);
    final categoryTotals = _getCategoryTotals();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Expense & Receipt Tracker', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thẻ tổng tiền chi tiêu
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4F46E5).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tổng chi tiêu', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 6),
                    Text(
                      formatCurrency.format(totalSpent),
                      style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Biểu đồ tròn Donut Chart (CustomPainter)
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Phân bổ theo danh mục', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          SizedBox(
                            height: 120,
                            width: 120,
                            child: CustomPaint(
                              painter: DonutChartPainter(
                                categoryData: categoryTotals,
                                categoryColors: _categoryColors,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              children: _categoryColors.entries.map((e) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2.5),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(color: e.value, shape: BoxShape.circle),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(e.key, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                                      ),
                                      Text(
                                        formatCurrency.format(categoryTotals[e.key] ?? 0),
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Biểu đồ cột chi tiêu theo tuần (CustomPainter)
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Chi tiêu 7 ngày qua (T2 - CN)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 110,
                        width: double.infinity,
                        child: CustomPaint(
                          painter: WeeklyBarChartPainter(weeklySpending: _getWeeklySpending()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Danh sách hóa đơn
              const Text('Biên lai gần đây', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              if (_txs.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Text('Chưa có dữ liệu. Bấm quét để bắt đầu!', style: TextStyle(color: Colors.grey)),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _txs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final tx = _txs[index];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: tx.imagePath != null
                                ? Image.file(File(tx.imagePath!), width: 48, height: 48, fit: BoxFit.cover)
                                : Container(
                                    width: 48,
                                    height: 48,
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.receipt, color: Colors.grey),
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(tx.merchant, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(height: 4),
                                Text(
                                  '${tx.category} • ${DateFormat('dd/MM/yyyy').format(tx.date)}',
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            formatCurrency.format(tx.amount),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent, fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        onPressed: () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ReceiptScannerScreen(cameras: widget.cameras)),
          );
          if (res == true) _loadData();
        },
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Quét hóa đơn'),
      ),
    );
  }
}