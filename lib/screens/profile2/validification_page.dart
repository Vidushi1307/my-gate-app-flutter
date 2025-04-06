import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_gate_app/database/database_interface.dart';
import 'package:my_gate_app/screens/profile2/model/user.dart';
import 'package:my_gate_app/screens/profile2/utils/user_preferences.dart';
import 'package:my_gate_app/screens/utils/custom_snack_bar.dart';

// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unnecessary_new, deprecated_member_use, non_constant_identifier_names
import 'package:google_fonts/google_fonts.dart';
import 'package:my_gate_app/database/database_objects.dart';
import 'package:intl/intl.dart';
import 'package:my_gate_app/image_paths.dart' as image_paths;

class StudentTicketTable extends StatefulWidget {
  StudentTicketTable({
    super.key,
    required this.tickets,
  });
  List<ResultObj> tickets;

  @override
  _StudentTicketTableState createState() => _StudentTicketTableState();
}

class _StudentTicketTableState extends State<StudentTicketTable> {
  // List<TicketResultObj> tickets = [];

  @override
  void initState() {
    super.initState();
    // init();
  }

  Color getColorForType(String status) {
    switch (status) {
      // case "enter":
      //   return Color(0xff3E3E3E); // Change to your desired color
      case "enter":
        return Color(0xff3E5D5D); // Change to your desired color
      case "exit":
        return Color(0xff3E1313); // Change to your desired color
      default:
        return Colors.grey; // Default color
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        // backgroundColor: Colors.white, // added now

        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 232, 232, 234),
                Color.fromARGB(255, 255, 255, 255)
              ],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.95,
                    child: ListView.builder(
                      itemCount: widget.tickets.length,
                      itemBuilder: (BuildContext context, int index) {
                        // final bool isExpanded = index == selectedIndex;
                        return Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  decoration: BoxDecoration(
                                    color: getColorForType(
                                        widget.tickets[index].ticket_type),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: ExpansionTile(
                                    // tilePadding: EdgeInsets.zero, // Remove padding
                                    // backgroundColor: Colors.transparent, // Optional: Set background color to transparent if needed
                                    // collapsedBackgroundColor: Colors.transparent,
                                    title: Row(
                                      children: [
                                        Text(
                                          (widget.tickets[index].ticket_type ==
                                                  'enter')
                                              ? "Enter"
                                              : (widget.tickets[index]
                                                          .ticket_type ==
                                                      'exit')
                                                  ? 'Exit'
                                                  : widget.tickets[index]
                                                      .ticket_type,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        // Text(DateFormat('hh:mm a - MMM dd, yyyy')
                                        //     .format(DateTime.parse(
                                        //     widget.tickets[index].date_time).toLocal())),
                                        Text(
                                          DateFormat('hh:mm a - MMM dd, yyyy')
                                              .format(
                                            DateTime.parse(widget
                                                    .tickets[index].date_time)
                                                .toLocal(),
                                          ),
                                        )
                                      ],
                                    ),
                                    children: <Widget>[
                                      Details(widget.tickets[index]),
                                    ],
                                  )),
                              SizedBox(height: 8),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget Details(ResultObj ticket) {
    // Parse the time string to DateTime object
    DateTime time = DateTime.parse(ticket.date_time).toLocal();
    print(ticket.date_time);
    print("datetime: $time");
    // Format the date and time
    String formattedTime = DateFormat('MMM dd, yyyy - hh:mm a').format(time);
    return Container(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("Destination :${ticket.destination_address}",
            style: GoogleFonts.lato(
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontSize: 15,
            )),
        Text("Vehicle Number :${ticket.vehicle_number}",
            style: GoogleFonts.lato(
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontSize: 15,
            )),
        Text("IsApproved :${ticket.is_approved}",
            style: GoogleFonts.lato(
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontSize: 15,
            )),
        SizedBox(
          height: 10,
        )
      ]),
    );
  }
}

class Validification_page extends StatefulWidget {
  final String email;
  final bool isEditable;
  final String guard_location;
  final String vehicle_reg;
  final String ticket_type;
  final String destination_addr;
  final String guard_email;
  final String student_location;

