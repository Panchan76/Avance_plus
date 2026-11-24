
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../domain/services/assistant_engine.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final AssistantEngine _engine = AssistantEngine();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();

  final List<Map<String, String>> _messages = [];

  double _fontSize = 18;

  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;

      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    });
  }

  List<Map<String, String>> _context() {
    final result = <Map<String, String>>[];
    var size = 0;

    for (final message in _messages.reversed) {
      final content = message['content'] ?? '';

      final limited = content.length > 4000
          ? content.substring(0, 4000)
          : content;

      if (result.length >= 10 ||
          size + limited.length > 12000) {
        break;
      }

      result.insert(0, {
        'role': message['role'] ?? 'user',
        'content': limited,
      });

      size += limited.length;
    }

    return result;
  }

  Future<void> _send({bool retry = false}) async {
    if (_busy) return;

    if (!retry) {
      final text = _controller.text.trim();

      if (text.isEmpty || text.length > 4000) return;

      setState(() {
        _messages.add({
          'role': 'user',
          'content': text,
        });
        _error = null;
      });

      _controller.clear();
    }

    if (_messages.isEmpty) return;

    setState(() {
      _busy = true;
      _error = null;
    });

    _scrollDown();

    try {
      final answer = await _engine.respond(_context());

      if (!mounted) return;

      setState(() {
        _messages.add({
          'role': 'assistant',
          'content': answer,
        });
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error is AssistantException
            ? error.message
            : 'Não consegui falar com o assistente agora. '
                'Toque em "Tentar novamente".';
      });
    } finally {
      if (mounted) {
        setState(() => _busy = false);
        _scrollDown();
      }
    }
  }

  Future<void> _clearConversation() async {
    if (_busy || _messages.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Limpar conversa?'),
        content: const Text(
          'Todas as mensagens desta conversa serão apagadas. '
          'Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    setState(() {
      _messages.clear();
      _error = null;
    });
  }

  void _changeFont(double change) {
    setState(() {
      _fontSize = (_fontSize + change).clamp(16.0, 24.0).toDouble();
    });
  }

  Widget _buildHeader(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          bottom: BorderSide(
            color: colors.outlineVariant,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.smart_toy_rounded,
              color: colors.primary,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assistente IA Avance+',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: _fontSize + 1,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  _busy
                      ? 'Preparando resposta...'
                      : 'Seu assistente de carreira',
                  style: TextStyle(
                    fontSize: _fontSize - 2,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Diminuir letras',
            onPressed: _fontSize <= 16 ? null : () => _changeFont(-2),
            icon: const Icon(Icons.text_decrease_rounded, size: 26),
          ),
          IconButton(
            tooltip: 'Aumentar letras',
            onPressed: _fontSize >= 24 ? null : () => _changeFont(2),
            icon: const Icon(Icons.text_increase_rounded, size: 26),
          ),
          IconButton(
            tooltip: 'Limpar conversa',
            onPressed: _busy || _messages.isEmpty
                ? null
                : _clearConversation,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcome(ColorScheme colors) {
    final suggestions = [
      'Como montar meu currículo?',
      'Como me preparar para uma entrevista?',
      'Como usar a agenda?',
      'Como voltar ao mercado de trabalho?',
    ];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 30,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.smart_toy_rounded,
                  size: 42,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Olá! Como posso ajudar você?',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                       fontSize: _fontSize + 5,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                'Estou aqui para ajudar com currículos, '
                'entrevistas e sua jornada profissional.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  height: 1.5,
                  fontSize: _fontSize,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'As perguntas são enviadas ao serviço de IA. '
                'O assistente não executa ações na sua conta.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: _fontSize - 3,
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 28),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 10,
                children: suggestions.map((prompt) {
                  return ActionChip(
                    avatar: Icon(
                      Icons.auto_awesome_outlined,
                      size: 17,
                      color: colors.primary,
                    ),
                    label: Text(prompt, style: TextStyle(fontSize: _fontSize)),
                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    onPressed: _busy
                        ? null
                        : () {
                            _controller.text = prompt;
                            _send();
                          },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessage(
    Map<String, String> message,
    ColorScheme colors,
  ) {
    final isUser = message['role'] == 'user';
    final content = message['content'] ?? '';

    return Align(
      alignment: isUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width < 760
              ? MediaQuery.sizeOf(context).width * 0.88
              : 680,
        ),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? colors.primaryContainer
              : colors.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 5),
            bottomRight: Radius.circular(isUser ? 5 : 18),
          ),
        ),
        child: isUser
            ? SelectableText(
                content,
                style: TextStyle(
                  fontSize: _fontSize,
                  height: 1.5,
                  color: colors.onPrimaryContainer,
                ),
              )
            : MarkdownBody(
                data: content,
                selectable: true,
                softLineBreak: true,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(
                    fontSize: _fontSize,
                    height: 1.5,
                    color: colors.onSurface,
                  ),
                  h1: TextStyle(
                    fontSize: _fontSize + 5,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                  h2: TextStyle(
                    fontSize: _fontSize + 3,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                  h3: TextStyle(
                    fontSize: _fontSize + 1,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                  strong: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  listBullet: TextStyle(
                    color: colors.onSurface,
                  ),
                  blockSpacing: 10,
                  listIndent: 22,
                ),
              ),
      ),
    );
  }

  Widget _buildTypingIndicator(ColorScheme colors) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
            child: Text(
            'A IA está preparando sua resposta...',
              style: TextStyle(fontSize: _fontSize),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(
            color: colors.outlineVariant,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: TextStyle(fontSize: _fontSize),
                enabled: !_busy,
                minLines: 1,
                maxLines: 4,
                maxLength: 4000,
                textCapitalization:
                    TextCapitalization.sentences,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'Digite sua pergunta aqui...',
                   hintStyle: TextStyle(fontSize: _fontSize),
                  filled: true,
                  fillColor: colors.surfaceContainerLow,
                  contentPadding:
                      const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(18),
                    borderSide: BorderSide(
                      color: colors.outlineVariant,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(18),
                    borderSide: BorderSide(
                      color: colors.outlineVariant,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton.filled(
              tooltip: 'Enviar mensagem',
              onPressed: _busy ? null : () => _send(),
              icon: const Icon(Icons.send_rounded, size: 28),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      child: Column(
        children: [
          _buildHeader(colors),

          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return ListView(
                  controller: _scroll,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  children: [
                    if (_messages.isEmpty)
                      SizedBox(
                        height: constraints.maxHeight > 400
                            ? constraints.maxHeight - 40
                            : 360,
                        child: _buildWelcome(colors),
                      ),

                    for (final message in _messages)
                      _buildMessage(message, colors),

                    if (_busy)
                      _buildTypingIndicator(colors),

                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 16,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              _error!,
                              style: TextStyle(
                                color: colors.error,
                                 fontSize: _fontSize,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _busy
                                  ? null
                                  : () => _send(retry: true),
                              icon: const Icon(Icons.refresh),
                              label: Text(
                                'Tentar novamente',
                                style: TextStyle(fontSize: _fontSize - 2),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),

          _buildInput(colors),
        ],
      ),
    );
  }
}
