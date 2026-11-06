import 'package:flutter_test/flutter_test.dart';
import 'package:avance_plus/features/auth/data/cnpj_validator.dart';
void main() {
  test('Aceita CNPJ numérico e alfanumérico com dígitos corretos', () {
    for (final value in ['34.238.864/0001-68', '11222333000181', '12.ABC.345/01DE-35', '00.000.000/E08G-12']) {
      expect(validCnpj(value), isTrue, reason: value);
    }
  });
  test('Rejeita formato incorreto, repetição e dígitos alterados', () {
    for (final value in ['', '00000000000000', '11111111111111', '34238864000169', '12ABC34501DE36', '12ABC34501DEXX', '34@238864000168']) {
      expect(validCnpj(value), isFalse, reason: value);
    }
  });
}
