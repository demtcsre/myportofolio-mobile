import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/validators.dart';

void main() {
  testWidgets('Tambah Proyek opens the form, and Back returns to menu', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildApp());

    await tester.tap(find.text('Tambah Proyek'));
    await tester.pumpAndSettle();
    expect(find.text('Add Project Form'), findsOneWidget);

    // Form punya drawer, jadi uji tombol Back sistem, bukan tombol back AppBar.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Selamat datang di MyPortfolio Mobile!'), findsOneWidget);
  });

  testWidgets('Form validates required fields and URL, then shows dialog', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.tap(find.text('Tambah Proyek'));
    await tester.pumpAndSettle();

    final save = find.text('Save');
    Future<void> tapSave() async {
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();
    }

    final name = find.widgetWithText(TextFormField, 'Nama Proyek');
    final description = find.widgetWithText(TextFormField, 'Deskripsi Proyek');
    final url = find.widgetWithText(TextFormField, 'Tautan Proyek');

    await tapSave();
    expect(find.text('Nama proyek tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Deskripsi proyek tidak boleh kosong!'), findsOneWidget);

    // Batas max_length model Django: name 255, kicker 100 (spasi di tepi tidak dihitung).
    final kicker = find.widgetWithText(TextFormField, 'Kicker');
    await tester.enterText(name, 'a' * 256);
    await tester.enterText(kicker, 'k' * 101);
    await tapSave();
    expect(find.text('Nama proyek maksimal 255 karakter!'), findsOneWidget);
    expect(find.text('Kicker maksimal 100 karakter!'), findsOneWidget);

    await tester.enterText(kicker, ' ${'k' * 100} ');
    await tester.enterText(name, '  Flag Farm  ');
    await tester.enterText(description, 'Tool for A/D CTF');
    for (final bad in ['not a url', 'ftp://example.com', 'http://a']) {
      await tester.enterText(url, bad);
      await tapSave();
      expect(
        find.text('Tautan harus berupa URL yang valid!'),
        findsOneWidget,
        reason: bad,
      );
    }

    await tester.enterText(url, 'https://github.com/example');
    await tapSave();
    expect(find.text('Proyek berhasil ditambahkan!'), findsOneWidget);
    expect(find.text('Nama Proyek: Flag Farm'), findsOneWidget);

    // OK mengosongkan form; Save lagi harus gagal validasi, bukan memakai nilai lama.
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tapSave();
    expect(find.text('Proyek berhasil ditambahkan!'), findsNothing);
    expect(find.text('Nama proyek tidak boleh kosong!'), findsOneWidget);
  });

  testWidgets('Drawer goes to forms and back Home when logged in', (
    WidgetTester tester,
  ) async {
    // Font test membuat tiap huruf selebar ukuran font, teks DrawerHeader jadi
    // overflow padahal muat di perangkat asli. Abaikan hanya overflow dari
    // left_drawer.dart, overflow di tempat lain tetap membuat test gagal.
    final onError = FlutterError.onError;
    FlutterError.onError = (details) {
      final text = details.toString();
      final isDrawerOverflow =
          text.contains('overflowed') && text.contains('left_drawer.dart');
      if (!isDrawerOverflow) onError!(details);
    };

    try {
      await tester.pumpWidget(buildApp());
      expect(find.text('2506543640'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add Project'));
      await tester.pumpAndSettle();
      expect(find.text('Add Project Form'), findsOneWidget);

      // Drawer yang sama di tiap form membuka form lain.
      for (final (option, title) in [
        ('Add Experience', 'Add Experience Form'),
        ('Add Achievement', 'Add Achievement Form'),
      ]) {
        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();
        await tester.tap(find.text(option));
        await tester.pumpAndSettle();
        expect(find.text(title), findsOneWidget);
      }

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
    } finally {
      FlutterError.onError = onError;
    }
    expect(find.text('Selamat datang di MyPortfolio Mobile!'), findsOneWidget);
    // pushReplacement: form sudah diganti, bukan ditumpuk di bawah menu.
    expect(find.text('Add Project Form'), findsNothing);
    expect(find.text('Add Achievement Form'), findsNothing);
  });

  testWidgets('Experience and Achievement cards open forms, Back returns', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildApp());

    for (final (card, title) in [
      ('Tambah Pengalaman', 'Add Experience Form'),
      ('Tambah Pencapaian', 'Add Achievement Form'),
    ]) {
      await openCard(tester, card);
      expect(find.text(title), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(
        find.text('Selamat datang di MyPortfolio Mobile!'),
        findsOneWidget,
      );
    }
  });

  testWidgets('Experience form validates fields and date order, then dialog', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await openCard(tester, 'Tambah Pengalaman');

    final title = find.widgetWithText(TextFormField, 'Judul Pengalaman');
    final organization = find.widgetWithText(TextFormField, 'Organisasi');
    final description = find.widgetWithText(
      TextFormField,
      'Deskripsi Pengalaman',
    );
    final thumbnail = find.widgetWithText(TextFormField, 'Thumbnail');
    final startedAt = find.widgetWithText(TextFormField, 'Tanggal Mulai');
    final endedAt = find.widgetWithText(TextFormField, 'Tanggal Selesai');

    await tapSave(tester);
    expect(find.text('Judul pengalaman tidak boleh kosong!'), findsOneWidget);
    expect(
      find.text('Deskripsi pengalaman tidak boleh kosong!'),
      findsOneWidget,
    );
    expect(find.text('Tanggal mulai tidak boleh kosong!'), findsOneWidget);

    // Isian yang hanya spasi tetap dianggap kosong.
    await tester.enterText(title, '   ');
    await tapSave(tester);
    expect(find.text('Judul pengalaman tidak boleh kosong!'), findsOneWidget);

    await tester.enterText(title, 'a' * 256);
    await tester.enterText(organization, 'o' * 256);
    await tapSave(tester);
    expect(
      find.text('Judul pengalaman maksimal 255 karakter!'),
      findsOneWidget,
    );
    expect(find.text('Organisasi maksimal 255 karakter!'), findsOneWidget);

    await tester.enterText(title, '  Teaching Assistant  ');
    await tester.enterText(organization, 'Fasilkom UI');
    await tester.enterText(description, 'Asdos PBP');
    await tester.enterText(thumbnail, 'ftp://example.com/a.png');
    await tapSave(tester);
    expect(find.text('Tautan harus berupa URL yang valid!'), findsOneWidget);
    await tester.enterText(thumbnail, 'https://example.com/a.png');

    // Kategori dari dropdown (EXPERIENCE_CHOICES).
    await tester.ensureVisible(find.text('Full-time'));
    await tester.tap(find.text('Full-time'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Part-time').last);
    await tester.pumpAndSettle();

    // Tanggal selesai sebelum tanggal mulai ditolak.
    await pickDay(tester, startedAt, 20);
    await pickDay(tester, endedAt, 10);
    await tapSave(tester);
    expect(
      find.text('Tanggal selesai tidak boleh sebelum tanggal mulai!'),
      findsOneWidget,
    );

    // Tombol hapus mengosongkan tanggal selesai: pengalaman masih berjalan.
    await tester.tap(find.byTooltip('Hapus tanggal selesai'));
    await tester.pumpAndSettle();
    await tapSave(tester);
    expect(find.text('Pengalaman berhasil ditambahkan!'), findsOneWidget);
    expect(find.text('Selesai: Masih berjalan'), findsOneWidget);
    // Tutup dialog lewat barrier agar isian tidak di-reset.
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    await pickDay(tester, endedAt, 25);
    await tapSave(tester);
    expect(find.text('Judul: Teaching Assistant'), findsOneWidget);
    expect(find.text('Kategori: Part-time'), findsOneWidget);
    expect(find.text('Mulai: ${dayOfThisMonth(20)}'), findsOneWidget);
    expect(find.text('Selesai: ${dayOfThisMonth(25)}'), findsOneWidget);

    // OK mengosongkan form termasuk tanggal dan kategori.
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text(dayOfThisMonth(20)), findsNothing);
    expect(find.text('Full-time'), findsOneWidget);
    await tapSave(tester);
    expect(find.text('Pengalaman berhasil ditambahkan!'), findsNothing);
    expect(find.text('Tanggal mulai tidak boleh kosong!'), findsOneWidget);
  });

  testWidgets('Achievement form validates fields, then shows dialog', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await openCard(tester, 'Tambah Pencapaian');

    final title = find.widgetWithText(TextFormField, 'Judul Pencapaian');
    final organizer = find.widgetWithText(TextFormField, 'Penyelenggara');
    final certificate = find.widgetWithText(TextFormField, 'Tautan Sertifikat');

    await tester.enterText(title, '   ');
    await tapSave(tester);
    expect(find.text('Judul pencapaian tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Tanggal diraih tidak boleh kosong!'), findsOneWidget);

    await tester.enterText(title, 'a' * 256);
    await tester.enterText(organizer, 'o' * 256);
    await tapSave(tester);
    expect(
      find.text('Judul pencapaian maksimal 255 karakter!'),
      findsOneWidget,
    );
    expect(find.text('Penyelenggara maksimal 255 karakter!'), findsOneWidget);

    await tester.enterText(title, ' Juara 1 CTF ');
    await tester.enterText(organizer, 'CSUI');
    await tester.enterText(certificate, 'not a url');
    await pickDay(
      tester,
      find.widgetWithText(TextFormField, 'Tanggal Diraih'),
      15,
    );
    await tapSave(tester);
    expect(find.text('Tautan harus berupa URL yang valid!'), findsOneWidget);

    await tester.enterText(certificate, 'https://example.com/cert.pdf');
    await tapSave(tester);
    expect(find.text('Pencapaian berhasil ditambahkan!'), findsOneWidget);
    expect(find.text('Judul: Juara 1 CTF'), findsOneWidget);
    expect(find.text('Tanggal: ${dayOfThisMonth(15)}'), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tapSave(tester);
    expect(find.text('Pencapaian berhasil ditambahkan!'), findsNothing);
    expect(find.text('Tanggal diraih tidak boleh kosong!'), findsOneWidget);
  });

  testWidgets('Add Project asks for login first, then opens the form', (
    WidgetTester tester,
  ) async {
    final log = <http.Request>[];
    await tester.pumpWidget(buildApp(token: null, log: log));

    await openCard(tester, 'Tambah Proyek');
    expect(find.text('Add Project Form'), findsNothing);
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Username'),
      'owner',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'secret',
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();
    expect(find.text('Add Project Form'), findsOneWidget);
    expect(jsonDecode(log.single.body), {
      'username': 'owner',
      'password': 'secret',
    });
  });

  testWidgets('Wrong password stays on login and shows the status code', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildApp(token: null, loginStatus: 400));
    await openCard(tester, 'Tambah Proyek');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Username'),
      'owner',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'wrong',
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();
    expect(find.text('Login gagal (400).'), findsOneWidget);
    expect(find.text('Add Project Form'), findsNothing);
  });

  testWidgets('Lihat Proyek lists projects from the API and opens detail', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildApp(token: null));
    await openCard(tester, 'Lihat Proyek');
    expect(find.text('Flag Farm'), findsOneWidget);

    await tester.tap(find.text('Flag Farm'));
    await tester.pumpAndSettle();
    expect(find.text('A/D CTF tool'), findsOneWidget);
    expect(find.text('Tautan: https://github.com/example'), findsOneWidget);
  });

  testWidgets('Project list shows empty message', (WidgetTester tester) async {
    await tester.pumpWidget(buildApp(projects: []));
    await openCard(tester, 'Lihat Proyek');
    expect(find.text('No projects found.'), findsOneWidget);
  });

  testWidgets('Project list shows retry when the API fails', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildApp(listStatus: 500));
    await openCard(tester, 'Lihat Proyek');
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('Save sends the project with the token, revoked token logs out', (
    WidgetTester tester,
  ) async {
    final log = <http.Request>[];
    await tester.pumpWidget(buildApp(log: log, createStatus: 403));
    await openCard(tester, 'Tambah Proyek');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nama Proyek'),
      ' Flag Farm ',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Deskripsi Proyek'),
      'Tool',
    );
    await tapSave(tester);

    final post = log.first;
    expect(post.headers['Authorization'], 'Token test-token');
    expect(jsonDecode(post.body)['name'], 'Flag Farm');
    expect((jsonDecode(post.body) as Map).containsKey('id'), isFalse);
    // Token ditolak: aplikasi logout lalu membuka layar login.
    expect(log.last.url.path, '/api/v1/auth/logout/');
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
  });

  testWidgets('Logout card revokes the token and login is required again', (
    WidgetTester tester,
  ) async {
    final log = <http.Request>[];
    await tester.pumpWidget(buildApp(log: log));
    await tester.ensureVisible(find.text('Logout'));
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();
    expect(find.text('Berhasil logout.'), findsOneWidget);
    expect(log.single.url.path, '/api/v1/auth/logout/');
    expect(log.single.headers['Authorization'], 'Token test-token');

    // Token sudah hilang, jadi Tambah Proyek kembali meminta login.
    await openCard(tester, 'Tambah Proyek');
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
  });

  test('Project JSON maps snake_case and skips id when sending', () {
    final project = Project.fromJson({
      'id': 'abc',
      'name': 'A',
      'description': 'B',
      'kicker': null,
      'star_count': 3,
    });
    expect(project.id, 'abc');
    expect(project.kicker, '');
    expect(project.toJson(), {
      'name': 'A',
      'kicker': '',
      'url': '',
      'description': 'B',
      'order': 0,
    });
  });

  test('validateOptionalUrl accepts empty and valid http(s) URLs only', () {
    for (final ok in [
      null,
      '',
      '  ',
      'https://a.com',
      'http://localhost:8000',
      'http://[::1]/',
    ]) {
      expect(validateOptionalUrl(ok), isNull, reason: ok);
    }
    for (final bad in ['a.com', 'ftp://a.com', 'http://a', 'https://']) {
      expect(validateOptionalUrl(bad), isNotNull, reason: bad);
    }
  });
}

