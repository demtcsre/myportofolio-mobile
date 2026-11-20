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

### Tugas 8


#### Progres
- Melanjutkan proyek Flutter `myportofolio_mobile` dari tutorial 9
- Menambahkan form experience dan achievement
- Refactor validator extract url agar dapat digunakan banyak form

#### AI Disclosure
Model AI: Claude Code Opus 5 High effort

AI Chat Session Link: https://claude.ai/code/cshk_015m9jBAhkVQ9Vm2p8n3ZZCGTmc9p5UrVUNX3kbuAru7x3

#### Pertanyaan Reflektif
1. Navigator.push() menambah halaman baru di atas stack, sehingga halaman lama masih bisa dituju dengan tombol back. Navigator.pushReplacement() mengganti halaman aktif dengan halaman baru, jadi halaman lama hilang dari stack. Navigator.pop() menutup halaman teratas dan kembali ke halaman di bawahnya. Kartu aksi membuka formulir dengan Navigator.push() (project_card.dart), jadi back dari formulir kembali ke menu. Opsi Home di drawer memakai Navigator.pushReplacement() ke MyHomePage() (left_drawer.dart), sehingga halaman aktif diganti halaman utama dan stack tidak menumpuk.
2. Menu dan ketiga formulir memakai Scaffold dengan susunan yang sama: appBar untuk judul, drawer: const LeftDrawer() untuk navigasi, dan body untuk isi. Karena drawer berasal dari satu widget yang dipakai bersama, menunya selalu sama di setiap halaman dan cukup diubah di satu file. Contoh warna tema adalah indigo: menu memakai Theme.of(context).colorScheme.primary dari seedColor: Colors.indigo di main.dart, sedangkan AppBar dan tombol Simpan di ketiga formulir serta header drawer memakai Colors.indigo.
3. Formulir disusun sebagai Column satu kolom rata kiri di dalam SingleChildScrollView, sehingga field diisi berurutan dari atas ke bawah dan pas di layar HP yang sempit. Padding(EdgeInsets.all(8.0)) di setiap field memberi jarak antarfield dan dari tepi layar. SingleChildScrollView membuat isi bisa digulir saat layar pendek atau tertutup keyboard, sehingga tidak terjadi overflow dan tombol Simpan tetap bisa dijangkau.
4. GlobalKey<FormState> dipasang di Form agar tombol Simpan bisa mengakses state form. Setiap validator mengembalikan null jika nilai valid atau pesan error jika tidak. Saat Simpan ditekan, _formKey.currentState!.validate() menjalankan semua validator. Jika ada yang gagal, error tampil di bawah field dan dialog ringkasan tidak muncul. Contohnya, tautan www.github.com ditolak validateOptionalUrl karena tidak memakai skema http/https. keyboardType: TextInputType.url hanya mengubah tampilan keyboard, sedangkan pengguna tetap bisa mengetik atau menempelkan teks apa pun, jadi validator tetap diperlukan.

#### Penggunaan AI
Membantu membuat rencana pengerjaan Tugas Individu 8 dan mengerjakan rencana tersebut.

#### Perbaikan Manual
Tidak ada