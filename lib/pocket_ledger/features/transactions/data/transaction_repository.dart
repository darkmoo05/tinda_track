import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import 'transaction_models.dart';

class TransactionApiException implements Exception {
  const TransactionApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() {
    if (statusCode == null) {
      return message;
    }
    return '$message (status: $statusCode)';
  }
}

class TransactionRepository {
  TransactionRepository._();

  static final TransactionRepository instance = TransactionRepository._();

  final ApiClient _apiClient = ApiClient.instance;

  /// Preview a transaction without creating it.
  /// Returns transaction breakdown including charges, balances, and fee routing info.
  Future<TransactionPreviewResponse> previewTransaction({
    required String walletProvider,
    required String direction,
    required double amount,
    String chargeHandling = 'addOnTop',
    String? transactionTypeKey,
  }) async {
    try {
      final response = await _apiClient.get(
        '/transactions/preview',
        params: {
          'walletProvider': walletProvider,
          'direction': direction,
          'amount': amount,
          'chargeHandling': chargeHandling,
          ...?transactionTypeKey == null
              ? null
              : {'transactionTypeKey': transactionTypeKey},
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          return TransactionPreviewResponse.fromJson(
            data['data'] as Map<String, dynamic>,
          );
        }
        throw TransactionApiException('Preview failed: ${data['error']}');
      }
      throw TransactionApiException(
        'Unexpected response status from preview',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      final responseData = e.response?.data;
      final serverMessage = responseData is Map<String, dynamic>
          ? (responseData['message'] ?? responseData['error']) as String?
          : null;
      throw TransactionApiException(
        serverMessage ?? 'Failed to preview transaction: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Create a new transaction on the server.
  /// Returns transaction details including balance updates.
  /// Throws [TransactionApiException] with statusCode 409 if duplicate syncId exists.
  /// Throws [TransactionApiException] with statusCode 400 if balance would go negative.
  Future<TransactionCreateResponse> createTransaction({
    required String walletProvider,
    required String direction,
    required double amount,
    required String chargeHandling,
    String? deviceId,
    String? syncId,
    String? reference,
    String? note,
    String? entryDate,
    String? externalProvider,
    String? externalTransactionId,
    String? transactionTypeKey,
  }) async {
    try {
      final request = TransactionCreateRequest(
        walletProvider: walletProvider,
        direction: direction,
        amount: amount,
        chargeHandling: chargeHandling,
        deviceId: deviceId,
        syncId: syncId,
        reference: reference,
        note: note,
        entryDate: entryDate,
        externalProvider: externalProvider,
        externalTransactionId: externalTransactionId,
        transactionTypeKey: transactionTypeKey,
      );

      final response = await _apiClient.post('/transactions', request.toJson());

      if (response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          return TransactionCreateResponse.fromJson(
            data['data'] as Map<String, dynamic>,
          );
        }
        throw TransactionApiException(
          'Transaction creation failed: ${data['error']}',
        );
      }
      throw TransactionApiException(
        'Unexpected response status while creating transaction',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw const TransactionApiException(
          'Transaction already exists (duplicate syncId)',
          statusCode: 409,
        );
      }
      if (e.response?.statusCode == 400) {
        final errorData = e.response?.data as Map<String, dynamic>?;
        throw TransactionApiException(
          'Invalid transaction: ${errorData?['message'] ?? e.message}',
          statusCode: 400,
        );
      }
      throw TransactionApiException(
        'Failed to create transaction: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch latest transactions from server.
  Future<List<TransactionListItem>> listTransactions({
    String? walletProvider,
    String? direction,
    int limit = 20,
    String? status,
  }) async {
    try {
      final response = await _apiClient.get(
        '/transactions',
        params: {
          if (walletProvider != null) 'walletProvider': walletProvider,
          if (direction != null) 'direction': direction,
          'limit': limit,
          if (status != null) 'status': status,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] is List) {
          final rows = data['data'] as List<dynamic>;
          return rows
              .whereType<Map<String, dynamic>>()
              .map(TransactionListItem.fromJson)
              .toList(growable: false);
        }
        throw TransactionApiException('Transaction list failed');
      }

      throw TransactionApiException(
        'Unexpected response status while listing transactions',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      final responseData = e.response?.data;
      final serverMessage = responseData is Map<String, dynamic>
          ? (responseData['message'] ?? responseData['error']) as String?
          : null;
      throw TransactionApiException(
        serverMessage ?? 'Failed to list transactions: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      rethrow;
    }
  }
}
