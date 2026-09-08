import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../services/local_store.dart';
import '../widgets/app_top_bar.dart';

const List<String> kInstrumentOptions = ['Tumdak', 'Tamak', 'Octapad'];

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  final _aboutController = TextEditingController();
  String _uniqueId = '';
  String _instrument = 'Tumdak';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profile = await LocalStore.instance.loadProfile();
    if (!mounted) return;
    setState(() {
      _nameController.text = profile['name'] ?? '';
      _aboutController.text = profile['about'] ?? '';
      _uniqueId = profile['id'] ?? '';
      _instrument = profile['instrument'] ?? 'Tumdak';
      _loading = false;
    });
  }

  Future<void> _save() async {
    await LocalStore.instance.saveProfile(
      name: _nameController.text.trim(),
      about: _aboutController.text.trim(),
      instrument: _instrument,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved')),
    );
  }

  void _copyId() {
    Clipboard.setData(ClipboardData(text: _uniqueId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ID copied')),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppGradients.maroonBackground,
        child: Column(
          children: [
            AppTopBar(
              title: 'Profile',
              onLeadingTap: () => Navigator.of(context).pop(),
              actions: [
                TopBarAction(
                  iconAsset: 'assets/images/icon/download_save_icon.png',
                  label: 'Save',
                  onTap: _save,
                ),
              ],
            ),
            if (_loading)
              const Expanded(child: Center(child: CircularProgressIndicator(color: AppColors.gold)))
            else
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Center(
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black26,
                          border: Border.all(color: AppColors.gold, width: 1.6),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.person, color: AppColors.gold, size: 46),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: GestureDetector(
                        onTap: _copyId,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.gold.withOpacity(0.5)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('ID: $_uniqueId', style: const TextStyle(color: AppColors.gold, fontSize: 12)),
                              const SizedBox(width: 6),
                              const Icon(Icons.copy, color: AppColors.gold, size: 14),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Name', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 6),
                    _field(_nameController, hint: 'Enter your name'),
                    const SizedBox(height: 18),
                    const Text('Favorite Instrument', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.gold.withOpacity(0.4)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _instrument,
                          isExpanded: true,
                          dropdownColor: AppColors.panelDark,
                          style: const TextStyle(color: Colors.white),
                          items: kInstrumentOptions
                              .map((i) => DropdownMenuItem(value: i, child: Text(i)))
                              .toList(),
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() => _instrument = v);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text('About (optional)', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 6),
                    _field(_aboutController, hint: 'Write something about yourself', maxLines: 3),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Save Profile', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, {required String hint, int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: Colors.black26,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}
