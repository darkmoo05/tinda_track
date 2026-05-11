import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import 'transaction_models.dart';

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
          if (transactionTypeKey != null)
            'transactionTypeKey': transactionTypeKey,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          return TransactionPreviewResponse.fromJson(
            data['data'] as Map<String, dynamic>,
          );
        }
        throw Exception('Preview failed: ${data['error']}');
      }
      throw Exception('Unexpected response status: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('Failed to preview transaction: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  /// Create a new transaction on the server.
  /// Returns transaction details including balance updates.
  /// Throws [DioException] with statusCode 409 if duplicate syncId exists.
  /// Throws [DioException] with statusCode 400 if balance would go negative.
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
        throw Exception('Transaction creation failed: ${data['error']}');
      }
      throw Exception('Unexpected response status: ${response.statusCode}');
    } on DioException catch (e) {
      // Re-throw DioException to preserve status code for caller handling
      if (e.response?.statusCode == 409) {
        throw Exception('Transaction already exists (duplicate syncId)');
      }
      if (e.response?.statusCode == 400) {
        final errorData = e.response?.data as Map<String, dynamic>?;
        throw Exception(
          'Invalid transaction: ${errorData?['message'] ?? e.message}',
        );
      }
      throw Exception('Failed to create transaction: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }
}
