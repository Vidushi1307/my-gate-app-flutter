// ignore_for_file: non_constant_identifier_names, avoid_print, unused_local_variable
import 'dart:io';
import 'package:flutter/foundation.dart'; // Required for compute()
import 'package:my_gate_app/myglobals.dart' as myglobals;
import 'package:flutter/material.dart';
import 'package:my_gate_app/get_email.dart';
import 'package:my_gate_app/screens/profile2/utils/user_preferences.dart';
import 'package:my_gate_app/screens/profile2/model/user.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'database_objects.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_gate_app/image_paths.dart' as image_paths;

enum HttpMethod {
  GET,
  POST,
  PUT,
  DELETE,
  // Add more HTTP methods as needed
}

// Temporary data holder
class _UserData {
  final Map<String, dynamic> data;
  final Uint8List bytes;
  _UserData(this.data, this.bytes);
}

class databaseInterface {
  static int REFRESH_RATE = 1;
  static int PORT_NO_static = 8000;
  static String complete_base_url_static = "https://mygate-vercel.vercel.app";
//  static String complete_base_url_static =  "https://bbab-2401-4900-8519-8a84-eb38-4edf-2cf9-b2d0.ngrok-free.app";

  static Map<String, dynamic> retry = {
    "try": 1,
    "ifretry": false,
  };
  databaseInterface();

  static Future<String> get_welcome_message(String email) async {
    var uri = "$complete_base_url_static/get_welcome_message";

    var url = Uri.parse(uri);
    try {
      var response = await http.post(url, body: {'email': email});
      var data = json.decode(response.body);
      String welcome_message = data['welcome_message'];
      return welcome_message;
    } catch (e) {
      print("Exception in get_welcome_message: $e");
      return "Welcome";
    }
  }

// Function to get access token from shared preferences
  static Future<String?> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

// Function to get refresh token from shared preferences
  static Future<String?> getRefreshToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }

// Function to save access token to shared preferences
  static Future<void> saveAccessToken(String accessToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('access_token', accessToken);
  }

  static Future<http.Response> makeAuthenticatedRequest(
      Uri url, HttpMethod method,
      {required Map<String, dynamic> body}) async {
    retry['try'] = 1;
    retry['retry'] = false;
    http.Response response = await makeTry(url, method, body: body);
    if (retry['try'] <= 1 && retry['retry'] == true) {
      response = await makeTry(url, method, body: body);
    }
    return response;
  }

  static Future<http.Response> makeTry(Uri url, HttpMethod method,
      {required Map<String, dynamic> body}) async {
    // Get access token
    String? accessToken = await getAccessToken();

    // Add access token to headers
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    // Make API request based on the specified method
    http.Response response;
    switch (method) {
      case HttpMethod.GET:
        response = await _makeGetRequest(url, headers);
        break;
      case HttpMethod.POST:
        response = await _makePostRequest(url, headers, body);
        break;
      case HttpMethod.PUT:
        response = await _makePutRequest(url, headers, body);
        break;
      case HttpMethod.DELETE:
        response = await _makeDeleteRequest(url, headers);
        break;
      // Add more cases for other HTTP methods if needed
    }
    return response;
  }

  static Future<http.Response> _makeGetRequest(
      Uri url, Map<String, String> headers) async {
    final response = await http.get(url, headers: headers);
    await _handleResponse(response);
    return response;
  }

  static Future<http.Response> _makePostRequest(
      Uri url, Map<String, String> headers, Map<String, dynamic> body) async {
    final response =
        await http.post(url, headers: headers, body: jsonEncode(body));
    await _handleResponse(response);
    return response;
  }

  static Future<http.Response> _makePutRequest(
      Uri url, Map<String, String> headers, Map<String, dynamic> body) async {
    final response =
        await http.put(url, headers: headers, body: jsonEncode(body));
    await _handleResponse(response);
    return response;
  }

  static Future<http.Response> _makeDeleteRequest(
      Uri url, Map<String, String> headers) async {
    final response = await http.delete(url, headers: headers);
    await _handleResponse(response);
    return response;
  }

  static Future<void> _handleResponse(http.Response response) async {
    if (response.statusCode == 401) {
      // Access token expired, try refreshing token
      bool success =
          await refreshToken(); // Call your refreshToken function here
      if (success) {
        retry['retry'] = true;
      }
    }
  }

