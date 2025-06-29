import '../models/notification.dart';
import '../services/api_service.dart';

class NotificationsRepository {
  static Future<List<AppNotification>> getNotifications() async {
    try {
      final result = await ApiService.get('notifications');

      if (result['success'] == true) {
        final List<dynamic> notificationsData = result['notifications'] ?? [];
        return notificationsData
            .map((json) => AppNotification.fromJson(json))
            .toList();
      } else {
        throw Exception(
          result['message'] ??
              'Erreur lors de la récupération des notifications',
        );
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  static Future<AppNotification> getNotificationById(int id) async {
    try {
      final result = await ApiService.get('notifications/$id');

      if (result['success'] == true) {
        return AppNotification.fromJson(result['notification']);
      } else {
        throw Exception(
          result['message'] ??
              'Erreur lors de la récupération de la notification',
        );
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  static Future<void> markAsRead(int id) async {
    try {
      final result = await ApiService.put('notifications/$id/read', {});

      if (result['success'] != true) {
        throw Exception(
          result['message'] ?? 'Erreur lors du marquage de la notification',
        );
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  static Future<void> markAllAsRead() async {
    try {
      final result = await ApiService.put('notifications/read-all', {});

      if (result['success'] != true) {
        throw Exception(
          result['message'] ?? 'Erreur lors du marquage des notifications',
        );
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  static Future<void> deleteNotification(int id) async {
    try {
      final result = await ApiService.delete('notifications/$id');

      if (result['success'] != true) {
        throw Exception(
          result['message'] ??
              'Erreur lors de la suppression de la notification',
        );
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  static Future<void> deleteAllNotifications() async {
    try {
      final result = await ApiService.delete('notifications');

      if (result['success'] != true) {
        throw Exception(
          result['message'] ??
              'Erreur lors de la suppression des notifications',
        );
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Méthodes utilitaires pour filtrer les notifications
  static List<AppNotification> filterByType(
    List<AppNotification> notifications,
    String type,
  ) {
    return notifications
        .where(
          (notification) =>
              notification.type.toLowerCase() == type.toLowerCase(),
        )
        .toList();
  }

  static List<AppNotification> filterByReadStatus(
    List<AppNotification> notifications,
    bool lu,
  ) {
    return notifications
        .where((notification) => notification.lu == lu)
        .toList();
  }

  static List<AppNotification> getUnreadNotifications(
    List<AppNotification> notifications,
  ) {
    return filterByReadStatus(notifications, false);
  }

  static List<AppNotification> getReadNotifications(
    List<AppNotification> notifications,
  ) {
    return filterByReadStatus(notifications, true);
  }

  static List<AppNotification> getDemandeNotifications(
    List<AppNotification> notifications,
  ) {
    return filterByType(notifications, 'demande');
  }

  static List<AppNotification> getReclamationNotifications(
    List<AppNotification> notifications,
  ) {
    return filterByType(notifications, 'reclamation');
  }

  static List<AppNotification> getSystemNotifications(
    List<AppNotification> notifications,
  ) {
    return filterByType(notifications, 'system');
  }

  static int getUnreadCount(List<AppNotification> notifications) {
    return getUnreadNotifications(notifications).length;
  }

  // Trier les notifications par date (plus récentes en premier)
  static List<AppNotification> sortByDate(List<AppNotification> notifications) {
    final sorted = List<AppNotification>.from(notifications);
    sorted.sort((a, b) => b.dateEnvoi.compareTo(a.dateEnvoi));
    return sorted;
  }
}
