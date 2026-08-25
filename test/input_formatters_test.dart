import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:belajar_flutter/input_formatters.dart';

String _apply(TextInputFormatter f, String input) => f
    .formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: input))
    .text;

void main() {
  group('PlateInputFormatter', () {
    final f = PlateInputFormatter();

    test('menyisipkan spasi: huruf-digit-huruf', () {
      expect(_apply(f, 'b1234xyz'), 'B 1234 XYZ');
    });

    test('kode wilayah 2 huruf', () {
      expect(_apply(f, 'aa12bc'), 'AA 12 BC');
    });

    test('membatasi digit maksimal 4 dan seri maksimal 3 huruf', () {
      expect(_apply(f, 'd7890efgh'), 'D 7890 EFG');
    });

    test('membuang karakter selain huruf/angka', () {
      expect(_apply(f, 'b 12-34 xyz'), 'B 1234 XYZ');
    });
  });

  group('RupiahInputFormatter', () {
    final f = RupiahInputFormatter();

    test('menambah titik ribuan', () {
      expect(_apply(f, '10000'), '10.000');
      expect(_apply(f, '1234567'), '1.234.567');
    });

    test('angka pendek tidak ditambah titik', () {
      expect(_apply(f, '100'), '100');
    });

    test('membuang angka nol di depan', () {
      expect(_apply(f, '0100'), '100');
    });

    test('input kosong tetap kosong', () {
      expect(_apply(f, ''), '');
    });
  });
}
