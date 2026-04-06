import 'package:flutter/material.dart';
import 'package:s_a/Screens/PersonalChatPage.dart';
import 'package:s_a/const/color/colors.dart';


class ChatItem {
  final String name;
  final String lastMessage;
  final String time;
  final String image;
  final int unreadCount;
  final bool isOnline;

  ChatItem({
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.image,
    this.unreadCount = 0,
    this.isOnline = false,
  });
}


class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ── DYNAMIC CHAT LIST ──
    final List<ChatItem> chats = [
      ChatItem(
        name: "Manvi (Specialist)",
        lastMessage: "Your booking is confirmed for 4 PM.",
        time: "10:30 AM",
        image: "assets/images/user.png",
        unreadCount: 2,
        isOnline: true,
      ),
      ChatItem(
        name: "Rahul - Electrician",
        lastMessage: "I'm outside the gate now.",
        time: "Yesterday",
        image: "assets/images/pop2.png",
        isOnline: true,
      ),
      ChatItem(
        name: "Glow Salon Support",
        lastMessage: "How was your experience today?",
        time: "02/04/26",
        image: "assets/images/salon.png",
      ),
      ChatItem(
        name: "Priya - Hair Stylist",
        lastMessage: "See you on Saturday!",
        time: "28/03/26",
        image: "assets/images/salon3.png",
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Messages", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          )
        ],
      ),
      body: Column(
        children: [
          // ── 1. SEARCH BAR ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Search messages...",
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),

          // ── 2. ONLINE NOW SECTION (Horizontal) ──
          _buildOnlineStatusRow(chats),

          const Divider(height: 1),

          // ── 3. CHAT LIST (Vertical) ──
          Expanded(
            child: ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                return _buildChatTile(context,chats[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget for the Horizontal Online List
  Widget _buildOnlineStatusRow(List<ChatItem> chats) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: chats.length,
        itemBuilder: (context, index) {
          if (!chats[index].isOnline) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: AssetImage(chats[index].image),
                    ),
                    Positioned(
                      right: 2,
                      bottom: 2,
                      child: Container(
                        height: 12, width: 12,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 4),
                Text(chats[index].name.split(' ')[0], style: const TextStyle(fontSize: 12)),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget for Individual Chat Tile
  Widget _buildChatTile(BuildContext context,ChatItem chat) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      leading: CircleAvatar(
        radius: 28,
        backgroundImage: AssetImage(chat.image),
      ),
      title: Text(
        chat.name,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Text(
        chat.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: chat.unreadCount > 0 ? Colors.black : Colors.grey,
          fontWeight: chat.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(chat.time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 5),
          if (chat.unreadCount > 0)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Text(
                chat.unreadCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PersonalChatScreen(
              userName: chat.name,
              userImage: chat.image,
            ),
          ),
        );
      },
    );
  }
}