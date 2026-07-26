import 'dart:convert';
import 'package:http/http.dart' as http;

class RxTermsService {
  static const String baseUrl =
      'https://clinicaltables.nlm.nih.gov/api/rxterms/v3/search';

  /// Search for medications using the RxTerms API
  /// Returns a list of medication names
  static Future<List<String>> searchMedications(String query) async {
    if (query.isEmpty) {
      return [];
    }

    try {
      final uri = Uri.parse('$baseUrl?terms=$query');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // The API returns: [total_count, [suggestions], {extra_data}, [terms]]
        // We want the terms array (index 3)
        if (data is List && data.length > 3) {
          final terms = data[3] as List;
          return terms.map((term) => term.toString()).toList();
        }

        return [];
      } else {
        throw Exception('Failed to load medications: ${response.statusCode}');
      }
    } catch (e) {
      return [];
    }
  }

  /// Search with additional details
  /// Returns a list of maps containing name and other details
  static Future<List<MedicationSuggestion>> searchMedicationsDetailed(
    String query,
  ) async {
    if (query.isEmpty) {
      return [];
    }

    try {
      final uri = Uri.parse('$baseUrl?terms=$query&ef=DISPLAY_NAME,RXCUIS');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List && data.length > 3) {
          final terms = data[3] as List;
          return terms.map((term) {
            return MedicationSuggestion(name: term.toString());
          }).toList();
        }

        return [];
      } else {
        throw Exception('Failed to load medications: ${response.statusCode}');
      }
    } catch (e) {
      return [];
    }
  }
}

class MedicationSuggestion {
  final String name;
  final String? rxcui;

  MedicationSuggestion({required this.name, this.rxcui});

  @override
  String toString() => name;
}
