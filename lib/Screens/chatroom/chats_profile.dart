import 'package:flutter/material.dart';

class ChatsProfile extends StatefulWidget {
  final String img;
  final String name;
  final String email;

  const ChatsProfile({
    super.key,
    required this.img,
    required this.name,
    required this.email,
  });

  @override
  State<ChatsProfile> createState() => _ChatsProfileState();
}

class _ChatsProfileState extends State<ChatsProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: CircleAvatar(
              radius: 80,
              backgroundImage: NetworkImage(widget.img),
              backgroundColor: Colors.grey[200],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            widget.email,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.favorite_border_outlined,
                    size: 30,
                  ),
                  title: const Text(
                    "Add to Favourite",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(
                    Icons.person,
                    color: Colors.red,
                    size: 30,
                  ),
                  title: Text(
                    "Block ${widget.name}",
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                    ),
                  ),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(
                    Icons.report,
                    size: 30,
                    color: Colors.red,
                  ),
                  title: Text(
                    'Report ${widget.name}',
                    style: const TextStyle(color: Colors.red, fontSize: 20),
                  ),
                  onTap: () {},
                ),
                // Add more ListTile widgets as needed
              ],
            ),
          ),
        ],
      ),
    );
  }
}
