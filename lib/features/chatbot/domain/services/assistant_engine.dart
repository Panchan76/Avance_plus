<<<<<<< HEAD
import 'dart:math' as math;

class AssistantEngine {
  AssistantEngine() {
    _train();
  }

  final Map<String, List<String>> _trainingData = {
    'saudacao': [
      'oi',
      'ola',
      'bom dia',
      'boa tarde',
      'boa noite',
      'tudo bem',
      'como vai',
      'preciso de ajuda',
    ],

    'buscar_vaga': [
      'quero procurar emprego',
      'quero encontrar uma vaga',
      'onde encontro vagas',
      'buscar trabalho',
      'procurar emprego',
      'tem emprego disponivel',
      'quero trabalhar',
      'mostrar vagas',
      'ver oportunidades',
      'preciso de trabalho',
    ],

    'curriculo': [
      'como fazer meu curriculo',
      'preciso criar um curriculo',
      'quero montar meu curriculo',
      'como cadastrar experiencia',
      'adicionar experiencia profissional',
      'editar meu curriculo',
      'me ajude com meu curriculo',
    ],

    'candidatura': [
      'como me candidatar',
      'quero me candidatar',
      'como enviar candidatura',
      'quero essa vaga',
      'como participar da vaga',
      'como mandar meu curriculo para empresa',
      'como concorrer a uma vaga',
    ],

    'perfil': [
      'quero alterar meu perfil',
      'editar meus dados',
      'mudar meu nome',
      'alterar meus dados',
      'onde fica meu perfil',
      'quero mudar minhas informacoes',
      'editar perfil',
    ],

    'sobre_avance': [
      'o que e o avance',
      'para que serve o avance',
      'como funciona o aplicativo',
      'o que posso fazer aqui',
      'como funciona o avance',
      'me explique o aplicativo',
    ],

    'seguranca': [
      'essa vaga e segura',
      'como saber se uma vaga e falsa',
      'tenho medo de golpe',
      'a empresa pediu dinheiro',
      'empresa pediu pagamento',
      'como evitar golpe',
      'vaga suspeita',
    ],
  };

  final Map<String, Map<String, int>> _wordCounts = {};

  final Map<String, int> _totalWords = {};

  final Map<String, int> _documentCounts = {};

  final Set<String> _vocabulary = {};

  int _totalDocuments = 0;

  void _train() {
    for (final entry in _trainingData.entries) {
      final intent = entry.key;
      final examples = entry.value;

      _wordCounts[intent] = {};
      _totalWords[intent] = 0;
      _documentCounts[intent] = examples.length;

      _totalDocuments += examples.length;

      for (final example in examples) {
        final words = _tokenize(example);

        for (final word in words) {
          _vocabulary.add(word);

          _wordCounts[intent]![word] =
              (_wordCounts[intent]![word] ?? 0) + 1;

          _totalWords[intent] =
              (_totalWords[intent] ?? 0) + 1;
        }
      }
    }
  }

  String respond(String input) {
    final intent = _classify(input);

    switch (intent) {
      case 'saudacao':
        return 'Olá! Sou a assistente do Avance+. '
            'Posso ajudar você a encontrar vagas, cuidar do seu perfil '
            'ou entender como utilizar o aplicativo.';

      case 'buscar_vaga':
        return 'Para encontrar oportunidades, abra a aba Vagas. '
            'Você pode pesquisar pelo nome da profissão, empresa ou cidade.';

      case 'curriculo':
        return 'O currículo apresenta suas experiências e habilidades. '
            'No Avance+, você poderá acessar Perfil e depois Currículo '
            'para adicionar suas informações profissionais.';

      case 'candidatura':
        return 'Abra a vaga que você deseja e leia as informações com atenção. '
            'Depois, toque no botão de candidatura para demonstrar interesse na oportunidade.';

      case 'perfil':
        return 'Abra a aba Perfil. Lá você poderá consultar e alterar '
            'suas informações pessoais e profissionais.';

      case 'sobre_avance':
        return 'O Avance+ foi criado para facilitar o acesso de pessoas idosas '
            'a oportunidades profissionais, com uma interface simples e acessível.';

      case 'seguranca':
        return 'Tenha cuidado com empresas que pedem pagamentos ou informações '
            'financeiras para liberar uma vaga. Confira os dados da empresa '
            'antes de continuar e não faça pagamentos para participar de processos seletivos.';

      default:
        return 'Ainda não aprendi a responder essa pergunta. '
            'Você pode perguntar sobre vagas, currículo, candidatura, perfil '
            'ou sobre como utilizar o Avance+.';
    }
  }