  const Validification_page({
    super.key,
    required this.email,
    required this.guard_location,
    required this.isEditable,
    required this.ticket_type,
    required this.destination_addr,
    required this.vehicle_reg,
    required this.guard_email,
    required this.student_location,
  });
  @override
  _Validification_pageState createState() => _Validification_pageState();
}

class _Validification_pageState extends State<Validification_page> {
  bool editAccess = true;
  var user = UserPreferences.myUser;

  late String imagePath;

  late final TextEditingController controller_phone;
  late final TextEditingController controller_department;
  late final TextEditingController controller_year_of_entry;
  late final TextEditingController controller_degree;
  late final TextEditingController controller_gender;
  late final TextEditingController controller_destination_address;
  late final TextEditingController controller_vehicle_reg_num;
  late final TextEditingController controller_location_of_guard;
  late final TextEditingController controller_ticket_type;
  List<ResultObj> dummyList = [
    ResultObj.constructor1(
        "Location 1",
        "2024-05-09 10:00:00",
        "Approved",
        "Type 1",
        "email1@example.com",
        "Student 1",
        "Authority Status 1",
        "Address 1",
        "Vehicle 1"),
    ResultObj.constructor1(
        "Location 2",
        "2024-05-10 11:00:00",
        "Pending",
        "Type 2",
        "email2@example.com",
        "Student 2",
        "Authority Status 2",
        "Address 2",
        "Vehicle 2"),
    ResultObj.constructor1(
        "Location 3",
        "2024-05-11 12:00:00",
        "Approved",
        "Type 1",
        "email3@example.com",
        "Student 3",
        "Authority Status 1",
        "Address 3",
        "Vehicle 3"),
    ResultObj.constructor1(
        "Location 4",
        "2024-05-12 13:00:00",
        "Pending",
        "Type 2",
        "email4@example.com",
        "Student 4",
        "Authority Status 2",
        "Address 4",
        "Vehicle 4"),
    ResultObj.constructor1(
        "Location 5",
        "2024-05-13 14:00:00",
        "Approved",
        "Type 1",
        "email5@example.com",
        "Student 5",
        "Authority Status 1",
        "Address 5",
        "Vehicle 5"),
  ];

  var imagePicker;
  var pic;

  Future<void> init() async {
    String? currEmail = widget.email;

    print("Current Email in validification page: $currEmail");
    databaseInterface db = databaseInterface();
    User result = await databaseInterface.get_student_by_email(currEmail);
    // print("result obj image path" + result.imagePath);
    print("result in validification page=${result.name}");
    setState(() {
      user = result;
      controller_phone.text = result.phone;
      controller_department.text = result.department;
      controller_year_of_entry.text = result.year_of_entry;
      controller_degree.text = result.degree;
      controller_gender.text = result.gender;
      controller_destination_address.text = widget.destination_addr;
      controller_vehicle_reg_num.text = widget.vehicle_reg;
      controller_location_of_guard.text = widget.guard_location;
      controller_ticket_type.text = widget.ticket_type;
      /* controller_gender.text=result. */
      print("Gender in yo:${result.gender}");
      // imagePath = result.imagePath;
      print("image path inside setstate: $imagePath");
    });

    setState(() {
      pic = result.profileImage;
    });
    /* print("Gender in yo:"+controller_gender.text); */
  }

