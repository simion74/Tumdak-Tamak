import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/local_store.dart';
import '../widgets/app_top_bar.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List<Map<String, String>> _projects = [];
  String _activeId = 'default';
  bool _haptic = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final projects = await LocalStore.instance.loadProjects();
    final active = await LocalStore.instance.getActiveProjectId();
    final haptic = await LocalStore.instance.getHapticEnabled();
    if (!mounted) return;
    setState(() {
      _projects = projects;
      _activeId = active;
      _haptic = haptic;
      _loading = false;
    });
  }

  Future<void> _addProject() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.panelDark,
        title: const Text('New Sound Project', style: TextStyle(color: AppColors.gold)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter project name',
            hintStyle: TextStyle(color: Colors.white38),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.gold)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Add', style: TextStyle(color: AppColors.goldBright)),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    final id = 'proj_${DateTime.now().millisecondsSinceEpoch}';
    setState(() {
      _projects = [..._projects, {'id': id, 'name': name}];
    });
    await LocalStore.instance.saveProjects(_projects);
  }

  Future<void> _selectProject(String id) async {
    setState(() => _activeId = id);
    await LocalStore.instance.setActiveProjectId(id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Project selected')),
    );
  }

  Future<void> _deleteProject(String id) async {
    if (id == 'default') return; // keep at least one project
    setState(() => _projects = _projects.where((p) => p['id'] != id).toList());
    await LocalStore.instance.saveProjects(_projects);
    if (_activeId == id) {
      await _selectProject('default');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppGradients.maroonBackground,
        child: Column(
          children: [
            AppTopBar(
              title: 'Settings',
              onLeadingTap: () => Navigator.of(context).pop(),
              actions: const [],
            ),
            if (_loading)
              const Expanded(child: Center(child: CircularProgressIndicator(color: AppColors.gold)))
            else
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    Row(
                      children: [
                        const GoldText('Sound Projects', fontSize: 16),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: _addProject,
                          icon: const Icon(Icons.add_circle_outline, color: AppColors.goldBright),
                          label: const Text('New Project', style: TextStyle(color: AppColors.goldBright)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    for (final p in _projects)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: p['id'] == _activeId ? AppColors.goldBright : AppColors.gold.withOpacity(0.25),
                            width: p['id'] == _activeId ? 1.6 : 1,
                          ),
                        ),
                        child: ListTile(
                          leading: Icon(
                            p['id'] == _activeId ? Icons.check_circle : Icons.folder_rounded,
                            color: p['id'] == _activeId ? AppColors.goldBright : AppColors.gold.withOpacity(0.7),
                          ),
                          title: Text(p['name'] ?? '', style: const TextStyle(color: Colors.white)),
                          onTap: () => _selectProject(p['id']!),
                          trailing: p['id'] == 'default'
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.white38),
                                  onPressed: () => _deleteProject(p['id']!),
                                ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    const GoldText('General', fontSize: 16),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.gold.withOpacity(0.25)),
                      ),
                      child: SwitchListTile(
                        value: _haptic,
                        onChanged: (v) async {
                          setState(() => _haptic = v);
                          await LocalStore.instance.setHapticEnabled(v);
                        },
                        activeColor: AppColors.gold,
                        title: const Text('Vibrate on tap (Haptic)', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.gold.withOpacity(0.25)),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.info_outline, color: AppColors.gold),
                        title: const Text('Tumdak ~ Tamak', style: TextStyle(color: Colors.white)),
                        subtitle: const Text('Version 0.1.0', style: TextStyle(color: Colors.white54)),
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
}
