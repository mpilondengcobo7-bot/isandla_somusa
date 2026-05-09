import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../../providers/auth_provider.dart';
import '../../providers/donation_provider.dart';
import '../../models/donation_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_constants.dart';
import '../../utils/validators.dart';
import '../../utils/helpers.dart';

class CreateDonationScreen extends StatefulWidget {
  const CreateDonationScreen({super.key});
  @override
  State<CreateDonationScreen> createState() => _CreateDonationScreenState();
}

class _CreateDonationScreenState extends State<CreateDonationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();
  final _qtyCtrl   = TextEditingController();
  final _addrCtrl  = TextEditingController();

  String _category = AppConstants.foodCategories.first;
  String _unit = 'portions';
  DateTime _expiry = DateTime.now().add(const Duration(hours: 24));
  List<String> _timeSlots = [];
  File? _imageFile;
  bool _isHalaal = false, _isVegetarian = false;
  List<String> _allergens = [];
  double? _lat, _lng;
  bool _locating = false;

  @override
  void dispose() {
    _titleCtrl.dispose(); _descCtrl.dispose();
    _qtyCtrl.dispose(); _addrCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (xFile != null) setState(() => _imageFile = File(xFile.path));
  }

  Future<void> _getLocation() async {
    setState(() => _locating = true);
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) throw Exception('Permission denied');
      final pos = await Geolocator.getCurrentPosition();
      setState(() { _lat = pos.latitude; _lng = pos.longitude; _locating = false; });
      _addrCtrl.text = 'Location detected (${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)})';
    } catch (e) {
      setState(() { _locating = false; _lat = AppConstants.defaultLat; _lng = AppConstants.defaultLng; });
    }
  }

  Future<void> _pickExpiry() async {
    final picked = await showDatePicker(
      context: context, initialDate: _expiry,
      firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 7)),
    );
    if (picked != null) setState(() => _expiry = picked);
  }

  void _toggleTimeSlot(String slot) {
    setState(() {
      _timeSlots.contains(slot) ? _timeSlots.remove(slot) : _timeSlots.add(slot);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_timeSlots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one pickup time slot')));
      return;
    }
    if (_lat == null) { await _getLocation(); }

    final auth = context.read<AuthProvider>();
    final prov = context.read<DonationProvider>();
    final id = prov.generateId();

    final donation = DonationModel(
      id: id,
      donorId: auth.user!.uid,
      donorName: auth.user!.displayName,
      donorPhoto: auth.user!.photoUrl,
      title: Validators.sanitise(_titleCtrl.text) ?? _titleCtrl.text,
      description: Validators.sanitise(_descCtrl.text) ?? _descCtrl.text,
      category: _category,
      quantity: int.tryParse(_qtyCtrl.text) ?? 1,
      unit: _unit,
      expiryDate: _expiry,
      latitude: _lat ?? AppConstants.defaultLat,
      longitude: _lng ?? AppConstants.defaultLng,
      address: _addrCtrl.text.trim(),
      availableTimeSlots: _timeSlots,
      donorRating: auth.user!.rating,
      isHalaal: _isHalaal,
      isVegetarian: _isVegetarian,
      allergens: _allergens,
      createdAt: DateTime.now(),
    );

    final ok = await prov.createDonation(donation, imageFile: _imageFile);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Donation posted successfully!'), backgroundColor: AppTheme.successGreen));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(prov.error ?? 'Failed to post donation'), backgroundColor: AppTheme.errorRed));
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<DonationProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Post a donation')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Image picker
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 160, width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.tealGreen.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.tealGreen.withOpacity(0.3), style: BorderStyle.solid),
                ),
                child: _imageFile != null
                    ? ClipRRect(borderRadius: BorderRadius.circular(12),
                        child: Image.file(_imageFile!, fit: BoxFit.cover))
                    : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.add_photo_alternate_outlined, size: 40, color: AppTheme.tealGreen),
                        SizedBox(height: 8),
                        Text('Add food photo (optional)', style: TextStyle(color: AppTheme.tealGreen)),
                      ]),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Food title *', prefixIcon: Icon(Icons.fastfood_outlined)),
              validator: (v) => Validators.required(v, fieldName: 'Title'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descCtrl, maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description *', prefixIcon: Icon(Icons.description_outlined),
                  alignLabelWithHint: true),
              validator: (v) => Validators.required(v, fieldName: 'Description'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Category', prefixIcon: Icon(Icons.category_outlined)),
              items: AppConstants.foodCategories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: TextFormField(
                controller: _qtyCtrl, keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantity *', prefixIcon: Icon(Icons.numbers)),
                validator: Validators.quantity,
              )),
              const SizedBox(width: 12),
              Expanded(child: DropdownButtonFormField<String>(
                value: _unit,
                decoration: const InputDecoration(labelText: 'Unit'),
                items: ['portions', 'kg', 'items', 'litres', 'boxes']
                    .map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                onChanged: (v) => setState(() => _unit = v!),
              )),
            ]),
            const SizedBox(height: 12),
            // Expiry date
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined, color: AppTheme.tealGreen),
              title: const Text('Expiry date *'),
              subtitle: Text(Helpers.formatDate(_expiry),
                style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.tealGreen)),
              trailing: TextButton(onPressed: _pickExpiry, child: const Text('Change')),
            ),
            const Divider(),
            // Address
            const SizedBox(height: 8),
            TextFormField(
              controller: _addrCtrl,
              decoration: InputDecoration(
                labelText: 'Pickup address *',
                prefixIcon: const Icon(Icons.location_on_outlined),
                suffixIcon: _locating
                    ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2))
                    : IconButton(icon: const Icon(Icons.my_location), onPressed: _getLocation,
                        tooltip: 'Use my location'),
              ),
              validator: (v) => Validators.required(v, fieldName: 'Address'),
            ),
            const SizedBox(height: 16),
            const Text('Available pickup time slots *',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8,
              children: AppConstants.timeSlots.map((slot) {
                final sel = _timeSlots.contains(slot);
                return FilterChip(
                  label: Text(slot),
                  selected: sel,
                  onSelected: (_) => _toggleTimeSlot(slot),
                  selectedColor: AppTheme.tealGreen.withOpacity(0.15),
                  checkmarkColor: AppTheme.tealGreen,
                  labelStyle: TextStyle(color: sel ? AppTheme.tealGreen : null, fontSize: 12),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Dietary information',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            Row(children: [
              Expanded(child: CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Halaal', style: TextStyle(fontSize: 14)),
                value: _isHalaal,
                onChanged: (v) => setState(() => _isHalaal = v!),
                activeColor: AppTheme.tealGreen,
              )),
              Expanded(child: CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Vegetarian', style: TextStyle(fontSize: 14)),
                value: _isVegetarian,
                onChanged: (v) => setState(() => _isVegetarian = v!),
                activeColor: AppTheme.tealGreen,
              )),
            ]),
            const SizedBox(height: 24),
            prov.loading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.volunteer_activism),
                    label: const Text('Post donation'),
                  ),
            const SizedBox(height: 32),
          ]),
        ),
      ),
    );
  }
}
