// Item model — represents a wardrobe item belonging to a user.

class Item
{
  final String id;
  final String name;
  final String type;
  final List<String> tags;
  final String notes;
  final String imageUrl;

  Item({
    required this.id,
    required this.name,
    required this.type,
    required this.tags,
    required this.notes,
    required this.imageUrl,
  });

  // Builds an Item from the JSON shape the backend returns.
  // Backend fields: _id, name, type, tags (string[]), notes, imageURL.
  factory Item.fromJson(Map<String, dynamic> json)
  {
    // Mongo's _id can come back as a string or as { $oid: "..." } depending on serialization.
    final rawId = json['_id'];
    final id = rawId is Map ? (rawId['\$oid'] ?? '').toString() : (rawId ?? '').toString();

    // tags is a JSON array of strings; defensively handle null.
    final rawTags = json['tags'];
    final tags = rawTags is List ? rawTags.map((t) => t.toString()).toList() : <String>[];

    return Item(
      id: id,
      name: (json['name'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      tags: tags,
      notes: (json['notes'] ?? '').toString(),
      imageUrl: (json['imageURL'] ?? '').toString(),
    );
  }
}
