import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/post_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../widgets/post_card.dart';
import 'chatbot_screen.dart';
import 'need_guidance_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final _postController = TextEditingController();
  bool _isAnonymous = false;
  bool _loading = false;
  List<PostModel> _posts = [];

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthService>().currentUser;
    _isAnonymous = user?.isAnonymous == true;
    _loadPosts();
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  Future<void> _loadPosts() async {
    setState(() => _loading = true);
    try {
      final response = await ApiService.getPosts();
      final list = response['posts'] as List<dynamic>? ?? [];
      setState(() {
        _posts = list
            .whereType<Map<String, dynamic>>()
            .map(PostModel.fromJson)
            .toList();
      });
    } catch (err) {
      if (!mounted) return;
      NotificationService.showMessage(
        context,
        err.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _createPost() async {
    final content = _postController.text.trim();
    if (content.isEmpty) return;

    try {
      final token = context.read<AuthService>().token;
      if (token == null) throw Exception('Please login again');

      final analysis = await ApiService.analyzePost(token, content: content);
      final actions = (analysis['suggestedActions'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList();
      final distressLevel = analysis['distressLevel']?.toString() ?? 'normal';

      if (!mounted) return;

      if (actions.isNotEmpty) {
        final action = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Distress detected: $distressLevel'),
            content: const Text(
              'Your post may indicate distress. Choose support before publishing.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, 'chatbot'),
                child: const Text('Open Chatbot'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, 'volunteer'),
                child: const Text('Volunteer Help'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, 'publish'),
                child: const Text('Publish to Feed'),
              ),
            ],
          ),
        );

        if (!mounted) return;

        if (action == 'chatbot') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatbotScreen()),
          );
          return;
        }

        if (action == 'volunteer') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NeedGuidanceScreen()),
          );
          return;
        }

        if (action != 'publish') return;
      }

      await ApiService.createPost(
        token,
        content: content,
        isAnonymous: _isAnonymous,
      );

      _postController.clear();
      await _loadPosts();
      if (!mounted) return;
      NotificationService.showMessage(context, 'Post published to community feed');
    } catch (err) {
      if (!mounted) return;
      NotificationService.showMessage(
        context,
        err.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Section'),
        actions: [
          IconButton(onPressed: _loadPosts, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _postController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Write a post to community feed...',
                border: OutlineInputBorder(),
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _isAnonymous,
              onChanged: (value) => setState(() => _isAnonymous = value),
              title: const Text('Publish as anonymous'),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _createPost,
                child: const Text('Write Post'),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _posts.isEmpty
                      ? const Center(child: Text('No community posts yet'))
                      : ListView.builder(
                          itemCount: _posts.length,
                          itemBuilder: (context, index) {
                            return PostCard(post: _posts[index]);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
