import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/help_request_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';

class HelpRequestsScreen extends StatefulWidget {
  final bool isVolunteer;
  final String? statusFilter;
  final String title;

  const HelpRequestsScreen({
    super.key,
    required this.isVolunteer,
    this.statusFilter,
    this.title = 'Help Requests',
  });

  @override
  State<HelpRequestsScreen> createState() => _HelpRequestsScreenState();
}

class _HelpRequestsScreenState extends State<HelpRequestsScreen> {
  bool _loading = false;
  List<HelpRequestModel> _requests = [];

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _loading = true);
    try {
      final token = context.read<AuthService>().token;
      if (token == null) throw Exception('Please login again');

      final response = await ApiService.getHelpRequests(token);
      final list = response['requests'] as List<dynamic>? ?? [];
      var parsed = list
          .whereType<Map<String, dynamic>>()
          .map(HelpRequestModel.fromJson)
          .toList();

      if (widget.statusFilter != null) {
        parsed = parsed.where((item) => item.status == widget.statusFilter).toList();
      }

      setState(() {
        _requests = parsed;
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

  Future<void> _updateStatus(String requestId, String status) async {
    try {
      final token = context.read<AuthService>().token;
      if (token == null) throw Exception('Please login again');

      String? assistanceNote;
      if (status == 'completed') {
        final noteController = TextEditingController();
        assistanceNote = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Provide Assistance Note'),
            content: TextField(
              controller: noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Add details about the help you provided',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, noteController.text.trim()),
                child: const Text('Submit'),
              ),
            ],
          ),
        );

        if (assistanceNote == null) return;
      }

      await ApiService.updateHelpRequestStatus(
        token,
        requestId,
        status,
        assistanceNote: assistanceNote,
      );
      await _loadRequests();
      if (!mounted) return;
      NotificationService.showMessage(context, 'Request updated: $status');
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
        title: Text(widget.title),
        actions: [
          IconButton(onPressed: _loadRequests, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
              ? const Center(child: Text('No help requests found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _requests.length,
                  itemBuilder: (context, index) {
                    final request = _requests[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(request.message),
                            const SizedBox(height: 6),
                            Text('Status: ${request.status}'),
                            Text('Requester: ${request.requesterName}'),
                            if (request.volunteerName != null)
                              Text('Volunteer: ${request.volunteerName}'),
                            if (request.assistanceNote.isNotEmpty)
                              Text('Assistance note: ${request.assistanceNote}'),
                            if (widget.isVolunteer)
                              Wrap(
                                spacing: 8,
                                children: [
                                  if (request.status == 'pending')
                                    ElevatedButton(
                                      onPressed: () => _updateStatus(request.id, 'accepted'),
                                      child: const Text('Accept'),
                                    ),
                                  if (request.status == 'pending')
                                    OutlinedButton(
                                      onPressed: () => _updateStatus(request.id, 'rejected'),
                                      child: const Text('Reject'),
                                    ),
                                  if (request.status == 'accepted')
                                    ElevatedButton(
                                      onPressed: () => _updateStatus(request.id, 'completed'),
                                      child: const Text('Provide Assistance'),
                                    ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
