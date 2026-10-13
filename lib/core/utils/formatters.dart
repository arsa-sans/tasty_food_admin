import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static String formatRupiah(num? amount) {
    if (amount == null) return 'Rp 0';
    try {
      return _currencyFormat.format(amount);
    } catch (_) {
      return 'Rp ${amount.toStringAsFixed(0)}';
    }
  }

  static String formatDate(DateTime? date) {
    if (date == null) return '-';
    try {
      return DateFormat('dd MMM yyyy', 'id_ID').format(date);
    } catch (_) {
      try {
        return DateFormat('dd MMM yyyy').format(date);
      } catch (_) {
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      }
    }
  }

  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '-';
    try {
      return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(dateTime);
    } catch (_) {
      try {
        return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
      } catch (_) {
        final d = dateTime;
        return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
      }
    }
  }

  static String formatTime(DateTime? dateTime) {
    if (dateTime == null) return '-';
    try {
      return DateFormat('HH:mm', 'id_ID').format(dateTime);
    } catch (_) {
      try {
        return DateFormat('HH:mm').format(dateTime);
      } catch (_) {
        return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      }
    }
  }

  static DateTime? parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
  }
}
