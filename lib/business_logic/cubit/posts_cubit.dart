import 'package:bloc/bloc.dart';
import 'package:Prefer/data/models/history_post.dart';
import 'package:Prefer/data/models/personal_post.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

import '../../data/models/post.dart';
import '../../data/repos/posts_repo.dart';

part 'posts_state.dart';

class PostsCubit extends Cubit<PostsState> {
  final postsRepo postsrepo;
  List<Post> posts = [];
  List<Personal_Post> myposts = [];
  List<History_Post> historyposts = [];
  List<List<dynamic>> percs = [];
  bool reported = false;
  bool changed = false;
  PostsCubit(this.postsrepo) : super(PostsInitial());

  List<Post> getAllPosts(userId, pageNum, {refresh = false}) {
    if (pageNum == 1) {
      emit(postsLoading(true));
    }
    postsrepo.getAllPosts(userId, pageNum).then((posts) {
      if (posts.length == 0 && pageNum == 1) {
        emit(postsEmpty(posts));
      } else {
        if (pageNum > 1) {
          emit(MorePostsLoaded(
            posts,
          ));
        } else {
          if (refresh) {
            emit(PostsRefresh(
              posts,
            ));
          } else {
            emit(postsLoaded(
              posts,
            ));
          }
        }
      }

      this.posts = posts;
    });
    return posts;
  }

  List<Post> getguestposts(pageNum, {refresh = false}) {
    if (pageNum == 1) {
      emit(postsLoading(true));
    }
    postsrepo.getguestposts(pageNum).then((posts) {
      if (posts.length == 0 && pageNum == 1) {
        emit(postsEmpty(posts));
      } else {
        if (pageNum > 1) {
          emit(MorePostsLoaded(
            posts,
          ));
        } else {
          if (refresh) {
            emit(PostsRefresh(
              posts,
            ));
          } else {
            emit(postsLoaded(
              posts,
            ));
          }
        }
      }

      this.posts = posts;
    });
    return posts;
  }

  List<Post> getmyposts(userId, pageNum, {refresh = false, itemperpage = 10}) {
    if (pageNum == 1) {
      emit(mypostsLoading(true));
    }
    postsrepo.getmyposts(userId, pageNum, itemperpage).then((posts) {
      if (posts.length == 0 && pageNum == 1) {
        emit(mypostsEmpty(posts));
      } else {
        if (pageNum > 1) {
          emit(MoreMyPostsLoaded(
            posts,
          ));
        } else {
          if (refresh) {
            emit(MyPostsRefresh(
              posts,
            ));
          } else {
            emit(MypostsLoaded(
              posts,
            ));
          }
        }
      }

      this.myposts = posts;
    });
    return posts;
  }

  List<Post> getchoiceshistory(userId, pageNum, {refresh = false}) {
    if (pageNum == 1) {
      emit(historypostsLoading(true));
    }
    postsrepo.getchoiceshistory(userId, pageNum).then((posts) {
      if (posts.length == 0 && pageNum == 1) {
        emit(historypostsEmpty(posts));
      } else {
        if (pageNum > 1) {
          emit(MoreHistoryPostsLoaded(
            posts,
          ));
        } else {
          if (refresh) {
            emit(HistoryPostsRefresh(
              posts,
            ));
          } else {
            emit(HistorypostsLoaded(
              posts,
            ));
          }
        }
      }

      this.historyposts = posts;
    });
    return posts;
  }

  List<Post> getOnePost() {
    postsrepo.getAllPosts("63346778e44d896dc325cd98", 1).then((posts) {
      posts.removeLast();
      emit(postsLoaded(
        posts,
      ));
      this.posts = posts;
    });

    return posts;
  }

  List<dynamic> getPercentages(postId, choice, index) {
    postsrepo.getPercentages(postId, choice).then((percs) {
      emit(percsLoaded(percs, index));
      this.percs.add(percs);
    });

    return percs;
  }

  List<dynamic> upload_photos(photos) {
    emit(photos_upload_loading(true));
    postsrepo.upload_photos(photos).then((urls) {
      emit(photos_uploaded(urls));
    });
    return photos;
  }

  void upload_post(description, urls, duration) {
    postsrepo.upload_post(description, urls, duration).then((uploaded) {
      emit(post_uploaded(uploaded));
    });
  }

  bool report_user(userId, postId, mainUserId) {
    postsrepo.report_user(userId, postId, mainUserId).then((reported) {
      reported = reported;
      emit(reportstatus(reported));
    });

    return reported;
  }

  viewphoto(showstat, image_url) async {
    emit(view_photo(showstat, image_url));
  }

  bool changehidden(postId) {
    postsrepo.changehidden(postId).then((changed) {
      changed = changed;
      emit(changedstatus(changed, postId));
    });

    return changed;
  }
}
