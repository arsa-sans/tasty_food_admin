# DESIGN DIRECTION: Tasty Merchant Command

> Desain sistem operasional merchant Tasty Food yang terang, elegan, dan fungsional.
> Diadaptasi dari referensi desain Google Stitch: Tasty Food Admin Dashboard.

## 1. Identitas & Karakter
- **Produk**: Dashboard Manajemen Operasional Tasty Food (Mobile Admin)
- **Target Pengguna**: Pemilik restoran, manajer operasional, dan staf dapur
- **Karakter Visual**: Terang, bersih, elegan, dan hidup dengan sentuhan hangat khas kuliner
- **Prinsip Utama**: Keterbacaan data tinggi, aksi cepat satu jempol, dan umpan balik taktil yang halus

## 2. Antislop Dials
- **ENERGY: 2** (Fokus operasional seimbang dengan aksen hangat oranye kuliner)
- **RHYTHM: 3** (Komposisi bervariasi: banner ringkasan, kartu triase prioritas, grid kartu mini, dan list tiket terstruktur)
- **MOTION: 2** (Animasi interaktif bermakna: umpan balik tekan pegas/taktil, hitungan angka bergulir, denyut lembut pada status darurat, dan transisi halus)

## 3. Palet Warna (Light & Elegant)
- **Background Canvas**: `#F8FAFC` (Slate-50, dasar bersih anti-silau)
- **Surface / Card**: `#FFFFFF` (Putih murni dengan pembatas halus `1px #E2E8F0`)
- **Primary Accent**: `#F97316` (Culinary Vivid Orange: untuk tombol aksi utama, tab aktif, dan status penting)
- **Secondary / Headings**: `#1E293B` (Dark Navy Slate: untuk judul tebal dan angka kunci)
- **Text Body**: `#0F172A` (Slate-900: kontras tinggi memenuhi standar WCAG AA 4.5:1+)
- **Text Secondary**: `#475569` (Slate-600)
- **Text Muted**: `#94A3B8` (Slate-400)
- **Success**: `#10B981` (Teks `#047857`, Latar `#ECFDF5` untuk pesanan selesai dan toko buka)
- **Warning / Pending**: `#F59E0B` (Teks `#B45309`, Latar `#FFFBEB` untuk pesanan menunggu konfirmasi)
- **Info / Delivery**: `#0284C7` (Teks `#0369A1`, Latar `#F0F9FF` untuk pengiriman)
- **Danger**: `#EF4444` (Teks `#B91C1C`, Latar `#FEF2F2` untuk pembatalan dan alert)

## 4. Tipografi
- **Font Family**: Plus Jakarta Sans (Google Fonts)
- **Display & Headline**: Bobot 700 / 800 dengan tracking rapat (-0.02em) untuk keterbacaan angka instan
- **Body & Label**: Bobot 400, 500, dan 600 dengan ruang karakter terbuka untuk membaca catatan pesanan dengan jelas

## 5. Sistem Bentuk & Elevasi
- **Sudut Lengkung (Radius)**:
  - Tombol & input: 12px (`RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))`)
  - Kartu & banner: 16px
  - Modal dialog: 20px
  - Status pill / badge: 24px (Pill shape fungsional)
- **Elevasi**:
  - Datar dasar: Lapisan Level 0 (`#F8FAFC`)
  - Kartu Level 1: Permukaan `#FFFFFF` dengan batas `1px #E2E8F0` dan bayangan lembut `0px 2px 8px -2px rgba(30, 41, 59, 0.04)`
  - Kartu Aktif/Triase: Aksen batas oranye hangat dengan cahaya halus saat perlu perhatian segera

## 6. Animasi & Interaksi Hidup
- **AnimatedPressable**: Efek tekan taktil (skala turun ke 0.97 dengan kurva pegas saat ditekan, kembali halus saat dilepas)
- **AnimatedCounter**: Angka metrik berputar naik secara halus dari nol saat halaman dimuat
- **PulsingDot / BreathingBadge**: Indikator denyut lembut pada tiket pesanan darurat (menunggu konfirmasi) agar mata kasir/koki langsung tertuju
- **StaggeredEntrance**: Masuknya daftar kartu dengan jeda offset vertikal dan opacity yang bertahap
