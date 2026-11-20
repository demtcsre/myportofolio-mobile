import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/validators.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

class AchievementFormPage extends StatefulWidget {
  const AchievementFormPage({super.key});

  @override
  State<AchievementFormPage> createState() => _AchievementFormPageState();
}

class _AchievementFormPageState extends State<AchievementFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Field mengikuti model Achievement di Django.
  String _title = "";
  String _organizer = "";
  DateTime? _awardedAt;
  String _certificate = "";

  // Controller untuk menampilkan tanggal hasil showDatePicker() di field.
  final _awardedController = TextEditingController();

  @override
  void dispose() {
    _awardedController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) => date.toIso8601String().substring(0, 10);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Add Achievement Form',
          ),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === Title ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "Judul Pencapaian",
                    labelText: "Judul Pencapaian",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _title = value!;
                    });
                  },
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Judul pencapaian tidak boleh kosong!";
                    }
                    if (value.trim().length > 255) {
                      return "Judul pencapaian maksimal 255 karakter!";
                    }
                    return null;
                  },
                ),
              ),

              // === Organizer ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "Nama penyelenggara (opsional)",
                    labelText: "Penyelenggara",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _organizer = value!;
                    });
                  },
                  validator: (String? value) {
                    if (value != null && value.trim().length > 255) {
                      return "Penyelenggara maksimal 255 karakter!";
                    }
                    return null;
                  },
                ),
              ),

              // === Awarded At ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _awardedController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: "Pilih tanggal diraih",
                    labelText: "Tanggal Diraih",
                    suffixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _awardedAt ?? DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        _awardedAt = picked;
                        _awardedController.text = _formatDate(picked);
                      });
                    }
                  },
                  validator: (String? value) {
                    if (_awardedAt == null) {
                      return "Tanggal diraih tidak boleh kosong!";
                    }
                    return null;
                  },
                ),
              ),

              // === Certificate ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  keyboardType: TextInputType.url,
                  decoration: InputDecoration(
                    hintText: "URL sertifikat (opsional)",
                    labelText: "Tautan Sertifikat",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _certificate = value!;
                    });
                  },
                  validator: validateOptionalUrl,
                ),
              ),

              // === Tombol Simpan ===
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.indigo),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text(
                                  'Pencapaian berhasil ditambahkan!'),
                              content: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // trim() seperti CharField Django.
                                    Text('Judul: ${_title.trim()}'),
                                    Text(
                                        'Penyelenggara: ${_organizer.trim()}'),
                                    Text(
                                        'Tanggal: ${_formatDate(_awardedAt!)}'),
                                    Text(
                                        'Sertifikat: ${_certificate.trim()}'),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  child: const Text('OK'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _formKey.currentState!.reset();
                                    // reset() tidak memanggil onChanged, jadi variabel dikosongkan manual.
                                    setState(() {
                                      _title = "";
                                      _organizer = "";
                                      _awardedAt = null;
                                      _certificate = "";
                                    });
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    child: const Text(
                      "Save",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
