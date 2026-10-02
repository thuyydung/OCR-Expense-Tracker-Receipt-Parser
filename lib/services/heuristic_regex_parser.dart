class ParsedReceipt {
  final String merchant;
  final double amount;
  final DateTime date;

  ParsedReceipt({required this.merchant, required this.amount, required this.date});
}

class HeuristicRegexParser {
  static ParsedReceipt parse(String text) {
    final lines = text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    // 1. Phỏng đoán Merchant: lấy các dòng đầu tiên không phải tiêu đề
    String merchant = "Cửa hàng tiện lợi";
    for (int i = 0; i < lines.length && i < 4; i++) {
      final line = lines[i];
      final upper = line.toUpperCase();
      if (!upper.contains("HÓA ĐƠN") &&
          !upper.contains("RECEIPT") &&
          !upper.contains("PHIẾU") &&
          !upper.contains("VAT") &&
          line.length >= 3) {
        merchant = line;
        break;
      }
    }

    // 2. Regex Ngày tháng: DD/MM/YYYY hoặc DD-MM-YYYY
    DateTime date = DateTime.now();
    final dateRegex = RegExp(r'\b(\d{1,2})[\/\.-](\d{1,2})[\/\.-](\d{2,4})\b');
    for (final line in lines) {
      final match = dateRegex.firstMatch(line);
      if (match != null) {
        try {
          int d = int.parse(match.group(1)!);
          int m = int.parse(match.group(2)!);
          int y = int.parse(match.group(3)!);
          if (y < 100) y += 2000;
          date = DateTime(y, m, d);
          break;
        } catch (_) {}
      }
    }

    // 3. Regex Tổng số tiền (tìm số có phân cách nghìn hoặc dạng tiền tệ VND)
    final moneyRegex = RegExp(r'(?:[\d]{1,3}(?:[.,]\d{3})+|\d{4,9})');
    double maxAmount = 0.0;

    for (final line in lines) {
      for (final match in moneyRegex.allMatches(line)) {
        String raw = match.group(0)!;
        String cleanNum = raw.replaceAll('.', '').replaceAll(',', '');
        double? val = double.tryParse(cleanNum);
        if (val != null && val > maxAmount && val < 500000000) {
          maxAmount = val;
        }
      }
    }

    return ParsedReceipt(merchant: merchant, amount: maxAmount, date: date);
  }
}