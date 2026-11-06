import 'package:flutter/material.dart';
import '../../../auth/data/auth_service.dart';
import '../../domain/services/assistant_engine.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});
  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}
class _ChatbotPageState extends State<ChatbotPage> {
  final _engine = AssistantEngine();
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final _messages = <Map<String, String>>[];
  bool _busy = false;
  String? _error;
  @override
  void dispose() { _controller.dispose(); _scroll.dispose(); super.dispose(); }
  void _scrollDown() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted && _scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  });
  List<Map<String, String>> _context() {
    final result = <Map<String, String>>[];
    var size = 0;
    for (final m in _messages.reversed) {
      final content = m['content']!.length > 4000 ? m['content']!.substring(0, 4000) : m['content']!;
      if (result.length >= 12 || size + content.length > 16000) break;
      result.insert(0, {'role': m['role']!, 'content': content});
      size += content.length;
    }
    return result;
  }
  Future<void> _send({bool retry = false}) async {
    if (_busy) return;
    if (!retry) {
      final text = _controller.text.trim();
      if (text.isEmpty || text.length > 4000) return;
      _messages.add({'role': 'user', 'content': text});
      _controller.clear();
    }
    if (_messages.isEmpty) return;
    setState(() { _busy = true; _error = null; });
    _scrollDown();
    try {
      final answer = await _engine.respond(_context());
      if (!mounted) return;
      setState(() => _messages.add({'role': 'assistant', 'content': answer}));
    } catch (error) { if (mounted) setState(() => _error = authErrorMessage(error)); }
    finally { if (mounted) { setState(() => _busy = false); _scrollDown(); } }
  }
  @override
  Widget build(BuildContext context) => SafeArea(child: Column(children: [
    Padding(padding: const EdgeInsets.all(16), child: Row(children: [
      const Icon(Icons.support_agent, size: 36), const SizedBox(width: 12),
      Expanded(child: Text('Assistente offline', style: Theme.of(context).textTheme.titleLarge)),
      IconButton(tooltip: 'Limpar conversa', onPressed: _busy || _messages.isEmpty ? null : () => setState(() { _messages.clear(); _error = null; }), icon: const Icon(Icons.delete_outline)),
    ])),
    const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Funciona sem internet, com respostas programadas sobre o Avance+. Esta conversa fica apenas nesta tela; não é enviada a uma API. O assistente não acessa sua agenda nem executa ações na conta.')),
    const Divider(),
    Expanded(child: ListView(controller: _scroll, padding: const EdgeInsets.all(16), children: [
      if (_messages.isEmpty) ...[
        const Text('Olá! Posso orientar sobre currículo, entrevistas e o uso do Avance+. Para começar um modelo de currículo, escreva: montar currículo.'),
        const SizedBox(height: 16),
        Wrap(spacing: 8, runSpacing: 8, children: [for (final prompt in ['Como envio meu currículo?', 'Como me preparo para uma entrevista?', 'Como usar a agenda?'])
          ActionChip(label: Text(prompt), onPressed: () { _controller.text = prompt; _send(); })]),
      ],
      for (final m in _messages) Align(alignment: m['role'] == 'user' ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(constraints: const BoxConstraints(maxWidth: 650), margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: m['role'] == 'user' ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(16)),
          child: SelectableText(m['content']!))),
      if (_busy) const Row(children: [SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)), SizedBox(width: 12), Text('Preparando resposta...')]),
      if (_error != null) Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_error!), TextButton(onPressed: _busy ? null : () => _send(retry: true), child: const Text('Tentar novamente'))]),
    ])),
    Padding(padding: const EdgeInsets.all(16), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: TextField(controller: _controller, enabled: !_busy, minLines: 1, maxLines: 4, maxLength: 4000,
        textInputAction: TextInputAction.send, onSubmitted: (_) => _send(), decoration: const InputDecoration(labelText: 'Sua pergunta'))),
      const SizedBox(width: 8), IconButton.filled(tooltip: 'Enviar pergunta', onPressed: _busy ? null : () => _send(), icon: const Icon(Icons.send)),
    ])),
  ]));
}
