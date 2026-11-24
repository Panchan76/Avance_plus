import 'dart:async';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';

/// Erro já traduzido para uma frase simples, pronta para mostrar à pessoa.
class AssistantException implements Exception {
  const AssistantException(this.message);
  final String message;

  @override
  String toString() => message;
}

class AssistantEngine {
  static const Duration _tempoLimite = Duration(seconds: 60);

  /// Pode ser trocado sem editar o código:
  /// flutter run --dart-define=GEMINI_MODEL=gemini-3.7-flash
  static const String _modelo = String.fromEnvironment(
    'GEMINI_MODEL',
    defaultValue: 'gemini-3.5-flash',
  );

  /// flutter run --dart-define=SHOW_AI_ERRORS=true mostra o erro técnico na tela.
  static const bool _mostrarDetalhes =
      kDebugMode || bool.fromEnvironment('SHOW_AI_ERRORS');

  // Criado só no primeiro uso, para um problema de configuração não
  // derrubar a tela do assistente ao abrir.
  late final GenerativeModel _model = FirebaseAI.googleAI().generativeModel(
    model: _modelo,
    generationConfig: GenerationConfig(temperature: 0.5),
    systemInstruction: Content.system(_instrucoes),
  );

  static const String _instrucoes = '''
Você é a assistente virtual do Avance+, um aplicativo que ajuda pessoas
com 60 anos ou mais a encontrar oportunidades de trabalho.

QUEM VOCÊ ATENDE:
- Pessoas idosas, muitas sem costume com tecnologia.
- Valorize a experiência de vida e profissional da pessoa.
- Nunca trate a idade como problema.

COMO ESCREVER:
- Português do Brasil, simples e acolhedor, como uma conversa.
- Frases curtas. Evite palavras difíceis e termos em inglês.
- Respostas de 2 a 5 frases. Só passe disso se a pessoa pedir.
- Para ensinar algo, explique em passos numerados, um de cada vez.
- Faça no máximo uma pergunta por vez.
- Não use tabelas, títulos ou listas grandes. Não repita o que já disse.
- Nunca deixe uma frase pela metade.
- Sem elogios exagerados.

O QUE VOCÊ FAZ:
- Ajuda a montar e melhorar currículos. Se pedirem um currículo,
  escreva o texto completo.
- Dá dicas para entrevistas e para voltar ao mercado de trabalho.
- Explica como usar o aplicativo.

COMO O APLICATIVO FUNCIONA:
- Barra de baixo: Cargos, Conversas, Agenda, Assistente e Perfil.
- O sino de Avisos fica no topo da tela, no canto direito.
- Cargos: ver profissões e compartilhar o currículo com empresas.
- Conversas: falar com as empresas que se interessaram.
- Agenda: ver e responder convites de entrevista.
- Perfil: editar seus dados e criar o Currículo (Perfil > Currículo).

SEGURANÇA:
- Nunca invente vagas, empresas ou experiências.
- Não diga que acessou os dados ou a agenda da pessoa, nem que fez
  alguma ação no aplicativo. Você só conversa.
- Nunca peça senha, CPF, número de cartão ou dados do banco.
- Avise que empresa séria não cobra para dar emprego nem pede
  dinheiro adiantado ou PIX. Se parecer golpe, diga para não pagar.
- Não prometa emprego nem aprovação em entrevista.
- Não dê orientação médica, jurídica ou financeira. Sugira procurar
  um profissional.
- Se o assunto fugir de trabalho ou do aplicativo, responda em uma
  frase e volte a oferecer ajuda com o trabalho.
- Se não souber, diga com sinceridade.
''';

