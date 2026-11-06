String normalizeCnpj(String value) => value.trim().toUpperCase().replaceAll(RegExp(r'[./\s-]'), '');
bool validCnpj(String value) {
  final s = normalizeCnpj(value);
  if (!RegExp(r'^[A-Z0-9]{12}[0-9]{2}$').hasMatch(s) || RegExp(r'^(.)\1{13}$').hasMatch(s)) return false;
  String digit(String base) {
    var sum = 0, weight = 2;
    for (var i = base.length - 1; i >= 0; i--) {
      sum += (base.codeUnitAt(i) - 48) * weight;
      weight = weight == 9 ? 2 : weight + 1;
    }
    final remainder = sum % 11;
    return '${remainder < 2 ? 0 : 11 - remainder}';
  }
  return digit(s.substring(0, 12)) == s[12] && digit(s.substring(0, 13)) == s[13];
}
String? validateCnpjField(String? value) => validCnpj(value ?? '') ? null : 'Informe um CNPJ válido, incluindo os dígitos verificadores.';
