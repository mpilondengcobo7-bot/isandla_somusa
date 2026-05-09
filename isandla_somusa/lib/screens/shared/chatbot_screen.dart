import 'package:flutter/material.dart';
import '../../services/ai_service.dart';
import '../../utils/app_theme.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});
  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final List<_Msg> _messages = [
    _Msg(text: 'Sawubona! I\'m Somusa, your food donation assistant. '
        'Ask me anything about donating, requesting food, pickups, or ratings!',
        isBot: true),
  ];

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Msg(text: text, isBot: false));
      _ctrl.clear();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      final reply = AiService.chatbotReply(text);
      if (mounted) setState(() => _messages.add(_Msg(text: reply, isBot: true)));
      Future.delayed(const Duration(milliseconds: 100), () {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      });
    });
  }

  @override
  void dispose() { _ctrl.dispose(); _scroll.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(children: [
          CircleAvatar(radius: 14, backgroundColor: Colors.white,
            child: Icon(Icons.psychology, color: AppTheme.tealGreen, size: 18)),
          SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Somusa Assistant', style: TextStyle(fontSize: 14)),
            Text('AI-powered helper', style: TextStyle(fontSize: 11, color: Colors.white70)),
          ]),
        ]),
      ),
      body: Column(children: [
        // Quick prompts
        Container(
          height: 40, color: AppTheme.tealGreen.withOpacity(0.06),
          child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            children: ['How do I donate?', 'How do I request food?', 'What is Somusa?', 'How does matching work?']
              .map((q) => GestureDetector(
                onTap: () { _ctrl.text = q; _send(); },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.tealGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.tealGreen.withOpacity(0.3))),
                  child: Center(child: Text(q, style: const TextStyle(fontSize: 12, color: AppTheme.tealGreen))),
                ),
              )).toList()),
        ),
        // Messages
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (_, i) => _BubbleTile(msg: _messages[i]),
          ),
        ),
        // Input
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
          ),
          child: Row(children: [
            Expanded(child: TextField(
              controller: _ctrl,
              onSubmitted: (_) => _send(),
              decoration: InputDecoration(
                hintText: 'Ask Somusa anything...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                filled: true, fillColor: Colors.grey.withOpacity(0.1),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            )),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: AppTheme.tealGreen,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 18),
                onPressed: _send),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _Msg { final String text; final bool isBot; _Msg({required this.text, required this.isBot}); }

class _BubbleTile extends StatelessWidget {
  final _Msg msg;
  const _BubbleTile({required this.msg});
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: msg.isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: BoxDecoration(
          color: msg.isBot ? AppTheme.tealGreen.withOpacity(0.1) : AppTheme.tealGreen,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
            bottomLeft: msg.isBot ? Radius.zero : const Radius.circular(16),
            bottomRight: msg.isBot ? const Radius.circular(16) : Radius.zero,
          ),
        ),
        child: Text(msg.text,
          style: TextStyle(
            color: msg.isBot ? AppTheme.charcoal : Colors.white, fontSize: 14, height: 1.4)),
      ),
    );
  }
}
