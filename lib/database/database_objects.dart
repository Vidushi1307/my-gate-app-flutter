// ignore_for_file: non_constant_identifier_names, unnecessary_new


class ResultObj {
  late String location;
  late String date_time;
  late String is_approved;
  late String ticket_type;
  late String email;
  late String student_name;
  late String authority_status;
  late String destination_address;
  late String vehicle_number;
  // TODO add fields: guard_name

  ResultObj();

  ResultObj.constructor1(this.location, this.date_time, this.is_approved,
      this.ticket_type, this.email, this.student_name, this.authority_status,this.destination_address,this.vehicle_number);

  // Usage
  // 1. get_pending_tickets_for_guard
  // 2. get_tickets_for_guard
  // 3. get_tickets_for_student
  static ResultObj fromJson1(Map<String, dynamic> json_data) {
    return new ResultObj.constructor1(
        json_data['location'],
        json_data['date_time'],
        json_data['is_approved'],
        json_data['ticket_type'],
        json_data['email'],
        json_data['student_name'],
        json_data['authority_status'],
        json_data['destination_address'],
        json_data['vehicle_number']);
        

  }

  // Usage
  // 1. accept_selected_tickets
  // 2. reject_selected_tickets
  Map<String, dynamic> toJson1() {
    return {
      "location": location,
      "date_time": date_time,
      "is_approved": is_approved,
      "ticket_type": ticket_type,
      "email": email,
      "student_name": student_name,
      "authority_status": authority_status,
      "destination_address" : destination_address,
      "vehicle_number":vehicle_number,
    };
  }
}

class LoginResultObj {
  late String person_type;
  late String message;

  LoginResultObj(this.person_type, this.message);
}

class StatisticsResultObj {
  late String category;
  late int count;

  StatisticsResultObj(this.category, this.count);
}

class ResultObj2 {
  late String location;
  late String date_time;
  late String is_approved;
  late String ticket_type;
  late String email;
  late String student_name;
  late String authority_message;

  ResultObj2();

  ResultObj2.constructor1(this.location, this.date_time, this.is_approved,
      this.ticket_type, this.email, this.student_name, this.authority_message);

  // Usage
  // 1. get_pending_tickets_for_authorities
  static ResultObj2 fromJson1(Map<String, dynamic> json_data) {
    return new ResultObj2.constructor1(
        json_data['location'],
        json_data['date_time'],
        json_data['is_approved'],
        json_data['ticket_type'],
        json_data['email'],
        json_data['student_name'],
        json_data['authority_message']);
  }

  // Usage
  // 1. accept_selected_tickets
  // 2. reject_selected_tickets
  Map<String, dynamic> toJson1() {
    return {
      "location": location,
      "date_time": date_time,
      "is_approved": is_approved,
      "ticket_type": ticket_type,
      "email": email,
      "student_name": student_name,
      "authority_message": authority_message,
    };
  }
}

class LocationsAndPreApprovalsObjects {
  late List<String> locations;
  late List<int> location_id;
  late List<bool> preApprovals;

  LocationsAndPreApprovalsObjects(this.locations,this.location_id, this.preApprovals);
}

class ResultObj3 {
  late String in_or_out;
  late String inside_parent_location;
  late String exited_all_children;

  ResultObj3();

  ResultObj3.constructor1(
      this.in_or_out, this.inside_parent_location, this.exited_all_children);

  // Usage
  // 1. get_student_status
  static ResultObj3 fromJson1(Map<String, dynamic> json_data) {
    return new ResultObj3.constructor1(
      json_data['in_or_out'],
      json_data['inside_parent_location'],
      json_data['exited_all_children'],
    );
  }

  // Usage
  // 1.
  Map<String, dynamic> toJson1() {
    return {
      "in_or_out": in_or_out,
      "inside_parent_location": inside_parent_location,
      "exited_all_children": exited_all_children,
    };
  }
}

class ReadTableObject {
  late String name;
  late String entry_no;
  late String email;
  late String gender;
  late String department;
  late String degree_name;
  late String degree_duration;
  late String hostel;
  late String room_no;
  late String year_of_entry;
  late String mobile_no;
  late String profile_img;
  late String location_name;
  late String parent_location;
  late String pre_approval_required;
  late String automatic_exit_required;
  late String designation;

  ReadTableObject();

  ReadTableObject.constructor1(
      this.name,
      this.entry_no,
      this.email,
      this.gender,
      this.department,
      this.degree_name,
      this.degree_duration,
      this.hostel,
      this.room_no,
      this.year_of_entry,
      this.mobile_no,
      this.profile_img,
      this.location_name,
      this.parent_location,
      this.pre_approval_required,
      this.automatic_exit_required,
      this.designation);

