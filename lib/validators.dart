// Validator URL opsional, mirip URLField Django: wajib http/https dan host
// berupa domain bertitik, localhost, atau alamat IPv6.
String? validateOptionalUrl(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }
  final uri = Uri.tryParse(value.trim());
  if (uri == null ||
      !(uri.isScheme('http') || uri.isScheme('https')) ||
      !(uri.host == 'localhost' ||
          uri.host.contains('.') ||
          uri.host.contains(':'))) {
    return "Tautan harus berupa URL yang valid!";
  }
  return null;
}
