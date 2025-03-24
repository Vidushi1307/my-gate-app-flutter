import 'package:flutter/material.dart';
import 'package:my_gate_app/database/database_interface.dart';
import 'package:my_gate_app/screens/guard/visitors/visitors_tabs_controller.dart';
import 'package:my_gate_app/screens/guard/utils/UI_statics.dart';
import 'package:google_fonts/google_fonts.dart';

class selectVisitor extends StatefulWidget {
  const selectVisitor({super.key});

  @override
  _selectVisitorState createState() => _selectVisitorState();
}

class _selectVisitorState extends State<selectVisitor> {
  String _name = "";
  String _phoneNumber = "";

  List<User> _users = [];

  List<User> searchUsers(String name, String phoneNumber) {
    return _users
        .where((user) =>
            user.name.toLowerCase().contains(name.toLowerCase()) &&
            user.phoneNumber.contains(phoneNumber))
        .toList();
  }

  User? _selectedUser;

  void getUsers() async {
    List<String> visitorList = await databaseInterface.get_list_of_visitors();
    print(visitorList);
    List<User> userList = visitorList.map((visitorString) {
      List<String> parts = visitorString.split(',');
      return User(
        id: int.parse(parts[2]),
        name: parts[1].trim(),
        phoneNumber: parts[0].trim(),
      );
    }).toList();
    setState(() {
      _users = userList;
    });
  }

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 180, 180, 180),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        flexibleSpace: Container(
            decoration: BoxDecoration(
          color: hexToColor(guardColors[0]),
        )),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [hexToColor(guardColors[0]), hexToColor(guardColors[1])],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Search or Add Visitor',
                style: GoogleFonts.mPlusRounded1c(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color:
                      // Color.fromARGB(255, 0, 0, 0),
                      Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ),
              Container(
                height: 40.0, // Adjust the height as needed
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.white,
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _name = value;
                    });
                  },
                  decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      border: InputBorder.none,
                      hintText: 'Name',
                      hintStyle: GoogleFonts.lato(color: Colors.grey)),
                  style: GoogleFonts.lato(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              Container(
                height: 40.0, // Adjust the height as needed

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.white,
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _phoneNumber = value;
                    });
                  },
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      border: InputBorder.none,
                      hintText: 'Phone Number',
                      hintStyle: GoogleFonts.lato(color: Colors.grey)),
                  style: GoogleFonts.lato(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.04),
              const Text("Search Results:",
                  style: TextStyle(
                    color: Colors.black,
                  )),
              Expanded(
                child: ListView.builder(
                  itemCount: (_name.isEmpty && _phoneNumber.isEmpty)
                      ? 0
                      : searchUsers(_name, _phoneNumber).length.clamp(0, 4),
                  itemBuilder: (context, index) {
                    final user = searchUsers(_name, _phoneNumber)[index];
                    return ListTile(
                      title: Text(user.name),
                      subtitle: Text(user.phoneNumber),
                      onTap: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VisitorsTabs(
                              username: user.name,
                              userid: user.id,
                              phonenumber: user.phoneNumber,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(
                      hexToColor(guardColors[2])),
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          5.0), // Set the border radius here
                    ),
                  ),
                ),
                onPressed: () async {
                  if (_name.isNotEmpty && _phoneNumber.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VisitorsTabs(
                          username: _name,
                          phonenumber: _phoneNumber,
                        ),
                      ),
                    ).then((value) => initState());
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.red,
                        content: const Text(
                            "Name/Phone number fields required for adding new visitor."),
                        action: SnackBarAction(
                          label: "OK",
                          onPressed: () {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          },
                        ),
                      ),
                    );
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8.0),
                    Text("New User",
                        style: GoogleFonts.lato(
                          color: Colors.white,
                          fontSize: 18,
                        )),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03)
            ],
          ),
        ),
      ),
    );
  }
}

class User {
  final int id;
  final String name;
  final String phoneNumber;

  User({required this.id, required this.name, required this.phoneNumber});
}
