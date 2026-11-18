import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/main.dart' as app;

void main() {
  testWidgets('Tambah Proyek opens the form, and Back returns to menu',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Tambah Proyek'));
    await tester.pumpAndSettle();
    expect(find.text('Add Project Form'), findsOneWidget);

    // Form punya drawer, jadi uji tombol Back sistem, bukan tombol back AppBar.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Selamat datang di MyPortfolio Mobile!'), findsOneWidget);
  });

  testWidgets('Form validates required fields and URL, then shows dialog',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
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
      expect(find.text('Tautan harus berupa URL yang valid!'), findsOneWidget,
          reason: bad);
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

  testWidgets('main() starts the app, drawer goes to form and back Home',
      (WidgetTester tester) async {
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
      app.main();
      await tester.pumpAndSettle();
      expect(find.text('2506543640'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add Project'));
      await tester.pumpAndSettle();
      expect(find.text('Add Project Form'), findsOneWidget);

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
  });
}