  String _classify(String input) {
    final tokens = _tokenize(input);

    final knownTokens = tokens
        .where((token) => _vocabulary.contains(token))
        .toList();

    if (knownTokens.isEmpty) {
      return 'desconhecido';
    }

    String bestIntent = 'desconhecido';

    double bestScore = double.negativeInfinity;

    for (final intent in _trainingData.keys) {
      final documentCount = _documentCounts[intent] ?? 1;

      final prior = documentCount / _totalDocuments;

      double score = math.log(prior);

      final intentWords = _wordCounts[intent] ?? {};

      final totalIntentWords = _totalWords[intent] ?? 0;

      for (final token in knownTokens) {
        final wordCount = intentWords[token] ?? 0;

        // Laplace smoothing
        final probability = (wordCount + 1) /
            (totalIntentWords + _vocabulary.length);

        score += math.log(probability);
      }

      if (score > bestScore) {
        bestScore = score;
        bestIntent = intent;
      }
    }

    return bestIntent;
  }

  List<String> _tokenize(String text) {
    final normalized = _normalize(text);

    return normalized
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
  }

  String _normalize(String text) {
    var value = text.toLowerCase();

    const accents = {
      'á': 'a',
      'à': 'a',
      'ã': 'a',
      'â': 'a',
      'ä': 'a',
      'é': 'e',
      'è': 'e',
      'ê': 'e',
      'ë': 'e',
      'í': 'i',
      'ì': 'i',
      'î': 'i',
      'ï': 'i',
      'ó': 'o',
      'ò': 'o',
      'õ': 'o',
      'ô': 'o',
      'ö': 'o',
      'ú': 'u',
      'ù': 'u',
      'û': 'u',
      'ü': 'u',
      'ç': 'c',
    };

    accents.forEach((accent, replacement) {
      value = value.replaceAll(accent, replacement);
    });

    value = value.replaceAll(
      RegExp(r'[^a-z0-9\s]'),
      ' ',
    );

    return value;
  }
=======
import 'dart:math' as math;

class AssistantEngine {
  AssistantEngine() {
    _train();
  }

  final Map<String, List<String>> _trainingData = {
    'saudacao': [
      'oi',
      'ola',
      'bom dia',
      'boa tarde',
      'boa noite',
      'tudo bem',
      'como vai',
      'preciso de ajuda',
    ],

    'buscar_vaga': [
      'quero procurar emprego',
      'quero encontrar uma vaga',
      'onde encontro vagas',
      'buscar trabalho',
      'procurar emprego',
      'tem emprego disponivel',
      'quero trabalhar',
      'mostrar vagas',
      'ver oportunidades',
      'preciso de trabalho',
    ],

    'curriculo': [
      'como fazer meu curriculo',
      'preciso criar um curriculo',
      'quero montar meu curriculo',
      'como cadastrar experiencia',
      'adicionar experiencia profissional',
      'editar meu curriculo',
      'me ajude com meu curriculo',
    ],

    'candidatura': [
      'como me candidatar',
      'quero me candidatar',
      'como enviar candidatura',
      'quero essa vaga',
      'como participar da vaga',
      'como mandar meu curriculo para empresa',
      'como concorrer a uma vaga',
    ],

    'perfil': [
      'quero alterar meu perfil',
      'editar meus dados',
      'mudar meu nome',
      'alterar meus dados',
      'onde fica meu perfil',
      'quero mudar minhas informacoes',
      'editar perfil',
    ],

    'sobre_avance': [
      'o que e o avance',
      'para que serve o avance',
      'como funciona o aplicativo',
      'o que posso fazer aqui',
      'como funciona o avance',
      'me explique o aplicativo',
    ],

    'seguranca': [
      'essa vaga e segura',
      'como saber se uma vaga e falsa',
      'tenho medo de golpe',
      'a empresa pediu dinheiro',
      'empresa pediu pagamento',
      'como evitar golpe',
      'vaga suspeita',
    ],
  };

  final Map<String, Map<String, int>> _wordCounts = {};

  final Map<String, int> _totalWords = {};

  final Map<String, int> _documentCounts = {};

  final Set<String> _vocabulary = {};

