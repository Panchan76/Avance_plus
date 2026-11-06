import 'package:flutter/material.dart';

class UserProfileScope extends InheritedWidget {
  const UserProfileScope({super.key, required this.data, required super.child});
  final Map<String, dynamic> data;
  static Map<String, dynamic> of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<UserProfileScope>()!.data;
  @override
  bool updateShouldNotify(UserProfileScope oldWidget) => data != oldWidget.data;
}
