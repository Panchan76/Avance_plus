<<<<<<< HEAD
import 'package:flutter/material.dart';

import 'package:avance_plus/features/chatbot/domain/models/chat_message.dart';
import 'package:avance_plus/features/chatbot/domain/services/assistant_engine.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  final AssistantEngine _assistant = AssistantEngine();

  final List<ChatMessage> _messages = [
    const ChatMessage(
      text: 'Olá! Sou a assistente do Avance+. '
          'Como posso ajudar você hoje?',
      isUser: false,
    ),
  ];

  void _sendMessage([String? text]) {
    final message = text ?? _controller.text.trim();

    if (message.isEmpty) {
      return;
    }

    setState(() {
      _messages.add(
        ChatMessage(
          text: message,
          isUser: true,
        ),
      );

      _messages.add(
        ChatMessage(
          text: _assistant.respond(message),
          isUser: false,
        ),
      );
    });

    _controller.clear();

    Future.delayed(
      const Duration(milliseconds: 100),
      () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              8,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: const Icon(
                    Icons.support_agent,
                    size: 32,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assistente Avance+',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        'Estou aqui para ajudar',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _QuickButton(
                    text: 'Procurar vagas',
                    onTap: () {
                      _sendMessage('Quero procurar uma vaga');
                    },
                  ),

                  _QuickButton(
                    text: 'Meu currículo',
                    onTap: () {
                      _sendMessage('Como faço meu currículo?');
                    },
                  ),

                  _QuickButton(
                    text: 'Como me candidatar?',
                    onTap: () {
                      _sendMessage('Como me candidatar?');
                    },
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _MessageBubble(
                  message: _messages[index],
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: const Border(
                top: BorderSide(
                  color: Color(0xFFE4E8EE),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) {
                      _sendMessage();
                    },
                    decoration: const InputDecoration(
                      hintText: 'Digite sua pergunta...',
                      prefixIcon: Icon(
                        Icons.chat_bubble_outline,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                SizedBox(
                  width: 60,
                  height: 60,
                  child: IconButton.filled(
                    tooltip: 'Enviar mensagem',
                    onPressed: _sendMessage,
                    icon: const Icon(
                      Icons.send,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 600,
        ),
        margin: const EdgeInsets.only(
          bottom: 14,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: message.isUser
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          message.text,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}

class _QuickButton extends StatelessWidget {
  final String text;

  final VoidCallback onTap;

  const _QuickButton({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        right: 8,
      ),
      child: ActionChip(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
        onPressed: onTap,
      ),
    );
  }
=======
import 'package:flutter/material.dart';

import 'package:avance_plus/features/chatbot/domain/models/chat_message.dart';
import 'package:avance_plus/features/chatbot/domain/services/assistant_engine.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  final AssistantEngine _assistant = AssistantEngine();

  final List<ChatMessage> _messages = [
    const ChatMessage(
      text: 'Olá! Sou a assistente do Avance+. '
          'Como posso ajudar você hoje?',
      isUser: false,
    ),
  ];

  void _sendMessage([String? text]) {
    final message = text ?? _controller.text.trim();

    if (message.isEmpty) {
      return;
    }

    setState(() {
      _messages.add(
        ChatMessage(
          text: message,
          isUser: true,
        ),
      );

      _messages.add(
        ChatMessage(
          text: _assistant.respond(message),
          isUser: false,
        ),
      );
    });

    _controller.clear();

    Future.delayed(
      const Duration(milliseconds: 100),
      () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              8,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: const Icon(
                    Icons.support_agent,
                    size: 32,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assistente Avance+',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        'Estou aqui para ajudar',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _QuickButton(
                    text: 'Procurar vagas',
                    onTap: () {
                      _sendMessage('Quero procurar uma vaga');
                    },
                  ),

                  _QuickButton(
                    text: 'Meu currículo',
                    onTap: () {
                      _sendMessage('Como faço meu currículo?');
                    },
                  ),

                  _QuickButton(
                    text: 'Como me candidatar?',
                    onTap: () {
                      _sendMessage('Como me candidatar?');
                    },
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _MessageBubble(
                  message: _messages[index],
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: const Border(
                top: BorderSide(
                  color: Color(0xFFE4E8EE),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) {
                      _sendMessage();
                    },
                    decoration: const InputDecoration(
                      hintText: 'Digite sua pergunta...',
                      prefixIcon: Icon(
                        Icons.chat_bubble_outline,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                SizedBox(
                  width: 60,
                  height: 60,
                  child: IconButton.filled(
                    tooltip: 'Enviar mensagem',
                    onPressed: _sendMessage,
                    icon: const Icon(
                      Icons.send,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 600,
        ),
        margin: const EdgeInsets.only(
          bottom: 14,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: message.isUser
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          message.text,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}

class _QuickButton extends StatelessWidget {
  final String text;

  final VoidCallback onTap;

  const _QuickButton({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        right: 8,
      ),
      child: ActionChip(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
        onPressed: onTap,
      ),
    );
  }
>>>>>>> 6975be9 ( segundo commit)
}