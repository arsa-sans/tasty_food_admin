import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/shimmer_loading.dart';
import '../../viewmodels/message_viewmodel.dart';
import 'message_detail_view.dart';

class MessageListView extends StatefulWidget {
  const MessageListView({super.key});

  @override
  State<MessageListView> createState() => _MessageListViewState();
}

class _MessageListViewState extends State<MessageListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessageViewModel>().fetchMessages();
    });
  }

  @override
  Widget build(BuildContext context) {
    final msgVm = context.watch<MessageViewModel>();
    final messages = msgVm.filteredMessages;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // 1. Filter Strip
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _filterChip('Semua', !msgVm.onlyUnread, () => msgVm.toggleOnlyUnread(false)),
                    const SizedBox(width: 8),
                    _filterChip(
                      'Belum Dibaca (${msgVm.unreadCount})',
                      msgVm.onlyUnread,
                      () => msgVm.toggleOnlyUnread(true),
                      isUrgent: msgVm.unreadCount > 0,
                    ),
                  ],
                ),
                IconButton(
                  tooltip: 'Segarkan',
                  icon: const Icon(Icons.refresh_rounded, size: 20, color: AppColors.textSecondary),
                  onPressed: () => msgVm.fetchMessages(),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // 2. Messages List Body with Shimmer
          Expanded(
            child: msgVm.isLoading
                ? const MessageListShimmer()
                : RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () => msgVm.fetchMessages(),
                    child: messages.isEmpty
                        ? const EmptyState(
                            icon: Icons.mail_outline_rounded,
                            title: 'Kotak Masuk Kosong',
                            message: 'Tidak ada pesan atau pertanyaan pelanggan saat ini.',
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
                            itemCount: messages.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final m = messages[index];
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: m.isUnread ? const Color(0xFFFCA5A5) : AppColors.border,
                                    width: m.isUnread ? 1.5 : 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: m.isUnread
                                          ? AppColors.danger.withValues(alpha: 0.04)
                                          : Colors.black.withValues(alpha: 0.02),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: InkWell(
                                  onTap: () {

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => MessageDetailView(message: m),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Avatar
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor: m.isUnread
                                              ? AppColors.dangerLight
                                              : const Color(0xFFF1F5F9),
                                          child: Text(
                                            m.nama.isNotEmpty ? m.nama[0].toUpperCase() : 'U',
                                            style: TextStyle(
                                              color: m.isUnread ? AppColors.dangerDark : AppColors.textSecondary,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),

                                        // Content
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      m.nama,
                                                      style: TextStyle(
                                                        fontWeight: m.isUnread ? FontWeight.w800 : FontWeight.w600,
                                                        fontSize: 14,
                                                        color: AppColors.textPrimary,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  Text(
                                                    m.formattedDate,
                                                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                m.subjek,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: m.isUnread ? FontWeight.w700 : FontWeight.w500,
                                                  color: m.isUnread ? AppColors.textPrimary : AppColors.textSecondary,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                m.pesan,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                              ),
                                            ],
                                          ),
                                        ),

                                        if (m.isUnread) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            width: 8,
                                            height: 8,
                                            margin: const EdgeInsets.only(top: 6),
                                            decoration: const BoxDecoration(
                                              color: AppColors.danger,
                                              shape: BoxShape.circle,
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
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool isSelected, VoidCallback onTap, {bool isUrgent = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? (isUrgent ? AppColors.danger : AppColors.secondary) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (isUrgent ? AppColors.danger : AppColors.secondary)
                : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
