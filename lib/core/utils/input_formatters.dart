import 'package:flutter/services.dart';

/// Format otomatis mengikuti pola plat nomor Indonesia: HURUF DIGIT HURUF
/// (contoh: "B 1234 XYZ"). Maksimal 2 huruf kode wilayah, 4 digit nomor,
/// 3 huruf seri. Selalu huruf besar.
class PlateInputFormatter extends TextInputFormatter {
  static final _letter = RegExp('[A-Z]');
  static final _digit = RegExp('[0-9]');

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final raw = newValue.text
        .toUpperCase()
        .replaceAll(RegExp('[^A-Z0-9]'), '');
    final buffer = StringBuffer();
    var i = 0;

    var n = 0;
    while (i < raw.length && n < 2 && _letter.hasMatch(raw[i])) {
      buffer.write(raw[i]);
      i++;
      n++;
    }
    if (i < raw.length && _digit.hasMatch(raw[i])) {
      buffer.write(' ');
      n = 0;
      while (i < raw.length && n < 4 && _digit.hasMatch(raw[i])) {
        buffer.write(raw[i]);
        i++;
        n++;
      }
    }
    if (i < raw.length && _letter.hasMatch(raw[i])) {
      buffer.write(' ');
      n = 0;
      while (i < raw.length && n < 3 && _letter.hasMatch(raw[i])) {
        buffer.write(raw[i]);
        i++;
        n++;
      }
    }

    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Format angka jadi gaya rupiah dengan pemisah ribuan titik saat mengetik
/// (contoh: "10000" -> "10.000"). Hasil parsing tetap angka murni, tinggal
/// buang titiknya (lihat `PrinterService.uang` untuk pola yang sama).
class RupiahInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var digits = newValue.text.replaceAll(RegExp('[^0-9]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(text: '');
    }
    digits = digits.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    final text = digits.replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
