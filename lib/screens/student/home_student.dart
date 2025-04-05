// ignore_for_file: prefer_const_constructors, unnecessary_brace_in_string_interps, unnecessary_string_interpolations, non_constant_identifier_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
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
  final db = databaseInterface();

  String welcomeMessage = "Welcome"; // Welcome message text
  bool isLoading = false; // Loading state flag
  String? currentLocation; // Tracks where student is currently checked in
  String currentStatus = "Not checked in"; // Default status
  Color statusColor = Colors.grey; // Default color

  @override
  void initState() {
    super.initState();
    _profileManager = UserProfileManager(
      email: widget.email ?? UserPreferences.myUser.imagePath,
      user: UserPreferences.myUser,
    );
    _locationManager = LocationDataManager();
    _notificationManager = NotificationManager(LoggedInDetails.getEmail());
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() => isLoading = true);
    
    // First load the user data since other managers might depend on it
    final user = await db.get_student_by_email(widget.email ?? UserPreferences.myUser.email);
    
    setState(() {
      _profileManager.user = user;
    });

    // Run all independent initialization tasks in parallel
    await Future.wait([
      _loadWelcomeMessage(),
      _locationManager.loadData(LoggedInDetails.getEmail()),
      _notificationManager.refreshCount(),
      _profileManager.loadProfile(LoggedInDetails.getEmail()),
    ]);

    // This depends on location data being loaded first
    await _locationManager.updateCurrentStatus(LoggedInDetails.getEmail());
    
    if (!mounted) return;
    setState(() => isLoading = false);
  }

  Future<void> _loadWelcomeMessage() async {
    welcomeMessage =
        await databaseInterface.get_welcome_message(LoggedInDetails.getEmail());
        print("Loading welcome message done");
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
      notificationStream: _notificationManager.notificationStream,
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
          _buildExitButton(),
          _buildCurrentStatusCard(),
//          _buildLocationGrid(),
          _buildChangeLocationButton(),
          
        ],
      ),
    );
  }

  Widget _buildMainLocationCard() {
    return GestureDetector(
 //     onTap: () => _navigateToLocation(0),
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

  Widget _buildExitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: ElevatedButton.icon(
          icon: const Icon(
          Icons.qr_code_scanner, 
          color: Colors.white,
          size: 28, // Increased icon size (default is 24)
        ),
        label: const Text(
          'SCAN GUARD\'S QR TO EXIT',
          style: TextStyle(
            fontSize: 18, // Increased font size (default is typically 14)
            fontWeight: FontWeight.bold, // Optional: makes text bolder
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () => _openQRScanner(context),
      ),
    );
  }

  Widget _buildCurrentStatusCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title Section
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Text(
                'You are currently in:',
                style: GoogleFonts.mPlusRounded1c(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
            ),
            
            // Location Name
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                _locationManager.currentLocation ?? 'No active location',
                textAlign: TextAlign.center,
                style: GoogleFonts.mPlusRounded1c(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _locationManager.statusColor,
                ),
              ),
            ),
            
            // Refresh current location:
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: IconButton(
                icon: Icon(Icons.refresh, color: _locationManager.statusColor),
                onPressed: () async {
                  setState(() => isLoading = true);
                  await _locationManager.updateCurrentStatus(LoggedInDetails.getEmail());
                  setState(() => isLoading = false);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Location refreshed'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                tooltip: 'Refresh location status',
                splashRadius: 20, // Smaller splash effect
              ),
            ),
            
            // Location Image
            if (_locationManager.currentLocation != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 150), // Adjust as needed
                    child: Image.asset(
                      _getLocationImage(_locationManager.currentLocation!),
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Helper function to get image path
  String _getLocationImage(String locationName) {
    // Map your locations to image paths
    switch (locationName) {
      case 'CS Block':
        return image_paths.cs_block;
      case 'Lab 101':
        return image_paths.cs_lab;
      case 'Lab 102':
        return image_paths.research_lab;
      case 'Lab 202':
        return image_paths.lecture_room;
      case 'Lab 203':
        return image_paths.conference_room;
      default:
        return image_paths.spiral;
    }
  }

  Future<void> _handleCheckOut() async {
    if (_locationManager.currentLocation == null) return;

    setState(() => isLoading = true);
    
    final success = await databaseInterface.checkOutLocation(
      LoggedInDetails.getEmail(),
    );

    if (success && mounted) {
      await _locationManager.updateCurrentStatus(LoggedInDetails.getEmail());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Checked out successfully')),
      );
    }
    
    setState(() => isLoading = false);
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
      final result = await db.get_student_by_email(widget.email ?? '');
      setState(() {
        _profileManager.updateProfileImage(); // Then update the image provider
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

  void _openQRScanner(BuildContext context) {
    final MobileScannerController controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Scan QR Code'),
            backgroundColor: Colors.black,
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          body: Stack(
            children: [
              MobileScanner(
                controller: controller,
                onDetect: (capture) async {
                  final List<Barcode> barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    if (barcode.rawValue != null) {
                      await controller.stop(); // Stop camera first
                      if (mounted) {
                        Navigator.pop(context); // Then close scanner
                        _processQRCode(barcode.rawValue!);
                      }
                      return;
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    ).then((_) {
      controller.dispose(); // Ensure controller is disposed
    });
  }

  void _processQRCode(String qrData) {
    try {
      // Try to decode the JSON
      final decoded = jsonDecode(qrData) as Map<String, dynamic>;
      
      // Check if it has the required structure
      if (decoded.containsKey('tic_ty') && decoded['tic_ty'] == 'exit') {
        // Valid QR code - proceed with exit logic
        print('Valid exit QR code scanned');
        _handleCheckOut(); // Your method to handle successful validation
      } else {
        // Invalid QR code format
        print('Invalid QR code format');
        _showErrorDialog('The QR code is either invalid or expired');
      }
    } catch (e) {
      // Handle JSON parsing errors or invalid format
      print('Error processing QR code: $e');
      _showErrorDialog('Invalid QR code format. Please scan a valid exit QR code.');
    }
  }

  void _showErrorDialog(String message) {
    // You'll need BuildContext here - you might want to pass it from the scanner
    // or use a global key/navigator if you're using one
    showDialog(
      context: context, // You'll need to make context available here
      builder: (context) => AlertDialog(
        title: const Text('Invalid QR Code'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
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
