
import 'package:flutter/material.dart';
import 'package:my_gate_app/database/database_interface.dart';
import 'package:my_gate_app/screens/profile2/model/user.dart';
import 'package:my_gate_app/screens/profile2/utils/user_preferences.dart';
import 'package:my_gate_app/screens/profile2/widget/appbar_widget.dart';
import 'package:my_gate_app/screens/profile2/widget/profile_widget.dart';

class AuthorityEditProfilePage extends StatefulWidget {
  final String? email;
  const AuthorityEditProfilePage({super.key, required this.email});
  @override
  _AuthorityEditProfilePageState createState() => _AuthorityEditProfilePageState();
}

class _AuthorityEditProfilePageState extends State<AuthorityEditProfilePage> {
  AuthorityUser user = UserPreferences.myAuthorityUser;

  late final TextEditingController controller_name;
  late final TextEditingController controller_email;
  late final TextEditingController controller_designation;
  
  @override
  void initState(){
    super.initState();
    // String? curr_email = LoggedInDetails.getEmail();
    String? currEmail = widget.email;
    print("Current Email: $currEmail");
    controller_name = TextEditingController();
    controller_email = TextEditingController();
    controller_designation = TextEditingController();

    databaseInterface db = databaseInterface();
    db.get_authority_by_email(currEmail).then((AuthorityUser result){
      setState(() {
        user = result; 
        controller_name.text = user.name;
        controller_email.text = user.email;
        controller_designation.text = user.designation;
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
                builText(controller_designation,"Designation", false,1),
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