import 'package:flutter/material.dart';

import '../models/post_model.dart';

class PostCard extends StatelessWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  Color _distressColor(String level) {
    switch (level) {
      case 'high':
        return Colors.red.shade100;
      case 'medium':
        return Colors.orange.shade100;
      default:
        return Colors.green.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        title: Text(post.content),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _distressColor(post.distressLevel),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('Distress: ${post.distressLevel}'),
              ),
              const SizedBox(width: 10),
              Text(post.isAnonymous ? 'Anonymous' : 'Public'),
            ],
          ),
        ),
      ),
    );
  }
}
