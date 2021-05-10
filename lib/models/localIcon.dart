import 'dart:convert';

import 'package:meta/meta.dart';

class LocalIcon {
  final int iconCode;
  final int iconNo;
  final bool isCheck;
  final bool isFound;
  LocalIcon({
    @required this.iconCode,
    @required this.iconNo,
    this.isCheck,
    this.isFound,
  });

  LocalIcon copyWith({
    int iconCode,
    int iconNo,
    bool isCheck,
    bool isFound,
  }) {
    return LocalIcon(
      iconCode: iconCode ?? this.iconCode,
      iconNo: iconNo ?? this.iconNo,
      isCheck: isCheck ?? this.isCheck,
      isFound: isFound ?? this.isFound,
    );
  }

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
    );
  }

  //String toJson() => json.encode(toMap());

  factory LocalIcon.fromJson(String source) =>
      LocalIcon.fromMap(json.decode(source));

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
  final String icon;
  final int iconCode;

  IconInfo(this.icon, this.iconCode);
}
