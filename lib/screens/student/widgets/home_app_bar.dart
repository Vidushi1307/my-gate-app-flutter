import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_gate_app/screens/profile2/model/menu_item.dart';
import 'package:my_gate_app/screens/profile2/utils/menu_items.dart';
import 'package:my_gate_app/screens/profile2/model/user.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String welcomeMessage;
  final ImageProvider? profileImage;
  final ValueNotifier<bool> updateNotifier;
  final int notificationCount;
  final Stream<int>? notificationStream;
  final VoidCallback onProfilePressed;
  final VoidCallback onNotificationsPressed;

  const HomeAppBar({
    required this.welcomeMessage,
    required this.profileImage,
    required this.updateNotifier,
    required this.notificationCount,
    required this.notificationStream,
    required this.onProfilePressed,
    required this.onNotificationsPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: _buildTitleRow(context),
      actions: [
        _buildNotificationButton(),
        _buildMenuButton(),
      ],
    );
  }

  Widget _buildTitleRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 35.0, bottom: 35.0),
      child: Row(
        children: [
          _buildProfileImage(),
          const SizedBox(width: 12),
          _buildWelcomeText(context),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return ValueListenableBuilder<bool>(
      valueListenable: updateNotifier,
      builder: (_, __, ___) {
        return CircleAvatar(
          radius: 20,
          backgroundImage: profileImage,
        );
      },
    );
  }

  Widget _buildWelcomeText(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Hi,',
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          Text(
            welcomeMessage,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationButton() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications, color: Colors.black),
          onPressed: onNotificationsPressed,
        ),
        Positioned(
          right: 8,
          top: 8,
          child: StreamBuilder<int>(
            stream: notificationStream,
            builder: (context, snapshot) {
              final count = snapshot.data ?? notificationCount;
              return count > 0 
                  ? _buildNotificationBadge(count)
                  : const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationBadge(int count) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      constraints: const BoxConstraints(
        minWidth: 16,
        minHeight: 16,
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildMenuButton() {
    return PopupMenuButton<MenuItem>(
      onSelected: (item) => onProfilePressed(),
      icon: const Icon(Icons.more_vert, color: Colors.black),
      itemBuilder: (context) => [
        ...MenuItems.itemsFirst.map(_buildMenuItem),
        const PopupMenuDivider(),
        ...MenuItems.itemsThird.map(_buildMenuItem),
      ],
    );
  }

  PopupMenuItem<MenuItem> _buildMenuItem(MenuItem item) {
    return PopupMenuItem<MenuItem>(
      value: item,
      child: Row(
        children: [
          Icon(item.icon, size: 20),
          const SizedBox(width: 12),
          Text(item.text),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
