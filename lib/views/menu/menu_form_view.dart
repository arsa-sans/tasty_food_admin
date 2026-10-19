import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../data/models/menu_model.dart';
import '../../viewmodels/menu_viewmodel.dart';

class MenuFormView extends StatefulWidget {
  final MenuModel? menu;

  const MenuFormView({super.key, this.menu});

  @override
  State<MenuFormView> createState() => _MenuFormViewState();
}

class _MenuFormViewState extends State<MenuFormView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _kategoriController;
  late TextEditingController _hargaController;
  late TextEditingController _deskripsiController;
  late bool _isTersedia;
  String? _pickedImagePath;

  final List<String> _commonCategories = [
    'Makanan Utama',
    'Minuman',
    'Camilan',
    'Paket Katering',
    'Dessert',
  ];

  @override
  void initState() {
    super.initState();
    final m = widget.menu;
    _namaController = TextEditingController(text: m?.nama ?? '');
    _kategoriController = TextEditingController(text: m?.kategori ?? 'Makanan Utama');
    _hargaController = TextEditingController(text: m != null ? m.harga.toInt().toString() : '');
    _deskripsiController = TextEditingController(text: m?.deskripsi ?? '');
    _isTersedia = m?.isTersedia ?? true;
  }

  @override
  void dispose() {
    _namaController.dispose();
    _kategoriController.dispose();
    _hargaController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      setState(() => _pickedImagePath = picked.path);
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final harga = double.tryParse(_hargaController.text.trim()) ?? 0.0;
    final menuVm = context.read<MenuViewModel>();

    final success = await menuVm.saveMenu(
      id: widget.menu?.id,
      nama: _namaController.text.trim(),
      kategori: _kategoriController.text.trim(),
      harga: harga,
      deskripsi: _deskripsiController.text.trim(),
      imagePath: _pickedImagePath,
      isTersedia: _isTersedia,
    );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.menu == null ? 'Menu berhasil ditambahkan!' : 'Menu berhasil diperbarui!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.menu != null;
    final menuVm = context.watch<MenuViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Menu' : 'Tambah Menu Baru'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Picker Area
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: _pickedImagePath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              File(_pickedImagePath!),
                              fit: BoxFit.cover,
                            ),
                          )
                        : (widget.menu?.imageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  widget.menu!.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Center(
                                    child: Icon(Icons.add_a_photo, size: 40, color: AppColors.textMuted),
                                  ),
                                ),
                              )
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo_outlined, size: 42, color: AppColors.primary),
                                  SizedBox(height: 8),
                                  Text(
                                    'Pilih Foto Menu (Galeri)',
                                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              )),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Menu Name
              CustomTextField(
                controller: _namaController,
                label: 'Nama Menu',
                hint: 'Contoh: Mie Ayam Bakso Jumbo',
                prefixIcon: Icons.restaurant,
                validator: (val) => val == null || val.isEmpty ? 'Nama menu wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // Category with suggestions
              CustomTextField(
                controller: _kategoriController,
                label: 'Kategori Menu',
                hint: 'Makanan Utama, Minuman, dsb',
                prefixIcon: Icons.category_outlined,
                validator: (val) => val == null || val.isEmpty ? 'Kategori wajib diisi' : null,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: _commonCategories.map((c) {
                  return ActionChip(
                    label: Text(c, style: const TextStyle(fontSize: 11)),
                    onPressed: () {
                      setState(() => _kategoriController.text = c);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Price
              CustomTextField(
                controller: _hargaController,
                label: 'Harga (Rupiah)',
                hint: '25000',
                prefixIcon: Icons.monetization_on_outlined,
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Harga wajib diisi';
                  if (double.tryParse(val) == null) return 'Harga harus berupa angka';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              CustomTextField(
                controller: _deskripsiController,
                label: 'Deskripsi Menu',
                hint: 'Jelaskan cita rasa, bahan-bahan, dan kelezatannya...',
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Availability Switch
              Card(
                child: SwitchListTile(
                  title: const Text('Status Ketersediaan Menu', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text(
                    _isTersedia ? 'Menu dapat dipesan oleh pelanggan' : 'Menu ditandai habis (stok kosong)',
                    style: const TextStyle(fontSize: 12),
                  ),
                  value: _isTersedia,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) => setState(() => _isTersedia = val),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              CustomButton(
                text: isEditing ? 'Simpan Perubahan' : 'Tambahkan Menu',
                icon: Icons.check,
                isLoading: menuVm.isLoading,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
