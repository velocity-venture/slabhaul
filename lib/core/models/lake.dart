class Lake {
  final String id;
  final String name;
  final String state;
  final double centerLat;
  final double centerLon;
  final double zoomLevel;
  final double? normalPoolElevation;
  final String? usgsGageId;
  final int attractorCount;

  const Lake({
    required this.id,
    required this.name,
    required this.state,
    required this.centerLat,
    required this.centerLon,
    this.zoomLevel = 13.0,
    this.normalPoolElevation,
    this.usgsGageId,
    this.attractorCount = 0,
  });

  factory Lake.fromJson(Map<String, dynamic> json) {
    return Lake(
      id: json['id'] as String,
      name: json['name'] as String,
      state: json['state'] as String,
      centerLat: (json['center_lat'] as num).toDouble(),
      centerLon: (json['center_lon'] as num).toDouble(),
      zoomLevel: (json['zoom_level'] as num?)?.toDouble() ?? 13.0,
      normalPoolElevation:
          (json['normal_pool_elevation'] as num?)?.toDouble(),
      usgsGageId: json['usgs_gage_id'] as String?,
      attractorCount: json['attractor_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'state': state,
        'center_lat': centerLat,
        'center_lon': centerLon,
        'zoom_level': zoomLevel,
        'normal_pool_elevation': normalPoolElevation,
        'usgs_gage_id': usgsGageId,
        'attractor_count': attractorCount,
      };

  String get displayName => '$name, $state';
}
