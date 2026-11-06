import 'package:flutter_test/flutter_test.dart';
import 'package:avance_plus/features/chatbot/domain/services/assistant_engine.dart';
void main() {
  final engine = AssistantEngine();
  Future<String> ask(String text) => engine.respond([{'role':'user','content':text}]);
  test('Orientação de envio sem afirmar execução', () async {
    expect(await ask('Como enviar currículo?'), contains('Aguarde aparecer'));
    expect(await ask('Quero remarcar minha entrevista'), contains('Eu não alterei'));
  });
  test('Rascunho mantém somente dados fornecidos', () async {
    final result = await ask('Objetivo: jardinagem\nExperiência: cuidei de plantas\nHabilidades: poda');
    expect(result, contains('cuidei de plantas'));
    expect(result, contains('Não salvei nem enviei'));
    expect(result, isNot(contains('anos de experiência')));
  });
  test('Privacidade e proteção contra falso sucesso', () async {
    expect(await ask('A empresa pediu pagamento por pix'), contains('Desconfie'));
    expect(await ask('Me lembre amanhã'), contains('não envio notificações'));
    expect(await ask('Apagar currículo'), contains('desative'));
    expect(await ask('O CNPJ é verificado?'), contains('sem consulta'));
    expect(await ask('Qual a previsão do tempo?'), contains('Ainda não tenho'));
  });
  test('Contexto simples', () async {
    final result = await engine.respond([{'role':'user','content':'currículo'},{'role':'assistant','content':'Quer ajuda?'},{'role':'user','content':'sim'}]);
    expect(result, contains('Objetivo:'));
  });
}