  Future<String> respond(List<Map<String, String>> messages) async {
    final conversa = _montarConversa(messages);

    if (conversa.isEmpty) {
      return 'Olá! Como posso ajudar você hoje?';
    }

    try {
      debugPrint('Enviando mensagem ao Gemini ($_modelo)...');

      final response =
          await _model.generateContent(conversa).timeout(_tempoLimite);

      final resposta = response.text?.trim();

      if (resposta == null || resposta.isEmpty) {
        throw const AssistantException(
          'Não consegui pensar em uma resposta agora. '
          'Toque em "Tentar novamente".',
        );
      }

      debugPrint('Resposta recebida com sucesso!');
      return resposta;
    } on AssistantException {
      rethrow;
    } on TimeoutException {
      debugPrint('Tempo limite de 60 segundos atingido.');
      throw const AssistantException(
        'A resposta está demorando mais do que o normal. '
        'Toque em "Tentar novamente".',
      );
    } catch (e) {
      debugPrint('Erro na API Gemini: $e');
      throw AssistantException(_traduzirErro(e));
    }
  }

  /// Monta o histórico no formato de conversa do Gemini: começa com a pessoa,
  /// alterna os papéis e termina com a última pergunta dela.
  List<Content> _montarConversa(List<Map<String, String>> messages) {
    final turnos = <({bool pessoa, String texto})>[];

    for (final m in messages) {
      final papel = m['role'];
      final texto = m['content']?.trim() ?? '';
      if ((papel != 'user' && papel != 'assistant') || texto.isEmpty) continue;

      final pessoa = papel == 'user';
      if (turnos.isEmpty && !pessoa) continue; // começa sempre pela pessoa

      if (turnos.isNotEmpty && turnos.last.pessoa == pessoa) {
        turnos[turnos.length - 1] =
            (pessoa: pessoa, texto: '${turnos.last.texto}\n\n$texto');
      } else {
        turnos.add((pessoa: pessoa, texto: texto));
      }
    }

    if (turnos.isEmpty || !turnos.last.pessoa) return const [];

    // Só as últimas mensagens, mantendo o início na vez da pessoa.
    var inicio = turnos.length > 10 ? turnos.length - 10 : 0;
    if (!turnos[inicio].pessoa) inicio++;

    return [
      for (final t in turnos.sublist(inicio))
        t.pessoa ? Content.text(t.texto) : Content.model([TextPart(t.texto)]),
    ];
  }

  String _traduzirErro(Object e) {
    final erro = e.toString().toLowerCase();
    final detalhe = _mostrarDetalhes ? '\n\n[detalhe técnico: $e]' : '';

    if (erro.contains('app check') ||
        erro.contains('appcheck') ||
        erro.contains('app_check') ||
        erro.contains('permission_denied') ||
        erro.contains('permission denied') ||
        erro.contains('403') ||
        erro.contains('api key')) {
      return 'O assistente não conseguiu liberar o acesso agora. '
          'Tente de novo mais tarde.$detalhe';
    }

    if (erro.contains('429') ||
        erro.contains('quota') ||
        erro.contains('resource_exhausted')) {
      return 'O assistente recebeu muitas perguntas agora. '
          'Espere alguns minutos e tente de novo.$detalhe';
    }

    if (erro.contains('404') || erro.contains('not found')) {
      return 'O assistente não está disponível neste momento. '
          'Tente de novo mais tarde.$detalhe';
    }

    if (erro.contains('500') ||
        erro.contains('503') ||
        erro.contains('unavailable') ||
        erro.contains('overloaded') ||
        erro.contains('high demand')) {
      return 'O assistente está ocupado agora. '
          'Espere um pouco e tente de novo.$detalhe';
    }

    if (erro.contains('socketexception') ||
        erro.contains('failed host lookup') ||
        erro.contains('clientexception') ||
        erro.contains('xmlhttprequest') ||
        erro.contains('network')) {
      return 'Parece que está sem internet. '
          'Confira a conexão e tente de novo.$detalhe';
    }

    return 'Não consegui falar com o assistente agora. '
        'Tente de novo em alguns instantes.$detalhe';
  }
}
