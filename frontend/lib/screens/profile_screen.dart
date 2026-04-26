import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../widgets/custom_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  bool _voterIdVerified = false;
  bool _isAnonymous = false;
  bool _prefilled = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    try {
      final auth = context.read<AuthService>();
      await auth.updateProfile(
        name: _nameController.text.trim(),
        voterIdVerified: _voterIdVerified,
        isAnonymous: _isAnonymous,
      );
      if (!mounted) return;
      NotificationService.showMessage(context, 'Profile setup complete');
    } catch (err) {
      if (!mounted) return;
      NotificationService.showMessage(context, err.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.currentUser;

    if (!_prefilled && user != null) {
      _prefilled = true;
      _nameController.text = user.name;
      _voterIdVerified = user.voterIdVerified;
      _isAnonymous = user.isAnonymous;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Profile'),
        actions: [
          TextButton(
            onPressed: auth.loading ? null : () => auth.logout(),
            child: const Text('Logout'),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              children: [
                const Text('Create Profile', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Full name')),
                const SizedBox(height: 12),
                SwitchListTile(
                  value: _voterIdVerified,
                  onChanged: (value) => setState(() => _voterIdVerified = value),
                  title: const Text('Optional Voter ID verification completed'),
                ),
                SwitchListTile(
                  value: _isAnonymous,
                  onChanged: (value) => setState(() => _isAnonymous = value),
                  title: const Text('Use anonymous posting by default'),
                ),
                const SizedBox(height: 16),
                CustomButton(
                  label: 'Save and Continue',
                  onPressed: _save,
                  loading: auth.loading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
