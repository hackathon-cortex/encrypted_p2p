import 'package:flutter/material.dart';
import '../../core/state/app_state_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../services/ai_assistant_service.dart';
import '../../widgets/common/cortex_app_bar.dart';
import '../../widgets/common/cortex_badge.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _queryController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void dispose() {
    _queryController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _submitQuery([String? predefinedQuery]) async {
    final query = predefinedQuery ?? _queryController.text.trim();
    if (query.isEmpty) return;

    if (predefinedQuery == null) _queryController.clear();
    setState(() => _isLoading = true);
    _scrollToBottom();

    final appState = AppStateProvider.of(context);
    await appState.queryAiAssistant(query);

    if (!mounted) return;
    setState(() => _isLoading = false);
    _scrollToBottom();
  }

  void _handleActionButton(String action) {
    final appState = AppStateProvider.of(context);
    if (action.contains('Scan')) {
      appState.runSecurityScan();
      _submitQuery('Initiate perimeter security scan');
    } else if (action.contains('Threat') || action.contains('Isolate')) {
      appState.setNavigationIndex(4); // Security Center
    } else if (action.contains('Score')) {
      _submitQuery('Explain why my security score is what it is');
    } else if (action.contains('Audit') || action.contains('Report')) {
      appState.setNavigationIndex(9); // Audit Logs
    } else if (action.contains('Device')) {
      appState.setNavigationIndex(11); // Devices
    } else {
      _submitQuery(action);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final messages = appState.aiAssistantService.messages;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CortexAppBar(
        title: 'CORTEX AI SENTINEL',
        subtitle: 'AUTONOMOUS CYBERSECURITY & THREAT ANALYST',
        leading: Builder(
          builder: (ctx) {
            final isMobile = MediaQuery.of(context).size.width < 800;
            if (isMobile) {
              return IconButton(
                icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textMuted, size: 20),
            tooltip: 'Clear Context',
            onPressed: () {
              appState.aiAssistantService.clearConversation();
              setState(() {});
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Security Privacy Assurance Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              border: const Border(bottom: BorderSide(color: AppColors.border, width: 1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.privacy_tip_outlined, color: AppColors.accentCyan, size: 16),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'ZERO-KNOWLEDGE AI: Private messages are never exposed or processed by Sentinel.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
                  ),
                ),
                CortexBadge.encrypted(isSmall: true),
              ],
            ),
          ),

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return _AiMessageBubble(
                  message: msg,
                  onActionTap: _handleActionButton,
                );
              },
            ),
          ),

          // Quick Prompt Suggestion Chips
          Container(
            height: 38,
            margin: const EdgeInsets.only(bottom: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _PromptChip(label: '🛡️ Explain Security Score', onTap: () => _submitQuery('Explain my security score')),
                _PromptChip(label: '⚠️ Analyze Active Threats', onTap: () => _submitQuery('Analyze current threats in mesh')),
                _PromptChip(label: '📋 Summarize 24h Logs', onTap: () => _submitQuery('Summarize audit logs for the last 24 hours')),
                _PromptChip(label: '📱 Assess Connected Devices', onTap: () => _submitQuery('Assess risks for connected devices')),
                _PromptChip(label: '🔒 Cryptographic Architecture', onTap: () => _submitQuery('Explain CORTEX cryptographic specs')),
              ],
            ),
          ),

          // Query Input Box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border, width: 1)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _queryController,
                      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Ask Sentinel analyst about threats, scores, logs...',
                        filled: true,
                        fillColor: AppColors.surfaceElevated,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      onSubmitted: (_) => _submitQuery(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      onPressed: _isLoading ? null : () => _submitQuery(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PromptChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PromptChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label),
        backgroundColor: AppColors.surfaceElevated,
        labelStyle: const TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.border, width: 0.8),
        ),
        onPressed: onTap,
      ),
    );
  }
}

class _AiMessageBubble extends StatelessWidget {
  final AiMessage message;
  final ValueChanged<String> onActionTap;

  const _AiMessageBubble({required this.message, required this.onActionTap});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: const BoxConstraints(maxWidth: 580),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isUser) ...[
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.accentIndigo.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.accentIndigo, width: 1),
                ),
                child: const Icon(Icons.smart_toy_rounded, color: AppColors.accentIndigo, size: 18),
              ),
              const SizedBox(width: 12),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isUser ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isUser ? AppColors.primaryDark : AppColors.border, width: 1),
                    ),
                    child: Text(
                      message.text,
                      style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                    ),
                  ),
                  if (message.actionButtons != null && message.actionButtons!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: message.actionButtons!.map((btn) {
                        return OutlinedButton(
                          onPressed: () => onActionTap(btn),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppColors.surfaceElevated,
                            foregroundColor: AppColors.accentCyan,
                            side: const BorderSide(color: AppColors.borderLight, width: 0.8),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            minimumSize: const Size(0, 30),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          child: Text(btn, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
