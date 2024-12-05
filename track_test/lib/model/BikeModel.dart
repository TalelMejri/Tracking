class BikeModel {
  int id;
  String name;
  double latitude;
  double longitude;
  int reserved;
  int NbrLocation;

  BikeModel(
      {required this.id,
      required this.name,
      required this.latitude,
      required this.longitude,
      required this.reserved,
      required this.NbrLocation});

  factory BikeModel.fromJson(Map<String, dynamic> json) {
    return BikeModel(
        id: json["id"],
        latitude: json['latitude'],
        longitude: json['longitude'],
        reserved: json['reserved'],
        name: json['name'],
        NbrLocation:json['NbrLocation']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'reserved': reserved,
      'name': name,
      'NbrLocation':NbrLocation
    };
  }

  @override
  String toString() {
    return 'BikeModel{id: $id, longitude: $longitude, latitude: $latitude, name: $name ,reserved:$reserved , NbrLocation:$NbrLocation}';
  }
}
