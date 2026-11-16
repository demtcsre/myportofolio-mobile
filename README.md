# Identitas
- Nama    : Ahmad Rizki Daffaa
- NPM     : 2506543640
- Kelas   : PBP B

## Deskripsi Proyek
Aplikasi mobile berbasis flutter berisi laman portofolio pribadi untuk mata kuliah Pemrograman Berbasis Platform (PBP).

### Tugas 7


#### Progres
- Melanjutkan proyek Flutter `myportofolio_mobile` dari tutorial 8
- Menampilkan informasi identitas diri sendiri menggunakan `InfoCard` 
- Kustomisasi warna `ItemCard`

#### AI Disclosure
Tidak menggunakan AI untuk Tugas Individu 7

#### Pertanyaan Reflektif
1. Widget tree adalah struktur hierarki yang menggambarkan susunan widget dalam aplikasi Flutter. Widget induk (parent) mengatur dan menampung widget anak (child), termasuk tata letak dan tampilannya. Contohnya, `MaterialApp` memiliki `Scaffold`, yang kemudian berisi `AppBar` dan `Column` untuk menyusun komponen halaman.
2. Widget yang digunakan dalam proyek MyPortfolio Mobile meliputi `MaterialApp` untuk konfigurasi aplikasi, `Scaffold` dan `AppBar` untuk struktur halaman, `Text` dan `TextStyle` untuk teks, `Column` dan `Row` untuk tata letak, `Container`, `Card`, dan `Material` untuk tampilan komponen, `Padding`, `SizedBox`, dan `Center` untuk pengaturan jarak serta posisi, `GridView.count` untuk menyusun menu dalam tiga kolom, `Icon` untuk menampilkan ikon, `InkWell` untuk interaksi tombol, `SnackBar` untuk pesan sementara, serta `MediaQuery` untuk menyesuaikan ukuran layar. Selain itu, terdapat widget buatan sendiri, yaitu `InfoCard` untuk menampilkan informasi pengguna dan `ItemCard` untuk menampilkan tombol menu.
3. `MaterialApp` merupakan widget utama yang menyediakan konfigurasi aplikasi berbasis Material Design, seperti judul, tema, warna, dan navigasi. Pada proyek ini, `MaterialApp` mengatur tema melalui `ThemeData` dan `ColorScheme`, serta menentukan `MyHomePage` sebagai halaman awal melalui properti `home`. Widget ini menjadi root widget karena merupakan titik awal struktur aplikasi dan menyediakan konfigurasi bagi widget di bawahnya.
4. `StatelessWidget` adalah widget yang tidak memiliki state internal yang dapat berubah, sedangkan StatefulWidget memiliki state yang dapat diperbarui selama aplikasi berjalan. `StatelessWidget` cocok untuk tampilan statis seperti teks dan kartu informasi, sementara StatefulWidget digunakan untuk komponen interaktif seperti counter dan form. Pada proyek ini, MyApp, MyHomePage, InfoCard, dan ItemCard menggunakan `StatelessWidget` karena tidak mengelola perubahan state internal.
5. `BuildContext` adalah objek yang menunjukkan posisi widget dalam widget tree dan memungkinkan widget mengakses informasi dari lingkungan sekitarnya. Dalam metode `build`, objek ini digunakan untuk mengakses tema, ukuran layar, dan navigasi. Pada proyek ini, `Theme.of(context)` digunakan untuk mengambil warna utama aplikasi, sedangkan `MediaQuery.of(context)` digunakan untuk menyesuaikan lebar kartu berdasarkan ukuran layar.
6. Hot reload memungkinkan perubahan kode diterapkan tanpa menjalankan ulang aplikasi dan tetap mempertahankan state. Sebaliknya, hot restart menjalankan ulang aplikasi dari awal sehingga state sebelumnya hilang. Hot reload cocok untuk perubahan tampilan, sedangkan hot restart diperlukan ketika perubahan membutuhkan inisialisasi ulang aplikasi. Sementara itu, full restart diperlukan untuk perubahan konfigurasi native Android/iOS, dependency tertentu, atau proses build yang tidak dapat diterapkan melalui kedua metode sebelumnya.
