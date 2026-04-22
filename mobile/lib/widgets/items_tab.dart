// ItemsTab — second bottom-nav tab. Loads the user's wardrobe items from the
// backend and supports add, edit, and delete with an image picker.

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/item.dart';
import '../services/item_service.dart';
import '../theme/app_theme.dart';
import 'graffiti_button.dart';
import 'graffiti_text_field.dart';

class ItemsTab extends StatefulWidget
{
  // Called after any add/edit/delete so OutfitManagerScreen can refresh its
  // own items pool (used by the slot picker on the Preview tab).
  final VoidCallback onItemsChanged;

  const ItemsTab({super.key, required this.onItemsChanged});

  @override
  State<ItemsTab> createState() => ItemsTabState();
}

// Public so OutfitManagerScreen can call refresh() after outfit changes.
class ItemsTabState extends State<ItemsTab>
{
  final _searchCtrl = TextEditingController();
  List<Item> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState()
  {
    super.initState();
    refresh();
  }

  @override
  void dispose()
  {
    _searchCtrl.dispose();
    super.dispose();
  }

  // Fetches all items. Called on init and after any mutation.
  Future<void> refresh() async
  {
    setState(() { _loading = true; _error = null; });
    final result = await ItemService.searchItems('');
    if (!mounted) return;

    if (!result.success)
    {
      setState(() { _loading = false; _error = result.error; });
      return;
    }

    setState(() { _loading = false; _items = result.data ?? []; });
  }

  // Returns the filtered subset based on the current search query.
  List<Item> get _filtered
  {
    final q = _searchCtrl.text.toLowerCase();
    if (q.isEmpty) return _items;
    return _items.where((i) {
      return i.name.toLowerCase().contains(q) ||
          i.type.toLowerCase().contains(q) ||
          i.tags.any((t) => t.toLowerCase().contains(q));
    }).toList();
  }

