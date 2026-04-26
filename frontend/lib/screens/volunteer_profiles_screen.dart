import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/volunteer_profile_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';

class VolunteerProfilesScreen extends StatefulWidget {
  const VolunteerProfilesScreen({super.key});

  @override
  State<VolunteerProfilesScreen> createState() => _VolunteerProfilesScreenState();
}

class _VolunteerProfilesScreenState extends State<VolunteerProfilesScreen> {
  bool _loading = false;
  List<VolunteerProfileModel> _volunteers = [];

  @override
  void initState() {
    super.initState();
    _loadVolunteers();
  }

  Future<void> _loadVolunteers() async {
    setState(() => _loading = true);
    try {
      final token = context.read<AuthService>().token;
      if (token == null) throw Exception("Please login again");

      final response = await ApiService.getVolunteerProfiles(token, onlyActive: true);
      final list = response["volunteers"] as List<dynamic>? ?? [];

      setState(() {
        _volunteers = list
            .whereType<Map<String, dynamic>>()
            .map(VolunteerProfileModel.fromJson)
            .toList();
      });
    } catch (err) {
      if (!mounted) return;
      NotificationService.showMessage(
        context,
        err.toString().replaceFirst("Exception: ", ""),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendRequest(VolunteerProfileModel volunteer) async {
    final controller = TextEditingController();
    final message = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Request ${volunteer.name}"),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: "Describe what support you need",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text("Send Help Request"),
          ),
        ],
      ),
    );

    if (message == null || message.isEmpty) return;
    if (!mounted) return;

    try {
      final token = context.read<AuthService>().token;
      if (token == null) throw Exception("Please login again");

      await ApiService.createHelpRequest(
        token,
        message: message,
        volunteerId: volunteer.id,
      );

      if (!mounted) return;
      NotificationService.showMessage(
        context,
        "Help request sent to ${volunteer.name}",
      );
    } catch (err) {
      if (!mounted) return;
      NotificationService.showMessage(
        context,
        err.toString().replaceFirst("Exception: ", ""),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Volunteer Profiles"),
        actions: [
          IconButton(onPressed: _loadVolunteers, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _volunteers.isEmpty
              ? const Center(
                  child: Text("No active volunteers available right now"),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _volunteers.length,
                  itemBuilder: (context, index) {
                    final volunteer = _volunteers[index];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.volunteer_activism)),
                        title: Text(volunteer.name),
                        subtitle: Text(
                          "Availability: ${volunteer.availability} • Voter ID: ${volunteer.voterIdVerified ? "Verified" : "Not verified"}",
                        ),
                        trailing: ElevatedButton(
                          onPressed: () => _sendRequest(volunteer),
                          child: const Text("Send Request"),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
