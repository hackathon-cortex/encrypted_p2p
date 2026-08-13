import 'package:flutter/material.dart';
import '../../core/state/app_state_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/call_session_model.dart';
import '../../models/message_model.dart';
import '../../widgets/common/cortex_app_bar.dart';
import '../../widgets/common/cortex_badge.dart';
import '../../widgets/common/cortex_modal.dart';
import '../../widgets/tactical/audio_wave_visualizer.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _filter = 'All'; // 'All', 'Direct', 'Groups', 'Pinned'
  String? _activeConversationId;
  MessageModel? _replyingTo;
  bool _isRecordingVoice = false;

  @override
  void initState() {
    super.initState();
    _activeConversationId = 'grp_alpha_command';
  }

  @override
  void dispose() {
    _searchController.dispose();
    _messageController.dispose();
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

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final appState = AppStateProvider.of(context);
    appState.sendChatMessage(
      message: text,
      conversationId: _activeConversationId,
      replyToMessageId: _replyingTo?.id,
      replyToText: _replyingTo?.message,
    );

    _messageController.clear();
    setState(() => _replyingTo = null);
    _scrollToBottom();
  }

  void _sendAttachment(MessageAttachmentType type, String name, String size) {
    final appState = AppStateProvider.of(context);
    appState.sendChatMessage(
      message: 'Shared attachment: $name',
      conversationId: _activeConversationId,
      attachmentType: type,
      attachmentName: name,
      attachmentSize: size,
    );
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 800;
    final conversations = appState.chatService.conversations;

    // Filter conversations
    final filtered = conversations.where((c) {
      if (_filter == 'Direct' && c.isGroup) return false;
      if (_filter == 'Groups' && !c.isGroup) return false;
      if (_filter == 'Pinned' && !c.isPinned) return false;
      if (_searchController.text.trim().isNotEmpty) {
        return c.title.toLowerCase().contains(_searchController.text.toLowerCase());
      }
      return true;
    }).toList();

    final activeConvo = conversations.firstWhere(
      (c) => c.id == _activeConversationId,
      orElse: () => conversations.first,
    );

    final messages = appState.chatService.getMessagesForConversation(activeConvo.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CortexAppBar(
        title: 'SECURE CHAT',
        subtitle: 'AES-256-GCM • DECENTRALIZED P2P RELAY',
      ),
      body: Row(
        children: [
          // Left: Conversation List Panel (Always visible on desktop, or full screen if no convo on mobile)
          if (isDesktop || _activeConversationId == null)
            Container(
              width: isDesktop ? 320 : MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: AppColors.backgroundSecondary,
                border: Border(
                  right: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: Column(
                children: [
                  // Search & Filter
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Search encrypted channels...',
                        prefixIcon: const Icon(Icons.search_rounded, size: 18),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        filled: true,
                        fillColor: AppColors.surfaceElevated,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    child: Row(
                      children: ['All', 'Direct', 'Groups', 'Pinned'].map((tab) {
                        final isSel = _filter == tab;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text(tab),
                            selected: isSel,
                            onSelected: (_) => setState(() => _filter = tab),
                            selectedColor: AppColors.primary,
                            backgroundColor: AppColors.surfaceElevated,
                            labelStyle: TextStyle(
                              fontSize: 11,
                              fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                              color: isSel ? Colors.white : AppColors.textSecondary,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const Divider(height: 1),

                  // Conversations List
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final convo = filtered[index];
                        final isSelected = convo.id == _activeConversationId;

                        return Material(
                          color: isSelected ? AppColors.surfaceElevated : Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              setState(() => _activeConversationId = convo.id);
                              appState.chatService.setActiveConversation(convo.id);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              child: Row(
                                children: [
                                  Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: convo.isGroup ? AppColors.accentIndigo : AppColors.primary,
                                        child: Icon(
                                          convo.isGroup ? Icons.groups_rounded : Icons.person_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      if (convo.isOnline)
                                        Positioned(
                                          right: 0,
                                          bottom: 0,
                                          child: Container(
                                            width: 10,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              color: AppColors.success,
                                              shape: BoxShape.circle,
                                              border: Border.all(color: AppColors.backgroundSecondary, width: 1.5),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                convo.title,
                                                style: TextStyle(
                                                  color: AppColors.textPrimary,
                                                  fontSize: 13,
                                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (convo.isPinned)
                                              const Icon(Icons.push_pin_rounded, size: 13, color: AppColors.accentCyan),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          convo.lastMessage?.message ?? convo.subtitle ?? 'Encrypted channel',
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 11,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (convo.unreadCount > 0) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: const BoxDecoration(
                                        color: AppColors.primaryLight,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        '${convo.unreadCount}',
                                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

          // Right: Active Chat Room
          if (isDesktop || _activeConversationId != null)
            Expanded(
              child: Container(
                color: AppColors.background,
                child: Column(
                  children: [
                    // Active Conversation Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
                      ),
                      child: Row(
                        children: [
                          if (!isDesktop)
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                              onPressed: () => setState(() => _activeConversationId = null),
                            ),
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: activeConvo.isGroup ? AppColors.accentIndigo : AppColors.primary,
                            child: Icon(
                              activeConvo.isGroup ? Icons.groups_rounded : Icons.person_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(activeConvo.title, style: AppTypography.titleMedium),
                                    const SizedBox(width: 8),
                                    CortexBadge.encrypted(isSmall: true),
                                  ],
                                ),
                                Text(
                                  activeConvo.subtitle ?? 'End-to-End Encrypted',
                                  style: AppTypography.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          // Actions: Audio call, Video call, Pin, Cipher Info
                          IconButton(
                            icon: const Icon(Icons.call_outlined, color: AppColors.textPrimary, size: 20),
                            tooltip: 'Voice Call',
                            onPressed: () {
                              appState.startCall(
                                peerId: activeConvo.id,
                                peerName: activeConvo.title,
                                peerCallsign: 'Alpha-Peer',
                              );
                              appState.setNavigationIndex(3);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.videocam_outlined, color: AppColors.textPrimary, size: 20),
                            tooltip: 'Video Call',
                            onPressed: () {
                              appState.startCall(
                                peerId: activeConvo.id,
                                peerName: activeConvo.title,
                                peerCallsign: 'Alpha-Peer',
                                callType: CallType.video,
                              );
                              appState.setNavigationIndex(3);
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              activeConvo.isMuted ? Icons.volume_off_rounded : Icons.notifications_none_rounded,
                              color: AppColors.textMuted,
                              size: 20,
                            ),
                            tooltip: 'Mute Channel',
                            onPressed: () {
                              appState.toggleMuteConversation(activeConvo.id);
                            },
                          ),
                        ],
                      ),
                    ),

                    // Messages View
                    Expanded(
                      child: messages.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.lock_rounded, size: 36, color: AppColors.textMuted),
                                  const SizedBox(height: 10),
                                  const Text('No messages yet in this encrypted channel', style: AppTypography.bodyMedium),
                                  const SizedBox(height: 4),
                                  Text('Keys exchanged via Curve25519', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                ],
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              itemCount: messages.length,
                              itemBuilder: (context, idx) {
                                final msg = messages[idx];
                                final isMe = msg.senderId == (appState.authService.currentUser?.id ?? 'usr_cortex_01');

                                return _MessageBubble(
                                  message: msg,
                                  isMe: isMe,
                                  onReply: () => setState(() => _replyingTo = msg),
                                  onDelete: () => appState.deleteChatMessage(activeConvo.id, msg.id),
                                  onPin: () => appState.togglePinChatMessage(activeConvo.id, msg.id),
                                );
                              },
                            ),
                    ),

                    // Replying banner
                    if (_replyingTo != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        color: AppColors.surfaceElevated,
                        child: Row(
                          children: [
                            const Icon(Icons.reply_rounded, color: AppColors.accentCyan, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Replying to: ${_replyingTo!.message}',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.textMuted),
                              onPressed: () => setState(() => _replyingTo = null),
                            ),
                          ],
                        ),
                      ),

                    // Bottom Input Area
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
                      ),
                      child: SafeArea(
                        top: false,
                        child: Row(
                          children: [
                            // Attachments menu
                            IconButton(
                              icon: const Icon(Icons.attach_file_rounded, color: AppColors.textSecondary, size: 20),
                              tooltip: 'Attach Payload',
                              onPressed: () {
                                _showAttachmentOptions();
                              },
                            ),

                            // Voice Note simulator toggle
                            IconButton(
                              icon: Icon(
                                _isRecordingVoice ? Icons.stop_circle_rounded : Icons.mic_none_rounded,
                                color: _isRecordingVoice ? AppColors.error : AppColors.textSecondary,
                                size: 20,
                              ),
                              tooltip: _isRecordingVoice ? 'Stop Recording' : 'Voice Message',
                              onPressed: () {
                                if (_isRecordingVoice) {
                                  _sendAttachment(MessageAttachmentType.voice, 'Voice_Note_${DateTime.now().millisecondsSinceEpoch % 1000}.aac', '180 KB');
                                  setState(() => _isRecordingVoice = false);
                                } else {
                                  setState(() => _isRecordingVoice = true);
                                }
                              },
                            ),

                            if (_isRecordingVoice) ...[
                              const Expanded(
                                child: Row(
                                  children: [
                                    Text('RECORDING...', style: TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.bold)),
                                    SizedBox(width: 12),
                                    Expanded(child: AudioWaveVisualizer(barCount: 16, height: 24, barColor: AppColors.error)),
                                  ],
                                ),
                              ),
                            ] else ...[
                              // Text Field
                              Expanded(
                                child: TextField(
                                  controller: _messageController,
                                  style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                                  decoration: InputDecoration(
                                    hintText: 'Type encrypted message...',
                                    filled: true,
                                    fillColor: AppColors.surfaceElevated,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  onSubmitted: (_) => _sendMessage(),
                                ),
                              ),
                            ],

                            const SizedBox(width: 8),

                            // Send Button
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                                onPressed: _sendMessage,
                              ),
                            ),
                          ],
                        ),
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

  void _showAttachmentOptions() {
    CortexModal.showBottomSheet(
      context: context,
      title: 'SHARE ENCRYPTED PAYLOAD',
      subtitle: 'Select attachment type to encrypt before transmission',
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.insert_drive_file_outlined, color: AppColors.accentCyan),
            title: const Text('Tactical File / Document', style: TextStyle(color: AppColors.textPrimary)),
            subtitle: const Text('Encrypt and transfer via P2P stream', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
            onTap: () {
              Navigator.pop(context);
              _sendAttachment(MessageAttachmentType.file, 'Mission_Dossier_Alpha.pdf.enc', '2.8 MB');
            },
          ),
          ListTile(
            leading: const Icon(Icons.image_outlined, color: AppColors.primaryLight),
            title: const Text('Tactical Imagery / Map Overlay', style: TextStyle(color: AppColors.textPrimary)),
            subtitle: const Text('Encrypted raster telemetry', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
            onTap: () {
              Navigator.pop(context);
              _sendAttachment(MessageAttachmentType.image, 'Thermal_Satellite_Map.png.enc', '5.1 MB');
            },
          ),
          ListTile(
            leading: const Icon(Icons.location_on_outlined, color: AppColors.success),
            title: const Text('GPS Tactical Coordinates', style: TextStyle(color: AppColors.textPrimary)),
            subtitle: const Text('Transmit current live position beacon', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
            onTap: () {
              Navigator.pop(context);
              final appState = AppStateProvider.of(context);
              final loc = appState.locationService.myLocation;
              appState.sendChatMessage(
                message: 'Tactical coordinates: ${loc.latitude.toStringAsFixed(4)}° N, ${loc.longitude.toStringAsFixed(4)}° W (${loc.sector})',
                conversationId: _activeConversationId,
                attachmentType: MessageAttachmentType.location,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final VoidCallback onReply;
  final VoidCallback onDelete;
  final VoidCallback onPin;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.onReply,
    required this.onDelete,
    required this.onPin,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: const BoxConstraints(maxWidth: 380),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 3),
                child: Text(
                  message.senderName,
                  style: const TextStyle(
                    color: AppColors.accentCyan,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            // Main Bubble Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : AppColors.surfaceElevated,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(14),
                  topRight: const Radius.circular(14),
                  bottomLeft: Radius.circular(isMe ? 14 : 2),
                  bottomRight: Radius.circular(isMe ? 2 : 14),
                ),
                border: Border.all(
                  color: isMe ? AppColors.primaryDark : AppColors.border,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quoted reply text
                  if (message.replyToText != null) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: const Border(left: BorderSide(color: AppColors.accentCyan, width: 3)),
                      ),
                      child: Text(
                        message.replyToText!,
                        style: const TextStyle(fontSize: 11, color: Colors.white70),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],

                  // Attachment Preview
                  if (message.attachmentType == MessageAttachmentType.file) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.insert_drive_file_rounded, color: AppColors.accentCyan, size: 24),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message.attachmentName ?? 'Payload.enc',
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${message.attachmentSize ?? "2.4 MB"} • E2EE Encrypted',
                                  style: const TextStyle(color: Colors.white60, fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else if (message.attachmentType == MessageAttachmentType.voice) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.play_arrow_rounded, color: AppColors.accentCyan, size: 22),
                          SizedBox(width: 8),
                          Expanded(child: AudioWaveVisualizer(barCount: 14, height: 18, isPlaying: false)),
                          SizedBox(width: 8),
                          Text('0:14', style: TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'monospace')),
                        ],
                      ),
                    ),
                  ],

                  // Message text
                  Text(
                    message.message,
                    style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.3),
                  ),

                  const SizedBox(height: 6),

                  // Timestamp & Status
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (message.isPinned) ...[
                        const Icon(Icons.push_pin_rounded, size: 10, color: AppColors.accentCyan),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 10,
                          fontFamily: 'monospace',
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.status == MessageStatus.read ? Icons.done_all_rounded : Icons.done_rounded,
                          size: 13,
                          color: message.status == MessageStatus.read ? AppColors.accentCyan : Colors.white70,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
