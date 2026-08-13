import 'package:flutter/material.dart';
import '../../core/state/app_state_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/call_session_model.dart';
import '../../models/message_model.dart';
import '../../widgets/common/cortex_app_bar.dart';
import '../../widgets/common/cortex_modal.dart';
import '../../widgets/tactical/audio_wave_visualizer.dart';

// PRIMARY: Contacts List (main screen on mobile)
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _filter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 800;
    final conversations = appState.chatService.conversations;

    final filtered = conversations.where((c) {
      if (_filter == 'Direct' && c.isGroup) return false;
      if (_filter == 'Groups' && !c.isGroup) return false;
      if (_filter == 'Pinned' && !c.isPinned) return false;
      final q = _searchController.text.trim().toLowerCase();
      if (q.isNotEmpty) return c.title.toLowerCase().contains(q);
      return true;
    }).toList();

    if (isDesktop) {
      return _DesktopChatLayout(
        appState: appState,
        filtered: filtered,
        filter: _filter,
        searchController: _searchController,
        onFilterChanged: (f) => setState(() => _filter = f),
        onSearchChanged: () => setState(() {}),
      );
    }

    // Mobile: contacts list as primary
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CortexAppBar(
        title: 'SECURE CHAT',
        subtitle: 'AES-256-GCM • P2P RELAY',
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
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
          const Divider(height: 1, color: AppColors.border),
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded, size: 40, color: AppColors.textMuted),
                        SizedBox(height: 12),
                        Text('No channels found', style: AppTypography.bodyMedium),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final convo = filtered[index];
                      return _ContactTile(
                        convo: convo,
                        onTap: () {
                          appState.chatService.setActiveConversation(convo.id);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => _ChatRoomScreen(conversationId: convo.id),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
// CONTACT TILE
class _ContactTile extends StatelessWidget {
  final dynamic convo;
  final VoidCallback onTap;
  final bool isSelected;
  const _ContactTile({required this.convo, required this.onTap, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.surfaceElevated : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: convo.isGroup ? AppColors.primaryDark : AppColors.primary,
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
                        width: 11,
                        height: 11,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.background, width: 2),
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
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (convo.isPinned)
                          const Icon(Icons.push_pin_rounded, size: 12, color: AppColors.primaryLight),
                        const SizedBox(width: 4),
                        const Icon(Icons.lock_rounded, size: 11, color: AppColors.primaryLight),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      convo.lastMessage?.message ?? convo.subtitle ?? 'Encrypted channel',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
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
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: Text(
                    '${convo.unreadCount}',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

// SECONDARY: Chat Room Screen
class _ChatRoomScreen extends StatefulWidget {
  final String conversationId;
  const _ChatRoomScreen({required this.conversationId});
  @override
  State<_ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<_ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  MessageModel? _replyingTo;
  bool _isRecordingVoice = false;

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
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(AppStateProvider appState) {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    appState.sendChatMessage(
      message: text,
      conversationId: widget.conversationId,
      replyToMessageId: _replyingTo?.id,
      replyToText: _replyingTo?.message,
    );
    _messageController.clear();
    setState(() => _replyingTo = null);
    _scrollToBottom();
  }

  void _sendAttachment(AppStateProvider appState, MessageAttachmentType type, String name, String size) {
    appState.sendChatMessage(
      message: 'Shared attachment: $name',
      conversationId: widget.conversationId,
      attachmentType: type,
      attachmentName: name,
      attachmentSize: size,
    );
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final conversations = appState.chatService.conversations;
    final convo = conversations.firstWhere(
      (c) => c.id == widget.conversationId,
      orElse: () => conversations.first,
    );
    final messages = appState.chatService.getMessagesForConversation(convo.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: convo.isGroup ? AppColors.primaryDark : AppColors.primary,
              child: Icon(
                convo.isGroup ? Icons.groups_rounded : Icons.person_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          convo.title,
                          style: AppTypography.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Icon(Icons.lock_rounded, size: 11, color: AppColors.primaryLight),
                    ],
                  ),
                  Text(convo.subtitle ?? 'End-to-End Encrypted', style: AppTypography.bodySmall),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_outlined, color: AppColors.textPrimary, size: 20),
            tooltip: 'Voice Call',
            onPressed: () {
              appState.startCall(peerId: convo.id, peerName: convo.title, peerCallsign: 'Alpha-Peer');
              appState.setNavigationIndex(3);
            },
          ),
          IconButton(
            icon: const Icon(Icons.videocam_outlined, color: AppColors.textPrimary, size: 20),
            tooltip: 'Video Call',
            onPressed: () {
              appState.startCall(peerId: convo.id, peerName: convo.title, peerCallsign: 'Alpha-Peer', callType: CallType.video);
              appState.setNavigationIndex(3);
            },
          ),
          IconButton(
            icon: Icon(convo.isMuted ? Icons.volume_off_rounded : Icons.notifications_none_rounded, color: AppColors.textMuted, size: 20),
            tooltip: 'Mute Channel',
            onPressed: () => appState.toggleMuteConversation(convo.id),
          ),
        ],
        bottom: const PreferredSize(preferredSize: Size.fromHeight(1), child: Divider(height: 1, color: AppColors.border)),
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_rounded, size: 36, color: AppColors.textMuted),
                        SizedBox(height: 10),
                        Text('No messages yet in this encrypted channel', style: AppTypography.bodyMedium),
                        SizedBox(height: 4),
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
                        onDelete: () => appState.deleteChatMessage(convo.id, msg.id),
                        onPin: () => appState.togglePinChatMessage(convo.id, msg.id),
                      );
                    },
                  ),
          ),
          if (_replyingTo != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.surfaceElevated,
              child: Row(
                children: [
                  const Icon(Icons.reply_rounded, color: AppColors.primaryLight, size: 18),
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
                  IconButton(
                    icon: const Icon(Icons.attach_file_rounded, color: AppColors.textSecondary, size: 20),
                    tooltip: 'Attach Payload',
                    onPressed: () => _showAttachmentOptions(appState),
                  ),
                  IconButton(
                    icon: Icon(
                      _isRecordingVoice ? Icons.stop_circle_rounded : Icons.mic_none_rounded,
                      color: _isRecordingVoice ? AppColors.error : AppColors.textSecondary,
                      size: 20,
                    ),
                    tooltip: _isRecordingVoice ? 'Stop Recording' : 'Voice Message',
                    onPressed: () {
                      if (_isRecordingVoice) {
                        _sendAttachment(appState, MessageAttachmentType.voice, 'Voice_Note_${DateTime.now().millisecondsSinceEpoch % 1000}.aac', '180 KB');
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
                          AudioWaveVisualizer(barCount: 16, height: 24, barColor: AppColors.error),
                        ],
                      ),
                    ),
                  ] else ...[
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
                        onSubmitted: (_) => _sendMessage(appState),
                      ),
                    ),
                  ],
                  const SizedBox(width: 8),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                      onPressed: () => _sendMessage(appState),
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

  void _showAttachmentOptions(AppStateProvider appState) {
    CortexModal.showBottomSheet(
      context: context,
      title: 'SHARE ENCRYPTED PAYLOAD',
      subtitle: 'Select attachment type to encrypt before transmission',
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.insert_drive_file_outlined, color: AppColors.primaryLight),
            title: const Text('Tactical File / Document', style: TextStyle(color: AppColors.textPrimary)),
            subtitle: const Text('Encrypt and transfer via P2P stream', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
            onTap: () { Navigator.pop(context); _sendAttachment(appState, MessageAttachmentType.file, 'Mission_Dossier_Alpha.pdf.enc', '2.8 MB'); },
          ),
          ListTile(
            leading: const Icon(Icons.image_outlined, color: AppColors.primaryLight),
            title: const Text('Tactical Imagery / Map Overlay', style: TextStyle(color: AppColors.textPrimary)),
            subtitle: const Text('Encrypted raster telemetry', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
            onTap: () { Navigator.pop(context); _sendAttachment(appState, MessageAttachmentType.image, 'Thermal_Satellite_Map.png.enc', '5.1 MB'); },
          ),
          ListTile(
            leading: const Icon(Icons.location_on_outlined, color: AppColors.success),
            title: const Text('GPS Tactical Coordinates', style: TextStyle(color: AppColors.textPrimary)),
            subtitle: const Text('Transmit current live position beacon', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
            onTap: () {
              Navigator.pop(context);
              final loc = appState.locationService.myLocation;
              appState.sendChatMessage(
                message: 'Tactical coordinates: ${loc.latitude.toStringAsFixed(4)} N, ${loc.longitude.toStringAsFixed(4)} W (${loc.sector})',
                conversationId: widget.conversationId,
                attachmentType: MessageAttachmentType.location,
              );
            },
          ),
        ],
      ),
    );
  }
}

