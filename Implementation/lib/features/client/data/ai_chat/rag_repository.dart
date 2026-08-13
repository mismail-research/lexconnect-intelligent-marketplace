import 'dart:convert';
import 'package:http/http.dart' as http;

class RagRepository {
  final String hfToken;
  final String pineconeApiKey;
  final String pineconeHost;
  final String geminiApiKey;

  RagRepository({
    required this.hfToken,
    required this.pineconeApiKey,
    required this.pineconeHost,
    required this.geminiApiKey,
  });

  Future<List<double>> embedQuery(String query) async {
    final response = await http.post(
      Uri.parse(
        'https://router.huggingface.co/hf-inference/models/sentence-transformers/all-MiniLM-L6-v2/pipeline/feature-extraction',
      ),
      headers: {
        'Authorization': 'Bearer $hfToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'inputs': query}),
    );

    if (response.statusCode != 200) {
      throw Exception('HuggingFace embedding failed: ${response.body}');
    }

    final raw = jsonDecode(response.body);
    if (raw is List && raw.first is List) {
      return (raw.first as List).map((e) => (e as num).toDouble()).toList();
    }
    return (raw as List).map((e) => (e as num).toDouble()).toList();
  }

  Future<List<Map<String, dynamic>>> queryPinecone(List<double> vector) async {
    final response = await http.post(
      Uri.parse('$pineconeHost/query'),
      headers: {
        'Api-Key': pineconeApiKey,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'vector': vector,
        'topK': 5,
        'includeMetadata': true,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Pinecone query failed: ${response.body}');
    }

    final data = jsonDecode(response.body);
    final matches = data['matches'] as List<dynamic>;
    return matches
        .map((m) => m['metadata'] as Map<String, dynamic>)
        .toList();
  }

  // Synchronous — returns real case text directly, zero hallucination
  String generateAnswer(
      String userQuery,
      List<Map<String, dynamic>> docs,
      ) {
    if (docs.isEmpty) {
      return 'I could not find relevant Pakistani case law for this query.';
    }

    final buffer = StringBuffer();
    buffer.writeln('Here is what Pakistani case law says:\n');

    final topDocs = docs.take(3).toList();
    for (var i = 0; i < topDocs.length; i++) {
      final doc = topDocs[i];
      final citation = doc['citation_number'] ?? 'Unknown Citation';
      final text = (doc['text'] as String? ?? '').trim();
      final preview =
      text.length > 300 ? '${text.substring(0, 300)}...' : text;

      buffer.writeln('📄 Case ${i + 1} — $citation');
      buffer.writeln(preview);
      if (i < topDocs.length - 1) buffer.writeln('');
    }

    return buffer.toString().trim();
  }

  Future<String> ragQuery(String userQuery) async {
    final vector = await embedQuery(userQuery);
    final docs = await queryPinecone(vector);
    return generateAnswer(userQuery, docs);
  }

  bool needsCaseLookup(String query) {
    final lower = query.toLowerCase().trim();

    // Never RAG these — handled by Firestore lawyer flow
    final excludePhrases = [
      'find a lawyer', 'get a lawyer', 'need a lawyer',
      'find lawyer', 'get lawyer', 'need lawyer',
      'find me a lawyer', 'i need a lawyer',
      'connect me', 'show me a lawyer', 'recommend a lawyer',
      'suggest a lawyer', 'i want a lawyer',
      'connect me with a lawyer',
      'divorce lawyer', 'criminal lawyer', 'family lawyer',
      'property lawyer', 'corporate lawyer', 'labor lawyer',
      'constitutional lawyer', 'civil lawyer',
    ];
    if (excludePhrases.any((p) => lower.contains(p))) return false;

    // Broad keyword list — any legal topic description triggers RAG
    final caseKeywords = [
      // Legal process
      'case', 'law', 'section', 'act', 'judgment', 'court',
      'precedent', 'ruling', 'legal basis', 'legal',
      'is it legal', 'penalty', 'punishment', 'article', 'constitution',
      'evidence', 'appeal', 'hearing', 'verdict', 'ordinance',
      'legal procedure', 'legal process', 'legal rights', 'rights',
      'supreme court', 'high court', 'court ruling',
      // Family
      'inheritance', 'divorce', 'custody', 'khula', 'marriage',
      'maintenance', 'child support',
      // Property & civil
      'dispute', 'property dispute', 'property', 'real estate',
      'land', 'plot', 'partition', 'rent', 'tenant', 'landlord',
      'lease', 'deed', 'registration', 'will',
      // Criminal
      'fir', 'bail', 'arrest', 'murder', 'theft', 'fraud',
      'assault', 'crime', 'cybercrime',
      // Corporate & labor
      'contract', 'wrongful termination', 'employment', 'salary',
      'workplace', 'business', 'commercial',
      // Constitutional
      'writ', 'fundamental rights', 'human rights',
    ];

    return caseKeywords.any((k) => lower.contains(k));
  }
}