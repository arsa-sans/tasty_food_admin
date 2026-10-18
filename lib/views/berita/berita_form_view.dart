import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../data/models/berita_model.dart';
import '../../viewmodels/berita_viewmodel.dart';

class BeritaFormView extends StatefulWidget {
  final BeritaModel? berita;

  const BeritaFormView({super.key, this.berita});

  @override
  State<BeritaFormView> createState() => _BeritaFormViewState();
}

class _BeritaFormViewState extends State<BeritaFormView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _judulController;
  late TextEditingController _kontenController;
  late String _status;
  late DateTime _tanggal;
  String? _pickedImagePath;

  @override
  void initState() {
    super.initState();
    final b = widget.berita;
    _judulController = TextEditingController(text: b?.judul ?? '');
    _kontenController = TextEditingController(text: b?.konten ?? '');
    _status = b?.status ?? 'published';
    _tanggal = b?.tanggal ?? DateTime.now();
  }

  @override
  void dispose() {
    _judulController.dispose();
    _kontenController.dispose();
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

    final vm = context.read<BeritaViewModel>();
    final success = await vm.saveBerita(
      id: widget.berita?.id,
      judul: _judulController.text.trim(),
      konten: _kontenController.text.trim(),
      status: _status,
      tanggal: _tanggal,
      imagePath: _pickedImagePath,
    );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.berita == null ? 'Berita berhasil dipublikasikan!' : 'Berita berhasil diperbarui!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.berita != null;
    final vm = context.watch<BeritaViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Berita' : 'Tulis Berita Baru'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Picker
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 160,
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
                        : (widget.berita?.imageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(widget.berita!.imageUrl!, fit: BoxFit.cover),
                              )
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate_outlined, size: 40, color: AppColors.primary),
                                  SizedBox(height: 8),
                                  Text(
                                    'Pilih Foto Header Berita',
                                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
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
                label: 'Judul Berita',
                hint: 'Contoh: Rahasia Cita Rasa Lezat Kuliner Nusantara',
                prefixIcon: Icons.title,
                validator: (val) => val == null || val.isEmpty ? 'Judul wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // Status Dropdown
              const Text('Status Publikasi', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(),
                items: const [
                  DropdownMenuItem(value: 'published', child: Text('Published (Langsung Tayang)')),
                  DropdownMenuItem(value: 'draft', child: Text('Draft (Simpan Sementara)')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _status = val);
                },
              ),
              const SizedBox(height: 16),

              // Date Picker Field
              CustomTextField(
                label: 'Tanggal Berita',
                controller: TextEditingController(text: Formatters.formatDate(_tanggal)),
                readOnly: true,
                prefixIcon: Icons.calendar_today,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _tanggal,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setState(() => _tanggal = picked);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Content
              CustomTextField(
                controller: _kontenController,
                label: 'Konten / Isi Artikel',
                hint: 'Tuliskan isi berita secara lengkap...',
                maxLines: 8,
                validator: (val) => val == null || val.isEmpty ? 'Konten tidak boleh kosong' : null,
              ),
              const SizedBox(height: 24),

              CustomButton(
                text: isEditing ? 'Simpan Perubahan' : 'Publikasikan Berita',
                icon: Icons.publish,
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
