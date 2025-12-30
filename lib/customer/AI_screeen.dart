import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

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

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  // --- LOGIC SECTION ---

  Future<String> sendToGemini(String userMessage, XFile? image) async {
    // PLACE YOUR API KEY HERE
    const String apiKey = "AIzaSyDwurHHDlVZi7MQsduGU7bVLmwH8mZkqWQ";

    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey",
    );

    List<Map<String, dynamic>> parts = [
      {"text": userMessage.isEmpty ? "What is in this image?" : userMessage},
    ];

    if (image != null) {
      final bytes = await image.readAsBytes();
      String base64Image = base64Encode(bytes);
      parts.add({
        "inline_data": {"mime_type": "image/jpeg", "data": base64Image},
      });
    }

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {"parts": parts},
          ],
        }),
      );

      final data = jsonDecode(response.body);
      return data["candidates"][0]["content"]["parts"][0]["text"];
    } catch (e) {
      return "Error connecting to Gemini. Check your API key or internet.";
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

  // --- UI SECTION ---

  Widget typingIndicator() {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Text(
          "Gemini is thinking...",
          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 238, 241, 238),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 241, 160, 39),
        foregroundColor: Colors.black,
        toolbarHeight: 100,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "FloorBit AI",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.auto_awesome,
                  size: 24,
                ),
              ],
            ),
            const Text(
              "Powered by Gemini.com",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.black54,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: messages.length + (isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (isTyping && index == messages.length) {
                  return typingIndicator();
                }

                final msg = messages[index];
                bool isUser = msg["sender"] == "user";

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 10,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? const Color.fromARGB(255, 240, 147, 86)
                          : const Color.fromARGB(255, 239, 241, 240),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (msg["image"] != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(msg["image"]),
                            ),
                          ),
                        if (msg["text"] != null && msg["text"].isNotEmpty)
                          Text(
                            msg["text"],
                            style: TextStyle(
                              color: isUser
                                  ? const Color.fromARGB(255, 240, 238, 237)
                                  : Colors.black87,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_selectedImage != null)
            Container(
              height: 100,
              padding: const EdgeInsets.all(8),
              color: const Color.fromARGB(255, 244, 247, 244),
              child: Stack(
                children: [
                  Image.file(File(_selectedImage!.path)),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      onPressed: () => setState(() => _selectedImage = null),
                    ),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.black12)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image, color: Colors.orangeAccent),
                  onPressed: _pickImage,
                ),
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: "Let our AI decide..",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.orangeAccent),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
