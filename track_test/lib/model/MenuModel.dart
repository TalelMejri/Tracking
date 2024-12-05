class MenuModel {
  int bikesReserved;
  int bikesNotReserved;

  MenuModel({
    required this.bikesReserved,
    required this.bikesNotReserved,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      bikesReserved: json["bikesReserved"],
      bikesNotReserved: json['bikesNotReserved'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bikesReserved': bikesReserved,
      'bikesNotReserved': bikesNotReserved,
    };
  }

  @override
  String toString() {
    return 'MenuModel{bikesReserved: $bikesReserved, bikesNotReserved: $bikesNotReserved}';
  }
}
