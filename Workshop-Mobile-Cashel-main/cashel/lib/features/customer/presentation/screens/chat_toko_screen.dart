import 'package:flutter/material.dart';

class ChatTokoScreen extends StatelessWidget {
  const ChatTokoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat dengan Toko"),
        backgroundColor: const Color(0xFF3B95DE),
      ),
      body: Column(
        children: [
          const Expanded(
            child: Center(child: Text("Belum ada pesan")),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.white,
            child: Row(
              children: [
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(hintText: "Tulis pesan..."),
                  ),
                ),
                IconButton(onPressed: () {}, icon: const Icon(Icons.send)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}