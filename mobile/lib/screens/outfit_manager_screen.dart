// OutfitManagerScreen — lists the user's outfits and supports create / edit / delete.

import 'package:flutter/material.dart';

import '../models/outfit.dart';
import '../services/auth_service.dart';
import '../services/outfit_service.dart';
import 'login_screen.dart';

class OutfitManagerScreen extends StatefulWidget
{
  const OutfitManagerScreen({super.key});

  @override
  State<OutfitManagerScreen> createState() => _OutfitManagerScreenState();
}

class _OutfitManagerScreenState extends State<OutfitManagerScreen>
{
  List<Outfit> _outfits = [];
  bool _loading = true;
  String? _error;

  @override
  void initState()
  {
    super.initState();
    _load();
  }

  // Fetches the outfit list. If the server reports the JWT is expired, AuthService.logout
  // has already run inside the service — bounce the user back to Login.
  Future<void> _load() async
  {
    setState(() { _loading = true; _error = null; });
    final result = await OutfitService.listOutfits();
    if (!mounted) return;

    if (!result.success)
    {
      final loggedIn = await AuthService.isLoggedIn();
      if (!mounted) return;
      if (!loggedIn)
      {
        _goToLogin();
        return;
      }
      setState(() { _loading = false; _error = result.error; });
      return;
    }

    setState(() { _loading = false; _outfits = result.data ?? []; });
  }

  // Clears the token and replaces the stack with the Login screen.
  Future<void> _logout() async
  {
    await AuthService.logout();
    if (!mounted) return;
    _goToLogin();
  }

  void _goToLogin()
  {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  // Opens the create/edit form. When outfit is null we're creating; otherwise editing.
  Future<void> _openEditor({Outfit? outfit}) async
  {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => _OutfitEditor(outfit: outfit)),
    );
    if (changed == true) await _load();
  }

  // Prompts for confirmation, deletes the outfit, and refreshes the list.
  Future<void> _confirmDelete(Outfit outfit) async
  {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${outfit.name}"?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;

    final result = await OutfitService.deleteOutfit(outfit.id);
    if (!mounted) return;

    if (!result.success)
    {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result.error ?? 'Delete failed')));
      return;
    }
    await _load();
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Outfits'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh), tooltip: 'Refresh'),
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout), tooltip: 'Logout'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(),
        child: const Icon(Icons.add),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody()
  {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text('Error: $_error'));
    if (_outfits.isEmpty)
    {
      return const Center(child: Text('No outfits yet. Tap + to create one.'));
    }

    return ListView.separated(
      itemCount: _outfits.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (_, i)
      {
        final o = _outfits[i];
        return ListTile(
          title: Text(o.name),
          subtitle: Text(
            o.description.isEmpty
                ? '${o.itemIds.length} item(s)'
                : '${o.description} · ${o.itemIds.length} item(s)',
          ),
          onTap: () => _openEditor(outfit: o),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(o),
          ),
        );
      },
    );
  }
}

// Inline create/edit form. Separated from the list screen to keep each widget focused.
class _OutfitEditor extends StatefulWidget
{
  final Outfit? outfit;
  const _OutfitEditor({this.outfit});

  @override
  State<_OutfitEditor> createState() => _OutfitEditorState();
}

class _OutfitEditorState extends State<_OutfitEditor>
{
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _itemIdsCtrl;
  bool _submitting = false;

  @override
  void initState()
  {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.outfit?.name ?? '');
    _descCtrl = TextEditingController(text: widget.outfit?.description ?? '');
    // Item IDs are edited as a comma-separated string since a proper picker is out of scope.
    _itemIdsCtrl = TextEditingController(text: widget.outfit?.itemIds.join(',') ?? '');
  }

  @override
  void dispose()
  {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _itemIdsCtrl.dispose();
    super.dispose();
  }

  // Splits the itemIds text field into a clean list of non-empty ids.
  List<String> _parseItemIds()
  {
    return _itemIdsCtrl.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  // Dispatches to add or edit depending on whether we opened with an existing outfit.
  Future<void> _submit() async
  {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty)
    {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Name is required')));
      return;
    }

    setState(() => _submitting = true);

    final itemIds = _parseItemIds();
    final description = _descCtrl.text.trim();

    final existing = widget.outfit;
    final result = existing == null
        ? await OutfitService.addOutfit(name: name, description: description, itemIds: itemIds)
        : await OutfitService.editOutfit(
            outfitId: existing.id,
            name: name,
            description: description,
            itemIds: itemIds,
          );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (!result.success)
    {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result.error ?? 'Save failed')));
      return;
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context)
  {
    final isEdit = widget.outfit != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit outfit' : 'New outfit')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _itemIdsCtrl,
              decoration: const InputDecoration(
                labelText: 'Item IDs (comma-separated, optional)',
                helperText: 'Leave blank for now; a real item picker comes later.',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(isEdit ? 'Save changes' : 'Create outfit'),
            ),
          ],
        ),
      ),
    );
  }
}
