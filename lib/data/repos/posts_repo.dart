import 'package:Prefer/data/models/history_post.dart';
import 'package:Prefer/data/models/personal_post.dart';

import '../apis/posts_apis.dart';
import '../models/post.dart';

class postsRepo {
  final postsApis postsapis;

  postsRepo(this.postsapis);

  Future<List<Post>> getAllPosts(user_id, page_num) async {
    final posts = await postsapis.getAllPosts(user_id, page_num);
    return posts.map((post) => Post.fromJson(post)).toList();
  }

  Future<List<Post>> getguestposts(pagenum) async {
    final posts = await postsapis.getguestposts(pagenum);
    return posts.map((post) => Post.fromJson(post)).toList();
  }

  Future<List<Personal_Post>> getmyposts(user_id, page_num, itemperpage) async {
    final myposts =
        await postsapis.getmyposts(user_id, page_num, itemperpage: itemperpage);
    return myposts.map((post) => Personal_Post.fromJson(post)).toList();
  }

  Future<List<History_Post>> getchoiceshistory(user_id, page_num) async {
    final historyposts = await postsapis.getchoiceshistory(user_id, page_num);
    return historyposts.map((post) => History_Post.fromJson(post)).toList();
  }

  Future<List<dynamic>> getPercentages(postId, choice) async {
    final percs = await postsapis.getPercentages(postId, choice);
    return percs;
  }

  Future<List<dynamic>> upload_photos(photos) async {
    final photos_urls = await postsapis.upload_photos(photos);
    return photos_urls;
  }

  Future<bool> upload_post(description, urls, duration) async {
    final post_uploaded =
        await postsapis.upload_post(description, urls, duration);
    return post_uploaded;
  }

  Future<bool> report_user(userId, postId, mainUserId) async {
    final reported = await postsapis.report_user(userId, postId, mainUserId);
    return reported;
  }

  Future<bool> changehidden(postId) async {
    final changed = await postsapis.changehidden(
      postId,
    );
    return changed;
  }
}
