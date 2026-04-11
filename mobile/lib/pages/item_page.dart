import 'package:flutter/material.dart';

class ItemPage extends StatefulWidget {
  final String firstName;

  const ItemPage({super.key, required this.firstName});

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  final _searchController = TextEditingController();
  final _addItemController = TextEditingController();

  String _searchResultMessage = '';
  String _itemList = '';
  String _addResultMessage = '';

  // Local hardcoded item storage
  final List<String> _items = [];

  void _doLogout() {
    Navigator.of(context).pop();
  }

  void _searchItem() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return;

    final results = _items.where((item) => item.toLowerCase().contains(query)).toList();

    setState(() {
      if (results.isNotEmpty) {
        _searchResultMessage = 'Item(s) have been retrieved';
        _itemList = results.join(', ');
      } else {
        _searchResultMessage = 'No items found';
        _itemList = '';
      }
    });
  }

  void _addItem() {
    final itemName = _addItemController.text.trim();
    if (itemName.isEmpty) return;

    setState(() {
      _items.add(itemName);
      _addResultMessage = 'Item has been added';
      _addItemController.clear();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _addItemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Title
              Padding(
                padding: const EdgeInsets.only(top: 32),
                child: Text(
                  'Outfittr',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: -1.68,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Logged in bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Theme.of(context).dividerColor),
                    bottom: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Logged In As ${widget.firstName}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _doLogout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFAA3BFF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Log Out'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Search section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Search Items',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Item To Search For',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                    color: Color(0xFFAA3BFF), width: 2),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _searchItem,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFAA3BFF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Search Item'),
                        ),
                      ],
                    ),
                    if (_searchResultMessage.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        _searchResultMessage,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                    if (_itemList.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        _itemList,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Add item section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Add Item',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _addItemController,
                            decoration: InputDecoration(
                              hintText: 'Item To Add',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                    color: Color(0xFFAA3BFF), width: 2),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _addItem,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFAA3BFF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Add Item'),
                        ),
                      ],
                    ),
                    if (_addResultMessage.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        _addResultMessage,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
