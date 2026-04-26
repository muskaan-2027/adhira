import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/notification_service.dart';
import '../widgets/chat_bubble.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _isLoading = true;
    });

    _controller.clear();

    try {
      final response = await ApiService.chatbot(text);
      final reply = response['reply']?.toString() ?? 'No response';
      setState(() {
        _messages.add({'sender': 'bot', 'text': reply});
      });
    } catch (err) {
      if (!mounted) return;
      NotificationService.showMessage(
        context,
        err.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Assistant')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return ChatBubble(
                  text: msg['text'] ?? '',
                  isUser: msg['sender'] == 'user',
                );
              },
            ),
          ),
          if (_isLoading) const Padding(
            padding: EdgeInsets.all(8),
            child: CircularProgressIndicator(),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Ask something...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(onPressed: _sendMessage, icon: const Icon(Icons.send)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
