/// Subscribers Screen — Manage Telegram subscribers

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_provider.dart';
import '../theme.dart';

class SubscribersScreen extends StatefulWidget {
  const SubscribersScreen({super.key});

  @override
  State<SubscribersScreen> createState() => _SubscribersScreenState();
}

class _SubscribersScreenState extends State<SubscribersScreen> {
  List<Subscriber> _subscribers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSubscribers();
  }

  Future<void> _loadSubscribers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final provider = context.read<AppProvider>();
      final rawList = await provider.apiService.getSubscribersRaw();
      setState(() {
        _subscribers = rawList.map((s) => Subscriber.fromJson(s)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addSubscriber() async {
    final result = await showDialog<Subscriber>(
      context: context,
      builder: (context) => const AddSubscriberDialog(),
    );

    if (result != null) {
      try {
        final provider = context.read<AppProvider>();
        await provider.apiService.addSubscriber(
          chatId: result.chatId,
          role: result.role,
          accountId: result.accountId,
        );
        _loadSubscribers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added subscriber ${result.chatId}'),
              backgroundColor: AppTheme.primaryGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add: $e'),
              backgroundColor: AppTheme.primaryRed,
            ),
          );
        }
      }
    }
  }

  Future<void> _editSubscriber(Subscriber subscriber) async {
    final result = await showDialog<Subscriber>(
      context: context,
      builder: (context) => AddSubscriberDialog(existing: subscriber),
    );

    if (result != null) {
      try {
        final provider = context.read<AppProvider>();
        await provider.apiService.updateSubscriber(
          chatId: subscriber.chatId,
          role: result.role,
          accountId: result.accountId,
        );
        _loadSubscribers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Updated subscriber ${subscriber.chatId}'),
              backgroundColor: AppTheme.primaryGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update: $e'),
              backgroundColor: AppTheme.primaryRed,
            ),
          );
        }
      }
    }
  }

  Future<void> _removeSubscriber(Subscriber subscriber) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Subscriber'),
        content: Text(
          'Remove ${subscriber.username ?? subscriber.chatId} from notifications?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.primaryRed),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final provider = context.read<AppProvider>();
        await provider.apiService.removeSubscriber(subscriber.chatId);
        _loadSubscribers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Removed ${subscriber.chatId}'),
              backgroundColor: AppTheme.primaryGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to remove: $e'),
              backgroundColor: AppTheme.primaryRed,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscribers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSubscribers,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSubscriber,
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.person_add, color: Colors.black),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppTheme.primaryRed),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSubscribers,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_subscribers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No subscribers yet',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add Telegram chat IDs to receive alerts',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSubscribers,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _subscribers.length,
        itemBuilder: (context, index) {
          final subscriber = _subscribers[index];
          return _SubscriberCard(
            subscriber: subscriber,
            onEdit: () => _editSubscriber(subscriber),
            onRemove: () => _removeSubscriber(subscriber),
          );
        },
      ),
    );
  }
}

class _SubscriberCard extends StatelessWidget {
  final Subscriber subscriber;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  const _SubscriberCard({
    required this.subscriber,
    required this.onEdit,
    required this.onRemove,
  });

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'superadmin':
        return Colors.purple;
      case 'admin':
        return AppTheme.primaryGreen;
      case 'readonly':
      default:
        return AppTheme.textSecondary;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'superadmin':
        return Icons.admin_panel_settings;
      case 'admin':
        return Icons.manage_accounts;
      case 'readonly':
      default:
        return Icons.visibility;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar with role icon
            CircleAvatar(
              backgroundColor: _getRoleColor(subscriber.role).withOpacity(0.2),
              child: Icon(
                _getRoleIcon(subscriber.role),
                color: _getRoleColor(subscriber.role),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subscriber.username ?? 'Chat ${subscriber.chatId}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getRoleColor(subscriber.role).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          subscriber.role.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _getRoleColor(subscriber.role),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        subscriber.accountId,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (subscriber.chatId.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${subscriber.chatId}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Actions
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: onEdit,
              color: AppTheme.textSecondary,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: onRemove,
              color: AppTheme.primaryRed,
            ),
          ],
        ),
      ),
    );
  }
}

class AddSubscriberDialog extends StatefulWidget {
  final Subscriber? existing;

  const AddSubscriberDialog({super.key, this.existing});

  @override
  State<AddSubscriberDialog> createState() => _AddSubscriberDialogState();
}

class _AddSubscriberDialogState extends State<AddSubscriberDialog> {
  late TextEditingController _chatIdController;
  late TextEditingController _accountIdController;
  String _selectedRole = 'readonly';

  final _roles = ['readonly', 'admin', 'superadmin'];

  @override
  void initState() {
    super.initState();
    _chatIdController = TextEditingController(
      text: widget.existing?.chatId ?? '',
    );
    _accountIdController = TextEditingController(
      text: widget.existing?.accountId ?? 'default',
    );
    _selectedRole = widget.existing?.role ?? 'readonly';
  }

  @override
  void dispose() {
    _chatIdController.dispose();
    _accountIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Subscriber' : 'Add Subscriber'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chat ID
            TextField(
              controller: _chatIdController,
              decoration: const InputDecoration(
                labelText: 'Telegram Chat ID',
                hintText: 'e.g., 123456789',
                prefixIcon: Icon(Icons.telegram),
              ),
              keyboardType: TextInputType.number,
              enabled: !isEditing,
            ),
            const SizedBox(height: 16),

            // Role dropdown
            const Text(
              'Role',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.borderColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedRole,
                  isExpanded: true,
                  items: _roles.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Row(
                        children: [
                          Icon(
                            _getRoleIcon(role),
                            size: 18,
                            color: _getRoleColor(role),
                          ),
                          const SizedBox(width: 8),
                          Text(role.toUpperCase()),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedRole = value);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Account ID
            TextField(
              controller: _accountIdController,
              decoration: const InputDecoration(
                labelText: 'Account ID',
                hintText: 'default',
                prefixIcon: Icon(Icons.account_circle),
              ),
            ),
            const SizedBox(height: 8),

            // Role descriptions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.bgSecondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Role Permissions:',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '• readonly: View alerts only\n'
                    '• admin: Execute trades, view status\n'
                    '• superadmin: Full control + settings',
                    style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final chatId = _chatIdController.text.trim();
            if (chatId.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chat ID is required')),
              );
              return;
            }

            Navigator.pop(
              context,
              Subscriber(
                chatId: chatId,
                username: null,
                role: _selectedRole,
                accountId: _accountIdController.text.trim().isEmpty
                    ? 'default'
                    : _accountIdController.text.trim(),
              ),
            );
          },
          child: Text(isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'superadmin':
        return Colors.purple;
      case 'admin':
        return AppTheme.primaryGreen;
      case 'readonly':
      default:
        return AppTheme.textSecondary;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'superadmin':
        return Icons.admin_panel_settings;
      case 'admin':
        return Icons.manage_accounts;
      case 'readonly':
      default:
        return Icons.visibility;
    }
  }
}

/// Subscriber model
class Subscriber {
  final String chatId;
  final String? username;
  final String role;
  final String accountId;
  final String? createdAt;

  Subscriber({
    required this.chatId,
    this.username,
    required this.role,
    required this.accountId,
    this.createdAt,
  });

  factory Subscriber.fromJson(Map<String, dynamic> json) {
    return Subscriber(
      chatId: json['chat_id'] as String,
      username: json['username'] as String?,
      role: json['role'] as String? ?? 'readonly',
      accountId: json['account_id'] as String? ?? 'default',
      createdAt: json['created_at'] as String?,
    );
  }
}