  static ReadTableObject fromJson1(Map<String, dynamic> json_data) {
    return new ReadTableObject.constructor1(
      json_data['name'],
      json_data['entry_no'],
      json_data['email'],
      json_data['gender'],
      json_data['department'],
      json_data['degree_name'],
      json_data['degree_duration'],
      json_data['hostel'],
      json_data['room_no'],
      json_data['year_of_entry'],
      json_data['mobile_no'],
      json_data['profile_img'],
      json_data['location_name'],
      json_data['parent_location'],
      json_data['pre_approval_required'],
      json_data['automatic_exit_required'],
      json_data['designation'],
    );
  }

  Map<String, dynamic> toJson1() {
    return {
      "name": name,
      "entry_no": entry_no,
      "email": email,
      "gender": gender,
      "department": department,
      "degree_name": degree_name,
      "degree_duration": degree_duration,
      "hostel": hostel,
      "room_no": room_no,
      "year_of_entry": year_of_entry,
      "mobile_no": mobile_no,
      "profile_img": profile_img,
      "location_name": location_name,
      "parent_location": parent_location,
      "pre_approval_required": pre_approval_required,
      "automatic_exit_required": automatic_exit_required,
      "designation": designation,
    };
  }
}

class ResultObj4 {
  late String visitor_name; //
  late String mobile_no; //
  late String current_status;
  late String car_number; //
  late String authority_name;
  late String authority_email;
  late String authority_designation;
  late String purpose; // 
  late String authority_status;
  late String authority_message; /// give procedure to 
  late String date_time_of_ticket_raised; // 
  late String date_time_authority; /// capture it 
  late String date_time_guard;
  late String date_time_of_exit;
  late String guard_status;
  late String ticket_type;
  late int visitor_ticket_id;
  late String duration_of_stay; //
  late String num_additional;

  ResultObj4();

  ResultObj4.constructor1(
    this.visitor_name,
    this.mobile_no,
    this.current_status,
    this.car_number,
    this.authority_name,
    this.authority_email,
    this.authority_designation,
    this.purpose,
    this.authority_status,
    this.authority_message,
    this.date_time_of_ticket_raised,
    this.date_time_authority,
    this.date_time_guard,
    this.date_time_of_exit,
    this.guard_status,
    this.ticket_type,
    this.visitor_ticket_id,
    this.duration_of_stay,
    this.num_additional,
      );


  // Usage
  // 1. get_pending_tickets_for_visitors
  static ResultObj4 fromJson2(Map<String, dynamic> json_data) {
    String date_time_authority;
    if(json_data['date_time_authority'] == null){
      date_time_authority = "";
    }else{
      date_time_authority = json_data['date_time_authority'];
    }
    String date_time_guard;
    if(json_data['date_time_guard'] == null){
      date_time_guard = "";
    }else{
      date_time_guard = json_data['date_time_guard'];
    }
    String date_time_of_exit;
    if(json_data['date_time_of_exit'] == null){
      date_time_of_exit = "";
    }else{
      date_time_of_exit = json_data['date_time_of_exit'];
    }
    return new ResultObj4.constructor1(
      json_data['visitor_name'],
      json_data['mobile_no'],
      json_data['current_status'] as String,
      json_data['car_number'] ,
      json_data['authority_name']?? '',
      json_data['authority_email']??'',
      json_data['authority_designation']??'',
      json_data['purpose']??'',
      json_data['authority_status']??'',
      json_data['authority_message']??'',
      json_data['date_time_of_ticket_raised'],
      date_time_authority,// json_data['date_time_authority'],
      date_time_guard,// json_data['date_time_guard'],
      date_time_of_exit,// json_data['date_time_of_exit'],
      json_data['guard_status'],
      json_data['ticket_type'],
      json_data['visitor_ticket_id'],
      json_data['duration_of_stay'],
      json_data['num_additional'],
    );
  }

  // Usage
  // 1. accept_selected_tickets_visitors
  Map<String, dynamic> toJson1() {
    return {
      'visitor_name':visitor_name,
      'mobile_no':mobile_no,
      'current_status':current_status,
      'car_number':car_number,
      'authority_name':authority_name,
      'authority_email':authority_email,
      'authority_designation':authority_designation,
      'purpose':purpose,
      'authority_status':authority_status,
      'authority_message':authority_message,
      'date_time_of_ticket_raised':date_time_of_ticket_raised,
      'date_time_authority':date_time_authority,
      'date_time_guard':date_time_guard,
      'date_time_of_exit':date_time_of_exit,
      'guard_status':guard_status,
      'ticket_type':ticket_type,
      'visitor_ticket_id':visitor_ticket_id,
      'duration_of_stay':duration_of_stay,
    };
  }

  
}

class ResultObj7 {
  late String is_approved;
  late String ticket_type;
  late String date_time;
  late String location;
  late String email;
  late String student_name;
  late String authority_status;
  late String student_message;

  ResultObj7();

  ResultObj7.constructor(
    this.is_approved,
    this.ticket_type,
    this.date_time,
    this.location,
    this.email,
    this.student_name,
    this.authority_status,
    this.student_message,
  );

