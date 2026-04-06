import 'package:flutter/material.dart';
import 'package:s_a/const/color/colors.dart';



class ChatMessage {
  final String text;
  final bool isMe; // True if sent by the user, false if received
  final String time;

  ChatMessage({required this.text, required this.isMe, required this.time});
}

class PersonalChatScreen extends StatefulWidget {
  final String userName;
  final String userImage;

  const PersonalChatScreen({
    super.key,
    this.userName = "Manvi (Specialist)",
    this.userImage = "assets/images/user.png"
  });

  @override
  State<PersonalChatScreen> createState() => _PersonalChatScreenState();
}

class _PersonalChatScreenState extends State<PersonalChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  // ── DYNAMIC MESSAGE LIST ──
  final List<ChatMessage> _messages = [
    ChatMessage(text: "Hello! How can I help you today?", isMe: false, time: "10:00 AM"),
    ChatMessage(text: "I wanted to know if the AC service includes gas charging?", isMe: true, time: "10:05 AM"),
    ChatMessage(text: "Yes, it does! We check the pressure and top it up if needed.", isMe: false, time: "10:06 AM"),
    ChatMessage(text: "Great, I've booked the 4 PM slot.", isMe: true, time: "10:10 AM"),
    ChatMessage(text: "Perfect. I'll be there on time. See you!", isMe: false, time: "10:12 AM"),
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: _messageController.text,
            isMe: true,
            time: "10:15 AM", // In a real app, use DateTime.now()
          ),
        );
        _messageController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      // ── 1. CUSTOM APP BAR ──
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage(widget.userImage),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userName,
                  style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Online",
                  style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.videocam_outlined, color: Colors.black), onPressed: () {}),
          IconButton(icon: const Icon(Icons.call_outlined, color: Colors.black), onPressed: () {}),
        ],
      ),

      // ── 2. CHAT BODY ──
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildChatBubble(_messages[index]);
              },
            ),
          ),

          // ── 3. INPUT AREA ──
          _buildMessageInput(),
        ],
      ),
    );
  }

  // ── WIDGET: CHAT BUBBLE ──
  Widget _buildChatBubble(ChatMessage message) {
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 5, top: 5),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              color: message.isMe ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(message.isMe ? 20 : 0),
                bottomRight: Radius.circular(message.isMe ? 0 : 20),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))
              ],
            ),
            child: Text(
              message.text,
              style: TextStyle(
                color: message.isMe ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
          ),
          Text(
            message.time,
            style: const TextStyle(color: Colors.grey, fontSize: 10),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // ── WIDGET: MESSAGE INPUT ──
  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      margin: const EdgeInsets.only(bottom: 25, left: 15, right: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.add_circle, color: AppColors.primary, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: "Type a message...",
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}