  int _totalDocuments = 0;

  void _train() {
    for (final entry in _trainingData.entries) {
      final intent = entry.key;
      final examples = entry.value;

      _wordCounts[intent] = {};
      _totalWords[intent] = 0;
      _documentCounts[intent] = examples.length;

      _totalDocuments += examples.length;

      for (final example in examples) {
        final words = _tokenize(example);

        for (final word in words) {
          _vocabulary.add(word);

          _wordCounts[intent]![word] =
              (_wordCounts[intent]![word] ?? 0) + 1;

          _totalWords[intent] =
              (_totalWords[intent] ?? 0) + 1;
        }
      }
    }
  }

  String respond(String input) {
    final intent = _classify(input);

    switch (intent) {
      case 'saudacao':
        return 'Olá! Sou a assistente do Avance+. '
            'Posso ajudar você a encontrar vagas, cuidar do seu perfil '
            'ou entender como utilizar o aplicativo.';

      case 'buscar_vaga':
        return 'Para encontrar oportunidades, abra a aba Vagas. '
            'Você pode pesquisar pelo nome da profissão, empresa ou cidade.';

      case 'curriculo':
        return 'O currículo apresenta suas experiências e habilidades. '
            'No Avance+, você poderá acessar Perfil e depois Currículo '
            'para adicionar suas informações profissionais.';

      case 'candidatura':
        return 'Abra a vaga que você deseja e leia as informações com atenção. '
            'Depois, toque no botão de candidatura para demonstrar interesse na oportunidade.';

      case 'perfil':
        return 'Abra a aba Perfil. Lá você poderá consultar e alterar '
            'suas informações pessoais e profissionais.';

      case 'sobre_avance':
        return 'O Avance+ foi criado para facilitar o acesso de pessoas idosas '
            'a oportunidades profissionais, com uma interface simples e acessível.';

      case 'seguranca':
        return 'Tenha cuidado com empresas que pedem pagamentos ou informações '
            'financeiras para liberar uma vaga. Confira os dados da empresa '
            'antes de continuar e não faça pagamentos para participar de processos seletivos.';

      default:
        return 'Ainda não aprendi a responder essa pergunta. '
            'Você pode perguntar sobre vagas, currículo, candidatura, perfil '
            'ou sobre como utilizar o Avance+.';
    }
  }

  String _classify(String input) {
    final tokens = _tokenize(input);

    final knownTokens = tokens
        .where((token) => _vocabulary.contains(token))
        .toList();

    if (knownTokens.isEmpty) {
      return 'desconhecido';
    }

    String bestIntent = 'desconhecido';

    double bestScore = double.negativeInfinity;

    for (final intent in _trainingData.keys) {
      final documentCount = _documentCounts[intent] ?? 1;

      final prior = documentCount / _totalDocuments;

      double score = math.log(prior);

      final intentWords = _wordCounts[intent] ?? {};

      final totalIntentWords = _totalWords[intent] ?? 0;

      for (final token in knownTokens) {
        final wordCount = intentWords[token] ?? 0;

        // Laplace smoothing
        final probability = (wordCount + 1) /
            (totalIntentWords + _vocabulary.length);

        score += math.log(probability);
      }

      if (score > bestScore) {
        bestScore = score;
        bestIntent = intent;
      }
    }

    return bestIntent;
  }

  List<String> _tokenize(String text) {
    final normalized = _normalize(text);

    return normalized
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
  }

  String _normalize(String text) {
    var value = text.toLowerCase();

    const accents = {
      'á': 'a',
      'à': 'a',
      'ã': 'a',
      'â': 'a',
      'ä': 'a',
      'é': 'e',
      'è': 'e',
      'ê': 'e',
      'ë': 'e',
      'í': 'i',
      'ì': 'i',
      'î': 'i',
      'ï': 'i',
      'ó': 'o',
      'ò': 'o',
      'õ': 'o',
      'ô': 'o',
      'ö': 'o',
      'ú': 'u',
      'ù': 'u',
      'û': 'u',
      'ü': 'u',
      'ç': 'c',
    };

    accents.forEach((accent, replacement) {
      value = value.replaceAll(accent, replacement);
    });

    value = value.replaceAll(
      RegExp(r'[^a-z0-9\s]'),
      ' ',
    );

    return value;
  }
>>>>>>> 6975be9 ( segundo commit)
}