import 'user.dart';

class Post {
  String? sId;
  User? user;
  String? description;
  int? totalAnswers;
  List? photos;
  bool? hidden;
  int? period;

  Post(
      {this.sId,
      this.user,
      this.description,
      this.totalAnswers,
      this.photos,
      this.hidden,
      this.period});

  Post.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    description = json['description'];
    totalAnswers = json['total_answers'];
    photos = json['photos'];
    hidden = json['hidden'];
    period = json['period'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    data['description'] = this.description;
    data['total_answers'] = this.totalAnswers;
    data['photos'] = this.photos;
    data['hidden'] = this.hidden;
    data['period'] = this.period;
    return data;
  }
}
