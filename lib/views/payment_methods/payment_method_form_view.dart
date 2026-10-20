import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../data/models/payment_method_model.dart';
import '../../viewmodels/payment_method_viewmodel.dart';

class PaymentMethodFormView extends StatefulWidget {
  final PaymentMethodModel? method;

  const PaymentMethodFormView({super.key, this.method});

  @override
  State<PaymentMethodFormView> createState() => _PaymentMethodFormViewState();
}

class _PaymentMethodFormViewState extends State<PaymentMethodFormView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _nomorRekeningController;
  late TextEditingController _atasNamaController;
  late TextEditingController _instruksiController;
  late String _tipe;
  late bool _isAktif;
  String? _pickedImagePath;

  @override
  void initState() {
    super.initState();
    final m = widget.method;
    _namaController = TextEditingController(text: m?.nama ?? '');
    _nomorRekeningController = TextEditingController(text: m?.nomorRekening ?? '');
    _atasNamaController = TextEditingController(text: m?.atasNama ?? '');
    _instruksiController = TextEditingController(text: m?.instruksi ?? '');
    _tipe = m?.tipe ?? 'cash';
    _isAktif = m?.isAktif ?? true;
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nomorRekeningController.dispose();
    _atasNamaController.dispose();
    _instruksiController.dispose();
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

    final payVm = context.read<PaymentMethodViewModel>();
    final success = await payVm.savePaymentMethod(
      id: widget.method?.id,
      nama: _namaController.text.trim(),
      tipe: _tipe,
      nomorRekening: _nomorRekeningController.text.trim(),
      atasNama: _atasNamaController.text.trim(),
      instruksi: _instruksiController.text.trim(),
      imagePath: _pickedImagePath,
      isAktif: _isAktif,
    );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.method == null ? 'Metode pembayaran ditambahkan!' : 'Metode pembayaran diperbarui!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.method != null;
    final payVm = context.watch<PaymentMethodViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Metode Pembayaran' : 'Tambah Metode Pembayaran'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo / QRIS Image Picker
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 140,
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
                              fit: BoxFit.contain,
                            ),
                          )
                        : (widget.method?.gambarUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  widget.method!.gambarUrl!,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Center(
                                    child: Icon(Icons.qr_code_2, size: 40, color: AppColors.textMuted),
                                  ),
                                ),
                              )
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.qr_code_2_rounded, size: 40, color: AppColors.primary),
                                  SizedBox(height: 8),
                                  Text(
                                    'Pilih Logo / QRIS Image (Opsional)',
                                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              )),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Name
              CustomTextField(
                controller: _namaController,
                label: 'Nama Metode Pembayaran',
                hint: 'Contoh: Transfer BCA, QRIS, Tunai (COD)',
                prefixIcon: Icons.payment,
                validator: (val) => val == null || val.isEmpty ? 'Nama metode wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // Tipe Dropdown
              const Text(
                'Tipe Pembayaran',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _tipe,
                decoration: const InputDecoration(),
                items: const [
                  DropdownMenuItem(value: 'cash', child: Text('Tunai (COD)')),
                  DropdownMenuItem(value: 'e_wallet', child: Text('E-Wallet / QRIS')),
                  DropdownMenuItem(value: 'bank', child: Text('Transfer Bank')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _tipe = val);
                },
              ),
              const SizedBox(height: 16),

              if (_tipe != 'cash') ...[
                // Account number / e-wallet phone
                CustomTextField(
                  controller: _nomorRekeningController,
                  label: _tipe == 'bank' ? 'Nomor Rekening Bank' : 'Nomor HP E-Wallet',
                  hint: 'Contoh: 5221345678',
                  prefixIcon: Icons.credit_card,
                ),
                const SizedBox(height: 16),

                // Account Holder Name
                CustomTextField(
                  controller: _atasNamaController,
                  label: 'Atas Nama (A/N)',
                  hint: 'Contoh: PT Tasty Food Indonesia',
                  prefixIcon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
              ],

              // Instructions
              CustomTextField(
                controller: _instruksiController,
                label: 'Instruksi Pembayaran',
                hint: 'Langkah-langkah transfer atau pembayaran bagi pelanggan...',
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Active switch
              Card(
                child: SwitchListTile(
                  title: const Text('Status Aktif', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Tampilkan metode ini pada saat checkout pelanggan', style: TextStyle(fontSize: 12)),
                  value: _isAktif,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) => setState(() => _isAktif = val),
                ),
              ),
              const SizedBox(height: 24),

              CustomButton(
                text: isEditing ? 'Simpan Perubahan' : 'Tambahkan Metode',
                icon: Icons.check,
                isLoading: payVm.isLoading,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
