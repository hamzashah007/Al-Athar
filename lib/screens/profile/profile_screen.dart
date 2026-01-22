import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_widget.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _loading = false;
  String? _error;
  XFile? _pickedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        setState(() => _pickedImage = picked);
        // TODO: Upload to Firebase Storage and update user photoURL
      }
    } catch (e) {
      setState(() => _error = 'Failed to pick image.');
    }
  }

  Future<void> _editName(User user) async {
    final controller = TextEditingController(text: user.displayName ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty && result != user.displayName) {
      setState(() {
        _loading = true;
        _error = null;
      });
      try {
        await user.updateDisplayName(result);
        setState(() {
          _loading = false;
        });
        if (mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Name updated!')));
      } catch (e) {
        setState(() {
          _loading = false;
          _error = 'Failed to update name.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(firebaseAuthProvider).currentUser;
    final isGuest = user == null || (user.isAnonymous == true);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: _loading
          ? const CustomLoadingWidget(message: 'Updating profile...')
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedScale(
                      scale: 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundImage: _pickedImage != null
                                ? Image.file(
                                    File(_pickedImage!.path),
                                    fit: BoxFit.cover,
                                  ).image
                                : (user?.photoURL != null && !isGuest)
                                ? NetworkImage(user.photoURL!)
                                : const AssetImage('assets/icon.png')
                                      as ImageProvider,
                          ),
                          if (!isGuest)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Material(
                                color: Colors.transparent,
                                child: IconButton(
                                  icon: const Icon(Icons.camera_alt, size: 22),
                                  onPressed: _pickImage,
                                  tooltip: 'Change Profile Picture',
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      isGuest ? 'Guest Mode' : (user.displayName ?? 'No Name'),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isGuest
                          ? 'You are using the app as a guest.'
                          : (user.email ?? 'No Email'),
                      style: theme.textTheme.bodyMedium,
                    ),
                    if (!isGuest) ...[
                      const SizedBox(height: 18),
                      CustomButton.elevated(
                        text: 'Edit Name',
                        icon: const Icon(Icons.edit),
                        onPressed: _loading ? null : () => _editName(user),
                      ),
                    ],
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}
