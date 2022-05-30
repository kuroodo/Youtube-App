import 'package:intl/intl.dart';

class FormatStringNumber {
  static String compact(String number) {
    return _format(number, NumberFormat.compact());
  }

  static String withCommas(String number) {
    return _format(number, NumberFormat.decimalPattern('en_us'));
  }

  static String _format(String number, NumberFormat format) {
    int? intNumber = int.tryParse(number);

    if (intNumber == null) {
      return number;
    }

    return format.format(intNumber);
  }
}
