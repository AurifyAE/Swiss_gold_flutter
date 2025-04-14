// lib/providers/notification_provider.dart

import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notifications = await _notificationService.getNotifications();
      _calculateUnreadCount();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final success = await _notificationService.markNotificationAsRead(notificationId);
      
      if (success) {
        // Update local state
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          _notifications[index] = _notifications[index].copyWith(read: true);
          _calculateUnreadCount();
          notifyListeners();
        }
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void _calculateUnreadCount() {
    _unreadCount = _notifications.where((notification) => !notification.read).length;
  }

  // Method to get a specific notification by ID
  NotificationModel? getNotificationById(String id) {
    try {
      return _notifications.firstWhere((notification) => notification.id == id);
    } catch (e) {
      return null;
    }
  }
}