import 'package:flutter/material.dart' as yo;
import 'package:my_gate_app/screens/profile2/model/menu_item.dart';

class MenuItems{

  static const List<MenuItem> itemsFirst = [
    itemProfile,
  ];
  
  static const List<MenuItem> itemsSecond = [
    itemLogOut,
  ];
  static const List<MenuItem> itemsThird = [
    itemAboutUs,
  ];
  static const List<MenuItem> itemsFourth = [
    itemViewStats,
  ];
  static const List<MenuItem> itemsFifth = [
    itemDeleteAccount,
  ];

  static const itemProfile = MenuItem(
    text: 'Profile',
    icon: yo.Icons.account_circle,
  );
  static const itemLogOut = MenuItem(
    text: 'Log Out',
    icon: yo.Icons.logout,
  );
  static const itemAboutUs = MenuItem(
    text: 'About Us',
    icon: yo.Icons.info_outline,
  );
  static const itemViewStats = MenuItem(
    text: 'View Stats',
    icon: yo.Icons.query_stats_outlined,
  );
  static const itemDeleteAccount = MenuItem(
    text: 'Delete Account',
    icon: yo.Icons.delete,
    color: yo.Colors.red,
  );
  
}
