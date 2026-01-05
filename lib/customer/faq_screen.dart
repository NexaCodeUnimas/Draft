import 'package:flutter/material.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  static const themeColor = Color(0xFFFF9800);

  static const List<Map<String, String>> faqs = [
    {
      'question': 'What is Floorbit?',
      'answer':
          'Floorbit is a flooring app that lets you browse products, visualize floors, and manage orders and appointments.'
    },
    {
      'question': 'What flooring products are available?',
      'answer':
          'Floorbit offers various flooring types with filters by material, color, and price.'
    },
    {
      'question': 'Are prices shown final?',
      'answer':
          'Prices shown are estimates. Final pricing may vary based on space size and installation requirements.'
    },
    {
      'question': 'Can I place an order through the app?',
      'answer': 'Yes. You can place and track orders directly in the app.'
    },
    {
      'question': 'How do I track my order?',
      'answer':
          'Go to the Orders section to view order status and updates.'
    },
    {
      'question': 'Can I book an appointment?',
      'answer':
          'Yes. You can schedule consultations or site visits through the Appointments section.'
    },
    {
      'question': 'What payment methods are supported?',
      'answer':
          'Supported payment methods are shown during checkout and may vary.'
    },
    {
      'question': 'Who do I contact for support?',
      'answer':
          'Contact the Floorbit sales representative at 012-851 1678.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: themeColor,
        title: const Text("FAQ"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: const Column(
              children: [
                Icon(Icons.help_outline, size: 60, color: Colors.white),
                SizedBox(height: 12),
                Text(
                  'Frequently Asked Questions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Find answers to common questions',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: faqs.length,
              itemBuilder: (context, index) {
                return _FAQItem(
                  question: faqs[index]['question']!,
                  answer: faqs[index]['answer']!,
                  number: index + 1,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FAQItem extends StatefulWidget {
  final String question;
  final String answer;
  final int number;

  const _FAQItem({
    required this.question,
    required this.answer,
    required this.number,
  });

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding:
              const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          leading: CircleAvatar(
            backgroundColor: FAQScreen.themeColor.withOpacity(0.1),
            radius: 18,
            child: Text(
              '${widget.number}',
              style: const TextStyle(
                color: FAQScreen.themeColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          title: Text(
            widget.question,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: Icon(
            _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: FAQScreen.themeColor,
          ),
          onExpansionChanged: (expanded) {
            setState(() {
              _isExpanded = expanded;
            });
          },
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.answer,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}