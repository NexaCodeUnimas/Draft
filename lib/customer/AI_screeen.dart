import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'widgets/app_bottom_nav.dart';
import 'package:firebase_ai/firebase_ai.dart';

class GeminiChatApp extends StatelessWidget {
  const GeminiChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const ChatScreen();
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  List<Map<String, dynamic>> messages = [];
  bool isTyping = false;
  XFile? _selectedImage;

  // Stable initialization of the model
  late final GenerativeModel _model;

  @override
  void initState() {
    super.initState();
    // Use getInstance with googleAI() to match your Firebase Console setup
    _model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.5-flash',
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImage = image);
    }
  }

  Future<String> sendToGemini(String userMessage, XFile? image) async {
    try {
      final List<Part> parts = [];

      if (userMessage.isNotEmpty) {
        parts.add(TextPart(userMessage));
      }

      if (image != null) {
        final bytes = await image.readAsBytes();
        // Updated to use InlineDataPart for better compatibility
        parts.add(InlineDataPart('image/jpeg', bytes));
      }

      if (parts.isEmpty) parts.add(TextPart("Hello!"));

      final response = await _model.generateContent([Content.multi(parts)]);

      return response.text ?? "I couldn't generate a response.";
    } catch (e) {
      debugPrint("AI Error Details: $e");
      return "Error: Check your Firebase setup. (Error: $e)";
    }
  }

  void sendMessage() async {
    String text = controller.text.trim();
    if (text.isEmpty && _selectedImage == null) return;

    final imageToSend = _selectedImage;

    setState(() {
      messages.add({
        "sender": "user",
        "text": text,
        "image": imageToSend != null ? File(imageToSend.path) : null,
      });
      isTyping = true;
      _selectedImage = null;
    });

    controller.clear();
    scrollToBottom();

    String reply = await sendToGemini(text, imageToSend);

    if (mounted) {
      setState(() {
        isTyping = false;
        messages.add({"sender": "bot", "text": reply.trim()});
      });
      scrollToBottom();
    }
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget typingIndicator() {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Text(
          "FloorBit AI is thinking...",
          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text("FloorBit AI", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: messages.length + (isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (isTyping && index == messages.length)
                  return typingIndicator();

                final msg = messages[index];
                bool isUser = msg["sender"] == "user";

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.orange : Colors.grey[300],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (msg["image"] != null)
                          Image.file(msg["image"], height: 150),
                        Text(
                          msg["text"] ?? "",
                          style: TextStyle(
                              color: isUser ? Colors.white : Colors.black),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_selectedImage != null)
            Image.file(File(_selectedImage!.path), height: 80),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.white,
            child: Row(
              children: [
                IconButton(
                    icon: const Icon(Icons.image), onPressed: _pickImage),
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration:
                        const InputDecoration(hintText: "Type a message..."),
                  ),
                ),
                IconButton(
                    icon: const Icon(Icons.send), onPressed: sendMessage),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }
}