// DESKTOP: Side-by-side layout
class _DesktopChatLayout extends StatefulWidget {
  final AppStateProvider appState;
  final List<dynamic> filtered;
  final String filter;
  final TextEditingController searchController;
  final ValueChanged<String> onFilterChanged;
  final VoidCallback onSearchChanged;

  const _DesktopChatLayout({
    required this.appState,
    required this.filtered,
    required this.filter,
    required this.searchController,
    required this.onFilterChanged,
    required this.onSearchChanged,
  });

  @override
  State<_DesktopChatLayout> createState() => _DesktopChatLayoutState();
}

class _DesktopChatLayoutState extends State<_DesktopChatLayout> {
  String? _activeId;

  @override
  void initState() {
    super.initState();
    final convos = widget.appState.chatService.conversations;
    if (convos.isNotEmpty) _activeId = convos.first.id;
  }

  @override
  Widget build(BuildContext context) {
    final appState = widget.appState;
    final convos = appState.chatService.conversations;
    final activeConvo = convos.firstWhere((c) => c.id == _activeId, orElse: () => convos.first);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CortexAppBar(title: 'SECURE CHAT', subtitle: 'AES-256-GCM • DECENTRALIZED P2P RELAY'),
      body: Row(
        children: [
          Container(
            width: 300,
            decoration: const BoxDecoration(
              color: AppColors.backgroundSecondary,
              border: Border(right: BorderSide(color: AppColors.border, width: 1)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
                  child: TextField(
                    controller: widget.searchController,
                    onChanged: (_) => widget.onSearchChanged(),
                    style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search channels...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 18),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      filled: true,
                      fillColor: AppColors.surfaceElevated,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  child: Row(
                    children: ['All', 'Direct', 'Groups', 'Pinned'].map((tab) {
                      final isSel = widget.filter == tab;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(tab),
                          selected: isSel,
                          onSelected: (_) => widget.onFilterChanged(tab),
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.surfaceElevated,
                          labelStyle: TextStyle(fontSize: 11, fontWeight: isSel ? FontWeight.bold : FontWeight.w500, color: isSel ? Colors.white : AppColors.textSecondary),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const Divider(height: 1, color: AppColors.border),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.filtered.length,
                    itemBuilder: (ctx, i) {
                      final c = widget.filtered[i];
                      return _ContactTile(
                        convo: c,
                        isSelected: c.id == _activeId,
                        onTap: () {
                          setState(() => _activeId = c.id);
                          appState.chatService.setActiveConversation(c.id);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _ChatRoomScreen(conversationId: activeConvo.id)),
        ],
      ),
    );
  }
}

// MESSAGE BUBBLE
class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final VoidCallback onReply;
  final VoidCallback onDelete;
  final VoidCallback onPin;

  const _MessageBubble({required this.message, required this.isMe, required this.onReply, required this.onDelete, required this.onPin});

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
                child: Text(message.senderName, style: const TextStyle(color: AppColors.primaryLight, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
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
                border: Border.all(color: isMe ? AppColors.primaryDark : AppColors.border, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.replyToText != null) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.black.withValues(alpha: 0.15) : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(6),
                        border: Border(left: BorderSide(color: isMe ? Colors.white70 : AppColors.primary, width: 3)),
                      ),
                      child: Text(message.replyToText!, style: TextStyle(fontSize: 11, color: isMe ? Colors.white70 : AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                  if (message.attachmentType == MessageAttachmentType.file) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(color: isMe ? Colors.black.withValues(alpha: 0.15) : AppColors.surfaceLight, borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          Icon(Icons.insert_drive_file_rounded, color: isMe ? Colors.white : AppColors.primary, size: 24),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(message.attachmentName ?? 'Payload.enc', style: TextStyle(color: isMe ? Colors.white : AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                Text('${message.attachmentSize ?? "2.4 MB"} - E2EE', style: TextStyle(color: isMe ? Colors.white70 : AppColors.textSecondary, fontSize: 10)),
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
                      decoration: BoxDecoration(color: isMe ? Colors.black.withValues(alpha: 0.15) : AppColors.surfaceLight, borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          Icon(Icons.play_arrow_rounded, color: isMe ? Colors.white : AppColors.primary, size: 22),
                          const SizedBox(width: 8),
                          const AudioWaveVisualizer(barCount: 14, height: 18, isPlaying: false),
                          const SizedBox(width: 8),
                          Text('0:14', style: TextStyle(color: isMe ? Colors.white70 : AppColors.textSecondary, fontSize: 11, fontFamily: 'monospace')),
                        ],
                      ),
                    ),
                  ],
                  Text(message.message, style: TextStyle(color: isMe ? Colors.white : AppColors.textPrimary, fontSize: 13, height: 1.3)),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (message.isPinned) ...[
                        Icon(Icons.push_pin_rounded, size: 10, color: isMe ? Colors.white70 : AppColors.primary),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(color: isMe ? Colors.white.withValues(alpha: 0.85) : AppColors.textMuted, fontSize: 10, fontFamily: 'monospace'),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(message.status == MessageStatus.read ? Icons.done_all_rounded : Icons.done_rounded, size: 13, color: message.status == MessageStatus.read ? AppColors.white : Colors.white70),
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