  // Opens the full-screen form for creating a new item.
  Future<void> _openAdd() async
  {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const _ItemFormScreen()),
    );
    if (changed == true)
    {
      await refresh();
      widget.onItemsChanged();
    }
  }

  // Opens the full-screen form pre-populated for editing.
  Future<void> _openEdit(Item item) async
  {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => _ItemFormScreen(editing: item)),
    );
    if (changed == true)
    {
      await refresh();
      widget.onItemsChanged();
    }
  }

  // Confirms and deletes an item.
  Future<void> _confirmDelete(Item item) async
  {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.panelDark,
        title: Text('Delete "${item.name}"?', style: AppTextStyles.heading),
        content: const Text('This cannot be undone.', style: AppTextStyles.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL', style: AppTextStyles.link),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('DELETE', style: AppTextStyles.link.copyWith(color: AppColors.errorText)),
          ),
        ],
      ),
    );
    if (ok != true) return;

    final result = await ItemService.deleteItem(item.id);
    if (!mounted) return;

    if (!result.success)
    {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result.error ?? 'Delete failed')));
      return;
    }

    await refresh();
    widget.onItemsChanged();
  }

  @override
  Widget build(BuildContext context)
  {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GraffitiTextField(
            controller: _searchCtrl,
            placeholder: 'Search items',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          GraffitiButton(
            label: '+ New item',
            variant: GraffitiButtonVariant.aqua,
            onPressed: _openAdd,
          ),
          const SizedBox(height: 20),
          Expanded(child: _buildGrid()),
        ],
      ),
    );
  }

  Widget _buildGrid()
  {
    if (_loading) return const Center(child: CircularProgressIndicator(color: AppColors.accentAqua));

    if (_error != null)
    {
      return Center(
        child: Text('Error: $_error', style: AppTextStyles.error, textAlign: TextAlign.center),
      );
    }

    final items = _filtered;
    if (items.isEmpty)
    {
      return Center(
        child: Text(
          _items.isEmpty ? 'No items yet.\nTap "+ New item" to add your first.' : 'No items match your search.',
          style: AppTextStyles.body,
          textAlign: TextAlign.center,
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _ItemCard(
        item: items[i],
        onTap: () => _openEdit(items[i]),
        onDelete: () => _confirmDelete(items[i]),
      ),
    );
  }
}

// ─── Item Card ────────────────────────────────────────────────────────────────

class _ItemCard extends StatelessWidget
{
  final Item item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ItemCard({required this.item, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context)
  {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.inputBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox.expand(
                      child: item.imageUrl.isNotEmpty
                          ? Image.network(
                              item.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const _NoImageBox(),
                            )
                          : const _NoImageBox(),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: onDelete,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.delete_outline, color: AppColors.errorText, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.name,
              style: AppTextStyles.input.copyWith(fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.accentPink.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                item.type.toUpperCase(),
                style: AppTextStyles.body.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accentPink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoImageBox extends StatelessWidget
{
  const _NoImageBox();

  @override
  Widget build(BuildContext context)
  {
    return const ColoredBox(
      color: Colors.black26,
      child: Center(child: Icon(Icons.checkroom, color: Colors.white38, size: 36)),
    );
  }
}

// ─── Item Form Screen ─────────────────────────────────────────────────────────

const _kTypes = ['HAT', 'SHIRT', 'PANTS', 'SHOES', 'JACKET', 'ACCESSORY'];

class _ItemFormScreen extends StatefulWidget
{
  final Item? editing;

  const _ItemFormScreen({this.editing});

  @override
  State<_ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends State<_ItemFormScreen>
{
  final _nameCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  String _type = _kTypes.first;
  XFile? _pickedImage;
  Uint8List? _previewBytes;
  bool _saving = false;
  String? _error;

  @override
  void initState()
  {
    super.initState();
    final item = widget.editing;
    if (item != null)
    {
      _nameCtrl.text = item.name;
      _type = _kTypes.contains(item.type.toUpperCase()) ? item.type.toUpperCase() : _kTypes.first;
      _notesCtrl.text = item.notes;
      _tagsCtrl.text = item.tags.join(', ');
    }
  }

  @override
  void dispose()
  {
    _nameCtrl.dispose();
    _notesCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  // Opens the system image picker (gallery on mobile, file dialog on web).
  Future<void> _pickImage() async
  {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() { _pickedImage = file; _previewBytes = bytes; });
  }

  // Splits the tags field on commas, trims whitespace, drops empty strings.
  List<String> _parseTags() =>
      _tagsCtrl.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();

  Future<void> _submit() async
  {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty)
    {
      setState(() => _error = 'Name is required');
      return;
    }

    setState(() { _saving = true; _error = null; });

    final existing = widget.editing;
    final result = existing == null
        ? await ItemService.addItem(
            name: name,
            type: _type,
            notes: _notesCtrl.text.trim(),
            tags: _parseTags(),
            image: _pickedImage,
          )
        : await ItemService.editItem(
            itemId: existing.id,
            name: name,
            type: _type,
            notes: _notesCtrl.text.trim(),
            tags: _parseTags(),
            image: _pickedImage,
          );

    if (!mounted) return;
    setState(() => _saving = false);

    if (!result.success)
    {
      setState(() => _error = result.error);
      return;
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context)
  {
    final isEdit = widget.editing != null;
    final existingImageUrl = widget.editing?.imageUrl ?? '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Text(
          isEdit ? 'EDIT ITEM' : 'NEW ITEM',
          style: AppTextStyles.heading.copyWith(fontSize: 18),
        ),
        iconTheme: const IconThemeData(color: AppColors.textBright),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image preview / picker
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.inputBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.inputBorder),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: _buildImagePreview(_previewBytes, existingImageUrl),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'TAP TO PICK IMAGE',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary.withValues(alpha: 0.5),
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(height: 24),

            GraffitiTextField(controller: _nameCtrl, placeholder: 'Name'),
            const SizedBox(height: 14),

            // Type dropdown styled to match the text field.
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.inputBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _type,
                  dropdownColor: AppColors.panelDark,
                  iconEnabledColor: AppColors.textBright,
                  style: AppTextStyles.input,
                  items: _kTypes
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) { if (v != null) setState(() => _type = v); },
                ),
              ),
            ),
            const SizedBox(height: 14),

            GraffitiTextField(controller: _tagsCtrl, placeholder: 'Tags (comma-separated)'),
            const SizedBox(height: 14),

            GraffitiTextField(controller: _notesCtrl, placeholder: 'Notes'),

            if (_error != null) ...[
              const SizedBox(height: 14),
              Text(_error!, style: AppTextStyles.error, textAlign: TextAlign.center),
            ],
            const SizedBox(height: 28),

            GraffitiButton(
              label: _saving ? 'Saving...' : (isEdit ? 'Save changes' : 'Create item'),
              onPressed: _saving ? null : _submit,
              busy: _saving,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Shows the freshly-picked image, the existing URL image, or a placeholder.
  Widget _buildImagePreview(Uint8List? localBytes, String networkUrl)
  {
    if (localBytes != null)
    {
      return Image.memory(localBytes, fit: BoxFit.contain);
    }
    if (networkUrl.isNotEmpty)
    {
      return Image.network(
        networkUrl,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => const _PickerPlaceholder(),
      );
    }
    return const _PickerPlaceholder();
  }
}

class _PickerPlaceholder extends StatelessWidget
{
  const _PickerPlaceholder();

  @override
  Widget build(BuildContext context)
  {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_outlined, color: AppColors.accentAqua, size: 48),
        SizedBox(height: 8),
        Text('Add image', style: AppTextStyles.link),
      ],
    );
  }
}
