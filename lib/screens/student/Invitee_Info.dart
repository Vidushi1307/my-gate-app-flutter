import 'package:my_gate_app/database/database_interface.dart';
import 'package:my_gate_app/database/database_objects.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_gate_app/get_email.dart';
import 'package:qr_flutter/qr_flutter.dart';
// import 'package:my_gate_app/screens/guard/utils/UI_statics.dart'; // Import necessary dependencies
import 'package:share_plus/share_plus.dart' as myshare;
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';
import 'dart:io';
import 'dart:ui';
import 'dart:convert';
import 'package:flutter/services.dart';

class InviteeInfoPage extends StatefulWidget {
  const InviteeInfoPage({super.key});

  @override
  _InviteeInfoPageState createState() => _InviteeInfoPageState();
}

class _InviteeInfoPageState extends State<InviteeInfoPage>
    with SingleTickerProviderStateMixin {
  late TabController controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 8,
            title: Text(
              'Invitee Info',
              style: GoogleFonts.mPlusRounded1c(
                  color: Colors.black, fontWeight: FontWeight.w900),
            ),
            iconTheme: const IconThemeData(color: Colors.black),
            centerTitle: true,
            bottom: TabBar(
              controller: controller,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(
                  width: 4,
                  color: Colors.black,
                ),
              ),
              labelStyle: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w800),
              unselectedLabelStyle: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w800),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.account_circle),
                      const SizedBox(width: 10),
                      Text(
                        'Form',
                        style: GoogleFonts.mPlusRounded1c(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.history),
                      const SizedBox(width: 10),
                      Text(
                        'Status',
                        style: GoogleFonts.mPlusRounded1c(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: Container(
            color: Colors.black,
            child: TabBarView(
              controller: controller,
              children: const [
                InviteeForm(),
                InviteeStatus(),
              ],
            ),
          ),
        ),
      );
}

class InviteeForm extends StatefulWidget {
  const InviteeForm({super.key});

  @override
  _InviteeFormState createState() => _InviteeFormState();
}

class _InviteeFormState extends State<InviteeForm> {
  final _formKey = GlobalKey<FormState>(); // Key for the form

