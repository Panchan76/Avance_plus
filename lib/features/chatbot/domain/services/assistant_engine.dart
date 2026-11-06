/// Assistente determinístico: não baixa modelos, não chama APIs e não acessa dados.
/// É um guia por intenções e modelos de texto, não um modelo generativo.
class AssistantEngine {
  Future<String> respond(List<Map<String, String>> messages) async {
    final user = messages.where((m) => m['role'] == 'user').toList();
    if (user.isEmpty) return _help;
    final raw = user.last['content']?.trim() ?? '';
    final text = _normalize(raw);
    if (text.isEmpty) return _help;

    // Não inserir dados sensíveis nos modelos de currículo.
    if (_has(text, ['minha senha', 'meu cpf', 'numero do cartao', 'codigo de verificacao'])) {
      return 'Não preciso de senhas, CPF, cartão ou códigos de acesso. Evite incluir esses dados na conversa ou no currículo. Posso ajudar com experiências, habilidades e uso do aplicativo.';
    }
    if (RegExp(r'\b(golpe|fraude|pagar|pagamento|pix|dinheiro|confiavel|segura)\b').hasMatch(text)) {
      return 'Desconfie de cobranças para conseguir vaga ou participar de entrevista. Não envie senhas nem códigos de acesso. Confira a identidade e os contatos da empresa. O CNPJ informado no Avance+ não é consultado nesta versão. Eu não consigo verificar se uma empresa ou proposta é legítima.';
    }
    if (_has(text, ['experiencia:', 'habilidades:', 'objetivo:'])) return _resumeDraft(raw);
    if (_has(text, ['montar curriculo', 'criar um curriculo', 'escrever curriculo', 'modelo de curriculo', 'fazer um curriculo'])) {
      return 'Vamos montar um rascunho usando apenas o que você informar. Responda neste formato, com um campo por linha:\n\nObjetivo: cargo que procura\nExperiência: trabalhos ou atividades que realizou\nHabilidades: o que sabe fazer\n\nNão precisa enviar documentos ou dados de contato aqui. Você poderá copiar o rascunho para Perfil > Currículo.';
    }
    if (_has(text, ['sem experiencia', 'nunca trabalhei', 'primeiro emprego'])) {
      return 'Você pode apresentar habilidades e atividades reais, mesmo sem emprego formal: cuidados com jardim, cozinha, reparos, artesanato ou trabalho voluntário. Inclua apenas o que você já fez. Para organizar essas informações, escreva “montar currículo”.';
    }
    if (_has(text, ['entrevista']) && _has(text, ['prepar', 'responder', 'dicas', 'pergunt', 'trein', 'nervos', 'medo'])) return _interview;
    if (_has(text, ['alterar data', 'mudar data', 'remarcar', 'reagendar', 'outro horario', 'nao posso', 'nao poderei'])) {
      return 'Na aba Agenda, abra a entrevista e escolha a opção para pedir outra data. Informe uma data futura e o motivo, se desejar. Aguarde a resposta da empresa.\n\nModelo para a conversa: “Olá! Não poderei comparecer no horário combinado. Seria possível remarcar para [dia e horário]? Obrigado pela compreensão.”\n\nEu não alterei sua entrevista.';
    }
    if (_has(text, ['agenda', 'calendario', 'entrevista', 'confirmar presenca', 'comparecer'])) {
      return 'Abra Agenda para consultar os convites.\n\n• Empresa: proponha a entrevista para o candidato.\n• Candidato: confirme, peça outra data ou rejeite.\n• Se houver pedido de mudança, aguarde a resposta da empresa.\n\nNão consigo ver seus compromissos nem marcar entrevistas. Para dicas de preparação, escreva “preparar entrevista”.';
    }
    if (_has(text, ['notificacao', 'lembrete', 'avisar', 'me lembre'])) {
      return 'Eu não envio notificações nem programo lembretes. Consulte os convites na aba Agenda e use o alarme ou calendário do celular para lembrar do horário. O agendamento de lembretes automáticos ainda precisa ser implementado.';
    }
    if (_has(text, ['retirar curriculo', 'excluir curriculo', 'apagar curriculo', 'ocultar', 'privado', 'privacidade', 'parar de compartilhar'])) {
      return 'Abra Perfil > Currículo, desative “Disponibilizar meu currículo às empresas” e salve. Ele deixará de aparecer na consulta das empresas. Isso não apaga as conversas já iniciadas nem informações que alguém já tenha copiado.';
    }
    if (_has(text, ['candidatar', 'candidatura', 'enviar curriculo', 'mandar curriculo', 'curriculo enviado', 'inscrever'])) {
      return '1. Preencha e salve seu currículo em Perfil > Currículo.\n2. Abra Cargos e escolha um cargo.\n3. Toque em Enviar currículo e confirme o compartilhamento.\n4. Aguarde aparecer “Currículo enviado”.\n\nVocê pode escolher até 5 cargos. Esse envio disponibiliza seu currículo às empresas; não garante convite para entrevista.';
    }
    if (_has(text, ['curriculo'])) {
      return 'Para criar ou editar seus dados profissionais, abra Perfil > Currículo. Preencha nome, contato, cidade, experiências e habilidades. No catálogo você envia o currículo e acompanha a indicação “Currículo enviado”.\n\nQuer ajuda com o texto? Escreva “montar currículo”.';
    }
    if (_has(text, ['criar cargo', 'novo cargo', 'cadastrar cargo', 'publicar cargo', 'aprovacao'])) {
      return 'Na conta da empresa, abra Cargos > Solicitar novo cargo / acompanhar pedidos. Informe o título e a descrição. O cargo só entra no catálogo geral depois da aprovação administrativa.';
    }
    if (_has(text, ['candidatos', 'contratar', 'buscar curriculos', 'ver curriculos'])) {
      return 'Na conta da empresa, abra Candidatos e selecione um cargo para ver os currículos compartilhados. Escolha um candidato para iniciar a conversa. Combine os detalhes e proponha uma entrevista pela agenda. Não tenho acesso aos currículos para escolher pessoas por você.';
    }
    if (_has(text, ['conversar', 'conversa', 'mensagem', 'contato', 'chat'])) {
      return 'A empresa inicia o contato pela aba Candidatos. Depois, empresa e candidato usam Conversas para trocar mensagens. Este assistente é separado dessas conversas: eu não leio nem envio mensagens para outras pessoas.';
    }
    if (_has(text, ['vaga', 'emprego', 'trabalho', 'cargo', 'oportunidade'])) {
      return 'Abra Cargos para consultar o catálogo e buscar uma profissão pelo nome. Envie seu currículo aos cargos de interesse. O catálogo reúne profissões; um cargo listado não significa que exista uma vaga garantida. As empresas procuram candidatos e entram em contato pelo aplicativo.';
    }
    if (_has(text, ['foto', 'imagem', 'avatar'])) {
      return 'Abra Perfil > Escolher foto. Selecione uma imagem JPG, PNG ou WebP de até 5 MB. Você também pode remover a foto no Perfil. Nesta versão ela aparece apenas no seu próprio perfil. Salvar a foto exige conexão com o Firebase Storage.';
    }
    if (_has(text, ['senha', 'login', 'entrar', 'acessar conta'])) {
      return 'Para recuperar uma conta com senha, use a recuperação na tela de login ou Perfil > Configurações > Redefinir senha por e-mail. Confira também a pasta de spam. Se entra com Google, administre a senha na sua Conta Google. Nunca envie sua senha aqui.';
    }
    if (_has(text, ['letra', 'fonte', 'enxergar', 'configurac', 'acessibilidade'])) {
      return 'Abra Perfil > Configurações e ative Letras maiores. A preferência fica salva na sua conta. Você também pode usar as opções de acessibilidade do celular.';
    }
    if (_has(text, ['perfil', 'dados pessoais', 'nome', 'telefone', 'cidade', 'email'])) {
      return 'Abra Perfil > Dados pessoais (ou Dados da empresa e contato), altere os campos e toque em Salvar alterações. O e-mail de contato pode ser editado; o e-mail de login permanece o mesmo. Os dados do currículo são editados separadamente em Perfil > Currículo.';
    }
    if (_has(text, ['cnpj', 'empresa verificada', 'validar empresa'])) {
      return 'O CNPJ é informado no cadastro da empresa, sem consulta automática a um serviço externo. O cadastro não confirma a identidade do representante. Confira a empresa antes de compartilhar informações sensíveis.';
    }
    if (_has(text, ['offline', 'internet', 'gratuit', 'inteligencia artificial', 'como funciona', 'voce e'])) {
      return 'Sou um assistente básico com respostas programadas. Minha conversa funciona localmente, sem API e sem cobrança por mensagem. Não gero respostas livres como um modelo de linguagem. Login, currículo, fotos, mensagens e agenda continuam dependendo do Firebase e da conexão.';
    }
    if (_has(text, ['obrigad', 'valeu'])) return 'Por nada! Posso continuar ajudando com currículo, cargos, entrevistas, perfil ou configurações.';
    if (RegExp(r'^(oi|ola|bom dia|boa tarde|boa noite|tudo bem)[ !?.]*$').hasMatch(text)) return 'Olá! Sou o assistente offline do Avance+. Posso explicar como usar o aplicativo, ajudar com um modelo de currículo ou dar dicas de preparação para entrevistas. Sobre o que você quer conversar?';
    // Contexto curto para respostas como “sim”, sem fingir compreensão geral.
    if (RegExp(r'^(sim|quero|pode|vamos|me ajude|ajuda)[ !?.]*$').hasMatch(text) && user.length > 1) {
      final previous = _normalize(user[user.length - 2]['content'] ?? '');
      if (previous.contains('entrevista')) return _interview;
      if (previous.contains('curriculo')) return 'Para preparar seu rascunho, envie um campo por linha:\nObjetivo: ...\nExperiência: ...\nHabilidades: ...\n\nUse apenas informações verdadeiras. Não envie documentos ou senhas.';
    }
    return _help;
  }

