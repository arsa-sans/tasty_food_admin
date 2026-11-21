import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/animated_pressable.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/staggered_entrance.dart';
import '../../core/widgets/shimmer_loading.dart';
import '../../core/widgets/app_cached_image.dart';
import '../../viewmodels/galeri_viewmodel.dart';
import 'galeri_form_view.dart';

class GaleriListView extends StatefulWidget {
  const GaleriListView({super.key});

  @override
  State<GaleriListView> createState() => _GaleriListViewState();
}

class _GaleriListViewState extends State<GaleriListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GaleriViewModel>().fetchGaleris();
    });
  }

  void _confirmDelete(int id, String judul) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Foto'),
        content: Text('Apakah Anda yakin ingin menghapus foto "$judul"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context.read<GaleriViewModel>().deleteGaleri(id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Foto berhasil dihapus' : 'Gagal menghapus foto'),
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
    final galeriVm = context.watch<GaleriViewModel>();
    final galeris = galeriVm.galeris;

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: AnimatedPressable(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GaleriFormView()),
          );
        },
        pressedScale: 0.95,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_a_photo_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Tambah Foto',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
      body: galeriVm.isLoading
          ? const GaleriGridShimmer()
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => galeriVm.fetchGaleris(),
              child: galeris.isEmpty
                  ? const EmptyState(
                      icon: Icons.photo_library_outlined,
                      title: 'Galeri Foto Kosong',
                      message: 'Belum ada dokumentasi foto yang diunggah ke restoran.',
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = Responsive.value(
                          context,
                          mobile: 2,
                          tablet: 3,
                          desktop: 4,
                        );

                        return GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: galeris.length,
                          itemBuilder: (context, index) {
                            final item = galeris[index];
                            return StaggeredEntrance(
                              index: index,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.border),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF1E293B).withValues(alpha: 0.02),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: AppCachedImage(
                                        imageUrl: item.imageUrl ?? '',
                                        fit: BoxFit.cover,
                                        memCacheWidth: 350,
                                        memCacheHeight: 350,
                                        fallbackIcon: Icons.image_rounded,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  item.judul,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 13,
                                                    color: AppColors.textPrimary,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              AnimatedPressable(
                                                onTap: () => _confirmDelete(item.id, item.judul),
                                                borderRadius: BorderRadius.circular(6),
                                                child: Container(
                                                  padding: const EdgeInsets.all(5),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFFEF2F2),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.danger),
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (item.deskripsi != null && item.deskripsi!.isNotEmpty) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              item.deskripsi!,
                                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
    );
  }
}