// Function to refresh token
  static Future<bool> refreshToken() async {
    String? refreshToken = await getRefreshToken();
    var url = "$complete_base_url_static/refresh_token";
    // Make request to refresh token endpoint
    final response = await http.post(
      Uri.parse(url),
      body: {
        'refresh_token': refreshToken,
      },
    );

    // Parse response
    if (response.statusCode == 200) {
      // Save new access token
      Map<String, dynamic> data = json.decode(response.body);
      String accessToken = data['access_token'];
      await saveAccessToken(accessToken);
      return true;
    } else {
      return false;
    }
  }

  static List<String> getLoctions() {
    // TODO: get this list from the backend
    final List<String> entries = <String>[
      'CS Block',
      'Lab 101',
      'Lab 102',
      'Lab 202',
      'Lab 203'
    ];
    return entries;
  }

  static Future<List<String>> getLoctions2() async {
    List<String> blank_list = [];
    List<String> output = [];
    var url = "$complete_base_url_static/locations/get_all_locations";
    try {
      var response = await http.post(Uri.parse(url));

      var data = json.decode(response.body);
      for (var location in data['output']) {
        String location_name = location['location_name'];
        bool pre_approval = location['pre_approval'];
        output.add(location_name);
      }
      if (response.statusCode == 200) {
        return output;
      } else {
        return blank_list;
      }
    } catch (e) {
      print("Exception while getting locations");
      print(e.toString());
      return blank_list;
    }
  }

  static Future<LocationsAndPreApprovalsObjects> getLoctionsAndPreApprovals() async {
    var url = "$complete_base_url_static/locations/get_all_locations";
    try {
      final response = await http.post(Uri.parse(url)).timeout(Duration(seconds: 5));
      
      if (response.statusCode != 200) return LocationsAndPreApprovalsObjects([], [], []);
      
      // Move JSON parsing to isolate (minimal change)
      final data = await compute(jsonDecode, response.body);
      
      return LocationsAndPreApprovalsObjects(
        (data['output'] as List).map((loc) => loc['location_name'] as String).toList(),
        (data['output'] as List).map((loc) => loc['location_id'] as int).toList(),
        (data['output'] as List).map((loc) => loc['pre_approval'] as bool).toList(),
      );
    } catch (e) {
      print("getLoctionsAndPreApprovals error: $e");
      return LocationsAndPreApprovalsObjects([], [], []);
    }
  }
  static Future<List<String>> get_all_guard_emails() async {
    List<String> blank_list = [];
    List<String> output = [];
    var url = "$complete_base_url_static/guards/get_all_guard_emails";
    try {
      var response = await http.post(Uri.parse(url));

      var data = json.decode(response.body);
      for (var guard_email in data['output']) {
        String email = guard_email['email'];
        output.add(email);
      }
      if (response.statusCode == 200) {
        return output;
      } else {
        return blank_list;
      }
    } catch (e) {
      print("Exception while getting Guards Email List");
      print(e.toString());
      return blank_list;
    }
  }

  static List<String> getGuardNames() {
    // TODO: get this list from the backend
    final List<String> entries = <String>[
      'Guard 1',
      'Guard 2',
      'Guard 3',
    ];
    return entries;
  }

  static List<String> getGuardLocations() {
    // TODO: get this list from the backend
    final List<String> entries = <String>[
      'Guard 1 Email',
      'Guard 2 Email',
      'Guard 3 Email',
      'abc@gmail.com',
    ];
    return entries;
  }

  static List<String> getLocationImagesPaths() {
    final List<String> entries = [
      image_paths.cs_block,
      image_paths.cs_lab,
      image_paths.research_lab,
      image_paths.lecture_room,
      image_paths.conference_room,
    ];
    return entries;
  }

  static String getImagePath(String location) {
    switch (location) {
      case "Main Gate":
        return image_paths.spiral;
      case "CS Department":
        return image_paths.cs_block;
      case "CS Block":
        return image_paths.cs_block;
      case "Mess":
        return image_paths.mess;
      case "Library":
        return image_paths.lib;
      case "Hostel":
        return image_paths.hostel;
      case "CSLab":
        return image_paths.cs_lab;
      default:
        return image_paths.spiral;
    }
  }

  static List<String> getUserTypes() {
    final List<String> entries = <String>['Student', 'Guard', 'Admin'];
    return entries;
  }

  static Future<LoginResultObj> login_user(
      String email, String password) async {
    var url = "$complete_base_url_static/login_user";
    try {
      var response = await http.post(
        Uri.parse(url),
        body: {
          'email': email,
          'password': password,
        },
      );
      var data = json.decode(response.body);
      String person_type = data['person_type'];
      String message = data['message'];

      LoginResultObj res = LoginResultObj(person_type, message);
      return res;
    } catch (e) {
      LoginResultObj res = LoginResultObj("NA", "Internal Server Error");
      return res;
    }
  }

  static Future<List<String>> get_authorities_list() async {
    var url = "$complete_base_url_static/authorities/get_authorities_list";
    try {
      var response = await http.post(Uri.parse(url));
      var data = json.decode(response.body) as List;
      List<String> res = [];
      for (var i = 0; i < data.length; i++) {
        String obj = data[i]['authority_name'] +
            ", " +
            data[i]['authority_designation'] +
            "\n" +
            data[i]['email'];
        res.add(obj);
      }
      return res;
    } catch (e) {
      List<String> res = [];
      return res;
    }
  }

  // Called by the guard to get the list of entry numbers
  static Future<List<String>> get_list_of_entry_numbers(String route) async {
    var url = "$complete_base_url_static/$route/get_list_of_entry_numbers";
    try {
      var response = await http.post(Uri.parse(url));
      var data = json.decode(response.body) as List;
      List<String> res = [];
      for (var i = 0; i < data.length; i++) {
        String obj = data[i]['entry_no'] +
            ", " +
            data[i]['st_name'] +
            "\n" +
            data[i]['email'];
        res.add(obj);
      }
      return res;
    } catch (e) {
      List<String> res = [];
      return res;
    }
  }

  static Future<List<String>> get_list_of_visitors() async {
    var url = "$complete_base_url_static/visitors/get_list_of_visitors";
    try {
      var response = await http.post(Uri.parse(url));
      var data = json.decode(response.body) as List;
      List<String> res = [];
      for (var i = 0; i < data.length; i++) {
        String obj = data[i]['mobile_no'] +
            ", " +
            data[i]['visitor_name'] +
            ", " +
            data[i]['visitor_id'].toString() +
            "\n";
        res.add(obj);
      }

      return res;
    } catch (e) {
      print("Caught exception in get_list_of_visitors");
      print(e);
      List<String> res = [];
      return res;
    }
  }

  static Future<List<String>> get_authority_tickets_with_status_accepted(
      String email, String location, String ticket_type) async {
    var url =
        "$complete_base_url_static/authorities/get_authority_tickets_with_status_accepted";
    try {
      var response = await http.post(Uri.parse(url), body: {
        "email": email,
        "location": location,
        "ticket_type": ticket_type,
      });
      var data = json.decode(response.body) as List;
      List<String> res = [];
      for (var i = 0; i < data.length; i++) {
        String obj = data[i]['authority_name'] +
            ", " +
            data[i]['authority_designation'] +
            "\n" +
            "authority_message: " +
            data[i]['authority_message'] +
            "\n" +
            "student_message:" +
            data[i]['student_message'] +
            "\n" +
            data[i]['ref_id'];
        res.add(obj);
      }

      return res;
    } catch (e) {
      print("Caught exception in get_authority_tickets_with_status_accepted");
      List<String> res = [];
      return res;
    }
  }

  static Future<String> forgot_password(
      String email, int op, int entered_otp) async {
    var url = "$complete_base_url_static/forgot_password";
    try {
      var response = await http.post(
        Uri.parse(url),
        body: {
          'email': email,
          'op': op.toString(),
          'entered_otp': entered_otp.toString(),
        },
      );
      var data = json.decode(response.body);
      String message = data['message'];
      if (op == 2 && response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("reset_password_token", data['token']);
        prefs.setString("reset_password_uid", data['uidb64']);
      }
      return message;
    } catch (e) {
      print("OTP error=${e.toString()}");
      print(e);
      return "Exception in forgot password";
    }
  }

  static Future<String> reset_password(String email, String password) async {
    var uri = "$complete_base_url_static/reset_password";
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString("reset_password_token")!;
      String uid = prefs.getString("reset_password_uid")!;
      var response = await http.post(
        Uri.parse(uri),
        body: {
          'token': token,
          'uidb64': uid,
          'password': password,
        },
      );
      var data = json.decode(response.body);
      String message = data['message'];
      return message;
    } catch (e) {
      print(e);
      return "Password RESET Failed";
    }
  }

  Future<int> insert_in_guard_ticket_table(
      String email,
      String location,
      String date_time,
      String ticket_type,
      String choosen_authority_ticket,
      String destination_address) async {
    var uri = "$complete_base_url_static/guards/insert_in_guard_ticket_table";
    try {
      var response = await http.post(
        Uri.parse(uri),
        body: {
          'email': email,
          'location': location,
          'date_time': date_time,
          'ticket_type': ticket_type,
          'choosen_authority_ticket': choosen_authority_ticket,
          'address': destination_address,
        },
      );
      return response.statusCode.toInt();
    } catch (e) {
      print("post request error");
      print(e.toString());
      return 500;
    }
  }

  static Future<int> insert_in_authorities_ticket_table(
      String chosen_authority,
      String ticket_type,
      String student_message,
      String email,
      String date_time,
      String location) async {
    var uri =
        "$complete_base_url_static/authorities/insert_in_authorities_ticket_table";
    try {
      var response = await http.post(
        Uri.parse(uri),
        body: {
          'chosen_authority': chosen_authority,
          'ticket_type': ticket_type,
          'student_message': student_message,
          'email': email,
          'date_time': date_time,
          'location': location,
        },
      );
      if (response.statusCode.toInt() == 200) {
        print("Ticket inserted into authorities ticket table");
      } else {
        print("Failed to insert ticket into authorities ticket table");
      }
      return response.statusCode.toInt();
    } catch (e) {
      print(
          "Failed to insert ticket into authorities ticket table, exception: $e");
      return 500;
    }
  }

  // TODO: Add data type of variable student_list
  void change_ticket_status(student_list) async {
    var uri = "$complete_base_url_static/students/approve_selected_tickets";
    try {
      var response = await http.post(
        Uri.parse(uri),
        body: {"data": student_list},
      );
    } catch (e) {
      print("post request error");
      print(e.toString());
    }
  }

  // This fetches guard tickets
  static Stream<List<ResultObj>> get_tickets_for_student(
          String email, String location) =>
      Stream.periodic(Duration(seconds: REFRESH_RATE))
          .asyncMap((_) => get_tickets_for_student_util(email, location));

  // This fetches guard tickets
  static Future<List<ResultObj>> get_tickets_for_student_util(
      String email, String location) async {
    var uri = "$complete_base_url_static/students/get_tickets_for_student";
    try {
      var response = await http
          .post(Uri.parse(uri), body: {'email': email, 'location': location});
      List<ResultObj> tickets_list = (json.decode(response.body) as List)
          .map((i) => ResultObj.fromJson1(i))
          .toList();

      if (response.statusCode == 200) {
        return tickets_list;
      } else {
        print("Server Error in get_tickets_for_student_util");
        List<ResultObj> tickets_list = [];
        return tickets_list;
      }
    } catch (e) {
      List<ResultObj> tickets_list = [];
      return tickets_list;
    }
  }

  static Stream<List<ResultObj7>> get_authority_tickets_for_student(
          String email, String location) =>
      Stream.periodic(Duration(seconds: REFRESH_RATE)).asyncMap(
          (_) => get_authority_tickets_for_student_util(email, location));

  static Future<List<ResultObj7>> get_authority_tickets_for_student_util(
      String email, String location) async {
    var uri =
        "$complete_base_url_static/students/get_authority_tickets_for_students";
    try {
      var response = await http
          .post(Uri.parse(uri), body: {'email': email, 'location': location});
      List<ResultObj7> tickets_list = (json.decode(response.body) as List)
          .map((i) => ResultObj7.fromJson(i))
          .toList();

      if (response.statusCode == 200) {
        return tickets_list;
      } else {
        print("Server Error in get_authority_tickets_for_student");
        List<ResultObj7> tickets_list = [];
        return tickets_list;
      }
    } catch (e) {
      List<ResultObj7> tickets_list = [];
      return tickets_list;
    }
  }

  static Stream<List<ResultObj>> get_pending_tickets_for_guard_stream(
          String location) =>
      Stream.periodic(Duration(seconds: REFRESH_RATE))
          .asyncMap((_) => get_pending_tickets_for_guard_stream_util(location));

  static Future<List<ResultObj>> get_pending_tickets_for_guard_stream_util(
      String location) async {
    var uri = "$complete_base_url_static/guards/get_pending_tickets_for_guard";
    try {
      var response =
          await http.post(Uri.parse(uri), body: {'location': location});
      List<ResultObj> pending_tickets_list =
          (json.decode(response.body) as List)
              .map((i) => ResultObj.fromJson1(i))
              .toList();

      if (response.statusCode == 200) {
        return pending_tickets_list;
      } else {
        print("Server Error in get_pending_tickets_for_guard_stream_util");
        List<ResultObj> pending_tickets_list = [];
        return pending_tickets_list;
      }
    } catch (e) {
      print("Exception while getting pending tickets for guard stream util");
      print(e.toString());
      List<ResultObj> pending_tickets_list = [];
      return pending_tickets_list;
    }
  }

  static Future<List<ResultObj>> get_pending_tickets_for_guard(
      String location, String enter_exit) async {
    var uri = "$complete_base_url_static/guards/get_pending_tickets_for_guard";
    try {
      var response = await http.post(Uri.parse(uri),
          body: {'location': location, 'enter_exit': enter_exit});
      List<ResultObj> pending_tickets_list =
          (json.decode(response.body) as List)
              .map((i) => ResultObj.fromJson1(i))
              .toList();

      if (response.statusCode == 200) {
        return pending_tickets_list;
      } else {
        print("Server Error in get_pending_tickets_for_guard");
        List<ResultObj> pending_tickets_list = [];
        return pending_tickets_list;
      }
    } catch (e) {
      print("Exception while getting pending tickets for guard$e");
      List<ResultObj> pending_tickets_list = [];
      return pending_tickets_list;
    }
  }

  // To get visitor tickets on the guard side
  static Future<List<ResultObj4>> get_pending_tickets_for_visitors(
      String enter_exit) async {
    var uri =
        "$complete_base_url_static/visitors/get_pending_tickets_for_visitors";
    try {
      var response =
          await http.post(Uri.parse(uri), body: {'enter_exit': enter_exit});

      List<ResultObj4> pending_tickets_list =
          (json.decode(response.body) as List)
              .map((i) => ResultObj4.fromJson2(i))
              .toList();

      if (response.statusCode == 200) {
        return pending_tickets_list;
      } else {
        print("Server Error in get_pending_tickets_for_visitors");
        List<ResultObj4> pending_tickets_list = [];
        return pending_tickets_list;
      }
    } catch (e) {
      print("Exception in get_pending_tickets_for_visitors: $e");
      List<ResultObj4> pending_tickets_list = [];
      return pending_tickets_list;
    }
  }

  // To get pending visitor tickets on the authority side
  static Future<List<ResultObj4>> get_pending_visitor_tickets_for_authorities(
      String authority_email) async {
    var uri =
        "$complete_base_url_static/visitors/get_pending_visitor_tickets_for_authorities";
    try {
      var response = await http
          .post(Uri.parse(uri), body: {'authority_email': authority_email});
      List<ResultObj4> pending_tickets_list =
          (json.decode(response.body) as List)
              .map((i) => ResultObj4.fromJson2(i))
              .toList();
      if (response.statusCode == 200) {
        return pending_tickets_list;
      } else {
        print("Server Error in get_pending_visitor_tickets_for_authorities");
        List<ResultObj4> pending_tickets_list = [];
        return pending_tickets_list;
      }
    } catch (e) {
      print("Exception in get_pending_visitor_tickets_for_authorities: $e");
      List<ResultObj4> pending_tickets_list = [];
      return pending_tickets_list;
    }
  }

  // To get past visitor tickets on the authority side
  static Future<List<ResultObj4>> get_past_visitor_tickets_for_authorities(
      String authority_email) async {
    var uri =
        "$complete_base_url_static/visitors/get_past_visitor_tickets_for_authorities";
    try {
      var response = await http
          .post(Uri.parse(uri), body: {'authority_email': authority_email});
      List<ResultObj4> pending_tickets_list =
          (json.decode(response.body) as List)
              .map((i) => ResultObj4.fromJson2(i))
              .toList();

      if (response.statusCode == 200) {
        return pending_tickets_list;
      } else {
        print("Server Error in get_past_visitor_tickets_for_authorities");
        List<ResultObj4> pending_tickets_list = [];
        return pending_tickets_list;
      }
    } catch (e) {
      print("Exception in get_past_visitor_tickets_for_authorities: $e");
      List<ResultObj4> pending_tickets_list = [];
      return pending_tickets_list;
    }
  }

  static Future<List<ResultObj2>> get_pending_tickets_for_authorities(
      String authority_email) async {
    var uri =
        "$complete_base_url_static/authorities/get_pending_tickets_for_authorities";
    try {
      var response = await http
          .post(Uri.parse(uri), body: {'authority_email': authority_email});
      List<ResultObj2> pending_tickets_list =
          (json.decode(response.body) as List)
              .map((i) => ResultObj2.fromJson1(i))
              .toList();

      if (response.statusCode == 200) {
        return pending_tickets_list;
      } else {
        print("Server Error in get_pending_tickets_for_authorities");
        List<ResultObj2> pending_tickets_list = []; // return empty list
        return pending_tickets_list;
      }
    } catch (e) {
      print("Exception while get_pending_tickets_for_authorities");
      print("The exception is $e");
      List<ResultObj2> pending_tickets_list = []; // return empty list
      return pending_tickets_list;
    }
  }

  static Stream<List<ResultObj>> get_tickets_for_guard_stream(
          String location, String is_approved, String enter_exit) =>
      Stream.periodic(Duration(seconds: REFRESH_RATE)).asyncMap((_) =>
          get_tickets_for_guard_stream_util(location, is_approved, enter_exit));

  static Future<List<ResultObj>> get_tickets_for_guard_stream_util(
      String location, String is_approved, String enter_exit) async {
    var uri = "$complete_base_url_static/guards/get_tickets_for_guard";

    try {
      var response = await http.post(Uri.parse(uri), body: {
        'location': location,
        'is_approved': is_approved,
        'enter_exit': enter_exit
      });

      List<ResultObj> tickets_list = (json.decode(response.body) as List)
          .map((i) => ResultObj.fromJson1(i))
          .toList();

      if (response.statusCode == 200) {
        return tickets_list;
      } else {
        print("Server Error in get_tickets_for_guard_stream_util");
        List<ResultObj> tickets_list = [];
        return tickets_list;
      }
    } catch (e) {
      print("Exception while get_tickets_for_guard_stream_util");
      print(e.toString());
      List<ResultObj> tickets_list = [];
      return tickets_list;
    }
  }

  static Stream<List<ResultObj2>> get_tickets_for_authorities_stream(
          String authority_email, String is_approved) =>
      Stream.periodic(Duration(seconds: REFRESH_RATE)).asyncMap((_) =>
          get_tickets_for_authorities_stream_util(
              authority_email, is_approved));

  static Future<List<ResultObj2>> get_tickets_for_authorities_stream_util(
      String authority_email, String is_approved) async {
    var uri =
        "$complete_base_url_static/authorities/get_tickets_for_authorities";
    try {
      var response = await http.post(Uri.parse(uri), body: {
        'authority_email': authority_email,
        'is_approved': is_approved
      });

      List<ResultObj2> tickets_list = (json.decode(response.body) as List)
          .map((i) => ResultObj2.fromJson1(i))
          .toList();

      if (response.statusCode == 200) {
        return tickets_list;
      } else {
        print("Server Error in get_tickets_for_authorities_stream_util");
        List<ResultObj2> tickets_list = [];
        return tickets_list;
      }
    } catch (e) {
      List<ResultObj2> tickets_list = [];
      return tickets_list;
    }
  }

  static Future<List<ResultObj>> get_tickets_for_guard(
      String location, String is_approved, String enter_exit) async {
    var uri = "$complete_base_url_static/guards/get_tickets_for_guard";
    try {
      var response = await http.post(Uri.parse(uri), body: {
        'location': location,
        'is_approved': is_approved,
        'enter_exit': enter_exit
      });
      List<ResultObj> tickets_list = (json.decode(response.body) as List)
          .map((i) => ResultObj.fromJson1(i))
          .toList();

      if (response.statusCode == 200) {
        return tickets_list;
      } else {
        print("Server Error in get_tickets_for_guard");
        List<ResultObj> tickets_list = [];
        return tickets_list;
      }
    } catch (e) {
      print("Exception while getting tickets for guard");
      print("error in get students=${e.toString()}");
      List<ResultObj> tickets_list = [];
      return tickets_list;
    }
  }

  static Future<bool> markLocationEmpty(String location) async {
    try {
      final response = await http.post(
        Uri.parse('$complete_base_url_static/guards/mark_location_empty'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'location': location}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error marking location empty: $e');
      return false;
    }
  }

  static Future<List<ReadTableObject>> get_data_for_admin(
      String table_name) async {
    var uri = complete_base_url_static;
    if (table_name == 'Student') {
      uri = "$uri/students/get_all_students";
    } else if (table_name == 'Guard') {
      uri = "$uri/guards/get_all_guards";
    } else if (table_name == 'Admins') {
      uri = "$uri/admins/get_all_admins";
    } else if (table_name == 'Locations') {
      uri = "$uri/locations/view_all_locations";
    } else if (table_name == 'Hostels') {
      uri = "$uri/hostels/get_all_hostels";
    } else if (table_name == 'Authorities') {
      uri = "$uri/authorities/get_all_authorites";
    } else if (table_name == 'Departments') {
      uri = "$uri/departments/get_all_departments";
    } else if (table_name == 'Programs') {
      uri = "$uri/programs/get_all_programs";
    }
    try {
      var response = await http.post(Uri.parse(uri));
      List<ReadTableObject> tickets_list =
          (json.decode(response.body)['output'] as List)
              .map((i) => ReadTableObject.fromJson1(i))
              .toList();

      if (response.statusCode == 200) {
        return tickets_list;
      } else {
        print("Server Error in get_data_for_admin_tables_stream_util");
        List<ReadTableObject> tickets_list = [];
        return tickets_list;
      }
    } catch (e) {
      print("Exception while get_data_for_admin_tables_stream_util");
      print(e.toString());
      List<ReadTableObject> tickets_list = [];
      return tickets_list;
    }
  }

  static Stream<List<ReadTableObject>> get_data_for_admin_tables_stream(
          String table_name) =>
      Stream.periodic(Duration(seconds: REFRESH_RATE))
          .asyncMap((_) => get_data_for_admin_tables_stream_util(table_name));

  static Future<List<ReadTableObject>> get_data_for_admin_tables_stream_util(
      String table_name) async {
    var uri = complete_base_url_static;
    if (table_name == 'Student') {
      uri = "$uri/students/get_all_students";
    } else if (table_name == 'Guard') {
      uri = "$uri/guards/get_all_guards";
    } else if (table_name == 'Admins') {
      uri = "$uri/admins/get_all_admins";
    } else if (table_name == 'Locations') {
      uri = "$uri/locations/view_all_locations";
    } else if (table_name == 'Hostels') {
      uri = "$uri/hostels/get_all_hostels";
    } else if (table_name == 'Authorities') {
      uri = "$uri/authorities/get_all_authorites";
    } else if (table_name == 'Departments') {
      uri = "$uri/departments/get_all_departments";
    } else if (table_name == 'Programs') {
      uri = "$uri/programs/get_all_programs";
    }
    try {
      var response = await http.post(Uri.parse(uri));
      List<ReadTableObject> tickets_list =
          (json.decode(response.body)['output'] as List)
              .map((i) => ReadTableObject.fromJson1(i))
              .toList();

      if (response.statusCode == 200) {
        return tickets_list;
      } else {
        print("Server Error in get_data_for_admin_tables_stream_util");
        List<ReadTableObject> tickets_list = [];
        return tickets_list;
      }
    } catch (e) {
      print("Exception while get_data_for_admin_tables_stream_util");
      print(e.toString());
      List<ReadTableObject> tickets_list = [];
      return tickets_list;
    }
  }

  static Future<List<ResultObj2>> get_tickets_for_authorities(
      String authority_email, String is_approved) async {
    var uri =
        "$complete_base_url_static/authorities/get_tickets_for_authorities";
    try {
      var response = await http.post(Uri.parse(uri), body: {
        'authority_email': authority_email,
        'is_approved': is_approved
      });

      List<ResultObj2> tickets_list = (json.decode(response.body) as List)
          .map((i) => ResultObj2.fromJson1(i))
          .toList();

      if (response.statusCode == 200) {
        return tickets_list;
      } else {
        print("Server Error in get_tickets_for_guard");
        List<ResultObj2> tickets_list = [];
        return tickets_list;
      }
    } catch (e) {
      List<ResultObj2> tickets_list = [];
      return tickets_list;
    }
  }

  static Stream<ResultObj3> get_student_status(String email, String location) =>
      Stream.periodic(Duration(seconds: REFRESH_RATE))
          .asyncMap((_) => get_student_status_util(email, location));

  static Future<ResultObj3> get_student_status_util(
      String email, String location) async {
    var uri = "$complete_base_url_static/students/get_student_status";
    ResultObj3 invalid = ResultObj3.constructor1("Invalid Status", "", "");
    try {
      var response = await http
          .post(Uri.parse(uri), body: {'email': email, 'location': location});
      Map<String, dynamic> data =
          json.decode(response.body) as Map<String, dynamic>;
      ResultObj3 res = ResultObj3.fromJson1(data);
      if (response.statusCode == 200) {
        return res;
      } else {
        return invalid;
      }
    } catch (e) {
      return invalid;
    }
  }

  Future<int> accept_selected_tickets(List<ResultObj> selectedTickets) async {
    var uri = "$complete_base_url_static/guards/accept_selected_tickets";
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };

    for (var ticket in selectedTickets) {
      await databaseInterface.insert_notification_guard_accept_reject(
          LoggedInDetails.getEmail(),
          ticket.email,
          ticket.ticket_type,
          ticket.location,
          "Guard has accepted your ticket");
    }

    try {
      int length = 0;
      var response = await http.post(Uri.parse(uri),
          body: jsonEncode(selectedTickets.map((i) => i.toJson1()).toList()),
          headers: headers);
      length = selectedTickets.length;

      int status_code = 0;
      if (length == 0) {
        status_code = 201;
      } else if (length > 0) {
        status_code = response.statusCode.toInt();
      } else {
        status_code = 500;
      }

      return status_code;
    } catch (e) {
      print("Request to accepted selected tickets failed .. ");
      print(e.toString());
      return 500;
    }
  }

  Future<int> accept_selected_tickets_visitors(
      List<ResultObj4> selectedTickets_visitors) async {
    var uri =
        "$complete_base_url_static/visitors/accept_selected_tickets_visitors";
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };
    try {
      int length = 0;
      var response = await http.post(Uri.parse(uri),
          body: jsonEncode(
              selectedTickets_visitors.map((i) => i.toJson1()).toList()),
          headers: headers);
      length = selectedTickets_visitors.length;

      int status_code = 0;
      if (length == 0) {
        status_code = 201;
      } else if (length > 0) {
        status_code = response.statusCode.toInt();
      } else {
        status_code = 500;
      }
      return status_code;
    } catch (e) {
      print("Request to accepted selected tickets for visitors failed .. ");
      print(e.toString());
      return 500;
    }
  }

  Future<int> accept_selected_tickets_authorities(
      List<ResultObj2> selectedTickets) async {
    var uri =
        "$complete_base_url_static/authorities/accept_selected_tickets_authorities";
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };

    for (var ticket in selectedTickets) {
      await databaseInterface.insert_notification_guard_accept_reject(
          LoggedInDetails.getEmail(),
          ticket.email,
          ticket.ticket_type,
          ticket.location,
          ticket.authority_message);
    }

    try {
      int length = 0;

      var response = await http.post(Uri.parse(uri),
          body: jsonEncode(selectedTickets.map((i) => i.toJson1()).toList()),
          headers: headers);
      length = selectedTickets.length;

      int status_code = 0;
      if (length == 0) {
        status_code = 201;
      } else if (length > 0) {
        status_code = response.statusCode.toInt();
      } else {
        status_code = 500;
      }

      return status_code;
    } catch (e) {
      print("Request to accepted selected tickets by authorities failed .. ");
      print("The exception is: $e");
      return 500;
    }
  }

  Future<int> reject_selected_tickets(List<ResultObj> selectedTickets) async {
    var uri = "$complete_base_url_static/guards/reject_selected_tickets";
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };

    for (var ticket in selectedTickets) {
      await databaseInterface.insert_notification_guard_accept_reject(
          LoggedInDetails.getEmail(),
          ticket.email,
          ticket.ticket_type,
          ticket.location,
          "Guard has rejected your ticket");
    }
    try {
      int length = 0;
      var response = await http.post(Uri.parse(uri),
          body: jsonEncode(selectedTickets.map((i) => i.toJson1()).toList()),
          headers: headers);
      length = selectedTickets.length;
      int status_code = 0;
      if (length == 0) {
        status_code = 201;
      } else if (length > 0) {
        status_code = response.statusCode.toInt();
      } else {
        status_code = 500;
      }
      return status_code;
    } catch (e) {
      print("Request to reject selected tickets failed .. ");
      print(e.toString());
      return 500;
    }
  }

  Future<int> reject_selected_tickets_visitors(
      List<ResultObj4> selectedTickets) async {
    var uri =
        "$complete_base_url_static/visitors/reject_selected_tickets_visitors";
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };
    try {
      int length = 0;
      var response = await http.post(Uri.parse(uri),
          body: jsonEncode(selectedTickets.map((i) => i.toJson1()).toList()),
          headers: headers);
      length = selectedTickets.length;
      int status_code = 0;
      if (length == 0) {
        status_code = 201;
      } else if (length > 0) {
        status_code = response.statusCode.toInt();
      } else {
        status_code = 500;
      }
      return status_code;
    } catch (e) {
      print("Request to reject selected tickets for visitors failed .. ");
      print(e.toString());
      return 500;
    }
  }

  Future<int> reject_selected_tickets_authorities(
      List<ResultObj2> selectedTickets) async {
    var uri =
        "$complete_base_url_static/authorities/reject_selected_tickets_authorities";
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };

    for (var ticket in selectedTickets) {
      await databaseInterface.insert_notification_guard_accept_reject(
          LoggedInDetails.getEmail(),
          ticket.email,
          ticket.ticket_type,
          ticket.location,
          ticket.authority_message);
    }

    try {
      int length = 0;
      var response = await http.post(Uri.parse(uri),
          body: jsonEncode(selectedTickets.map((i) => i.toJson1()).toList()),
          headers: headers);
      length = selectedTickets.length;

      int status_code = 0;
      if (length == 0) {
        status_code = 201;
      } else if (length > 0) {
        status_code = response.statusCode.toInt();
      } else {
        status_code = 500;
      }

      return status_code;
    } catch (e) {
      print("reject_selected_tickets_authorities raised exception: $e");
      return 500;
    }
  }

  static Future<User> get_student_by_email(String? email_) async {
    var uri = "$complete_base_url_static/students/get_student_by_email";
    try {
      // 1. Add timeout to prevent hanging
      final response = await makeAuthenticatedRequest(
        Uri.parse(uri),
        HttpMethod.POST,
        body: {"email": email_},
      ).timeout(const Duration(seconds: 5));

      // 2. Move JSON parsing and image decoding to a background isolate
      final processedData = await compute(_parseUserData, response.body);
      
      return User(
        profileImage: MemoryImage(processedData.bytes),
        imagePath: processedData.data["image_path"],
        name: processedData.data["name"],
        email: processedData.data["email"],
        phone: processedData.data['mobile_no'],
        degree: processedData.data['degree'],
        department: processedData.data['department'],
        year_of_entry: processedData.data['year_of_entry'],
        gender: processedData.data['gender'],
        isDarkMode: true,
      );
    } catch (e) {
      print("Error in get_student_by_email: $e");
      return UserPreferences.myUser; // Fallback
    }
  }

  // Helper function to run in isolate
  static _UserData _parseUserData(String responseBody) {
    final data = jsonDecode(responseBody);
    return _UserData(
      data,
      base64.decode(data["profile_img"]),
    );
  }


  static Future<String> get_parent_location_name(String location) async {
    var uri = "$complete_base_url_static/locations/get_parent_location_name";
    try {
      var response =
          await http.post(Uri.parse(uri), body: {"location": location});

      var data = json.decode(response.body);

      return data['parent_location'];
    } catch (e) {
      return "";
    }
  }

  Future<GuardUser> get_guard_by_email(String? email_) async {
    var uri = "$complete_base_url_static/guards/get_guard_by_email";
    try {
      var response = await http.post(Uri.parse(uri), body: {"email": email_});
      var data = json.decode(response.body);
      String img_base_url = complete_base_url_static;
      GuardUser user = GuardUser(
        imagePath: img_base_url + data['profile_img'],
        name: data["name"],
        email: data["email"],
        location: data['location'],
        isDarkMode: true,
      );
      return user;
    } catch (e) {
      print("post request error");
      print(e.toString());
      GuardUser user = UserPreferences.myGuardUser;
      return user;
    }
  }

  Future<AdminUser> get_admin_by_email(String? email_) async {
    var uri = "$complete_base_url_static/admins/get_admin_by_email";
    try {
      var response = await http.post(Uri.parse(uri), body: {"email": email_});
      var data = json.decode(response.body);
      String img_base_url = complete_base_url_static;
      AdminUser user = AdminUser(
        imagePath: img_base_url + data['profile_img'],
        name: data["name"],
        email: data["email"],
        isDarkMode: true,
      );
      return user;
    } catch (e) {
      print("post request error");
      print(e.toString());
      AdminUser user = UserPreferences.myAdminUser;
      return user;
    }
  }

  Future<AuthorityUser> get_authority_by_email(String? email_) async {
    var uri = "$complete_base_url_static/authorities/get_authority_by_email";
    try {
      var response = await http.post(Uri.parse(uri), body: {"email": email_});
      var data = json.decode(response.body);
      String img_base_url = complete_base_url_static;
      AuthorityUser user = AuthorityUser(
        imagePath: img_base_url + data['profile_img'],
        name: data["name"],
        email: data["email"],
        designation: data['designation'],
        isDarkMode: true,
      );
      return user;
    } catch (e) {
      print("post request error");
      print(e.toString());
      AuthorityUser user = UserPreferences.myAuthorityUser;
      return user;
    }
  }

  static Future<String> add_new_location(
      String new_location_name,
      String chosen_parent_location,
      String chosen_pre_approval_needed,
      String automatic_exit_required) async {
    var uri = "$complete_base_url_static/locations/add_new_location";
    try {
      var response = await http.post(Uri.parse(uri), body: {
        'new_location_name': new_location_name,
        'chosen_parent_location': chosen_parent_location,
        'chosen_pre_approval_needed': chosen_pre_approval_needed,
        'automatic_exit_required': automatic_exit_required
      });
      if (response.statusCode == 200) {
        return "New location added successfully";
      } else {
        return "Failed to add new location";
      }
    } catch (e) {
      return "Failed to add new location";
    }
  }

  static Future<String> modify_locations(
      String chosen_modify_location,
      String chosen_parent_location,
      String chosen_pre_approval_needed,
      String automatic_exit_required) async {
    var uri = "$complete_base_url_static/locations/modify_locations";
    try {
      var response = await http.post(Uri.parse(uri), body: {
        'chosen_modify_location': chosen_modify_location,
        'chosen_parent_location': chosen_parent_location,
        'chosen_pre_approval_needed': chosen_pre_approval_needed,
        'automatic_exit_required': automatic_exit_required
      });
      if (response.statusCode == 200) {
        return "Location updated successfully";
      } else {
        return response.body.toString();
      }
    } catch (e) {
      return "Failed to update location data";
    }
  }

  static Future<String> delete_location(String chosen_delete_location) async {
    var uri = "$complete_base_url_static/locations/delete_location";
    try {
      var response = await http.post(Uri.parse(uri), body: {
        'chosen_delete_location': chosen_delete_location,
      });
      if (response.statusCode == 200) {
        return "Location deleted successfully";
      } else {
        return response.body.toString();
      }
    } catch (e) {
      return "Failed to delete location";
    }
  }

  Future<void> send_file(Uint8List? chosen_file, String route) async {
    var uri = complete_base_url_static + route;
    var url = Uri.parse(uri);
    if (chosen_file != null) {
      List<int> iterable_data = chosen_file;

      try {
        var request = http.MultipartRequest("POST", url);
        request.files.add(http.MultipartFile.fromBytes('file', iterable_data,
            contentType: MediaType('application', 'octet-stream'),
            filename: 'file.csv'));

        request.send().then((response) {
          print(response.statusCode);
        });
      } catch (e) {
        print("post request error");
        print(e.toString());
      }
    }
  }

  static Future<void> send_image(
      XFile chosen_file, String route, String email) async {
    String uri = complete_base_url_static + route;
    var url = Uri.parse(uri);
    File img_file = File(chosen_file.path);
    List<int> iterable_data = await chosen_file.readAsBytes();
    try {
      var request = http.MultipartRequest("POST", url);
      request.fields['email'] = email;
      request.files.add(http.MultipartFile.fromBytes('image', iterable_data,
          contentType: MediaType('image', 'jpg'), filename: 'image_file.jpg'));
      var response = await request.send();
    } catch (e) {
      print("post request error");
      print(e.toString());
    }
  }

  static Future<String> add_guard(
      String name, String email, String location) async {
    String uri = "$complete_base_url_static/forms/add_guard_form";
    try {
      var response = await http.post(Uri.parse(uri), body: {
        'name': name,
        'email': email,
        'location_name': location,
      });
      return response.body.toString();
    } catch (e) {
      return "Failed to add guard";
    }
  }

  static Future<String> add_admin_form(String name, String email) async {
    String uri = "$complete_base_url_static/forms/add_admin_form";
    try {
      var response = await http.post(Uri.parse(uri), body: {
        'name': name,
        'email': email,
      });
      return response.body.toString();
    } catch (e) {
      print("Exception in add_admin_form: $e");
      return "Failed to add admin";
    }
  }

  static Future<String> modify_guard(String email, String location) async {
    String uri = "$complete_base_url_static/forms/modify_guard_form";
    try {
      var response = await http.post(Uri.parse(uri), body: {
        'email': email,
        'location_name': location,
      });
      return response.body.toString();
    } catch (e) {
      return "Failed to add guard";
    }
  }

  static Future<String> delete_guard(String email) async {
    String uri = "$complete_base_url_static/forms/delete_guard_form";
    try {
      var response = await http.post(Uri.parse(uri), body: {
        'email': email,
      });
      return response.body.toString();
    } catch (e) {
      return "Failed to add guard";
    }
  }

  static Future<List<StatisticsResultObj>> get_statistics_data_by_location(
      String location, String filter, String status) async {
    var uri =
        "$complete_base_url_static/statistics/get_statistics_data_by_location";
    try {
      var response = await http.post(Uri.parse(uri),
          body: {"location": location, "filter": filter, "status": status});
      var data = json.decode(response.body);
      List<StatisticsResultObj> res = [];
      for (var each_data_object in data['output']) {
        StatisticsResultObj statisticsResultObj = StatisticsResultObj(
            each_data_object['category'], each_data_object['count']);
        res.add(statisticsResultObj);
      }
      return res;
    } catch (e) {
      List<StatisticsResultObj> res = [];
      print(e);
      return res;
    }
  }

  static Future<List<StatisticsResultObj>> get_piechart_statistics_by_location(
      String location,
      String filter,
      String start_date,
      String end_date) async {
    var uri =
        "$complete_base_url_static/statistics/get_piechart_statistics_by_location";

    try {
      var response = await http.post(Uri.parse(uri), body: {
        "location": location,
        "filter": filter,
        "start_date": start_date,
        "end_date": end_date
      });
      var data = json.decode(response.body);
      List<StatisticsResultObj> res = [];
      for (var each_data_object in data['output']) {
        StatisticsResultObj statisticsResultObj = StatisticsResultObj(
            each_data_object['category'], each_data_object['count']);
        res.add(statisticsResultObj);
      }
      return res;
    } catch (e) {
      List<StatisticsResultObj> res = [];
      print(e);
      return res;
    }
  }

  // This is used to raise a ticket for the first time using the addVisitors button
  static Future<int> insert_in_visitors_ticket_table(
      String visitor_name,
      String mobile_no,
      String car_number,
      String authority_name,
      String authority_email,
      String authority_designation,
      String purpose,
      String ticket_type,
      String duration_of_stay,
      String num_additional,
      String student_id) async {
    var uri =
        "$complete_base_url_static/visitors/insert_in_visitors_ticket_table";
    try {
      var response = await http.post(
        Uri.parse(uri),
        body: {
          'visitor_name': visitor_name,
          'mobile_no': mobile_no,
          'car_number': car_number,
          'authority_name': authority_name,
          'authority_email': authority_email,
          'authority_designation': authority_designation,
          'purpose': purpose,
          'ticket_type': ticket_type,
          'duration_of_stay': duration_of_stay,
          'num_additional': num_additional,
          'student_email': student_id,
          'type': 'student',
          'guard_status': "Approved"
        },
      );
      var data = json.decode(response.body);
      var data_map = data["output"] as Map<String, dynamic>;
      bool status = data_map['status'];
      String message = data_map['message'];
      return response.statusCode.toInt();
    } catch (e) {
      print("Exception in insert_in_visitors_ticket_table: $e");
      return 500;
    }
  }

  // This is used to update the authority status of a visitor ticket
  static Future<int> insert_in_visitors_ticket_table_2(
    String authority_status,
    ResultObj4 ticket_visitor,
  ) async {
    var uri =
        "$complete_base_url_static/visitors/insert_in_visitors_ticket_table_2";
    try {
      String visitor_ticket_id = ticket_visitor.visitor_ticket_id.toString();
      String authority_message = ticket_visitor.authority_message;
      var response = await http.post(
        Uri.parse(uri),
        body: {
          'authority_status': authority_status,
          'visitor_ticket_id': visitor_ticket_id,
          'authority_message': authority_message,
        },
      );
      var data = json.decode(response.body);
      var data_map = data["output"] as Map<String, dynamic>;
      bool status = data_map['status'];
      String message = data_map['message'];
      return response.statusCode.toInt();
    } catch (e) {
      print("Exception in insert_in_visitors_ticket_table: $e");
      return 500;
    }
  }
  
  static Map<String, dynamic> _parseJson(String jsonString) {
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }


  static Future<Map<String, dynamic>> get_student_status_for_all_locations_2(
    String email, 
    List<int> location_ids,
  ) async {
    var uri = "$complete_base_url_static/students/get_status_for_all_locations";
    //TODO: Avoid hardcoding this map.
    const _errorMap = {
      'CS Block': 'ERROR', 
      'Lab 101': 'ERROR',
      'Lab 102': 'ERROR',
      'Lab 202': 'ERROR',
      'Lab 203': 'ERROR',
    };

    try {
      final response = await makeAuthenticatedRequest(
        Uri.parse(uri),
        HttpMethod.POST,
        body: {
          'email': email,
          'location_ids': json.encode(location_ids),
        },
      ).timeout(Duration(seconds: 5));

      if (response.statusCode != 200) return _errorMap;
      return await compute(_parseJson, response.body); // Parse in background
    } catch (e) {
      print("get_student_status error: $e");
      return _errorMap;
    }
  }

  static Future<int> count_inside_Location(int loc_id) async {
    int location_id = loc_id;

    var uri = '$complete_base_url_static/students/get_location_count/';
    try {
      var response = await http.get(
        Uri.parse('$uri?location_id=$location_id'),
      );
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        int in_count = data['in_count'];
        return in_count;
      } else {
        print("Error occured while fetching the data from backend");
        return -1;
      }
    } catch (e) {
      print("Exception in insert_in_visitors_ticket_table: $e");
      return -1;
    }
  }

  static Future<bool> update_number(String number, String email) async {
    var uri = '$complete_base_url_static/students/update_phone_number/';
    try {
      var response = await http.post(
        Uri.parse(uri),
        body: {'phone_number': number, 'email': email},
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  static Future<int> get_guard_notifications(
      String email, String location, String ticket_type) async {
    var uri = Uri.parse(
        "$complete_base_url_static/locations/get_guard_at_a_location/");
    var uri_noti =
        "$complete_base_url_static/notification/insert_notification/";
    try {
      var response = await http.get(
          uri.replace(queryParameters: {"email": email, "location": location}));
      var response_noti = await http.post(Uri.parse(uri_noti), body: {
        'from_whom': email,
        'for_whom': json.decode(response.body)['guard_id'].toString(),
        'ticket_type': ticket_type,
        'location_id': json.decode(response.body)['loc_id'].toString(),
        'display_message': 'Student is asking for a ticket'
      });
    } catch (e) {
      print(e.toString());
    }
    return 0;
  }

  static Future<void> insert_notification(String from_whom, String for_whom,
      String ticket_type, String location, String message) async {
    var uri = "$complete_base_url_static/notification/insert_notification/";
    try {
      var response_noti = await http.post(Uri.parse(uri), body: {
        'from_whom': from_whom,
        'for_whom': for_whom,
        'ticket_type': ticket_type,
        'location': location,
        'display_message': message
      });
      if (response_noti.statusCode != 200) {
        print("There is an error=${response_noti.statusCode}");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  static Future<void> insert_notification_guard_accept_reject(
      String from_whom,
      String for_whom,
      String ticket_type,
      String location,
      String message) async {
    var uri =
        "$complete_base_url_static/notification/insert_notification_guard_accept_reject/";
    try {
      //post request
      var response_noti = await http.post(Uri.parse(uri), body: {
        'from_whom': from_whom,
        'for_whom': for_whom,
        'ticket_type': ticket_type,
        'location': location,
        'display_message': message
      });
      if (response_noti.statusCode != 200) {
        print("There is an error=${response_noti.statusCode}");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  static Future<int> return_total_notification_count_guard(String email) async {
    const timeout = Duration(seconds: 3); // Fail fast
    try {
      final uri = Uri.parse("$complete_base_url_static/notification/count_notification/")
          .replace(queryParameters: {"email": email});
      
      final response = await http.get(uri).timeout(timeout);
      return jsonDecode(response.body)['count'] as int; // Explicit type cast
    } catch (e) {
      print("Notification count fetch failed: $e");
      return 0; // Fallback value
    }
  }

  static Future<void> mark_stakeholder_notification_as_false(
      String email) async {
    var uri =
        "$complete_base_url_static/notification/mark_notification_as_false/";
    try {
      var response = await http.post(
        Uri.parse(uri),
        body: {'email': email},
      );
      if (response.statusCode != 200) {
        print("There is an error.");
      } else {}
    } catch (e) {
      print(e.toString());
    }
  }

  static Future<String> loc_from_loc_id(String loc_id) async {
    var uri = Uri.parse("$complete_base_url_static/location/loc_from_loc_id/");
    try {
      var response =
          await http.get(uri.replace(queryParameters: {"loc_id": loc_id}));
      return json.decode(response.body)['loc_name'];
    } catch (e) {}
    return "";
  }

  static Future<List<List<String>>> fetch_notification_guard(
      String email) async {
    List<List<String>> messages = [];
    var uri = Uri.parse(
        "$complete_base_url_static/notification/fetch_notification_guard/");
    try {
      var response =
          await http.get(uri.replace(queryParameters: {"email": email}));
      var data = json.decode(response.body)['data'];
      if (response.statusCode != 200) {
        print("There is an error.");
      } else {
        for (var item in data) {
          List<String> notification = [];
          notification.add(item['ticket_id'].toString());
          notification.add(item['from_whom'].toString());
          String loc_name =
              await loc_from_loc_id(item['location_id'].toString());
          notification.add(loc_name);
          notification.add(item['display_message'].toString());
          notification.add(item['date_time'].toString());
          notification.add(item['ticket_type'].toString());
          messages.add(notification);
        }
      }
    } catch (e) {
      print(e.toString());
    }

    return messages;
  }

  static Future<void> mark_individual_notification(
      String ticket_id, String email) async {
    var uri =
        "$complete_base_url_static/notification/mark_individual_notification/";
    try {
      var response = await http.post(
        Uri.parse(uri),
        body: {'tick_id': ticket_id, 'email': email},
      );
      if (response.statusCode != 200) {
        print("There is an error.");
      } else {}
    } catch (e) {
      print("database interface error************");
      print(e.toString());
    }
  }

  static Future<void> insert_qr_ticket(
      String email,
      String status,
      String vehicle_reg_num,
      String ticket_type,
      String date_time,
      String destination_addr,
      String location_name,
      String guard_email) async {
    var uri = "$complete_base_url_static/guards/insert_in_guard_ticket_table";
    try {
      var response = await http.post(
        Uri.parse(uri),
        body: {
          'email': email,
          'status': status,
          'vehicle_reg_num': vehicle_reg_num,
          'ticket_type': ticket_type,
          'date_time': date_time,
          // 'destination_addr': destination_addr,
          'address': destination_addr,
          // 'location_name': location_name,
          'location': location_name,
          'guard_email': guard_email,
          'choosen_authority_ticket': "",
        },
      );
      if (response.statusCode != 200) {
        print("There is an error.");
      } else {}
    } catch (e) {
      print("database interface error************");
      print(e.toString());
    }
  }

  static Future<void> accept_generated_QR(
      String location,
      String student_selected_location,
      String is_approved,
      String ticket_type,
      String date_time,
      String st_email) async {
    ResultObj myobj = ResultObj();
    myobj.location = location;
    myobj.is_approved = is_approved;
    myobj.ticket_type = ticket_type;
    myobj.date_time = date_time;
    myobj.email = st_email;
    myobj.student_name = "No student name";
    myobj.authority_status = "NO AUTH STATUS";
    myobj.destination_address = student_selected_location;
    myobj.vehicle_number = "PB XX";

    List<ResultObj> selectedTickets = [];
    selectedTickets.add(myobj);
    if (is_approved == "Approved") {
      await databaseInterface().accept_selected_tickets(selectedTickets);
    } else if (is_approved == "Rejected") {
      await databaseInterface().reject_selected_tickets(selectedTickets);
    } else {
      print("NO Accepted Or Rejected ");
    }
  }

  static Future<List<ResultObj4>> return_entry_visitor_approved_ticket(
      String location, String is_approved, String enter_exit) async {
    var uri = Uri.parse("$complete_base_url_static/guards/get_visitor_tickets");
    try {
      var response = await http.post(uri,
          body: {"is_approved": is_approved, "enter_exit": enter_exit});
      List<ResultObj4> tickets_list = (json.decode(response.body) as List)
          .map((i) => ResultObj4.fromJson2(i))
          .toList();
      if (response.statusCode == 200) {
        return tickets_list;
      } else {
        print("Server Error in get_tickets_for_guard");
        List<ResultObj4> tickets_list = [];
        return tickets_list;
      }
    } catch (e) {
      print("Exception while getting tickets for guard");
      print(e.toString());
      List<ResultObj4> tickets_list = [];
      return tickets_list;
    }
  }

  static Future<List<String>> get_students_list_for_visitors() async {
    var url = "$complete_base_url_static/students/get_all_students";
    try {
      var response = await http.post(Uri.parse(url));

      var data = json.decode(response.body)['output'];
      List<String> res = [];
      for (var i = 0; i < data.length; i++) {
        String obj = data[i]['name'] +
            ", " +
            data[i]['email'] +
            ", " +
            data[i]['mobile_no'];
        res.add(obj);
      }
      return res;
    } catch (e) {
      print("error in getting student= $e");
      List<String> res = [];
      return res;
    }
  }

  static Stream<int> get_notification_count_stream(String email) {
    // Emit 0 immediately, then periodic updates
    return Stream.fromIterable([0]).asyncExpand(
      (_) => Stream.periodic(Duration(seconds: REFRESH_RATE * 5))
          .asyncMap((_) => return_total_notification_count_guard(email))
          .handleError((e) => print("Stream error: $e"))
    );
  }

  static Future<String> jwt_login(String email, String password) async {
    var url = "$complete_base_url_static/login";
    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        // Parse response body
        final Map<String, dynamic> data = json.decode(response.body);
        final String accessToken = data['access_token'];
        final String refreshToken = data['refresh_token'];
        final String type = data['type'];

        // Save tokens to shared preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', accessToken);
        await prefs.setString('refresh_token', refreshToken);
        await prefs.setString('email', email);
        await prefs.setString('type', type);
        LoggedInDetails.setEmail(email);
        myglobals.auth!.login();
        return ("Login Successful");
      } else {
        // Handle error

        final Map<String, dynamic> data = json.decode(response.body);
        print("Error at backend: ${data['error']}");
        return data['error'] ?? "Login Failed";
      }
    } catch (e) {
      print("Error while logging in, these error was catched at frontend");
      print("ERROR : ${e.toString()}");
      return "Login Failed";
    }
  }

  Future<int> GenerateRelativesTicket(
    String Student,
    String Name,
    String Relationship,
    String Contact,
    String Purpose,
    String visit_date,
    String durations,
  ) async {
    var uri = "$complete_base_url_static/generate_relatives_ticket";
    try {
      var response = await http.post(
        Uri.parse(uri),
        body: {
          'student': Student,
          'invitee_name': Name,
          'invitee_relationship': Relationship,
          'invitee_contact': Contact,
          'purpose': Purpose,
          'visit_date': visit_date,
          'duration': durations,
        },
      );
      return response.statusCode.toInt();
    } catch (e) {
      print("post request error");
      print(e.toString());
      return 500;
    }
  }

  static Future<List<StuRelTicket>> GetStudentRelativeTickets(
      String student) async {
    var uri = "$complete_base_url_static/getStudentRelativeTickets";

    try {
      final response = await http.post(
        Uri.parse(uri),
        body: {
          'student': student,
        },
      );
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<StuRelTicket> result =
            data.map((item) => StuRelTicket.fromJson(item)).toList();
        return result;
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print("post request error");
      print(e.toString());
      throw Exception('Failed to load data');
    }
  }

  static Future<List<StuRelTicket>> Get_relatives_ticket_for_authority(
      String status) async {
    var uri = "$complete_base_url_static/adminTickets/status/";

    try {
      final response = await http.post(
        Uri.parse(uri),
        body: {
          'status': status,
        },
      );
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<StuRelTicket> result =
            data.map((item) => StuRelTicket.fromJson1(item)).toList();
        return result;
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print("post request error");
      print(e.toString());
      throw Exception('Failed to load data');
    }
  }

  static Future<int> accept_action_relatives_tickets_authorities(
      String ticket_id) async {
    var uri = "$complete_base_url_static/accept_ticket/";

    try {
      final response = await http.post(
        Uri.parse(uri),
        body: {
          'ticket_id': ticket_id,
        },
      );
      if (response.statusCode == 200) {
        return 200;
      } else {
        throw Exception('Failed accept ticket');
      }
    } catch (e) {
      print("post request error");
      print(e.toString());
      throw Exception('Failed to load data');
    }
  }

  static Future<int> reject_action_relatives_tickets_authorities(
      String ticket_id) async {
    var uri = "$complete_base_url_static/reject_ticket/";

    try {
      final response = await http.post(
        Uri.parse(uri),
        body: {
          'ticket_id': ticket_id,
        },
      );
      if (response.statusCode == 200) {
        return 200;
      } else {
        throw Exception('Failed reject ticket');
      }
    } catch (e) {
      print("post request error");
      print(e.toString());
      throw Exception('Failed to load data');
    }
  }

  static Stream<void> get_relative_tickets_for_authorities_stream() {
    return Stream.periodic(Duration(seconds: REFRESH_RATE), (count) {
      // Your logic to return the desired value instead of making an API call
      print('Stream emitted value $count');
    });
  }

  static Future<Map<String, String>> getInviteeRequestByTicketID(
      String ticket_id) async {
    var uri = "$complete_base_url_static/getInviteRequestByTicketID";
    try {
      final response = await http.post(Uri.parse(uri), body: {
        "ticket_id": ticket_id,
      });
      if (response.statusCode == 200) {
        Map<String, dynamic> data_ = json.decode(response.body);
        Map<String, String> data = {};
        data_.forEach((key, value) {
          data[key] = value.toString();
        });
        return data;
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print("post request error in getInviteeRequestByTicketID");
      print(e.toString());
      throw Exception('Failed to load data');
    }
  }

  static Future<int> guardCreateInviteeRecord(
      String ticket_id, String vehicle_number, String enter_exit) async {
    var uri = "$complete_base_url_static/guardCreateInviteeRecord";
    try {
      final response = await http.post(Uri.parse(uri), body: {
        "ticket_id": ticket_id,
        "vehicle_number": vehicle_number,
        "enter_exit": enter_exit,
      });
      if (response.statusCode == 200) {
        return response.statusCode;
      } else {
        print("error ${json.decode(response.body)["error"]}");
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print("post request error in getInviteeRequestByTicketID");
      print(e.toString());
      throw Exception('Failed to load data');
    }
  }

  static Future<List<InviteeRecord>> getInviteeRecords(
      String entryChoice, String statusType) async {
    String uri =
        '$complete_base_url_static/inviteeRecords?entry_choice=$entryChoice&status_type=$statusType';
    try {
      var response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        List<dynamic> responseData = json.decode(response.body);
        return responseData
            .map((json) => InviteeRecord.fromJson(json))
            .toList()
            .cast<InviteeRecord>();
      } else {
        print("Server Error in getInviteeRecords");
        return [];
      }
    } catch (e) {
      print("Exception while getting invitee records");
      print("Error: ${e.toString()}");
      return [];
    }
  }

  static Future<String?> updateInviteeRecordStatus(
      int recordId, String newStatus) async {
    String uri = '$complete_base_url_static/updateInviteeRecordStatus';
    try {
      var response = await http.post(
        Uri.parse(uri),
        body: {
          'record_id': recordId.toString(),
          'status': newStatus,
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['message'];
      } else {
        print("Server Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Exception while updating invitee record status: $e");
      return null;
    }
  }

  static Future<String> updateLocationStatus({
    required String email,
    required String newLocation,
    required String purpose,
  }) async {
    String uri =
        "$complete_base_url_static/update_location"; // Your backend endpoint
    print("VGGGGGGGGGGG");
    print(email);
    print(newLocation);
    print(purpose);

    try {
      print("NSSSSSSSSS");
      var response = await http.post(Uri.parse(uri), body: {
        'email': email,
        'new_location': newLocation,
        'purpose': purpose,
      });
      print(response.body);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        String message = data['message'];
        return message; // Assume backend sends confirmation message
      } else {
        print("Failed with status: ${response.statusCode}");
        return "Failed to update location. Try again.";
      }
    } catch (e) {
      print("Exception in updateLocationStatus: $e");
      return "Error occurred during update.";
    }
  }
 
 
  static Future<bool> checkOutLocation(
    String email,
  ) async {
    try {
      String uri = "$complete_base_url_static/student_exit";
      var response = await http.post(Uri.parse(uri), body: {
        'email': email,
      });
      
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        return true;
      } else {
        return false;
      }
    
    } catch (e) {
        print("Error occured in checkOutLocation");
        return false;
    }
  }    

  static Future<List<Map<String, dynamic>>> getCurrentStudents(
      String locationName) async {
    var url = "$complete_base_url_static/guards/get_students_in_location";
    try {
      var response = await http.post(
        Uri.parse(url),
        body: {'location': locationName},
      );
      print("VGGGGGGGG");
      var data = json.decode(response.body);
      print(data);
      return List<Map<String, dynamic>>.from(data['students']);
    } catch (e) {
      debugPrint("Error getting current students: $e");
      return [];
    }
  }
}
