
import 'package:flutter/material.dart';
import 'package:my_gate_app/database/database_interface.dart';
import 'package:my_gate_app/screens/profile2/model/user.dart';
import 'package:my_gate_app/screens/profile2/utils/user_preferences.dart';
import 'package:my_gate_app/screens/profile2/widget/appbar_widget.dart';
import 'package:my_gate_app/screens/profile2/widget/profile_widget.dart';

class GuardEditProfilePage extends StatefulWidget {
  final String? email;
  const GuardEditProfilePage({super.key, required this.email});
  @override
  _GuardEditProfilePageState createState() => _GuardEditProfilePageState();
}

class _GuardEditProfilePageState extends State<GuardEditProfilePage> {
  GuardUser user = UserPreferences.myGuardUser;

  late final TextEditingController controller_name;
  late final TextEditingController controller_email;
  late final TextEditingController controller_location;
  
  @override
  void initState(){
    super.initState();
    // String? curr_email = LoggedInDetails.getEmail();
    String? currEmail = widget.email;
    print("Current Email: $currEmail");
    controller_name = TextEditingController();
    controller_email = TextEditingController();
    controller_location = TextEditingController();

    databaseInterface db = databaseInterface();
    db.get_guard_by_email(currEmail).then((GuardUser result){
      setState(() {
        user = result; 
        controller_name.text = user.name;
        controller_email.text = user.email;
        controller_location.text = user.location;
        print("Result Name in Edit Profile Page${result.name}"); 
      });
    });
    print("User Name in Edit Profile Page${user.name}");
  }

  @override
  Widget build(BuildContext context) => Scaffold(
            appBar: buildAppBar(context),
            body: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              physics: const BouncingScrollPhysics(),
              children: [
                ProfileWidget(
                  imagePath: user.imagePath,
                  isEdit: true,
                  onClicked: () async {},
                ),
                const SizedBox(height: 24),
                builText(controller_name,"Name", false,1),
                const SizedBox(height: 24),
                builText(controller_email,"Email", false,1),
                const SizedBox(height: 24),
                builText(controller_location,"Location Allocated", false,1),
              ],
            ),
          );
    Widget builText(TextEditingController controller, String label, final bool enabled,int maxLines) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          TextField(
            enabled: enabled,
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            maxLines: maxLines,
          ),
        ],
      );
}