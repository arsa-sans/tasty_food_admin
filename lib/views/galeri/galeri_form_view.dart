import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../data/models/galeri_model.dart';
import '../../viewmodels/galeri_viewmodel.dart';

class GaleriFormView extends StatefulWidget {
  final GaleriModel? galeri;

  const GaleriFormView({super.key, this.galeri});

  @override
  State<GaleriFormView> createState() => _GaleriFormViewState();
}

class _GaleriFormViewState extends State<GaleriFormView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _judulController;
  late TextEditingController _deskripsiController;
  String? _pickedImagePath;

  @override
  void initState() {
    super.initState();
    final g = widget.galeri;
    _judulController = TextEditingController(text: g?.judul ?? '');
    _deskripsiController = TextEditingController(text: g?.deskripsi ?? '');
  }

  @override
  void dispose() {
    _judulController.dispose();
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
    if (widget.galeri == null && _pickedImagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih foto terlebih dahulu'), backgroundColor: AppColors.danger),
      );
      return;
    }

    final vm = context.read<GaleriViewModel>();
    final success = await vm.saveGaleri(
      id: widget.galeri?.id,
      judul: _judulController.text.trim(),
      deskripsi: _deskripsiController.text.trim(),
      imagePath: _pickedImagePath,
    );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto galeri berhasil disimpan!'), backgroundColor: AppColors.success),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<GaleriViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.galeri != null ? 'Edit Foto' : 'Unggah Foto Galeri'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Picker Box
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: _pickedImagePath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(File(_pickedImagePath!), fit: BoxFit.cover),
                          )
                        : (widget.galeri?.imageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(widget.galeri!.imageUrl!, fit: BoxFit.cover),
                              )
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo_outlined, size: 44, color: AppColors.primary),
                                  SizedBox(height: 10),
                                  Text(
                                    'Pilih Foto dari Galeri Ponsel',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textSecondary),
                                  ),
                                ],
                              )),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              CustomTextField(
                controller: _judulController,
                label: 'Judul / Keterangan Foto',
                hint: 'Contoh: Suasana Meja Makan Outdoor Restoran',
                prefixIcon: Icons.title,
                validator: (val) => val == null || val.isEmpty ? 'Judul foto wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // Description
              CustomTextField(
                controller: _deskripsiController,
                label: 'Deskripsi Tambahan (Opsional)',
                hint: 'Ceritakan momen atau suasana restoran pada foto ini...',
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              CustomButton(
                text: 'Simpan ke Galeri',
                icon: Icons.cloud_upload_outlined,
                isLoading: vm.isLoading,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
