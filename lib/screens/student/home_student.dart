// ignore_for_file: prefer_const_constructors, unnecessary_brace_in_string_interps, unnecessary_string_interpolations, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:my_gate_app/screens/student/managers/location_data_manager.dart';
import 'package:my_gate_app/screens/student/managers/notification_manager.dart';
import 'package:my_gate_app/screens/student/managers/user_profile_manager.dart';
import 'package:my_gate_app/screens/student/widgets/home_app_bar.dart';
import 'package:my_gate_app/screens/student/widgets/location_card.dart';
import 'package:my_gate_app/screens/student/change_location.dart';
import 'package:my_gate_app/screens/student/raise_ticket_for_guard_or_authorities.dart';
import 'package:my_gate_app/screens/student/student_guard_side/student_tabs.dart';
import 'package:my_gate_app/screens/notificationPage/notification.dart';
import 'package:my_gate_app/screens/profile2/profile_page.dart';
import 'package:my_gate_app/auth/authscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:my_gate_app/get_email.dart';
import 'package:my_gate_app/screens/profile2/utils/user_preferences.dart';
import 'package:my_gate_app/database/database_interface.dart';
import 'package:my_gate_app/image_paths.dart' as image_paths;
import 'package:my_gate_app/screens/student/widgets/loading_screen.dart';

// This file calls StudentTicketTable

class HomeStudent extends StatefulWidget {
  final String? email;
  const HomeStudent({super.key, required this.email});

  @override
  _HomeStudentState createState() => _HomeStudentState();
}

Color getColorFromHex(String hexColor) {
  hexColor = hexColor.replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF$hexColor";
  }
  if (hexColor.length == 8) {
    return Color(int.parse("0x$hexColor"));
  }
  return Colors.cyanAccent[100] as Color;
}

class _HomeStudentState extends State<HomeStudent> {
  late final UserProfileManager _profileManager;
  late final LocationDataManager _locationManager;
  late final NotificationManager _notificationManager;

  String welcomeMessage = "Welcome"; // Welcome message text
  bool isLoading = false; // Loading state flag

  @override
  void initState() {
    super.initState();
    _profileManager = UserProfileManager(
      email: widget.email ?? '',
      user: UserPreferences.myUser,
    );

    _locationManager = LocationDataManager();
    _notificationManager = NotificationManager();

    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() => isLoading = true);

    await Future.wait([
      _profileManager.loadProfile(),
      _loadWelcomeMessage(),
      _locationManager.loadData(LoggedInDetails.getEmail()),
      _notificationManager.refreshCount(LoggedInDetails.getEmail()),
    ]);

    _notificationManager.initialize(LoggedInDetails.getEmail());

    setState(() => isLoading = false);
  }

  Future<void> _loadWelcomeMessage() async {
    welcomeMessage =
        await databaseInterface.get_welcome_message(LoggedInDetails.getEmail());
  }

  Future<void> _refreshData() async {
    await _initializeData();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return LoadingScreen();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return HomeAppBar(
      welcomeMessage: welcomeMessage,
      profileImage: _profileManager.profileImage,
      updateNotifier: _profileManager.updateNotifier,
      notificationCount: _notificationManager.count,
      notificationStream: _notificationManager.countStream,
      onProfilePressed: _navigateToProfile,
      onNotificationsPressed: _navigateToNotifications,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your key to convenience,',
            style: GoogleFonts.kodchasan(
              fontSize: 20,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Encoded in a scan!!',
            style: GoogleFonts.kodchasan(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(),
          _buildMainLocationCard(),
          _buildLocationGrid(),
          _buildChangeLocationButton(),
        ],
      ),
    );
  }

  Widget _buildMainLocationCard() {
    return GestureDetector(
      onTap: () => _navigateToLocation(0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 0.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xff3E3E3E),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "CS Block",
                  style: GoogleFonts.mPlusRounded1c(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Status: ${_locationManager.statuses[0].toUpperCase()}",
                  style: GoogleFonts.mPlusRounded1c(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            _buildLocationImage(image_paths.cs_block),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationGrid() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          _locationManager.locations.length -
              1, // Skip CS Block (already shown)
          (index) => Padding(
            padding: const EdgeInsets.all(5.0),
            child: LocationCard(
              location: _locationManager.locations[index + 1],
              status: _locationManager.statuses[index + 1],
              imagePath: _locationManager.getImagePath(index + 1),
              preApprovalRequired: _locationManager.preApprovals[index + 1],
              onTap: () => _navigateToLocation(index + 1),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChangeLocationButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      child: ElevatedButton(
        onPressed: _navigateToChangeLocation,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: Text(
          'Change location',
          style: GoogleFonts.mPlusRounded1c(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _navigateToLocation(int index) {
    final route = _locationManager.preApprovals[index]
        ? MaterialPageRoute(
            builder: (_) => RaiseTicketForGuardOrAuthorities(
              location: _locationManager.locations[index],
              pre_approval_required: _locationManager.preApprovals[index],
            ),
          )
        : MaterialPageRoute(
            builder: (_) => StudentTabs(
              location: _locationManager.locations[index],
              pre_approval_required: _locationManager.preApprovals[index],
            ),
          );

    Navigator.push(context, route).then((_) => _refreshData());
  }

  void _navigateToChangeLocation() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChangeLocationPage(),
        ));
  }

  void _navigateToProfile() {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => ProfilePage(
          email: LoggedInDetails.getEmail(),
          isEditable: false,
        ),
      ),
    )
        .then((_) async {
      final result =
          await databaseInterface.get_student_by_email(widget.email ?? '');
      setState(() {
        _profileManager.profileImage = NetworkImage(result.imagePath);
        _profileManager.updateNotifier.value =
            !_profileManager.updateNotifier.value;
      });
    });
  }

  void _navigateToNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationsPage(
          notificationCount: _notificationManager.count,
        ),
      ),
    );
  }

  Widget _buildLocationImage(String path) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      width: 90,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white),
        color: Colors.white,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          path,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
