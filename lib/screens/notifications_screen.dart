import 'package:flutter/material.dart';
import 'package:app_gestion/theme/colors.dart';
import 'package:app_gestion/models/notification.dart';
import 'package:app_gestion/repositories/notifications_repository.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = false;
  List<AppNotification> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final notifications = await NotificationsRepository.getNotifications();
      if (mounted) {
        setState(() {
          _notifications = NotificationsRepository.sortByDate(notifications);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _markAsRead(AppNotification notification) async {
    try {
      await NotificationsRepository.markAsRead(notification.id);
      // Recharger les notifications
      await _loadNotifications();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await NotificationsRepository.markAllAsRead();
      await _loadNotifications();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Toutes les notifications ont été marquées comme lues'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteNotification(AppNotification notification) async {
    try {
      await NotificationsRepository.deleteNotification(notification.id);
      await _loadNotifications();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification supprimée'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = NotificationsRepository.getUnreadCount(_notifications);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: kSenelecBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Tout marquer',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(kSenelecBlue),
                ),
              )
              : _notifications.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Aucune notification',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Vous n\'avez pas encore de notifications',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadNotifications,
                color: kSenelecBlue,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: notification.lu ? 1 : 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color:
                          notification.lu
                              ? Colors.white
                              : kSenelecBlue.withOpacity(0.05),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                notification.lu
                                    ? Colors.grey.shade200
                                    : kSenelecBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            notification.typeIcon,
                            color:
                                notification.lu
                                    ? Colors.grey.shade600
                                    : kSenelecBlue,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          notification.message,
                          style: TextStyle(
                            fontWeight:
                                notification.lu
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 12,
                                  color: Colors.grey.shade500,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  notification.timeAgo,
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    notification.typeDisplay,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            switch (value) {
                              case 'read':
                                _markAsRead(notification);
                                break;
                              case 'delete':
                                _deleteNotification(notification);
                                break;
                            }
                          },
                          itemBuilder:
                              (context) => [
                                if (!notification.lu)
                                  const PopupMenuItem(
                                    value: 'read',
                                    child: Row(
                                      children: [
                                        Icon(Icons.mark_email_read),
                                        SizedBox(width: 8),
                                        Text('Marquer comme lu'),
                                      ],
                                    ),
                                  ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text(
                                        'Supprimer',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                        ),
                        onTap: () {
                          if (!notification.lu) {
                            _markAsRead(notification);
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
