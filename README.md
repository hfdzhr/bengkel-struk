# OtoNota

Aplikasi kasir sederhana untuk bengkel motor pribadi. Dibuat untuk kebutuhan sendiri: catat layanan, cetak struk ke printer thermal Bluetooth, selesai — tanpa ribet.

Ini adalah project pribadi (personal project) untuk kebutuhan bengkel sehari-hari.

## Latar belakang

Bengkel motor kecil biasanya cuma butuh: tulis layanan apa saja, hitung total, cetak struk buat pelanggan. Aplikasi POS di pasaran kebanyakan kebanyakan fitur (stok, laporan, multi-cabang, dll) untuk kebutuhan sekecil ini. OtoNota sengaja dibuat minim langkah:

- Buka app → langsung di layar "Buat Struk", nol langkah tambahan.
- Font besar & tombol besar supaya nyaman dipakai orang yang tidak terbiasa HP (termasuk lansia).
- Printer Bluetooth otomatis tersambung saat app dibuka, sehingga tinggal tekan **CETAK**.

## Fitur

- **Katalog layanan** — grid tombol layanan (Ganti Oli, Servis Rutin, Tambal Ban, dll) dengan harga, tekan untuk menambah ke struk. Tekan-lama untuk edit/hapus, tambah baru lewat "Tulis Manual".
- **Keranjang & kembalian** — atur jumlah per item, hitung total otomatis, dan ada kalkulator kembalian setelah struk tercetak.
- **Data pelanggan opsional** — nama pelanggan, plat nomor (auto uppercase & format), jenis motor.
- **Cetak ke printer thermal Bluetooth** — layout 32 kolom (kertas 58mm), header nama bengkel, tanggal/jam, rincian item, total, lalu potong kertas.
- **Auto-connect & retry** — saat app dibuka, otomatis coba sambung ke printer yang tersimpan. Saat mencetak, otomatis disconnect→connect ulang dan retry hingga 3x kalau gagal (koneksi Bluetooth classic ke printer thermal gampang putus diam-diam saat idle).
- **Cetak ulang** — dari layar sukses, bisa cetak ulang struk yang sama tanpa mengulang input.
- **Pengaturan printer** — cari perangkat Bluetooth yang sudah di-pair, pilih printer, simpan sebagai default, dan cetak tes.
- **Penyimpanan lokal** — katalog layanan, nama bengkel, dan printer pilihan disimpan di perangkat (`shared_preferences`), tidak butuh server/internet.

## Teknologi

- [Flutter](https://flutter.dev/) (SDK `^3.12.2`), target utama Android.
- [`print_bluetooth_thermal`](https://pub.dev/packages/print_bluetooth_thermal) — komunikasi ke printer thermal via Bluetooth classic (SPP/RFCOMM).
- [`permission_handler`](https://pub.dev/packages/permission_handler) — izin runtime `BLUETOOTH_CONNECT` & `BLUETOOTH_SCAN` (Android 12+).
- [`shared_preferences`](https://pub.dev/packages/shared_preferences) — penyimpanan lokal.

Printer yang jadi acuan pengembangan: **Xantri BT-58D** (thermal 58mm, tanpa auto-cutter). Beberapa perilaku plugin di atas ternyata punya bug/gotcha di sisi native Android — sudah didokumentasikan di `docs/adr/`:

- [ADR-0001](docs/adr/0001-printer-disconnect-before-reconnect.md) — kenapa selalu `disconnect()` sebelum `connect()`, dan kenapa setiap panggilan native dibungkus timeout.
- [ADR-0002](docs/adr/0002-request-bluetooth-scan-permission.md) — kenapa izin `BLUETOOTH_SCAN` wajib diminta juga, bukan cuma `BLUETOOTH_CONNECT`.

## Menjalankan project

Pastikan Flutter SDK sudah terpasang ([panduan instalasi](https://docs.flutter.dev/get-started/install)), lalu:

```bash
flutter pub get
flutter run
```

Untuk mencetak struk sungguhan, jalankan di HP Android fisik (bukan emulator) yang sudah pairing dengan printer thermal Bluetooth di Setelan HP terlebih dahulu — aplikasi hanya membaca perangkat yang sudah ter-pair, tidak melakukan scan sendiri.

Menjalankan test:

```bash
flutter test
```

## Struktur project

```
lib/
  main.dart               # entry point, tema (font besar, warna)
  home_screen.dart         # layar utama: pilih layanan, keranjang, cetak
  printer_screen.dart      # pengaturan: nama bengkel, pilih/tes printer
  printer_service.dart     # komunikasi Bluetooth, format struk, retry logic
  store.dart               # model data & penyimpanan lokal (SharedPreferences)
  input_formatters.dart    # formatter input (Rupiah, plat nomor)
docs/
  adr/                      # catatan keputusan teknis (Architecture Decision Records)
  agents/                   # panduan kerja untuk AI coding agent di repo ini
```

## Catatan pengembangan

Repo ini dikerjakan dengan bantuan AI coding agent, dengan konvensi kerja yang didefinisikan di `CLAUDE.md`/`AGENTS.md`:

- **Issue tracker** — catatan pekerjaan/fitur di `.scratch/<fitur>/` (lihat `docs/agents/issue-tracker.md`).
- **Domain docs** — keputusan desain & konteks domain di `docs/adr/` (lihat `docs/agents/domain.md`).
