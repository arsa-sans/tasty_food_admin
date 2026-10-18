import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/shimmer_loading.dart';
import '../../core/widgets/app_cached_image.dart';
import '../../viewmodels/berita_viewmodel.dart';
import 'berita_form_view.dart';

class BeritaListView extends StatefulWidget {
  const BeritaListView({super.key});

  @override
  State<BeritaListView> createState() => _BeritaListViewState();
}

class _BeritaListViewState extends State<BeritaListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BeritaViewModel>().fetchBeritas();
    });
  }

  void _confirmDelete(int id, String judul) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Artikel Berita'),
        content: Text('Apakah Anda yakin ingin menghapus "$judul"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context.read<BeritaViewModel>().deleteBerita(id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Berita berhasil dihapus' : 'Gagal menghapus berita'),
                    backgroundColor: success ? AppColors.success : AppColors.danger,
                  ),
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final beritaVm = context.watch<BeritaViewModel>();
    final beritas = beritaVm.filteredBeritas;

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BeritaFormView()),
          );
        },
        backgroundColor: AppColors.primary,
        elevation: 3,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Tulis Berita', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
      ),
      body: Column(
        children: [
          // 1. Filter Tabs (Semua, Published, Draft)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _filterChip(beritaVm, 'Semua'),
                const SizedBox(width: 8),
                _filterChip(beritaVm, 'Published'),
                const SizedBox(width: 8),
                _filterChip(beritaVm, 'Draft'),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // 2. Berita List with Shimmer
          Expanded(
            child: beritaVm.isLoading
                ? const BeritaListShimmer()
                : RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () => beritaVm.fetchBeritas(),
                    child: beritas.isEmpty
                        ? const EmptyState(
                            icon: Icons.newspaper_outlined,
                            title: 'Belum Ada Berita',
                            message: 'Belum ada artikel berita yang dipublikasikan.',
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
                            itemCount: beritas.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final b = beritas[index];
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.border),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.02),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      AppCachedImage(
                                        imageUrl: b.imageUrl ?? '',
                                        width: 84,
                                        height: 84,
                                        borderRadius: BorderRadius.circular(12),
                                        memCacheWidth: 260,
                                        memCacheHeight: 260,
                                        fallbackIcon: Icons.article_rounded,
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: b.isPublished ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    b.status.toUpperCase(),
                                                    style: TextStyle(
                                                      color: b.isPublished ? const Color(0xFF15803D) : const Color(0xFFB45309),
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w800,
                                                    ),
                                                  ),
                                                ),
                                                PopupMenuButton<String>(
                                                  icon: const Icon(Icons.more_vert_rounded, size: 20, color: AppColors.textMuted),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                  onSelected: (val) {
                                                    if (val == 'edit') {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (_) => BeritaFormView(berita: b),
                                                        ),
                                                      );
                                                    } else if (val == 'delete') {
                                                      _confirmDelete(b.id, b.judul);
                                                    }
                                                  },
                                                  itemBuilder: (_) => [
                                                    const PopupMenuItem(
                                                      value: 'edit',
                                                      child: Row(
                                                        children: [
                                                          Icon(Icons.edit_rounded, size: 18, color: AppColors.info),
                                                          SizedBox(width: 8),
                                                          Text('Edit Berita'),
                                                        ],
                                                      ),
                                                    ),
                                                    const PopupMenuItem(
                                                      value: 'delete',
                                                      child: Row(
                                                        children: [
                                                          Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.danger),
                                                          SizedBox(width: 8),
                                                          Text('Hapus Berita'),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              b.judul,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 14,
                                                color: AppColors.textPrimary,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              b.ringkasan,
                                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
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

  Widget _filterChip(BeritaViewModel vm, String status) {
    final isSelected = vm.statusFilter == status;
    return InkWell(
      onTap: () => vm.setStatusFilter(status),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.secondary : AppColors.border,
          ),
        ),
        child: Text(
          status,
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
