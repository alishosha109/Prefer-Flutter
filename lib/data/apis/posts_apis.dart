import 'package:dio/dio.dart';
import 'package:Prefer/constants/globals.dart';
import '../../constants/strings.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class postsApis {
  late Dio dio;

  postsApis() {
    BaseOptions options = BaseOptions(
      baseUrl: baseUrl,
      receiveDataWhenStatusError: true,
      connectTimeout: 30 * 1000,
      receiveTimeout: 30 * 1000,
      headers: {"authorization": "token ${acctoken}"},
      followRedirects: false,
      validateStatus: (status) {
        return status! < 500;
      },
    );
    dio = Dio(options);
  }

  bool check_acc_token_duration() {
    if (acctoken == "" || acctoken == "null") {
      return true;
    }
    String MyToken = acctoken;
    bool acc_Expired = JwtDecoder.isExpired(MyToken);
    return acc_Expired;
  }

  bool check_ref_token_duration() {
    String RefToken = reftoken;
    bool ref_Expired = JwtDecoder.isExpired(RefToken);
    return ref_Expired;
  }

  modify_acc_token() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      Response response = await dio.get('users/token/${main_user.sId}');
      var new_tokn = response.data['token'];
      prefs.setString('acc_token', new_tokn);
      acctoken = new_tokn;
      return;
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future<List<dynamic>> getAllPosts(user_id, page_num) async {
    var expire_token = await check_acc_token_duration();
    if (expire_token) {
      modify_acc_token().then((value) async {
        try {
          Response response =
              await dio.get('posts/${user_id}/false/10/${page_num}');
          return response.data['posts'];
        } catch (e) {
          print(e.toString());
          return [];
        }
      });
    } else {
      try {
        Response response =
            await dio.get('posts/${user_id}/false/10/${page_num}');
        return response.data['posts'];
      } catch (e) {
        print(e.toString());
        return [];
      }
    }
    return [];
  }

  Future<List<dynamic>> getguestposts(pagenum) async {
    try {
      Response response = await dio
          .get('posts/', queryParameters: {"itemperpage": 10, "page": pagenum});
      return response.data['posts'];
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future<List<dynamic>> getPercentages(postId, choice) async {
    var expire_token = await check_acc_token_duration();

    bool submitted = await submit_choice(postId, choice);
    if (submitted) {
      if (expire_token) {
        modify_acc_token().then((value) async {
          try {
            Response response =
                await dio.get('posts/get_percentages/${postId}');
            return response.data['percentages'];
          } catch (e) {
            print(e.toString());
            return [];
          }
        });
      } else {
        try {
          Response response = await dio.get('posts/get_percentages/${postId}');
          return response.data['percentages'];
        } catch (e) {
          print(e.toString());
          return [];
        }
      }
      return [];
    } else {
      return [];
    }
  }

  Future<bool> submit_choice(postId, choice) async {
    var expire_token = await check_acc_token_duration();
    if (expire_token) {
      modify_acc_token().then((value) async {
        try {
          Response response = await dio.post('posts/${postId}/${choice}');
          if (response.statusCode == 200 || response.statusCode == 201) {
            Response response2 =
                await dio.patch('users/chs/${main_user.sId}', data: {
              "choices_history": {"${postId}": choice}
            });
            if (response2.statusCode == 200 || response2.statusCode == 201) {
              return true;
            } else {
              return false;
            }
          } else {
            return false;
          }
        } catch (e) {
          print(e.toString());
          return false;
        }
      });
    } else {
      try {
        Response response = await dio.post('posts/${postId}/${choice}');
        if (response.statusCode == 200 || response.statusCode == 201) {
          Response response2 =
              await dio.patch('users/chs/${main_user.sId}', data: {
            "choices_history": {"${postId}": choice}
          });
          if (response2.statusCode == 200 || response2.statusCode == 201) {
            return true;
          } else {
            return false;
          }
        } else {
          return false;
        }
      } catch (e) {
        print(e.toString());
        return false;
      }
    }
    return false;
  }

  Future<bool> report_user(userId, postId, mainUserId) async {
    try {
      Response response =
          await dio.post('users/report/${userId}/${postId}/${mainUserId}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<List<dynamic>> getmyposts(user_id, page_num, {itemperpage: 10}) async {
    var expire_token = await check_acc_token_duration();
    if (expire_token) {
      modify_acc_token().then((value) async {
        try {
          Response response = await dio.get('posts/history/${user_id}',
              queryParameters: {'itemperpage': itemperpage, 'page': page_num});
          return response.data['posts'];
        } catch (e) {
          print(e.toString());
          return [];
        }
      });
    } else {
      try {
        Response response = await dio.get('posts/history/${user_id}',
            queryParameters: {'itemperpage': 10, 'page': page_num});
        return response.data['posts'];
      } catch (e) {
        print(e.toString());
        return [];
      }
    }
    return [];
  }

  Future<List<dynamic>> getchoiceshistory(
    user_id,
    page_num,
  ) async {
    var expire_token = await check_acc_token_duration();
    if (expire_token) {
      modify_acc_token().then((value) async {
        try {
          Response response = await dio.get('posts/choices_history/${user_id}',
              queryParameters: {'itemperpage': 10, 'page': page_num});
          return response.data['posts'];
        } catch (e) {
          print(e.toString());
          return [];
        }
      });
    } else {
      try {
        Response response = await dio.get('posts/choices_history/${user_id}',
            queryParameters: {'itemperpage': 10, 'page': page_num});
        return response.data['posts'];
      } catch (e) {
        print(e.toString());
        return [];
      }
    }
    return [];
  }

  Future<bool> changehidden(post_id) async {
    try {
      Response response = await dio.patch(
        'posts/$post_id',
        data: {
          'hidden': true,
        },
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print(e.toString());
      return false;
    }
    return false;
  }

  Future<List<dynamic>> upload_photos(photos) async {
    try {
      late var formData;
      var date = DateTime.now();
      switch (photos!.length) {
        case 2:
          formData = FormData.fromMap({
            'files': [
              await MultipartFile.fromFile(
                photos[0].path,
              ),
              await MultipartFile.fromFile(
                photos[1].path,
              ),
            ]
          });
          break;
        case 3:
          formData = FormData.fromMap({
            'files': [
              await MultipartFile.fromFile(
                photos[0].path,
              ),
              await MultipartFile.fromFile(
                photos[1].path,
              ),
              await MultipartFile.fromFile(
                photos[2].path,
              ),
            ]
          });
          break;
        case 4:
          formData = FormData.fromMap({
            'files': [
              await MultipartFile.fromFile(
                photos[0].path,
              ),
              await MultipartFile.fromFile(
                photos[1].path,
              ),
              await MultipartFile.fromFile(
                photos[2].path,
              ),
              await MultipartFile.fromFile(
                photos[3].path,
              ),
            ]
          });
          break;
      }
      var response = await dio.post('files', data: formData);
      return response.data['images_urls'];
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future<dynamic> upload_post(description, urls, duration) async {
    List<List> photos_urls = [];
    urls.forEach((item) {
      photos_urls.add([item, 0]);
    });
    var post_date = {
      "user": main_user.sId.toString(),
      "description": description,
      "total_answers": 0,
      "photos": photos_urls,
      "period": duration * 60
    };
    try {
      var response = await dio.post('posts', data: post_date);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print(e.toString());
      return false;
    }
  }
}
