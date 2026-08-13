import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:lexbid/core/constants/api_keys.dart';
import 'package:lexbid/features/client/bloc/ai_chat/ai_chat_event.dart';
import 'package:lexbid/features/client/bloc/ai_chat/ai_chat_state.dart';
import 'package:lexbid/features/client/data/ai_chat/models/chat_message.dart';
import 'package:lexbid/features/client/data/ai_chat/models/lawyer_match.dart';
import 'package:lexbid/features/client/data/ai_chat/rag_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kSessionKey = 'lexbid_chat_session';
const _kSessionStartKey = 'lexbid_chat_session_start';

const _lawyerTypeAliases = {
  'criminal': ['criminal', 'crime', 'murder', 'theft', 'fraud', 'assault', 'fir', 'bail'],
  'civil': [
    'civil', 'dispute', 'property dispute', 'property', 'real estate',
    'land', 'plot', 'housing', 'rent', 'lease', 'damages', 'compensation',
  ],
  'family': ['family', 'divorce', 'custody', 'marriage', 'khula', 'inheritance', 'maintenance'],
  'corporate': ['corporate', 'business', 'company', 'contract', 'commercial', 'startup'],
  'labor': ['labor', 'labour', 'employment', 'job', 'workplace', 'wrongful termination'],
  'constitutional': ['constitutional', 'human rights', 'fundamental rights', 'writ'],
};

const _systemPrompt = '''You are LexBid AI, a professional legal assistant for a Pakistani legal services app.

YOUR CONVERSATION FLOW — follow this strictly:

STEP 1 — When user greets or says hi:
- Respond warmly and ask what legal issue they are facing
- Do NOT add "FETCH_LAWYERS"

STEP 2 — When user describes a legal issue:
- Give 2-3 sentences of relevant legal advice
- Ask ONE follow-up question to understand their case better if needed
- Do NOT add "FETCH_LAWYERS" yet

STEP 3 — Only when you have enough context AND the user is ready to connect with a lawyer:
- Give a final short recommendation
- Add "FETCH_LAWYERS" on a new line at the very end
- Always add "LAWYER_TYPE:[type]" on the same line as FETCH_LAWYERS
- Replace [type] with exactly one of these values based on the user's issue:
  criminal | civil | family | corporate | labor | constitutional
- Example: FETCH_LAWYERS LAWYER_TYPE:criminal

WHEN TO ADD "FETCH_LAWYERS":
- ONLY when the user has clearly described their legal problem
- ONLY when they explicitly want to find or connect with a lawyer
- NEVER on the first message
- NEVER without a LAWYER_TYPE tag

LAWYER TYPE SELECTION RULES:
- criminal → FIR, bail, murder, theft, fraud, assault, cybercrime
- civil → general disputes, compensation, damages, property disputes, land, rent, real estate
- family → divorce, custody, khula, marriage, inheritance, child support
- corporate → business contracts, company registration, commercial disputes
- labor → wrongful termination, salary disputes, workplace issues
- constitutional → fundamental rights, writ petitions, human rights

STRICT RULES:
- ONLY answer legal questions. For anything else respond exactly: "IRRELEVANT: I can only assist with legal matters. Please describe your legal issue and I will help you find the right lawyer."
- Keep all responses under 3 sentences
- Always respond in English only
- Never make up laws or cases
- Never add FETCH_LAWYERS without the user describing their actual issue
- Never add FETCH_LAWYERS without a LAWYER_TYPE tag''';