  static ResultObj7 fromJson(Map<String, dynamic> json_data) {
    return ResultObj7.constructor(
      json_data['is_approved'],
      json_data['ticket_type'],
      json_data['date_time'],
      json_data['location'],
      json_data['email'],
      json_data['student_name'],
      json_data['authority_status'],
      json_data['student_message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_approved': is_approved,
      'ticket_type': ticket_type,
      'date_time': date_time,
      'location': location,
      'email': email,
      'student_name': student_name,
      'authority_status': authority_status,
      'student_message': student_message,
    };
  }
}

class RelativeResultObj {
  late String name;
  late String status;
  late String mobileNumber;
  late String ticket_id;

  RelativeResultObj({
    required this.name,
    required this.status,
    required this.mobileNumber,
    required this.ticket_id,

  });
  factory RelativeResultObj.fromJson(Map<String, dynamic> json) {
    return RelativeResultObj(
      name: json['invitee_name'],
      status: json['status'],
      mobileNumber: json['invitee_contact'],
      ticket_id: json['ticket_id'],
    );
  }
}

class StuRelTicket {
  String ticketId;
  String studentId; // Assuming this is a String representation of Student ID
  String? studentName; // Assuming this is a String representation of Student ID
  String inviteeName;
  String inviteeRelationship;
  String inviteeContact;
  String purpose;
  String status;
  String visit_date;
  int duration;

  StuRelTicket({
    required this.ticketId,
    required this.studentId,
    this.studentName,
    required this.inviteeName,
    required this.inviteeRelationship,
    required this.inviteeContact,
    required this.purpose,
    required this.status,
    required this.visit_date,
    required this.duration,
  });

  // Convenience constructor to create a Ticket object from a JSON map
  factory StuRelTicket.fromJson(Map<String, dynamic> json) {
    return StuRelTicket(
      ticketId: json['ticket_id'],
      studentId: json['student'], // Assuming Student ID is nested under 'student'
      // studentName: json['studentName'], // Assuming Student ID is nested under 'student'
      inviteeName: json['invitee_name'],
      inviteeRelationship: json['invitee_relationship'],
      inviteeContact: json['invitee_contact'],
      purpose: json['purpose'],
      status: json['status'],
      visit_date: json['visit_date'],
      duration: json['duration'],
    );
  }
  factory StuRelTicket.fromJson1(Map<String, dynamic> json) {
    return StuRelTicket(
      ticketId: json['ticket_id'],
      studentId: json['student'], // Assuming Student ID is nested under 'student'
      studentName: json['studentName'], // Assuming Student ID is nested under 'student'
      inviteeName: json['invitee_name'],
      inviteeRelationship: json['invitee_relationship'],
      inviteeContact: json['invitee_contact'],
      purpose: json['purpose'],
      status: json['status'],
      visit_date: json['visit_date'],
      duration: json['duration'],
    );
  }

  // Method to convert Ticket object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'ticket_id': ticketId,
      'studentId':  studentId, // Assuming 'student' is a nested object with 'id' field
      // 'studentName':  studentName, // Assuming 'student' is a nested object with 'id' field
      'invitee_name': inviteeName,
      'invitee_relationship': inviteeRelationship,
      'invitee_contact': inviteeContact,
      'purpose': purpose,
      'status': status,
      'visit_date':visit_date,
      'duration':duration,
    };
  }
  Map<String, dynamic> toJson1() {
    return {
      'ticket_id': ticketId,
      'studentId':  studentId, // Assuming 'student' is a nested object with 'id' field
      'studentName':  studentName, // Assuming 'student' is a nested object with 'id' field
      'invitee_name': inviteeName,
      'invitee_relationship': inviteeRelationship,
      'invitee_contact': inviteeContact,
      'purpose': purpose,
      'status': status,
      'visit_date':visit_date,
      'duration':duration,
    };
  }
}

class InviteeRecord {
  late int recordId;
  late String studentName;
  late String studentEntryNo;
  late String inviteeName;
  late String inviteeRelationship;
  late String inviteeContact;
  late String inviteePurpose;
  late String vehicleNumber;
  late String time;
  late String type;
  late String status;

  InviteeRecord({
    required this.recordId,
    required this.studentName,
    required this.studentEntryNo,
    required this.inviteeName,
    required this.inviteeRelationship,
    required this.inviteeContact,
    required this.inviteePurpose,
    required this.vehicleNumber,
    required this.time,
    required this.type,
    required this.status,
  });

  factory InviteeRecord.fromJson(Map<String, dynamic> json) {
    return InviteeRecord(
      recordId: json['record_id'],
      studentName: json['student_name'],
      studentEntryNo: json['student_entry_no'],
      inviteeName: json['invitee_name'],
      inviteeRelationship: json['invitee_relationship'],
      inviteeContact: json['invitee_contact'],
      inviteePurpose: json['invitee_purpose'],
      vehicleNumber: json['vehicle_number'],
      time: json['time'],
      type: json['type'],
      status: json['status'],
    );
  }
}
