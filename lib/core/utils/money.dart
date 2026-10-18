/// Formats integer VND the way the Figma mockups do: `143.100đ`.
String formatVnd(int amount, {bool symbol = true}) {
  final negative = amount < 0;
  final digits = amount.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    buf.write(digits[i]);
    final fromEnd = digits.length - i;
    if (fromEnd > 1 && fromEnd % 3 == 1) buf.write('.');
  }
  return '${negative ? '-' : ''}$buf${symbol ? 'đ' : ''}';
}
