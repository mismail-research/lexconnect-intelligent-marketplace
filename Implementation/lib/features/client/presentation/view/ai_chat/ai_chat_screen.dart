import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lexbid/core/constants/app_color.dart';
import '../../../bloc/ai_chat/ai_chat_bloc.dart';
import '../../../bloc/ai_chat/ai_chat_event.dart';
import '../../../bloc/ai_chat/ai_chat_state.dart';
import 'widgets/ai_chat_app_bar.dart';
import 'widgets/ai_chat_info_sheet.dart';
import 'widgets/ai_chat_input_bar.dart';
import 'widgets/ai_typing_indicator.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/lawyer_card_bubble.dart';

class AIChatScreen extends StatelessWidget {
  const AIChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AIChatBloc()..add(LoadInitialChat()),
      child: const _AIChatView(),
    );
  }
}

class _AIChatView extends StatefulWidget {
  const _AIChatView();

  @override
  State<_AIChatView> createState() => _AIChatViewState();
}

class _AIChatViewState extends State<_AIChatView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _hasText = false;
  bool _isSending = false; // 👈 prevents duplicate sends

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() {
      final hasText = _messageController.text.trim().isNotEmpty;
      if (hasText != _hasText) setState(() => _hasText = hasText);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    if (_isSending) return; // 👈 block rapid fire
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    setState(() => _isSending = true);
    context.read<AIChatBloc>().add(SendLegalCaseQuery(text));
    _messageController.clear();
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _isSending = false);
    });
  }

  void _sendChip(String text) {
    if (_isSending) return; // 👈 block chip spam too
    setState(() => _isSending = true);
    context.read<AIChatBloc>().add(SendLegalCaseQuery(text));
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _isSending = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AIChatAppBar(
        onInfoTap: () => AIChatInfoSheet.show(context),
      ),
      body: BlocConsumer<AIChatBloc, AIChatState>(
        listener: (context, state) => _scrollToBottom(),
        builder: (context, state) {
          return Column(
            children: [
              _buildDateDivider(),
              Expanded(child: _buildMessageList(state)),
              _buildSuggestionChips(state),
              AIChatInputBar(
                controller: _messageController,
                hasText: _hasText,
                onSend: _sendMessage,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDateDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: AppColors.borderColor.withValues(alpha: 0.25),
              thickness: 0.5,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'Today',
              style: TextStyle(
                color: AppColors.borderColor,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: AppColors.borderColor.withValues(alpha: 0.25),
              thickness: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(AIChatState state) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      itemCount: state.messages.length + (state.isAiTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.messages.length && state.isAiTyping) {
          // Show RAG status message instead of plain typing indicator
          return AiTypingIndicator(
            statusText: _getRagStatusText(state.ragStatus),
          );
        }
        final msg = state.messages[index];
        if (msg.isLawyerCard) {
          return LawyerCardBubble(lawyers: msg.lawyers);
        }
        return ChatBubble(message: msg.text, isUser: msg.isUser);
      },
    );
  }

  String _getRagStatusText(RagStatus status) {
    switch (status) {
      case RagStatus.embedding:
        return 'Understanding your query...';
      case RagStatus.searching:
        return 'Searching 500 legal cases...';
      case RagStatus.generating:
        return 'Analyzing and citing sources...';
      default:
        return '';
    }
  }

  Widget _buildSuggestionChips(AIChatState state) {
    final chips = ['Property dispute', 'Find a lawyer', 'Divorce lawyer'];
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: chips.length,
        separatorBuilder: (_, child) => const SizedBox(width: 8),
        itemBuilder: (context, i) => GestureDetector(
          onTap: () => _sendChip(chips[i]),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.liteBlue.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              chips[i],
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: AppColors.liteBlue,
              ),
            ),
          ),
        ),
      ),
    );
  }
}