// Kartu bisa berada di bawah layar, jadi gulir dulu sebelum ditekan.
Future<void> openCard(WidgetTester tester, String name) async {
  await tester.ensureVisible(find.text(name));
  await tester.tap(find.text(name));
  await tester.pumpAndSettle();
  // Timer SnackBar (4 detik) baru jalan setelah animasinya selesai; tunggu
  // sampai hilang agar tidak menutupi tombol Save.
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
  expect(find.byType(SnackBar), findsNothing);
}

Future<void> tapSave(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Save'));
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
}

// Date picker terbuka di bulan berjalan, jadi cukup pilih nomor hari.
Future<void> pickDay(WidgetTester tester, Finder field, int day) async {
  await tester.ensureVisible(field);
  await tester.tap(field);
  await tester.pumpAndSettle();
  await tester.tap(find.text('$day'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

String dayOfThisMonth(int day) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, day).toIso8601String().substring(0, 10);
}

// Backend palsu agar test tidak butuh server Django yang berjalan.
Widget buildApp({
  String? token = 'test-token',
  List<http.Request>? log,
  List<Map<String, dynamic>>? projects,
  int listStatus = 200,
  int createStatus = 201,
  int loginStatus = 200,
}) {
  final client = MockClient((request) async {
    final path = request.url.path;
    if (request.method == 'GET' && path == '/api/v1/projects/') {
      return http.Response(
        jsonEncode(
          projects ??
              [
                {
                  'id': '1',
                  'name': 'Flag Farm',
                  'kicker': 'CTF',
                  'url': 'https://github.com/example',
                  'description': 'A/D CTF tool',
                  'order': 0,
                  'star_count': 0,
                },
              ],
        ),
        listStatus,
      );
    }
    log?.add(request);
    if (path == '/api/v1/projects/') {
      if (createStatus == 403) {
        return http.Response('{"detail":"Invalid token."}', 403);
      }
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      return http.Response(jsonEncode({...body, 'id': 'new'}), createStatus);
    }
    if (path == '/api/v1/auth/token/') {
      return http.Response(jsonEncode({'token': 'new-token'}), loginStatus);
    }
    if (path == '/api/v1/auth/logout/') return http.Response('', 204);
    return http.Response('not found', 404);
  });
  return MyApp(
    apiClient: ApiClient(client: client),
    initialToken: token,
  );
}