class AIChatBloc extends Bloc<AIChatEvent, AIChatState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final RagRepository _ragRepository;
  Timer? _purgeTimer;

  // Groq conversation history
  final List<Map<String, String>> _conversationHistory = [];

  AIChatBloc() : super(const AIChatState()) {
    _ragRepository = RagRepository(
      hfToken: ApiKeys.huggingFaceToken,
      pineconeApiKey: ApiKeys.pineconeApiKey,
      pineconeHost: ApiKeys.pineconeHost,
      geminiApiKey: ApiKeys.geminiApiKey,
    );

    on<LoadInitialChat>(_onLoadInitialChat);
    on<SendMessage>(_onSendMessage);
    on<SendLegalCaseQuery>(_onSendLegalCaseQuery);
    on<FetchMoreLawyers>(_onFetchMoreLawyers);
    on<PurgeExpiredSession>(_onPurgeExpiredSession);
    on<DeleteConversation>(_onDeleteConversation);

    _purgeTimer = Timer.periodic(
      const Duration(hours: 1),
          (_) => add(PurgeExpiredSession()),
    );
  }

  // ── Groq API call ─────────────────────────────────────────────────────────

  Future<String> _callGroq(String userMessage) async {
    _conversationHistory.add({'role': 'user', 'content': userMessage});

    final messages = [
      {'role': 'system', 'content': _systemPrompt},
      ..._conversationHistory,
    ];

    final response = await http.post(
      Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer ${ApiKeys.groqApiKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'llama-3.3-70b-versatile',
        'messages': messages,
        'max_tokens': 512,
        'temperature': 0.3,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Groq failed: ${response.body}');
    }

    final data = jsonDecode(response.body);
    final reply = data['choices'][0]['message']['content'] as String;

    // Add assistant reply to history for context
    _conversationHistory.add({'role': 'assistant', 'content': reply});

    // Keep history manageable — last 10 messages
    if (_conversationHistory.length > 10) {
      _conversationHistory.removeRange(0, _conversationHistory.length - 10);
    }

    return reply;
  }

  // ── RAG + Groq Handler ────────────────────────────────────────────────────

  Future<void> _onSendLegalCaseQuery(
      SendLegalCaseQuery event,
      Emitter<AIChatState> emit,
      ) async {
    print('🚀 SendLegalCaseQuery received: "${event.text}"');

    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(_kSessionStartKey) == null) {
      await prefs.setString(_kSessionStartKey, DateTime.now().toIso8601String());
    }

    final userMsg = ChatMessage(text: event.text, isUser: true);
    final withUser = [...state.messages, userMsg];
    emit(state.copyWith(messages: withUser, isAiTyping: true));
    await _saveSession(withUser);

    try {
      if (_ragRepository.needsCaseLookup(event.text)) {
        print('📚 Going through RAG pipeline...');

        emit(state.copyWith(
          messages: withUser,
          isAiTyping: true,
          ragStatus: RagStatus.embedding,
        ));
        final vector = await _ragRepository.embedQuery(event.text);
        print('✅ Embedding done. Vector length: ${vector.length}');

        emit(state.copyWith(
          messages: withUser,
          isAiTyping: true,
          ragStatus: RagStatus.searching,
        ));
        final docs = await _ragRepository.queryPinecone(vector);
        print('✅ Pinecone returned ${docs.length} docs');

        emit(state.copyWith(
          messages: withUser,
          isAiTyping: true,
          ragStatus: RagStatus.generating,
        ));

        // No API call — instant, zero hallucination
        final ragAnswer = _ragRepository.generateAnswer(event.text, docs);
        print('✅ Answer generated from case law');

        final withRagAnswer = [
          ...withUser,
          ChatMessage(text: ragAnswer, isUser: false),
        ];

        emit(state.copyWith(
          messages: withRagAnswer,
          isAiTyping: false,
          ragStatus: RagStatus.idle,
        ));
        await _saveSession(withRagAnswer);

      } else {
        // Normal Groq conversational flow
        print('💬 Routing to Groq flow');
        emit(state.copyWith(ragStatus: RagStatus.idle));

        final rawResponse = await _callGroq(event.text);
        print('🤖 Groq raw response: $rawResponse');

        if (rawResponse.startsWith('IRRELEVANT:')) {
          final cleanMsg = rawResponse.replaceFirst('IRRELEVANT:', '').trim();
          final updated = [
            ...withUser,
            ChatMessage(text: cleanMsg, isUser: false),
          ];
          emit(state.copyWith(messages: updated, isAiTyping: false));
          await _saveSession(updated);
          return;
        }

        final shouldFetchLawyers = rawResponse.contains('FETCH_LAWYERS');
        String? lawyerType = _extractLawyerType(rawResponse) ??
            _inferLawyerTypeFromText(event.text);

        final cleanResponse = rawResponse
            .replaceAll(RegExp(r'FETCH_LAWYERS'), '')
            .replaceAll(RegExp(r'LAWYER_TYPE:\w+'), '')
            .trim();

        if (shouldFetchLawyers) {
          List<ChatMessage> base = withUser;
          if (cleanResponse.isNotEmpty) {
            base = [
              ...withUser,
              ChatMessage(text: cleanResponse, isUser: false),
            ];
            emit(state.copyWith(messages: base, isAiTyping: true));
            await _saveSession(base);
            await Future.delayed(const Duration(milliseconds: 500));
          }
          await _emitLawyerCards(emit, base, lawyerType);
        } else {
          if (cleanResponse.isNotEmpty) {
            final updated = [
              ...withUser,
              ChatMessage(text: cleanResponse, isUser: false),
            ];
            emit(state.copyWith(messages: updated, isAiTyping: false));
            await _saveSession(updated);
          }
        }
      }
    } catch (e) {
      print('❌ Error: $e');
      final updated = [
        ...withUser,
        ChatMessage(
          text: 'Sorry, I am having trouble responding right now. Please try again.',
          isUser: false,
        ),
      ];
      emit(state.copyWith(
        messages: updated,
        isAiTyping: false,
        ragStatus: RagStatus.idle,
      ));
      await _saveSession(updated);
    }
  }

  // ── Shared helper: fetch lawyers and emit cards ───────────────────────────

  Future<void> _emitLawyerCards(
      Emitter<AIChatState> emit,
      List<ChatMessage> base,
      String? lawyerType,
      ) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final lawyers = await _fetchTopLawyers(
      state.shownLawyerIds,
      lawyerType: lawyerType,
    );

    if (lawyers.isNotEmpty) {
      final newShownIds = [
        ...state.shownLawyerIds,
        ...lawyers.map((l) => l.id),
      ];
      final withCards = [
        ...base,
        ChatMessage(
          text: '',
          isUser: false,
          isLawyerCard: true,
          lawyers: lawyers,
        ),
      ];
      emit(state.copyWith(
        messages: withCards,
        isAiTyping: false,
        shownLawyerIds: newShownIds,
        lastLawyerType: lawyerType,
        ragStatus: RagStatus.idle,
      ));
      await _saveSession(withCards);
    } else {
      final noResultMsg = lawyerType != null
          ? 'I could not find any available $lawyerType lawyers at the moment. Please check back later.'
          : 'I could not find any available lawyers at the moment. Please check back later.';
      final updated = [
        ...base,
        ChatMessage(text: noResultMsg, isUser: false),
      ];
      emit(state.copyWith(
        messages: updated,
        isAiTyping: false,
        ragStatus: RagStatus.idle,
      ));
      await _saveSession(updated);
    }
  }

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> _onLoadInitialChat(
      LoadInitialChat event,
      Emitter<AIChatState> emit,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionStartRaw = prefs.getString(_kSessionStartKey);

    if (sessionStartRaw != null) {
      final sessionStart = DateTime.parse(sessionStartRaw);
      if (DateTime.now().difference(sessionStart).inHours >= 24) {
        await _wipeSession(prefs);
        _conversationHistory.clear();
        emit(state.copyWith(messages: [_greetingMessage()], shownLawyerIds: []));
        return;
      }
    }

    final raw = prefs.getString(_kSessionKey);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        final messages = list
            .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
            .toList();

        if (messages.isNotEmpty) {
          final shownIds = messages
              .where((m) => m.isLawyerCard)
              .expand((m) => m.lawyers.map((l) => l.id))
              .toList();
          emit(state.copyWith(messages: messages, shownLawyerIds: shownIds));
          return;
        }
      } catch (_) {}
    }

    emit(state.copyWith(messages: [_greetingMessage()]));
  }

  // ── Purge expired ─────────────────────────────────────────────────────────

  Future<void> _onPurgeExpiredSession(
      PurgeExpiredSession event,
      Emitter<AIChatState> emit,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionStartRaw = prefs.getString(_kSessionStartKey);
    if (sessionStartRaw == null) return;

    final sessionStart = DateTime.parse(sessionStartRaw);
    if (DateTime.now().difference(sessionStart).inHours >= 24) {
      await _wipeSession(prefs);
      _conversationHistory.clear();
      emit(state.copyWith(messages: [_greetingMessage()], shownLawyerIds: []));
    }
  }

  // ── Delete conversation ───────────────────────────────────────────────────

  Future<void> _onDeleteConversation(
      DeleteConversation event,
      Emitter<AIChatState> emit,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    await _wipeSession(prefs);
    _conversationHistory.clear();
    emit(state.copyWith(
      messages: [_greetingMessage()],
      shownLawyerIds: [],
      isAiTyping: false,
      lastLawyerType: null,
      ragStatus: RagStatus.idle,
    ));
  }

  // ── Send message (backward compat) ────────────────────────────────────────

  Future<void> _onSendMessage(
      SendMessage event,
      Emitter<AIChatState> emit,
      ) async {
    add(SendLegalCaseQuery(event.text));
  }

  // ── Fetch more lawyers ────────────────────────────────────────────────────

  Future<void> _onFetchMoreLawyers(
      FetchMoreLawyers event,
      Emitter<AIChatState> emit,
      ) async {
    emit(state.copyWith(isAiTyping: true));
    await Future.delayed(const Duration(seconds: 1));

    final lawyers = await _fetchTopLawyers(
      state.shownLawyerIds,
      lawyerType: state.lastLawyerType,
    );

    if (lawyers.isEmpty) {
      emit(state.copyWith(isAiTyping: false));
      return;
    }

    final newShownIds = [
      ...state.shownLawyerIds,
      ...lawyers.map((l) => l.id),
    ];
    final updated = [
      ...state.messages,
      ChatMessage(
        text: '',
        isUser: false,
        isLawyerCard: true,
        lawyers: lawyers,
      ),
    ];
    emit(state.copyWith(
      messages: updated,
      isAiTyping: false,
      shownLawyerIds: newShownIds,
    ));
    await _saveSession(updated);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Map<String, dynamic> _sanitizeForJson(Map<String, dynamic> data) {
    return data.map((key, value) {
      if (value is Timestamp) {
        return MapEntry(key, value.millisecondsSinceEpoch);
      }
      if (value is GeoPoint) {
        return MapEntry(key, {'lat': value.latitude, 'lng': value.longitude});
      }
      if (value is Map<String, dynamic>) {
        return MapEntry(key, _sanitizeForJson(value));
      }
      if (value is List) {
        return MapEntry(
          key,
          value.map((e) {
            if (e is Timestamp) return e.millisecondsSinceEpoch;
            if (e is GeoPoint) return {'lat': e.latitude, 'lng': e.longitude};
            if (e is Map<String, dynamic>) return _sanitizeForJson(e);
            return e;
          }).toList(),
        );
      }
      return MapEntry(key, value);
    });
  }

  String? _extractLawyerType(String response) {
    final match = RegExp(r'LAWYER_TYPE:(\w+)', caseSensitive: false)
        .firstMatch(response);
    if (match == null) return null;
    final raw = match.group(1)?.toLowerCase().trim();
    if (raw != null && _lawyerTypeAliases.containsKey(raw)) return raw;
    return null;
  }

  String? _inferLawyerTypeFromText(String text) {
    final lower = text.toLowerCase();
    for (final entry in _lawyerTypeAliases.entries) {
      for (final keyword in entry.value) {
        if (lower.contains(keyword)) return entry.key;
      }
    }
    return null;
  }

  bool _lawyerTypeMatches(String? firestoreType, String? targetType) {
    if (targetType == null) return true;
    if (firestoreType == null || firestoreType.isEmpty) return false;
    final normalized = firestoreType.toLowerCase().trim();
    final aliases = _lawyerTypeAliases[targetType] ?? [targetType];
    return aliases.any((alias) =>
    normalized.contains(alias) || alias.contains(normalized));
  }

  Future<List<LawyerMatch>> _fetchTopLawyers(
      List<String> excludeIds, {
        String? lawyerType,
      }) async {
    try {
      final query = await _firestore.collection('lawyers').get();
      print('📦 Total lawyers found: ${query.docs.length}');
      print('🔍 Filtering for lawyerType: $lawyerType');

      int parseInt(dynamic value) {
        if (value == null) return 0;
        if (value is int) return value;
        if (value is String) return int.tryParse(value) ?? 0;
        return 0;
      }

      final availableDocs = query.docs
          .where((doc) => !excludeIds.contains(doc.id))
          .where((doc) => (doc.data()['isAvailable'] ?? false) == true)
          .where((doc) => _lawyerTypeMatches(
        doc.data()['lawyerType']?.toString(),
        lawyerType,
      ))
          .toList();

      print('✅ Matched available lawyers: ${availableDocs.length}');

      availableDocs.sort((a, b) {
        final aCases = parseInt(a.data()['caseWon']);
        final bCases = parseInt(b.data()['caseWon']);
        if (bCases != aCases) return bCases.compareTo(aCases);
        final aExp = parseInt(a.data()['experience']);
        final bExp = parseInt(b.data()['experience']);
        return bExp.compareTo(aExp);
      });

      final lawyers = availableDocs.take(3).map((doc) {
        final data = doc.data();
        print('✅ Mapped lawyer: ${data['name']} | type: ${data['lawyerType']}');
        return LawyerMatch(
          id: doc.id,
          name: data['name'] ?? '',
          location: data['officeLocation'] ??
              data['businessName'] ??
              'Location not set',
          avatarUrl: data['avatarUrl'] ?? '',
          experienceYears: parseInt(data['experience']),
          casesWon: parseInt(data['caseWon']),
          isAvailable: data['isAvailable'] ?? false,
          rawData: _sanitizeForJson({...data, 'uid': doc.id}),
        );
      }).toList();

      print('✅ Total lawyers returned: ${lawyers.length}');
      return lawyers;
    } catch (e) {
      print('❌ Firestore error: $e');
      return [];
    }
  }

  ChatMessage _greetingMessage() => ChatMessage(
    text: 'Hello! I am your LexBid AI Legal Assistant. How can I help you today?',
    isUser: false,
  );

  Future<void> _wipeSession(SharedPreferences prefs) async {
    await prefs.remove(_kSessionKey);
    await prefs.remove(_kSessionStartKey);
  }

  Future<void> _saveSession(List<ChatMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(messages.map((m) => m.toJson()).toList());
    await prefs.setString(_kSessionKey, json);
  }

  @override
  Future<void> close() {
    _purgeTimer?.cancel();
    return super.close();
  }
}