  String _resumeDraft(String raw) {
    final values = <String, String>{};
    for (final line in raw.split('\n')) {
      final separator = line.indexOf(':');
      if (separator < 0) continue;
      final key = _normalize(line.substring(0, separator)).trim();
      final value = line.substring(separator + 1).trim();
      if (['objetivo', 'experiencia', 'habilidades'].contains(key) && value.isNotEmpty) values[key] = value;
    }
    if (values.isEmpty) return 'Escreva um campo por linha, por exemplo:\nObjetivo: jardinagem\nExperiência: descreva uma atividade que você realmente realizou\nHabilidades: liste o que sabe fazer';
    return 'Rascunho do currículo — revise antes de usar:\n\n'
      'OBJETIVO\n${values['objetivo'] ?? '[Informe o cargo desejado]'}\n\n'
      'EXPERIÊNCIA\n${values['experiencia'] ?? '[Descreva suas atividades reais]'}\n\n'
      'HABILIDADES\n${values['habilidades'] ?? '[Liste suas habilidades]'}\n\n'
      'Organizei somente as informações que você escreveu. Copie o texto para Perfil > Currículo e complete os campos. Não salvei nem enviei o currículo.';
  }
  bool _has(String text, List<String> words) => words.any(text.contains);
  String _normalize(String value) {
    var text = value.toLowerCase();
    const accents = {'á':'a','à':'a','â':'a','ã':'a','ä':'a','é':'e','ê':'e','è':'e','ë':'e','í':'i','ì':'i','ï':'i','î':'i','ó':'o','ô':'o','õ':'o','ò':'o','ö':'o','ú':'u','ù':'u','û':'u','ü':'u','ç':'c'};
    accents.forEach((a,b) => text = text.replaceAll(a,b));
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
  static const _interview = 'Para se preparar para a entrevista:\n\n1. Confira data, horário e local na Agenda.\n2. Prepare uma apresentação curta: o que sabe fazer e quais experiências tem.\n3. Escolha um exemplo verdadeiro de uma tarefa que realizou bem.\n4. Pense nas perguntas sobre atividades, horários, local e condições de trabalho.\n\nPergunta para treinar: “Conte uma experiência que mostre uma habilidade sua.” Não preciso de documentos para ajudar.';
  static const _help = 'Ainda não tenho uma resposta programada para essa pergunta. Posso ajudar nestes assuntos:\n\n• montar currículo;\n• enviar currículo;\n• preparar entrevista;\n• mudar a data da entrevista;\n• conversar com empresas;\n• alterar foto e dados;\n• aumentar as letras.\n\nEscolha um desses temas ou tente uma pergunta mais direta.';
}
