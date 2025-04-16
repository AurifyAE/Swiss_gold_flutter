import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:swiss_gold/core/models/transaction_model.dart';
import 'package:swiss_gold/core/models/user_model.dart';
import 'package:swiss_gold/core/services/transaction_service.dart';
import 'package:swiss_gold/core/utils/enum/view_state.dart';
import 'package:swiss_gold/core/services/local_storage.dart';

class TransactionViewModel extends ChangeNotifier {
  TransactionService? _transactionService;
  UserModel? _user;
  
  ViewState _state = ViewState.idle;
  ViewState get state => _state;
  
  ViewState _paginationState = ViewState.idle;
  ViewState get paginationState => _paginationState;
  
  TransactionData? _transactionData;
  TransactionData? get transactionData => _transactionData;
  
  List<Transaction> _transactions = [];
  List<Transaction> get transactions => _transactions;
  
  BalanceInfo? get balanceInfo => _transactionData?.balanceInfo;
  Summary? get summary => _transactionData?.summary;
  Pagination? get pagination => _transactionData?.pagination;
  
  String _selectedFilter = 'All';
  String get selectedFilter => _selectedFilter;
  
  bool _isAscending = false;
  bool get isAscending => _isAscending;
  
  bool get loadingMore => _paginationState == ViewState.loadingMore;
  
  bool _isGuest = false;
  bool get isGuest => _isGuest;
  
  // Constructor that safely initializes with user ID validation
  TransactionViewModel({UserModel? user}) {
    initializeWithUser(user);
    checkGuestMode();
  }
  
  // Initialize with user validation
  void initializeWithUser(UserModel? user) {
    // Only set user if it has a valid user ID
    if (user != null && user.userId.isNotEmpty) {
      _user = user;
      _transactionService = TransactionService(user: user);
      log('TransactionViewModel initialized with user ID: ${user.userId}');
    } else {
      log('Warning: Attempted to initialize TransactionViewModel with invalid user');
      // Try to get user from local storage as fallback
      _loadUserFromStorage();
    }
  }
  
  // Fallback method to load user from storage if needed
  Future<void> _loadUserFromStorage() async {
    try {
      // Try to get user ID from local storage
      final String? userId = await LocalStorage.getString('userId');
      
      if (userId != null && userId.isNotEmpty) {
        log('Loaded user ID from storage: $userId');
        // Create a basic user model with the ID
        _user = UserModel(
          userId: userId,
          message: 'User loaded from storage',
          success: true
        );
        _transactionService = TransactionService(user: _user!);
        log('TransactionService created with user ID: $userId');
      } else {
        log('No user ID found in storage');
      }
    } catch (e) {
      log('Error loading user from storage: $e');
    }
  }
  
  // Method to update user
  void updateUser(UserModel user) {
    if (user.userId.isEmpty) {
      log('Warning: Attempted to update with invalid user ID');
      return;
    }
    
    _user = user;
    _transactionService = TransactionService(user: user);
    log('User updated with ID: ${user.userId}');
    notifyListeners();
  }
  
  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }
  
  void toggleSortOrder() {
    _isAscending = !_isAscending;
    
    // Sort transactions based on date
    _transactions.sort((a, b) {
      return _isAscending ? a.createdAt.compareTo(b.createdAt) : b.createdAt.compareTo(a.createdAt);
    });
    
    notifyListeners();
  }
  
  List<Transaction> get filteredTransactions {
    if (_selectedFilter == 'All') {
      return _transactions;
    } else if (_selectedFilter == 'Gold') {
      return _transactions.where((t) => t.balanceType == 'GOLD').toList();
    } else if (_selectedFilter == 'Cash') {
      return _transactions.where((t) => t.balanceType == 'CASH').toList();
    } else if (_selectedFilter == 'Credit') {
      return _transactions.where((t) => t.type == 'CREDIT').toList();
    } else if (_selectedFilter == 'Debit') {
      return _transactions.where((t) => t.type == 'DEBIT').toList();
    }
    return _transactions;
  }

Future<bool> ensureUserInitialized() async {
  // If already initialized, return true
  if (_user != null && _transactionService != null && _user!.userId.isNotEmpty) {
    return true;
  }
  
  // Try to load from storage
  await _loadUserFromStorage();
  
  // Check if successfully initialized after loading
  return _user != null && _transactionService != null && _user!.userId.isNotEmpty;
}
  
Future<void> fetchTransactions() async {
  // First ensure user is initialized
  bool isInitialized = await ensureUserInitialized();
  
  if (!isInitialized) {
    log('Cannot fetch transactions: Failed to initialize user');
    _state = ViewState.error;
    notifyListeners();
    return;
  }
  
  // Rest of your existing fetchTransactions code...
  _state = ViewState.loading;
  notifyListeners();
    
    try {
      final response = await _transactionService!.fetchTransactions();
      
      if (response != null && response.success) {
        _transactionData = response.data;
        _transactions = response.data.transactions;
        
        // Sort transactions by default (newest first)
        if (!_isAscending) {
          _transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        } else {
          _transactions.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        }
        
        _state = ViewState.idle;
      } else {
        _state = ViewState.error;
      }
    } catch (e) {
      log('Error in transaction view model: $e');
      _state = ViewState.error;
    }
    
    notifyListeners();
  }
  
  Future<void> loadMoreTransactions() async {
    if (_user == null || _transactionService == null || _user!.userId.isEmpty) {
      log('Cannot load more transactions: Invalid user configuration');
      return;
    }
    
    if (_transactionData == null || 
        _paginationState == ViewState.loadingMore ||
        (pagination != null && pagination!.currentPage >= pagination!.totalPages)) {
      return;
    }
    
    _paginationState = ViewState.loadingMore;
    notifyListeners();
    
    try {
      final nextPage = pagination!.currentPage + 1;
      final response = await _transactionService!.fetchTransactions(page: nextPage);
      
      if (response != null && response.success) {
        _transactionData = response.data;
        
        // Sort new transactions based on current sort order before adding
        final newTransactions = response.data.transactions;
        if (!_isAscending) {
          newTransactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        } else {
          newTransactions.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        }
        
        _transactions.addAll(newTransactions);
        _paginationState = ViewState.idle;
      } else {
        _paginationState = ViewState.error;
      }
    } catch (e) {
      log('Error loading more transactions: $e');
      _paginationState = ViewState.error;
    }
    
    notifyListeners();
  }
  
  Future<void> checkGuestMode() async {
    try {
      _isGuest = await LocalStorage.getBool('isGuest') ?? false;
      log('Guest mode: $_isGuest');
    } catch (e) {
      log('Error checking guest mode: ${e.toString()}');
      _isGuest = false;
    }
    notifyListeners();
  }
  
  void refreshTransactions() {
    if (_user == null || _transactionService == null || _user!.userId.isEmpty) {
      log('Cannot refresh transactions: Invalid user configuration');
      return;
    }
    _transactions = [];
    fetchTransactions();
  }
}