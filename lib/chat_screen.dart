import 'dart:async';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'chatmessage.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // text editing controller helps us in linking what we wrote in our keyboard to what is being shown in our screen
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];

  OpenAI? chatGPT;

  StreamSubscription? _subscription;
  bool isTyping = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _sendMessage() {
    WidgetsFlutterBinding.ensureInitialized();
    ChatMessage _message = ChatMessage(text: _controller.text, sender: "user");

    setState(() {
      _messages.insert(0, _message);
      isTyping = true;
    });

    _controller.clear();

    final request = CompleteReq(prompt: message.text, model: kTranslateModelV3, max_tokens: 200);

    _subscription = chatGPT!
        .build(token: "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")
        .onCompletionStream(request: request)
        .listen((response) {
      Vx.log(response?.choices[0].text);
      ChatMessage botMessage =
          ChatMessage(text: response!.choices[0].text, sender: "bot");

      setState(() {
        _messages.insert(0, botMessage);
        isTyping = true;
      });
    });
  }

  //this is the text box where we would send our messages
  Widget _buildTextComposer() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onSubmitted: (value) => _sendMessage(),
            controller: _controller,
            decoration: const InputDecoration(hintText: "Send a message"),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: () {
            _sendMessage();
          },
        )
      ],
    ).px12(); // we added the padding
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatGPT'),
      ),
      body: Column(
        children: [
          Flexible(
            // here we created a list view as we wanted our items like a list like one after the another like a whatsapp chat
            child: ListView.builder(
                reverse: true,
                padding: Vx.m8,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _messages[index];
                }),
          ), // it moves our text field to the bottom of screen
          if(isTyping) const ThreeDots(), 
          const Divider(
            height: 1.0;
          ),
          Container(
            decoration: BoxDecoration(
              color: context.cardColor,
            ),
            // here we added the text button for sending our message
            child: _buildTextComposer(),
          )
        ],
      ),
    );
  }
}
