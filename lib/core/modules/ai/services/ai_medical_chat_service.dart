import '../../../network/api_endpoints.dart';
import '../../../network/base_api_service.dart';
import '../../../network/network_result.dart';
// import '../../../network/paginated_response.dart';
// import '../../medication/models/medical_report_model.dart';
// import '../models/fertility_test_model.dart';

/// Wraps all medical-ai-chat API calls:
class AIMedicalChatService extends BaseApiService {
  const AIMedicalChatService(super.client);

  // ─── Reference data ───────────────────────────────────────────────────────

  /**
   * Sends a text message to the AI medical chat endpoint and returns the AI's response.
   * Parameters:
   * - [text]: The text message to send to the AI medical chat.
   * Returns:
   * - A [NetworkResult] containing the AI's response as a string if successful, 
   * or an error message if the request fails.
   */
  Future<String> sendTextToAIMedicalChat(String text) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        ApiEndpoints.aiMedicalChatSendText,
        queryParameters: {'text': text},
      );

      return response.data!['result'] as String;
    } catch (e) {
      print('Error sending text to AI Medical Chat: $e');
      return '';
    }
  }
}
