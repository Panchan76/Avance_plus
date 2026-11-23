
import 'dart:async';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';

class AssistantEngine {
  static const Duration _tempoLimite = Duration(seconds: 60);

  final GenerativeModel _model = FirebaseAI.googleAI().generativeModel(
    model: 'gemini-3.8-flash',
    systemInstruction: Content.system('''
Você é a assistente virtual do Avance+, um aplicativo
que ajuda pessoas a encontrar oportunidades profissionais.

Suas funções:
- Ajudar a criar e melhorar currículos.
- Dar dicas para entrevistas de emprego.
- Orientar quem procura o primeiro emprego.
- Ajudar pessoas a voltar ao mercado de trabalho.
- Explicar as funcionalidades do Avance+.
- Atender pessoas idosas com linguagem simples.

Funcionalidades do Avance+:
- Perfil > Currículo: criar e editar currículos.
- Cargos: consultar profissões e compartilhar currículo.
- Conversas: comunicação entre empresas e candidatos.
- Agenda: acompanhar convites para entrevistas.
- Perfil > Configurações: ajustar preferências.

COMO RESPONDER:
- Responda sempre em português brasileiro.
- Seja educada, natural, paciente e objetiva.
- Prefira respostas curtas, de 2 a 5 frases.
- Para assuntos complexos, explique em etapas.
- Evite apresentações longas e repetitivas.
- Não repita informações já explicadas.
- Faça apenas uma pergunta por vez quando precisar
  de mais informações.
- Se o usuário pedir um currículo completo,
  forneça o conteúdo necessário.
- Nunca interrompa uma frase no meio.
- Não utilize elogios exagerados.
- Evite listas grandes quando não forem necessárias.

SEGURANÇA:
- Nunca invente vagas, empresas ou experiências.
- Não afirme que acessou dados pessoais ou a agenda.
- Não afirme que executou ações no aplicativo.
- Não solicite senhas, CPF ou dados bancários.
- Não prometa emprego ou aprovação em entrevistas.
- Se não souber algo, informe com transparência.
'''),
  );

  Future<String> respond(
    List<Map<String, String>> messages,
  ) async {
    if (messages.isEmpty) {
      return 'Olá! Como posso ajudar você hoje?';
    }

    final mensagensValidas = messages.where((m) {
      final role = m['role'];
      final conteudo = m['content']?.trim() ?? '';

      return (role == 'user' || role == 'assistant') &&
          conteudo.isNotEmpty;
    }).toList();

    if (mensagensValidas.isEmpty) {
      return 'Como posso ajudar você?';
    }

    // Envia somente as últimas 10 mensagens.
    final inicio = mensagensValidas.length > 10
        ? mensagensValidas.length - 10
        : 0;

    final mensagensRecentes = mensagensValidas.sublist(inicio);

    final historico = mensagensRecentes.map((m) {
      final autor = m['role'] == 'user'
          ? 'Usuário'
          : 'Assistente';

      return '$autor: ${m['content']}';
    }).join('\n\n');

    try {
      debugPrint('Enviando mensagem ao Gemini...');

      final response = await _model.generateContent([
        Content.text(
          'Considere o histórico da conversa abaixo.\n'
          'Responda à última mensagem do usuário.\n'
          'Seja breve, mas responda completamente.\n\n'
          '$historico',
        ),
      ]).timeout(_tempoLimite);

      final resposta = response.text?.trim();

      if (resposta == null || resposta.isEmpty) {
        return 'Não consegui gerar uma resposta agora. '
            'Pode tentar novamente?';
      }

      debugPrint('Resposta recebida com sucesso!');

      return resposta;
    } on TimeoutException {
      debugPrint('Tempo limite de 60 segundos atingido.');

      return 'A resposta está demorando mais que o esperado. '
          'Por favor, tente novamente em alguns instantes.';
    } catch (e) {
      debugPrint('Erro na API Gemini: $e');

      final erro = e.toString().toLowerCase();

      if (erro.contains('429') ||
          erro.contains('quota') ||
          erro.contains('resource_exhausted')) {
        return 'O limite de utilização da inteligência '
            'artificial foi atingido. '
            'Tente novamente mais tarde.';
      }

      if (erro.contains('500') ||
          erro.contains('503') ||
          erro.contains('unavailable') ||
          erro.contains('high demand')) {
        return 'O serviço de inteligência artificial '
            'está temporariamente indisponível. '
            'Tente novamente em alguns instantes.';
      }

      if (erro.contains('404') ||
          erro.contains('not found')) {
        return 'O modelo de inteligência artificial '
            'não está disponível. '
            'Verifique a configuração do serviço.';
      }

      if (erro.contains('403') ||
          erro.contains('app check') ||
          erro.contains('permission_denied')) {
        return 'Não foi possível validar o acesso '
            'ao serviço de inteligência artificial. '
            'Verifique a configuração do Firebase.';
      }

      return 'Não foi possível acessar a inteligência '
          'artificial neste momento. '
          'Verifique sua conexão e tente novamente.';
    }
  }
}
