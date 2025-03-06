import 'package:flutter/material.dart';
import 'package:my_gate_app/database/database_interface.dart';
import 'package:my_gate_app/get_email.dart';

class NotificationsPage extends StatefulWidget {
  int notificationCount;

  NotificationsPage({super.key, required this.notificationCount});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<List<String>> notifications = [];
  final Set<int> _selectedIndices = <int>{};
  String noti = "";

  @override
  void initState() {
    super.initState();
    getNotifications();
  }

  Future<void> getNotifications() async {
    List<List<String>> messages = await databaseInterface
        .fetch_notification_guard(LoggedInDetails.getEmail());
    setState(() {
      notifications = messages;
    });
  }

  String return_date_time(String datetime) {
    String date = datetime.split('T')[0];
    String time = datetime.split('T')[1];
    time = time.split('.')[0];
    return ("Date = $date , Time = $time");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context,widget.notificationCount);
          },
        ),
        iconTheme: const IconThemeData(
          color: Colors.black, // change the color of the back button here
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              // gradient: LinearGradient(
              //     begin: Alignment.topLeft,
              //     end: Alignment.bottomRight,
              //     colors: <Color>[Colors.purple, Colors.blue])),
            color: Colors.white,
        ),
        ),
        // backgroundColor: Color.fromARGB(255, 180, 180, 180),
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Container(
        // color: Colors.white,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(35.0), // Adjust the radius as needed
            topRight: Radius.circular(35.0), // Adjust the radius as needed
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.3),
              blurRadius: 0,
              spreadRadius: 2,
              offset: const Offset(0,3),

            ),

          ],
        ),
        child: ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (BuildContext context, int index) {
            final List<String> notification = notifications[index];
            return Column(
              children: [
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blueGrey,
                    child: Icon(Icons.notifications),

                  ),
                  title: Text(
                    "From : ${notification[1]}\nLocation : ${notification[2]}\nMessage : ${notification[3]}\nTicket Type : ${notification[5]}",
                    style: TextStyle(
                      color: _selectedIndices.contains(index)
                          ? Colors.grey
                          : Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    return_date_time(notification[4]),
                    style: TextStyle(
                      color: _selectedIndices.contains(index)
                          ? Colors.grey
                          : Colors.black,
                    ),
                  ),

                  trailing: const Icon(Icons.more_vert),
                  onTap: () async {
                    await databaseInterface.mark_individual_notification(
                        notification[0], LoggedInDetails.getEmail());
                    setState(() {
                      if (_selectedIndices.contains(index)) {
                        // _selectedIndices.remove(index);
                      } else {
                        _selectedIndices.add(index);
                        widget.notificationCount--;
                      }
                    });
                    /* Navigator.pop(context, widget.notificationCount); */
                  },
                ),
                Divider(
                  color: Colors.grey[600], // Set the color of the divider
                  thickness: 1, // Set the thickness of the divider
                  indent: 16, // Set the indentation of the divider from the leading edge
                  endIndent: 16, // Set the indentation of the divider from the trailing edge
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
