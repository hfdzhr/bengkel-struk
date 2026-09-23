# ADR-0003: Menggunakan Firebase Firestore Tanpa Auth untuk Riwayat Struk & Rekap Bulanan

## Konteks
Aplikasi OtoNota membutuhkan media penyimpanan transaksi struk dan histori omzet bulanan yang:
1. 100% gratis (tanpa biaya hosting bulanan).
2. Memiliki toleransi offline tinggi (bengkel sering mengalami gangguan sinyal/koneksi).
3. Tidak memerlukan manajemen login pengguna (single-tenant / kasir pribadi tanpa ribet auth).

## Keputusan
Menggunakan **Firebase Cloud Firestore**:
- Collection `receipts` menyimpan dokumen transaksi struk langsung dari aplikasi Flutter.
- Mengaktifkan offline-first persistence bawaan Firestore.
- Firestore Security Rules diatur untuk akses open/read-write tanpa Firebase Authentication, meminimalkan kompleksitas alur kerja bengkel.

## Konsekuensi
- **Positif:** 
  - Tidak perlu setup atau deploy server backend (Node.js/Go/Python).
  - Transaksi tetap tersimpan mulus meski printer offline / sinyal HP putus.
  - Kuota gratis Firestore (1 GB storage, 50.000 read/hari, 20.000 write/hari) jauh di atas kebutuhan bengkel harian.
- **Trade-off:**
  - Keamanan mengandalkan obscurity project config (karena tanpa auth), yang mana sangat dapat diterima untuk use-case aplikasi utilitas kasir bengkel pribadi.
