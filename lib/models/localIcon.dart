class LocalIcon {
  final String? iconCode;
  final int? iconNo;
  final bool? isCheck;
  final bool? isFound;
  final String? color;
  LocalIcon({
    required this.iconCode,
    required this.iconNo,
    this.color,
    this.isCheck,
    this.isFound,
  });

  Map<String, dynamic> toMap(String id) => {
        id: {
          'iconCode': iconCode,
          'iconNo': iconNo,
          'isCheck': isCheck,
          'isFound': isFound
        }
      };

  factory LocalIcon.fromMap(Map fromSnapshot) {
    final map = Map<String, dynamic>.from(fromSnapshot);
    return LocalIcon(
      iconCode: map['iconCode'],
      iconNo: map['iconNo'],
      isCheck: map['isCheck'] ?? false,
      isFound: map['isFound'] ?? false,
      color: map['color'] ?? null,
    );
  }

  @override
  String toString() {
    return 'LocalIcon(iconCode: $iconCode, iconNo: $iconNo, isCheck: $isCheck, isFound: $isFound)';
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

  @override
  int get hashCode {
    return iconCode.hashCode ^
        iconNo.hashCode ^
        isCheck.hashCode ^
        isFound.hashCode;
  }
}

class IconInfo {
  final String? icon;
  final String? iconCode;

  IconInfo(this.icon, this.iconCode);
}