  String _name = '';
  String _relationship = '';
  String _contact = '';
  String _purpose = '';
  late DateTime _selectedDate = DateTime.now(); // Initialize with current date
  String _durations = ''; // Initialize with current date

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white
      // appBar: AppBar(
      //   title: Text('Invitee Form', style: GoogleFonts.mPlusRounded1c(color: Colors.black)), // Set app bar title color to black
      //   backgroundColor: Colors.white, // Set app bar background color to white
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: GoogleFonts.mPlusRounded1c(
                        color: Colors
                            .black), // Set label text color to black using Google Fonts
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                          color:
                              Colors.black), // Set bottom border color to black
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors
                              .black), // Set bottom border color to black when focused
                    ),
                  ),
                  style: GoogleFonts.mPlusRounded1c(
                      color: Colors.black,
                      fontWeight: FontWeight
                          .bold), // Set input text color to black using Google Fonts
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _name = value!;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Relationship',
                    labelStyle: GoogleFonts.mPlusRounded1c(
                        color: Colors
                            .black), // Set label text color to black using Google Fonts
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                          color:
                              Colors.black), // Set bottom border color to black
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors
                              .black), // Set bottom border color to black when focused
                    ),
                  ),
                  style: GoogleFonts.mPlusRounded1c(
                      color: Colors.black,
                      fontWeight: FontWeight
                          .bold), // Set input text color to black using Google Fonts
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the relationship';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _relationship = value!;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Contact',
                    labelStyle: GoogleFonts.mPlusRounded1c(
                        color: Colors
                            .black), // Set label text color to black using Google Fonts
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                          color:
                              Colors.black), // Set bottom border color to black
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors
                              .black), // Set bottom border color to black when focused
                    ),
                  ),
                  style: GoogleFonts.mPlusRounded1c(
                      color: Colors.black,
                      fontWeight: FontWeight
                          .bold), // Set input text color to black using Google Fonts
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the contact';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _contact = value!;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Purpose to Invite',
                    labelStyle: GoogleFonts.mPlusRounded1c(
                        color: Colors
                            .black), // Set label text color to black using Google Fonts
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                          color:
                              Colors.black), // Set bottom border color to black
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors
                              .black), // Set bottom border color to black when focused
                    ),
                  ),
                  style: GoogleFonts.mPlusRounded1c(
                      color: Colors.black,
                      fontWeight: FontWeight
                          .bold), // Set input text color to black using Google Fonts
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the purpose to invite';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _purpose = value!;
                  },
                ),
                const SizedBox(height: 30),
                TextFormField(
                  readOnly: true, // Make the field read-only
                  controller: TextEditingController(
                      text:
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                  decoration: InputDecoration(
                    labelText: 'Visit Date',
                    labelStyle: GoogleFonts.mPlusRounded1c(color: Colors.black),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2022),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null && pickedDate != _selectedDate) {
                      setState(() {
                        _selectedDate = pickedDate;
                      });
                    }
                  },
                  style: const TextStyle(color: Colors.black),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Duration of Visit (in days)',
                    hintText: 'Enter duration of visit in days',
                    labelStyle: GoogleFonts.mPlusRounded1c(color: Colors.black),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  style: const TextStyle(color: Colors.black),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the duration of visit';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid integer';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _durations = value!;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      // Submit your form data here
                      print(
                          'Name: $_name, Relationship: $_relationship, Contact: $_contact, Purpose: $_purpose');
                      databaseInterface db = databaseInterface();
                      String email = LoggedInDetails.getEmail();
                      // Find the index of the "@" symbol
                      int atIndex = email.indexOf('@');

                      // Extract the substring before the "@" symbol
                      String extracted = email.substring(0, atIndex);

                      String extractedStudent = extracted.toUpperCase();
                      print(extractedStudent);
                      int statusCode;
                      String formattedDate =
                          '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}';
                      print('edgjkweq$formattedDate');
                      print('edgjkweq$_durations');
                      statusCode = await db.GenerateRelativesTicket(
                        extractedStudent,
                        _name,
                        _relationship,
                        _contact,
                        _purpose,
                        formattedDate,
                        _durations,
                      );
                      if (statusCode == 200) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Request Raised Sucessfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        _formKey.currentState!.reset();
                      } else if (statusCode == 500) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Request hasn\'t been submitted.\nError In Backend'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(
                        Colors.black), // Set button background color to black
                  ),
                  child: Center(
                    child: Text(
                      'Submit',
                      style: GoogleFonts.mPlusRounded1c(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class InviteeStatus extends StatefulWidget {
  const InviteeStatus({super.key});

  @override
  _InviteeStatusState createState() => _InviteeStatusState();
}

class _InviteeStatusState extends State<InviteeStatus> {
  String searchQuery = '';
  List<StuRelTicket> tickets = []; // Define necessary variables
  List<StuRelTicket> ticketsFiltered = [];
  int selectedIndex = -1; // Define selectedIndex variable

  @override
  void initState() {
    super.initState();
    // tickets = _generateDummyData(); // Initialize tickets with dummy data
    // ticketsFiltered = List.from(tickets);
    // print("hhhhelllo");
    _fetchTickets();
  }

  Future<void> _fetchTickets() async {
    try {
      String email = LoggedInDetails.getEmail();
      // Find the index of the "@" symbol
      int atIndex = email.indexOf('@');

      // Extract the substring before the "@" symbol
      String extracted = email.substring(0, atIndex);

      String extractedStudent = extracted.toUpperCase();

      List<StuRelTicket> fetchedTickets =
          await databaseInterface.GetStudentRelativeTickets(extractedStudent);

      setState(() {
        tickets = fetchedTickets;
        ticketsFiltered = List.from(tickets);
      });
    } catch (e) {
      print("Error fetching tickets: $e");
      // Handle error accordingly
    }
  }

  void toggleExpansion(int index) {
    setState(() {
      if (selectedIndex == index) {
        selectedIndex = -1; // Collapse if already expanded
      } else {
        selectedIndex = index; // Expand if not expanded
      }
    });
  }

  Future<File?> generateQrCode(String dataToGenerate) async {
    final qrValidationResult = QrValidator.validate(
      data: dataToGenerate,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.L,
    );

    if (qrValidationResult.isValid) {
      final QrCode? qrCode = qrValidationResult.qrCode;
      final QrPainter qrPainter = QrPainter.withQr(
        qr: qrCode!,
        color: Colors.blue,
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
        ),
      );
      final ByteData? bytes = await qrPainter.toImageData(
        200,
        format: ImageByteFormat.png,
      );

      if (bytes == null) {
        // Handle this block the way you want
        return null;
      }

      final Directory tempDir = await getTemporaryDirectory();
      final File tempQrFile = await File('${tempDir.path}/qr.jpg').create();
      final Uint8List list = bytes.buffer.asUint8List();

      await tempQrFile.writeAsBytes(list);
      return tempQrFile;
    }
    return null;
  }

  Future<void> shareQrCode(String url) async {
    final file = await generateQrCode(url);

    if (file != null) {
      print("sharing QR");
      print(file.path);

      await myshare.Share.shareXFiles(
          [myshare.XFile(file.path, mimeType: "image/jpg")]);
    }
  }

  String getQrData(StuRelTicket ticket) {
    String data = "";
    Map<String, String> obj = {
      "type": "invited_visitor",
      "ticket_id": ticket.ticketId,
    };
    data = jsonEncode(obj);
    return data;
  }

  Color getColorForStatus(String status) {
    switch (status) {
      case "Pending":
        return const Color(0xff3E3E3E); // Change to your desired color
      case "Accepted":
        return const Color(0xff3E5D5D); // Change to your desired color
      case "Rejected":
        return const Color(0xff3E1313); // Change to your desired color
      default:
        return Colors.grey; // Default color
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          Expanded(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.95,
              child: ListView.builder(
                itemCount: ticketsFiltered.length,
                itemBuilder: (BuildContext context, int index) {
                  final bool isExpanded = index == selectedIndex;
                  return Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: getColorForStatus(
                                ticketsFiltered[index].status),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            title: Row(
                              children: [
                                Text(
                                  ticketsFiltered[index].inviteeName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                if (ticketsFiltered[index].status == "Accepted")
                                  IconButton(
                                    icon: const Icon(Icons.qr_code),
                                    onPressed: () {
                                      // Show modal bottom sheet with QR code
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Container(
                                            color: Colors.transparent,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(10),
                                                  topRight: Radius.circular(10),
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  QrImageView(
                                                    data: getQrData(
                                                        ticketsFiltered[index]),
                                                    backgroundColor:
                                                        Colors.white,
                                                    size: 200,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  const Text(
                                                    'Share this QR code with your guest.',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                  const SizedBox(
                                                      height:
                                                          16), // Added some space
                                                  ElevatedButton.icon(
                                                    onPressed: () {
                                                      // Implement sharing functionality
                                                      shareQrCode(getQrData(
                                                          ticketsFiltered[
                                                              index])); // Replace with actual invitee details
                                                    },
                                                    icon: const Icon(
                                                        Icons.share,
                                                        color: Colors.white),
                                                    label: const Text(
                                                      'Share',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                              ],
                            ),
                            subtitle: isExpanded
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 8),
                                      Text(
                                        'Status: ${ticketsFiltered[index].status}',
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Invitee_Relationship: ${ticketsFiltered[index].inviteeRelationship}',
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Mobile Number: ${ticketsFiltered[index].inviteeContact}',
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Purpose: ${ticketsFiltered[index].purpose}',
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Visit_date: ${ticketsFiltered[index].visit_date}',
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Durations: ${ticketsFiltered[index].duration}',
                                      ),
                                      // Add more details here as needed
                                    ],
                                  )
                                : null,
                            onTap: () => toggleExpansion(index),
                            trailing: Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
