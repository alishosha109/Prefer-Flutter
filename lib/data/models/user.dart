class User {
  String? sId;
  String? username;
  String? phoneNumber;
  bool? blocked;
  int? reports;
  String? error;
  User({this.sId, this.username, this.phoneNumber, this.blocked, this.reports});

  User.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    username = json['username'];
    phoneNumber = json['phone_number'];
    blocked = json['blocked'];
    reports = json['reports'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['username'] = this.username;
    data['phone_number'] = this.phoneNumber;
    data['blocked'] = this.blocked;
    data['reports'] = this.reports;
    return data;
  }

  User.withError(String errorMessage) {
    error = errorMessage;
  }
}
