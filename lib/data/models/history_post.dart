import 'package:Prefer/data/models/post.dart';

class History_Post {
  Post? post;
  int? choice;

  History_Post({this.post, this.choice});

  History_Post.fromJson(Map<String, dynamic> json) {
    post = json['post'] != null ? new Post.fromJson(json['post']) : null;
    choice = json['choice'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.post != null) {
      data['post'] = this.post!.toJson();
    }
    data['choice'] = this.choice;
    return data;
  }
}
