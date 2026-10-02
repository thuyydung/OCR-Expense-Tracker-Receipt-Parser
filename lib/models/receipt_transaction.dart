class ReceiptTransaction {
  final int? id;
  final String merchant;
  final double amount;
  final DateTime date;
  final String category;
  final String? imagePath;

  ReceiptTransaction({
    this.id,
    required this.merchant,
    required this.amount,
    required this.date,
    required this.category,
    this.imagePath,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'merchant': merchant,
        'amount': amount,
        'date': date.toIso8601String(),
        'category': category,
        'imagePath': imagePath,
      };

  factory ReceiptTransaction.fromMap(Map<String, dynamic> map) => ReceiptTransaction(
        id: map['id'],
        merchant: map['merchant'] ?? '',
        amount: (map['amount'] as num).toDouble(),
        date: DateTime.parse(map['date']),
        category: map['category'] ?? 'Thực phẩm',
        imagePath: map['imagePath'],
      );
}