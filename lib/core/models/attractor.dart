class Attractor {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String lakeId;
  final String lakeName;
  final String state;
  final String type; // brush_pile, pvc_tree, stake_bed, pallet, unknown
  final double? depth;
  final String? description;
  final String? source; // AGFC, TWRA, KDFWR, community
  final int? yearPlaced;
  final bool verified;

  const Attractor({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.lakeId,
    required this.lakeName,
    required this.state,
    required this.type,
    this.depth,
    this.description,
    this.source,
    this.yearPlaced,
    this.verified = false,
  });

  factory Attractor.fromJson(Map<String, dynamic> json) {
    return Attractor(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      lakeId: json['lake_id'] as String,
      lakeName: json['lake_name'] as String,
      state: json['state'] as String,
      type: json['type'] as String? ?? 'unknown',
      depth: (json['depth'] as num?)?.toDouble(),
      description: json['description'] as String?,
      source: json['source'] as String?,
      yearPlaced: json['year_placed'] as int?,
      verified: json['verified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'lake_id': lakeId,
        'lake_name': lakeName,
        'state': state,
        'type': type,
        'depth': depth,
        'description': description,
        'source': source,
        'year_placed': yearPlaced,
        'verified': verified,
      };

  String get typeLabel {
    switch (type) {
      case 'brush_pile':
        return 'Brush Pile';
      case 'pvc_tree':
        return 'PVC Tree';
      case 'stake_bed':
        return 'Stake Bed';
      case 'pallet':
        return 'Pallet';
      default:
        return 'Unknown';
    }
  }

  String get coordinateString =>
      '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
}
