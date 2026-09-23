# Domain Glossary: OtoNota

Kamus istilah domain untuk aplikasi OtoNota (bengkel kasir & cetak struk).

## Core Concepts

### Transaksi / Struk (Receipt)
Catatan final dari satu sesi layanan bengkel untuk pelanggan.
- **Waktu Transaksi (Timestamp):** Waktu saat struk pertama kali dicetak / disimpan.
- **Identitas Transaksi (Receipt Identifier):** Penanda ringkas waktu + nomor polisi untuk memudahkan verifikasi fisik.
- **Rincian Layanan (Receipt Items):** Daftar item pekerjaan/sparepart, jumlah (qty), dan harga per satuan.
- **Data Kendaraan & Pelanggan (Vehicle & Customer Info):** Nomor plat polisi, jenis motor, dan nama pelanggan (opsional).
- **Total Pembayaran (Amounts):** Total tagihan (subtotal), uang diterima (paid amount), dan uang kembalian (change amount).

### Riwayat Struk (Receipt History)
Kumpulan seluruh transaksi struk yang tersimpan di database cloud (Firestore) dengan cache lokal (offline-first).
- Struk dalam riwayat dapat dicari (filter nomor plat/nama), dilihat rinciannya, dicetak ulang ke printer thermal, atau dihapus jika terjadi kesalahan input kasir.

### Cetak Ulang (Reprint)
Aksi mencetak kembali fisik struk yang sama ke printer thermal Bluetooth. Aksi ini bersifat idempotent: tidak menambah atau menduplikasi catatan transaksi di riwayat/database.

### Ringkasan Bulanan (Monthly Summary / Revenue)
Agregasi data keuangan transaksi dalam rentang satu bulan kalender:
- **Total Omzet:** Penjumlahan seluruh total transaksi struk yang valid pada bulan tersebut.
- **Total Struk / Unit:** Jumlah transaksi servis kendaraan yang tercatat pada bulan tersebut.

### Pengaturan Profil Bengkel (Shop Profile)
Pengaturan nama bengkel yang tersimpan secara lokal dan otomatis tersinkronisasi ke Firestore (`settings/shop_profile`).

