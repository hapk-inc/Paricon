class LocalIcon {
  final String iconCode;
  final int? iconNo;
  final bool isCheck;
  final bool isFound;
  final String color;

  LocalIcon({
    required this.iconCode,
    required this.iconNo,
    this.color = "",
    this.isCheck = false,
    this.isFound = false,
  });

  LocalIcon copyWith({
    String? iconCode,
    int? iconNo,
    bool? isCheck,
    bool? isFound,
    String? color,
  }) =>
      LocalIcon(
          iconCode: iconCode ?? this.iconCode,
          iconNo: iconNo ?? this.iconNo,
          isCheck: isCheck ?? this.isCheck,
          isFound: isFound ?? this.isFound,
          color: color ?? "");

  Map<String, dynamic> toMap(String id) => {
        id: {
          'iconCode': iconCode,
          'iconNo': iconNo,
          'isCheck': isCheck,
          'isFound': isFound
        }
      };

  Map<String, dynamic> get updateIcon => <String, dynamic>{
        'iconCode': iconCode,
        'iconNo': iconNo,
        'isCheck': isCheck,
        'isFound': isFound,
        'color': color,
      };

  factory LocalIcon.fromMap(Map fromSnapshot) {
    final map = Map<String, dynamic>.from(fromSnapshot);
    return LocalIcon(
      iconCode: map['iconCode'],
      iconNo: map['iconNo'],
      isCheck: map['isCheck'] ?? false,
      isFound: map['isFound'] ?? false,
      color: map['color'] ?? "",
    );
  }

  @override
  String toString() {
    return 'LocalIcon(iconCode: $iconCode, iconNo: $iconNo, isCheck: $isCheck, isFound: $isFound , color: $color)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LocalIcon &&
        other.iconCode == iconCode &&
        other.iconNo == iconNo &&
        other.isCheck == isCheck &&
        other.isFound == isFound;
  }

  bool checkIconCode(Object other) {
    if (identical(this, other)) return true;

    return other is LocalIcon && other.iconCode == iconCode;
  }

  @override
  int get hashCode {
    return iconCode.hashCode ^
        iconNo.hashCode ^
        isCheck.hashCode ^
        isFound.hashCode;
  }

  bool checkFound() => this.isCheck || this.isFound;

  LocalIcon setCheck(bool value) =>
      LocalIcon(iconCode: this.iconCode, iconNo: this.iconNo, isCheck: value);

  LocalIcon setFoundTrue(String color) => LocalIcon(
      iconCode: this.iconCode,
      color: color,
      iconNo: this.iconNo,
      isFound: true,
      isCheck: false);
}

class IconInfo {
  final String? icon;
  final String? iconCode;

  IconInfo(this.icon, this.iconCode);
}
