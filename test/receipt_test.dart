import 'package:flutter_test/flutter_test.dart';

import 'package:bengkel_struk/printer_service.dart';

void main() {
  test('uang: format rupiah', () {
    expect(PrinterService.uang(115000), 'Rp 115.000');
    expect(PrinterService.uang(0), 'Rp 0');
    expect(PrinterService.uang(-5000), '-Rp 5.000');
  });

  test('row: rata kanan, muat 32 kolom', () {
    final r = PrinterService.row('2x Tambal Ban', 'Rp 20.000');
    expect(r.length, 32);
    expect(r.startsWith('2x Tambal Ban'), isTrue);
    expect(r.endsWith('Rp 20.000'), isTrue);
  });

  test('row: nama panjang terpotong agar total tetap pas', () {
    const name = '1x Servis Berat Mesin Sangat Panjang Sekali Lipat';
    final r = PrinterService.row(name, 'Rp 150.000');
    expect(r.length, lessThanOrEqualTo(32));
    expect(r.endsWith('Rp 150.000'), isTrue);
  });
}
