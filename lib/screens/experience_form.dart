import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/validators.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

class ExperienceFormPage extends StatefulWidget {
  const ExperienceFormPage({super.key});

  @override
  State<ExperienceFormPage> createState() => _ExperienceFormPageState();
}

class _ExperienceFormPageState extends State<ExperienceFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Sama dengan EXPERIENCE_CHOICES di model Experience Django.
  static const Map<String, String> _categories = {
    'full-time': 'Full-time',
    'part-time': 'Part-time',
    'self-employed': 'Self-employed',
    'freelance': 'Freelance',
    'contract': 'Contract',
    'internship': 'Internship',
    'apprenticeship': 'Apprenticeship',
    'seasonal': 'Seasonal',
  };

  // Field mengikuti model Experience di Django.
  String _title = "";
  String _organization = "";
  String _description = "";
  String _category = 'full-time';
  String _thumbnail = "";
  DateTime? _startedAt;
  DateTime? _endedAt;

  // Controller untuk menampilkan tanggal hasil showDatePicker() di field.
  final _startedController = TextEditingController();
  final _endedController = TextEditingController();

  @override
  void dispose() {
    _startedController.dispose();
    _endedController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) => date.toIso8601String().substring(0, 10);

  Future<DateTime?> _pickDate(DateTime? initial) {
    return showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Add Experience Form')),
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
                    hintText: "Judul Pengalaman",
                    labelText: "Judul Pengalaman",
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
                      return "Judul pengalaman tidak boleh kosong!";
                    }
                    if (value.trim().length > 255) {
                      return "Judul pengalaman maksimal 255 karakter!";
                    }
                    return null;
                  },
                ),
              ),

              // === Organization ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "Nama organisasi (opsional)",
                    labelText: "Organisasi",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _organization = value!;
                    });
                  },
                  validator: (String? value) {
                    if (value != null && value.trim().length > 255) {
                      return "Organisasi maksimal 255 karakter!";
                    }
                    return null;
                  },
                ),
              ),

              // === Description ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: "Deskripsi Pengalaman",
                    labelText: "Deskripsi Pengalaman",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _description = value!;
                    });
                  },
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Deskripsi pengalaman tidak boleh kosong!";
                    }
                    return null;
                  },
                ),
              ),

              // === Category ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Kategori",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  initialValue: _category,
                  items: _categories.entries
                      .map(
                        (entry) => DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        ),
                      )
                      .toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _category = newValue!;
                    });
                  },
                ),
              ),

              // === Thumbnail ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  keyboardType: TextInputType.url,
                  decoration: InputDecoration(
                    hintText: "URL gambar (opsional)",
                    labelText: "Thumbnail",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _thumbnail = value!;
                    });
                  },
                  validator: validateOptionalUrl,
                ),
              ),

              // === Started At ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _startedController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: "Pilih tanggal mulai",
                    labelText: "Tanggal Mulai",
                    suffixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onTap: () async {
                    final picked = await _pickDate(_startedAt);
                    if (picked != null) {
                      setState(() {
                        _startedAt = picked;
                        _startedController.text = _formatDate(picked);
                      });
                    }
                  },
                  validator: (String? value) {
                    if (_startedAt == null) {
                      return "Tanggal mulai tidak boleh kosong!";
                    }
                    return null;
                  },
                ),
              ),

              // === Ended At ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _endedController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: "Kosongkan jika masih berjalan",
                    labelText: "Tanggal Selesai",
                    // Tanggal selesai opsional, jadi sediakan tombol hapus.
                    suffixIcon: _endedAt == null
                        ? const Icon(Icons.calendar_today)
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            tooltip: 'Hapus tanggal selesai',
                            onPressed: () {
                              setState(() {
                                _endedAt = null;
                                _endedController.clear();
                              });
                            },
                          ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onTap: () async {
                    final picked = await _pickDate(_endedAt ?? _startedAt);
                    if (picked != null) {
                      setState(() {
                        _endedAt = picked;
                        _endedController.text = _formatDate(picked);
                      });
                    }
                  },
                  validator: (String? value) {
                    if (_startedAt != null &&
                        _endedAt != null &&
                        _endedAt!.isBefore(_startedAt!)) {
                      return "Tanggal selesai tidak boleh sebelum tanggal mulai!";
                    }
                    return null;
                  },
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
                                'Pengalaman berhasil ditambahkan!',
                              ),
                              content: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // trim() seperti CharField Django.
                                    Text('Judul: ${_title.trim()}'),
                                    Text('Organisasi: ${_organization.trim()}'),
                                    Text('Deskripsi: ${_description.trim()}'),
                                    Text('Kategori: ${_categories[_category]}'),
                                    Text('Thumbnail: ${_thumbnail.trim()}'),
                                    Text('Mulai: ${_formatDate(_startedAt!)}'),
                                    Text(
                                      'Selesai: ${_endedAt == null ? 'Masih berjalan' : _formatDate(_endedAt!)}',
                                    ),
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
                                      _organization = "";
                                      _description = "";
                                      _category = 'full-time';
                                      _thumbnail = "";
                                      _startedAt = null;
                                      _endedAt = null;
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