  @override
  void initState() {
    super.initState();
    controller_phone = TextEditingController();
    controller_department = TextEditingController();
    controller_year_of_entry = TextEditingController();
    controller_degree = TextEditingController();
    controller_gender = TextEditingController();
    controller_destination_address = TextEditingController();
    controller_vehicle_reg_num = TextEditingController();
    controller_location_of_guard = TextEditingController();
    controller_ticket_type = TextEditingController();

    imagePath = UserPreferences.myUser.imagePath;
    pic = NetworkImage(imagePath);
    imagePicker = ImagePicker();
    // print("image path in image widget: " + this.imagePath);
    init();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.guard_location == widget.student_location) {
      return Scaffold(
        // backgroundColor: Colors.white,
        backgroundColor: Colors.white,
        // backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black, // Set the background color to black
          centerTitle: true, // Center-align the title
          iconTheme: const IconThemeData(
              color: Color.fromARGB(
                  221, 255, 255, 255)), // Set the back arrow color to white
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              color: Colors.black,
            ),
          ),
          title: const Text(
            "Profile Page",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold), // Set the text color to white
          ),
        ),

        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 232, 232, 234),
                Color.fromARGB(255, 255, 255, 255)
              ],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            physics: const BouncingScrollPhysics(),
            children: [
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ImageWidget(),
                  SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // buildName(user),

                          Text(
                            user.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: Colors.black),
                          ),

                          // Text(
                          //   user.name,
                          //   style: const TextStyle(
                          //       fontWeight: FontWeight.bold, fontSize: 24, color: Colors.black),
                          // ),
                          // const SizedBox(height: 4),

                          Text(
                            user.email,
                            style: TextStyle(color: Colors.black),
                          ),

                          // Text(
                          //   user.email,
                          //   style: TextStyle(color: Colors.black.withOpacity(0.7)),
                          // ),
                          // const SizedBox(height: 10),
                          // Text(
                          //   "Phone",
                          //   style: const TextStyle(
                          //     fontWeight: FontWeight.bold,
                          //     fontSize: 16,
                          //     color: Colors.black,
                          //   ),
                          // ),
                          TextField(
                            style: const TextStyle(color: Colors.black),
                            textAlign: TextAlign.center,
                            enabled: false, // Use the 'enabled' parameter here
                            controller: controller_phone,
                            // decoration: InputDecoration(
                            //   hintText: 'Enter your phone number',
                            //   hintStyle: TextStyle(
                            //       color: Colors.grey), // Adjust hint style
                            //   disabledBorder: OutlineInputBorder(
                            //     borderSide: const BorderSide(
                            //         color: Colors.black, width: 1.0),
                            //     borderRadius: BorderRadius.circular(12),
                            //   ),
                            //   labelStyle: TextStyle(
                            //       color: Color(int.parse("0xFF344953"))),
                            // ),
                            maxLines: 1,
                          ),
                        ],
                      ))
                ],
              ),
              // builText_phone(controller_phone, "Phone", widget.isEditable, 1),
              // const SizedBox(height: 24),
              // builText(controller_department, "Department", false, 1),
              // const SizedBox(height: 24),
              // builText(controller_degree, "Degree", false, 1),
              // const SizedBox(height: 24),
              // builText(controller_year_of_entry, "Year of Entry", false, 1),
              // const SizedBox(height: 24),
              // builText(controller_gender, "Gender", false, 1),
              const SizedBox(height: 20),
              builText(
                  controller_destination_address,
                  "Location Picked", //CHANGED BY VG
                  true,
                  1),
              const SizedBox(height: 20),
              builText(controller_vehicle_reg_num, "Purpose", true,
                  1), //CHANGED BY VG
              const SizedBox(height: 20),
              builText(controller_ticket_type, "Ticket Type", false, 1),
              const SizedBox(height: 20),
              SizedBox(
                height: MediaQuery.of(context).size.height * 290 / 925,
                // child: SingleChildScrollView(
                // scrollDirection: Axis.vertical, // Set scroll direction to vertical
                child:
                    // Column(
                    //   children: [
                    //
                    //   ],
                    // ),
                    StreamBuilder(
                  stream: databaseInterface.get_tickets_for_student(
                      user.email, widget.student_location),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return const Center(child: CircularProgressIndicator());
                      default:
                        if (snapshot.hasError) {
                          return const Text("Error",
                              style:
                                  TextStyle(fontSize: 24, color: Colors.red));
                        } else {
                          // String in_or_out = snapshot.data.toString();
                          List<ResultObj> tickets = [];
                          if (snapshot.hasData) {
                            tickets = snapshot.data as List<ResultObj>;
                          }
                          print("${tickets[0].date_time}**");
                          return StudentTicketTable(
                              tickets: tickets.take(5).toList());
                        }
                    }
                  },
                ),
                // StudentTicketTable(tickets: dummyList),
                // ),
              ),
              const SizedBox(height: 20),

              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Flexible(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          // await accept_selected_tickets();
                          // List <ResultObj> ticke
                          String time = DateTime.now().toString();
                          print("Accept button pressed == ${widget.email}");
                          await databaseInterface.insert_qr_ticket(
                              widget.email,
                              'Approved',
                              controller_vehicle_reg_num.text,
                              widget.ticket_type,
                              time,
                              controller_destination_address.text,
                              widget.guard_location,
                              widget.guard_email);
                          await databaseInterface.accept_generated_QR(
                              widget.guard_location,
                              controller_destination_address.text,
                              "Approved",
                              widget.ticket_type,
                              time,
                              widget.email);
                          ScaffoldMessenger.of(context).showSnackBar(
                              get_snack_bar("Ticket Approved", Colors.green));
                          Navigator.pop(context);
                        },
                        label: const Text(
                          "Accept",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        icon: const Icon(
                          Icons.check_circle_outlined,
                          color: Colors.green,
                          size: 50.0,
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            const Color.fromARGB(255, 255, 254, 255),
                          ),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          elevation: MaterialStateProperty.all<double>(10),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Flexible(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          String time = DateTime.now().toString();
                          // await reject_selected_tickets();
                          await databaseInterface.insert_qr_ticket(
                              widget.email,
                              'Rejected',
                              controller_vehicle_reg_num.text,
                              widget.ticket_type,
                              time,
                              controller_destination_address.text,
                              widget.guard_location,
                              widget.guard_email);
                          await databaseInterface.accept_generated_QR(
                              widget.guard_location,
                              controller_destination_address.text,
                              "Rejected",
                              widget.ticket_type,
                              time,
                              widget.email);
                          ScaffoldMessenger.of(context).showSnackBar(
                              get_snack_bar("Ticket Rejected", Colors.red));
                          Navigator.pop(context);
                        },
                        label: const Text(
                          "Reject",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        icon: const Icon(
                          Icons.cancel,
                          color: Colors.red,
                          size: 50.0,
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            const Color.fromARGB(255, 255, 255, 255),
                          ),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          elevation: MaterialStateProperty.all<double>(10),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              /* ElevatedButton(
              onPressed: (){},
              child:Text('Edit '),
            ), */
            ],
          ),
        ),
      );
    } else {
      // Display snack and go back to the previous screen
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(
      //         'You are not authorized for ${widget.student_location} Locations'),
      //     backgroundColor: Colors.red, // Set the background color to red
      //   ),
      // );
      Navigator.of(context).pop();

      return Scaffold(
        backgroundColor: Colors.white,
        body: Container(), // Blank container as the body
      );
    }
  }

  Widget buildName(User user) => Column(
        children: [
          Text(
            user.name,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 24, color: Colors.black),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: TextStyle(color: Colors.black.withOpacity(0.7)),
          )
        ],
      );

  Widget builText(TextEditingController controller, String label,
          final bool enabled, int maxLines) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
          ),
          const SizedBox(height: 4),
          TextField(
            style: const TextStyle(color: Colors.black),
            enabled: enabled,
            controller: controller,
            decoration: InputDecoration(
              disabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.black, width: 1.0),
                borderRadius: BorderRadius.circular(12),
              ),
              labelStyle: TextStyle(
                color: Color(int.parse("0xFF344953")),
              ),
            ),
            maxLines: maxLines,
          ),
        ],
      );

  Widget builText_phone(TextEditingController controller, String label,
          bool enabled, int maxLines) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              TextField(
                style: const TextStyle(color: Colors.black),
                enabled: enabled, // Use the 'enabled' parameter here
                controller: controller,
                decoration: InputDecoration(
                  disabledBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black, width: 1.0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelStyle: TextStyle(
                    color: Color(int.parse("0xFF344953")),
                  ),
                ),
                maxLines: maxLines,
              ),
              if (enabled) // Only show the edit button if enabled is true
                Positioned(
                  right: 0,
                  top: 10,
                  child: TextButton(
                    onPressed: () async {
                      // Handle button press here
                      await databaseInterface
                          .update_number(controller.text, user.email)
                          .then((res) => {
                                if (res == true)
                                  {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        get_snack_bar("Phone number updated",
                                            Colors.green))
                                  }
                                else
                                  {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        get_snack_bar(
                                            "Failed to Update Phone Number",
                                            Colors.red))
                                  }
                              });
                    },
                    child: const Text(
                      'Edit',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ],
      );

  Future<void> pick_image() async {
    print("edit profile page image clicked 2");
    var source = ImageSource.gallery;
    print(source);
    XFile image = await imagePicker.pickImage(source: source);
    var widgetEmail = widget.email;
    print("image is picked");
    print(image.path);
    await databaseInterface.send_image(
        image, "/students/change_profile_picture_of_student", widgetEmail);

    databaseInterface db = databaseInterface();
    User result = await databaseInterface.get_student_by_email(widget.email);

    var picLocal = result.profileImage;
    setState(() {
      pic = picLocal;
    });
  }

  Future<void> pick_image_blank() async {
    var source = ImageSource.gallery;
    print(source);
    var filePath =
        image_paths.dummy_person; // Replace with the actual file path
    XFile image = XFile(filePath);
    var widgetEmail = widget.email;
    await databaseInterface.send_image(
        image, "/students/change_profile_picture_of_student", widgetEmail);

    databaseInterface db = databaseInterface();
    User result = await databaseInterface.get_student_by_email(widget.email);

    var picLocal = NetworkImage(result.imagePath);
    var removeImage = const AssetImage(image_paths.dummy_person);
    setState(() {
      pic = removeImage;
    });
  }

  Widget ImageWidget() {
    print("edit 1");
    return ViewValidification_page();
    /* if(widget.isEditable){
      print("edit 2");
      /* return EditableValidification_page(); */
    } */
    /* return ViewValidification_page(); */
  }

  Widget EditableValidification_page() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Material(
                color: Colors.transparent,
                child: Ink.image(
                  // image: AssetImage(image),
                  // image: NetworkImage(widget.imagePath),
                  image: pic,
                  fit: BoxFit.cover,
                  width: 180,
                  height: 180,
                  child: InkWell(
                    onTap: () async {
                      pick_image();
                    },
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 4,
            // child: buildEditIcon(Theme.of(context).colorScheme.primary),
            child: buildEditIcon(Color(int.parse("0xFF344953"))),
          ),
          /* Positioned(
          bottom:0,
          right: 50,
          child: buildEditIcon_1(Color(int.parse("0xFF344953"))),
        ), */
        ],
      ),
    );
  }

  Widget ViewValidification_page() {
    return Stack(
      children: [
        ClipOval(
          child: Material(
            color: Colors.transparent,
            // color: Colors.blue,
            child: Ink.image(
              // image: AssetImage(image),
              // image: NetworkImage(widget.imagePath),
              image: pic,
              fit: BoxFit.cover,
              width: 90,
              height: 90,
            ),
          ),
        ),
        // Positioned(
        //   bottom: 0,
        //   right: 4,
        //   // child: buildEditIcon(Theme.of(context).colorScheme.primary),
        //   child: buildEditIcon(Color(int.parse("0xFF344953"))),
        // ),
      ],
    );
  }

  Widget buildEditIcon(Color color) => buildCircle(
        color: Colors.white,
        all: 3,
        child: buildCircle(
          color: color,
          all: 8,
          child: const Icon(
            Icons.add_a_photo,
            color: Colors.white,
            size: 20,
          ),
        ),
      );

  Widget buildEditIcon_1(Color color) => buildCircle(
        color: Colors.white,
        all: 3,
        child: buildCircle(
          color: color,
          all: 8,
          child: const Icon(
            Icons.add_a_photo,
            color: Colors.white,
            size: 20,
          ),
        ),
      );

  Widget buildCircle({
    required Widget child,
    required double all,
    required Color color,
  }) =>
      ClipOval(
        child: Container(
          padding: EdgeInsets.all(all),
          color: color,
          child: child,
        ),
      );
}
